import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import '../../core/logging/app_logger.dart';
import '../asr/models/asr_model_config.dart';
import 'speech_engine.dart';

enum EngineLifecycleState {
  notLoaded,
  loading,
  ready,
  listening,
  processing,
  error,
  disposing,
  disposed,
}

class SherpaSpeechEngine implements SpeechEngine {
  final AsrModelConfig modelConfig;
  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _stream;

  final StreamController<SpeechEngineEvent> _eventController =
      StreamController<SpeechEngineEvent>.broadcast();

  EngineLifecycleState _lifecycleState = EngineLifecycleState.notLoaded;
  int _totalAudioSamples = 0;
  String _lastPartialText = '';

  SherpaSpeechEngine(this.modelConfig);

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
    AppLogger.log('ASR', 'Initializing SherpaSpeechEngine with model ${modelConfig.id}');

    try {
      final tempDir = await getTemporaryDirectory();
      final modelDir = Directory('${tempDir.path}/asr_models/${modelConfig.id}');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      if (modelConfig.encoderPath == null || modelConfig.decoderPath == null || modelConfig.joinerPath == null) {
        throw Exception("encoderPath, decoderPath, and joinerPath cannot be null for Zipformer Transducer models.");
      }

      final encoderFile = await _copyAssetToFile(modelConfig.encoderPath!, '${modelDir.path}/encoder.onnx');
      final decoderFile = await _copyAssetToFile(modelConfig.decoderPath!, '${modelDir.path}/decoder.onnx');
      final joinerFile = await _copyAssetToFile(modelConfig.joinerPath!, '${modelDir.path}/joiner.onnx');
      final tokensFile = await _copyAssetToFile(modelConfig.tokensPath, '${modelDir.path}/tokens.txt');

      // Use ONLY the transducer config. The committed model files (encoder/decoder/joiner)
      // are a Zipformer transducer. Setting zipformer2Ctc simultaneously is incorrect and
      // causes a native crash at runtime.
      final transducer = sherpa.OnlineTransducerModelConfig(
        encoder: encoderFile.path,
        decoder: decoderFile.path,
        joiner: joinerFile.path,
      );

      final modelCfg = sherpa.OnlineModelConfig(
        transducer: transducer,
        tokens: tokensFile.path,
        numThreads: 2,
        debug: true,  // Temporarily enabled to diagnose load failure
        provider: 'cpu',
        modelType: 'zipformer2',
      );

      final featCfg = sherpa.FeatureConfig(
        sampleRate: modelConfig.sampleRate,
        featureDim: 80,
      );

      final recognizerCfg = sherpa.OnlineRecognizerConfig(
        model: modelCfg,
        feat: featCfg,
        enableEndpoint: true,
        rule1MinTrailingSilence: 2.4,
        rule2MinTrailingSilence: 1.2,
        rule3MinUtteranceLength: 20.0,
      );

      _recognizer = sherpa.OnlineRecognizer(recognizerCfg);
      _lifecycleState = EngineLifecycleState.ready;
      _eventController.add(const EngineReady());
      AppLogger.log('ASR', 'SherpaSpeechEngine successfully initialized');
    } catch (e, stack) {
      _lifecycleState = EngineLifecycleState.error;
      final msg = 'Failed to initialize speech recognition model: $e';
      AppLogger.error('ASR', msg, e, stack);
      _eventController.add(SpeechEngineError(msg, error: e));
    }
  }

  Future<File> _copyAssetToFile(String assetPath, String targetPath) async {
    final file = File(targetPath);
    // Only reuse cached file if it actually has content (guards against truncated writes)
    if (await file.exists() && await file.length() > 0) {
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

    try {
      _stream = _recognizer!.createStream(hotwords: hotwords);
      _lifecycleState = EngineLifecycleState.listening;
      _totalAudioSamples = 0;
      _lastPartialText = '';
      _eventController.add(const SpeechStarted());
    } catch (e) {
      _lifecycleState = EngineLifecycleState.error;
      _eventController.add(SpeechEngineError('Failed to start speech session: $e', error: e));
    }
  }

  @override
  Future<void> acceptAudio(Uint8List pcm16) async {
    if (_lifecycleState != EngineLifecycleState.listening || _stream == null || _recognizer == null) {
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

      _stream!.acceptWaveform(samples: float32List, sampleRate: modelConfig.sampleRate);

      while (_recognizer!.isReady(_stream!)) {
        _recognizer!.decode(_stream!);
      }

      final text = _recognizer!.getResult(_stream!).text.trim();
      if (text.isNotEmpty && text != _lastPartialText) {
        _lastPartialText = text;
        _eventController.add(PartialTranscript(text));
      }
    } catch (e) {
      AppLogger.error('ASR', 'Error during streaming audio accept', e);
    }
  }

  @override
  Future<void> stop() async {
    if (_lifecycleState != EngineLifecycleState.listening || _recognizer == null || _stream == null) {
      return;
    }

    _lifecycleState = EngineLifecycleState.processing;
    _eventController.add(const SpeechProcessing());

    final startTime = DateTime.now();
    try {
      // Signal the stream that no more audio will arrive, forcing a flush
      _stream!.inputFinished();

      while (_recognizer!.isReady(_stream!)) {
        _recognizer!.decode(_stream!);
      }

      final text = _recognizer!.getResult(_stream!).text.trim();
      final elapsedInference = DateTime.now().difference(startTime);
      final audioDuration = Duration(
        milliseconds: (_totalAudioSamples / modelConfig.sampleRate * 1000).round(),
      );

      final result = RecognitionResult(
        text: text,
        confidence: text.isNotEmpty ? 0.90 : null,
        processingTime: elapsedInference,
        audioDuration: audioDuration.inMilliseconds > 0
            ? audioDuration
            : const Duration(milliseconds: 100),
      );

      _eventController.add(FinalTranscript(text, result: result));
      _lifecycleState = EngineLifecycleState.ready;
      _eventController.add(const EngineReady());
    } catch (e) {
      _lifecycleState = EngineLifecycleState.error;
      _eventController.add(SpeechEngineError('Error finalizing speech transcription: $e', error: e));
    } finally {
      _stream = null;
    }
  }

  @override
  Future<void> dispose() async {
    if (_lifecycleState == EngineLifecycleState.disposed ||
        _lifecycleState == EngineLifecycleState.disposing) {
      return;
    }
    _lifecycleState = EngineLifecycleState.disposing;

    // Free the active stream before nulling the recognizer
    try {
      _stream?.free();
    } catch (_) {}
    _stream = null;

    // Free the recognizer native resources
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
