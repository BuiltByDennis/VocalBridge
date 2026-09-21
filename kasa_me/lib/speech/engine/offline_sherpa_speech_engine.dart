import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import '../../core/logging/app_logger.dart';
import '../asr/models/asr_model_config.dart';
import 'speech_engine.dart';
import 'sherpa_speech_engine.dart';

class OfflineSherpaSpeechEngine implements SpeechEngine {
  final AsrModelConfig modelConfig;
  sherpa.OfflineRecognizer? _recognizer;

  final StreamController<SpeechEngineEvent> _eventController =
      StreamController<SpeechEngineEvent>.broadcast();

  EngineLifecycleState _lifecycleState = EngineLifecycleState.notLoaded;
  List<Float32List> _audioBuffer = [];
  int _totalAudioSamples = 0;

  OfflineSherpaSpeechEngine(this.modelConfig);

  EngineLifecycleState get lifecycleState => _lifecycleState;

  @override
  bool get isInitialized =>
      _lifecycleState == EngineLifecycleState.ready ||
      _lifecycleState == EngineLifecycleState.listening ||
      _lifecycleState == EngineLifecycleState.processing;

  @override
  Stream<SpeechEngineEvent> get events => _eventController.stream;

  @override
  Future<void> initialize() async {
    if (_lifecycleState == EngineLifecycleState.loading || isInitialized) {
      return;
    }

    _lifecycleState = EngineLifecycleState.loading;
    AppLogger.log('ASR', 'Initializing OfflineSherpaSpeechEngine with model ${modelConfig.id}');

    try {
      final tempDir = await getTemporaryDirectory();
      final modelDir = Directory('${tempDir.path}/asr_models/${modelConfig.id}');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      sherpa.OfflineModelConfig modelCfg;
      final tokensFile = await _copyAssetToFile(modelConfig.tokensPath, '${modelDir.path}/tokens.txt');

      if (modelConfig.architecture == AsrArchitecture.whisper) {
        if (modelConfig.encoderPath == null || modelConfig.decoderPath == null) {
          throw Exception("encoderPath and decoderPath cannot be null for Whisper models.");
        }
        final encoderFile = await _copyAssetToFile(modelConfig.encoderPath!, '${modelDir.path}/encoder.onnx');
        final decoderFile = await _copyAssetToFile(modelConfig.decoderPath!, '${modelDir.path}/decoder.onnx');
        
        final whisperCfg = sherpa.OfflineWhisperModelConfig(
          encoder: encoderFile.path,
          decoder: decoderFile.path,
          language: 'en',
          task: 'transcribe',
        );

        modelCfg = sherpa.OfflineModelConfig(
          whisper: whisperCfg,
          tokens: tokensFile.path,
          numThreads: 2,
          debug: false,
          provider: 'cpu',
          modelType: '',
        );
      } else {
        if (modelConfig.modelPath == null) {
          throw Exception("modelPath cannot be null for Wav2Vec2 CTC models.");
        }
        final modelFile = await _copyAssetToFile(modelConfig.modelPath!, '${modelDir.path}/model.onnx');
        
        final nemoCtc = sherpa.OfflineNemoEncDecCtcModelConfig(
          model: modelFile.path,
        );

        modelCfg = sherpa.OfflineModelConfig(
          nemoCtc: nemoCtc,
          tokens: tokensFile.path,
          numThreads: 2,
          debug: false,
          provider: 'cpu',
          modelType: 'wav2vec2',
        );
      }

      final featCfg = sherpa.FeatureConfig(
        sampleRate: modelConfig.sampleRate,
        featureDim: 80,
      );

      final recognizerCfg = sherpa.OfflineRecognizerConfig(
        model: modelCfg,
        feat: featCfg,
      );

      _recognizer = sherpa.OfflineRecognizer(recognizerCfg);
      _lifecycleState = EngineLifecycleState.ready;
      _eventController.add(const EngineReady());
      AppLogger.log('ASR', 'OfflineSherpaSpeechEngine successfully initialized');
    } catch (e, stack) {
      _lifecycleState = EngineLifecycleState.error;
      final msg = 'Failed to initialize offline speech recognition model: $e';
      AppLogger.error('ASR', msg, e, stack);
      _eventController.add(SpeechEngineError(msg, error: e));
    }
  }

  Future<File> _copyAssetToFile(String assetPath, String targetPath) async {
    final file = File(targetPath);
    if (await file.exists()) {
      return file;
    }
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  @override
  Future<void> start({String hotwords = ''}) async {
    if (!isInitialized || _recognizer == null) {
      _eventController.add(const SpeechEngineError('Speech recognition is not initialized.'));
      return;
    }

    _lifecycleState = EngineLifecycleState.listening;
    _audioBuffer = [];
    _totalAudioSamples = 0;
    _eventController.add(const SpeechStarted());
  }

  @override
  Future<void> acceptAudio(Uint8List pcm16) async {
    if (_lifecycleState != EngineLifecycleState.listening) {
      return;
    }

    try {
      final sampleCount = pcm16.length ~/ 2;
      _totalAudioSamples += sampleCount;

      final float32List = Float32List(sampleCount);
      final byteData = ByteData.sublistView(pcm16);

      for (int i = 0; i < sampleCount; i++) {
        final sample16 = byteData.getInt16(i * 2, Endian.little);
        float32List[i] = sample16 / 32768.0;
      }

      _audioBuffer.add(float32List);
    } catch (e) {
      AppLogger.error('ASR', 'Error buffering audio', e);
    }
  }

  @override
  Future<void> stop() async {
    if (_lifecycleState != EngineLifecycleState.listening || _recognizer == null) {
      return;
    }

    _lifecycleState = EngineLifecycleState.processing;
    _eventController.add(const SpeechProcessing());

    final startTime = DateTime.now();
    try {
      final stream = _recognizer!.createStream();

      // Combine all buffered audio chunks
      final allSamples = Float32List(_totalAudioSamples);
      int offset = 0;
      for (var chunk in _audioBuffer) {
        allSamples.setAll(offset, chunk);
        offset += chunk.length;
      }

      stream.acceptWaveform(samples: allSamples, sampleRate: modelConfig.sampleRate);
      
      _recognizer!.decode(stream);
      final resultText = _recognizer!.getResult(stream).text.trim();
      stream.free();

      final elapsedInference = DateTime.now().difference(startTime);
      final audioDuration = Duration(
        milliseconds: (_totalAudioSamples / modelConfig.sampleRate * 1000).round(),
      );

      final result = RecognitionResult(
        text: resultText,
        confidence: resultText.isNotEmpty ? 0.90 : null,
        processingTime: elapsedInference,
        audioDuration: audioDuration.inMilliseconds > 0
            ? audioDuration
            : const Duration(milliseconds: 100),
      );

      _eventController.add(FinalTranscript(resultText, result: result));
      _lifecycleState = EngineLifecycleState.ready;
      _eventController.add(const EngineReady());
    } catch (e) {
      _lifecycleState = EngineLifecycleState.error;
      _eventController.add(SpeechEngineError('Error finalizing speech transcription: $e', error: e));
    } finally {
      _audioBuffer = [];
    }
  }

  @override
  Future<void> dispose() async {
    if (_lifecycleState == EngineLifecycleState.disposed ||
        _lifecycleState == EngineLifecycleState.disposing) {
      return;
    }
    _lifecycleState = EngineLifecycleState.disposing;

    try {
      _recognizer?.free();
    } catch (_) {}
    _recognizer = null;

    _lifecycleState = EngineLifecycleState.disposed;
    if (!_eventController.isClosed) {
      await _eventController.close();
    }
  }
}
