import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../../audio/recorder/audio_recorder_service.dart';
import '../../core/logging/app_logger.dart';
import '../engine/speech_engine.dart';
import '../engine/speech_engine_factory.dart';
import '../asr/models/asr_model_registry.dart';
import '../personalization/personalization_pipeline.dart';
import '../pipeline/streaming_audio_pipeline.dart';
import '../vad/energy_vad.dart';

class CalibrationResult {
  final String targetPhrase;
  final String recognizedPhrase;
  final bool isMatch;

  CalibrationResult({
    required this.targetPhrase,
    required this.recognizedPhrase,
    required this.isMatch,
  });
}

class CalibrationService {
  static const List<String> calibrationPhrases = [
    'I need water',
    'Call my doctor',
    'I am in pain',
    'Where is the station',
    'Please help me',
    'I want to sleep',
    'Thank you very much',
    'What time is it',
    'I am hungry',
    'Turn on the light',
    'I feel cold',
    'Can you repeat that'
  ];

  final PersonalizationPipeline _personalizationPipeline;
  late SpeechEngine _speechEngine;
  late AudioRecorderService _recorderService;
  late StreamingAudioPipeline _pipeline;

  StreamSubscription<SpeechEngineEvent>? _eventSub;
  final _resultController = StreamController<CalibrationResult>.broadcast();
  final _vadStateController = StreamController<VadState>.broadcast();

  String? _currentTargetPhrase;
  bool _isCalibrating = false;
  
  StreamSubscription<Uint8List>? _audioSub;
  final BytesBuilder _audioBuffer = BytesBuilder();

  Stream<CalibrationResult> get onResult => _resultController.stream;
  Stream<VadState> get onVadState => _vadStateController.stream;

  CalibrationService({
    required PersonalizationPipeline personalizationPipeline,
  }) : _personalizationPipeline = personalizationPipeline;

  Future<void> initialize() async {
    _speechEngine = SpeechEngineFactory.createEngine(config: AsrModelRegistry.defaultModel);
    _recorderService = AudioRecorderService();
    await _recorderService.initialize();
    
    // We create a custom VAD wrapper to intercept the state if needed, but since we can't easily 
    // inject a listener into StreamingAudioPipeline's private _vad, we'll just use the pipeline normally.
    // For automatic stop, the user will use a push-to-talk button in the wizard for this MVP.
    _pipeline = StreamingAudioPipeline(
      recorderService: _recorderService,
      speechEngine: _speechEngine,
    );

    await _pipeline.initialize();
    _eventSub = _speechEngine.events.listen(_handleEngineEvent);
  }

  void _handleEngineEvent(SpeechEngineEvent event) {
    if (!_isCalibrating || _currentTargetPhrase == null) return;

    if (event is FinalTranscript) {
      final recognized = event.text.trim();
      final target = _currentTargetPhrase!.trim();
      
      final isMatch = recognized.toLowerCase() == target.toLowerCase();
      
      AppLogger.log('Calibration', 'Target: $target | Recognized: $recognized | Match: $isMatch');

      if (!isMatch && recognized.isNotEmpty) {
        // Automatically seed the discrepancy as a correction so the system learns the user's speech
        _personalizationPipeline.applyCorrection(
          original: recognized,
          corrected: target,
          profileId: 'default_user',
        );
      }

      _resultController.add(CalibrationResult(
        targetPhrase: target,
        recognizedPhrase: recognized,
        isMatch: isMatch,
      ));
      
      _isCalibrating = false;
      _currentTargetPhrase = null;
    }
  }

  Future<void> startRecordingForPhrase(String targetPhrase) async {
    if (_isCalibrating) return;
    _currentTargetPhrase = targetPhrase;
    _isCalibrating = true;
    _audioBuffer.clear();
    
    // Subscribe to capture the raw PCM16 data
    _audioSub = _recorderService.audioStream.listen((data) {
      _audioBuffer.add(data);
    });

    await _pipeline.startPushToTalkSession(hotwords: targetPhrase);
  }

  Future<void> stopRecording() async {
    await _pipeline.stopPushToTalkSession();
    await _audioSub?.cancel();
    
    if (_currentTargetPhrase != null && _audioBuffer.isNotEmpty) {
      await _saveCalibrationAudio(_currentTargetPhrase!, _audioBuffer.toBytes());
    }
    _audioBuffer.clear();
  }

  Future<void> _saveCalibrationAudio(String phrase, Uint8List pcmData) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final calibDir = Directory('${appDir.path}/calibration_audio');
      if (!await calibDir.exists()) {
        await calibDir.create(recursive: true);
      }
      
      final safeName = phrase.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${calibDir.path}/${safeName}_$timestamp.wav');
      
      // Write simple WAV header
      const channels = 1;
      const sampleRate = 16000;
      final byteRate = sampleRate * channels * 2;
      final dataSize = pcmData.length;
      final fileSize = 36 + dataSize;
      
      final header = ByteData(44);
      // "RIFF"
      header.setUint8(0, 0x52); header.setUint8(1, 0x49); header.setUint8(2, 0x46); header.setUint8(3, 0x46);
      header.setUint32(4, fileSize, Endian.little);
      // "WAVE"
      header.setUint8(8, 0x57); header.setUint8(9, 0x41); header.setUint8(10, 0x56); header.setUint8(11, 0x45);
      // "fmt "
      header.setUint8(12, 0x66); header.setUint8(13, 0x6D); header.setUint8(14, 0x74); header.setUint8(15, 0x20);
      header.setUint32(16, 16, Endian.little); // subchunk1size
      header.setUint16(20, 1, Endian.little); // audio format (PCM)
      header.setUint16(22, channels, Endian.little);
      header.setUint32(24, sampleRate, Endian.little);
      header.setUint32(28, byteRate, Endian.little);
      header.setUint16(32, channels * 2, Endian.little); // block align
      header.setUint16(34, 16, Endian.little); // bits per sample
      // "data"
      header.setUint8(36, 0x64); header.setUint8(37, 0x61); header.setUint8(38, 0x74); header.setUint8(39, 0x61);
      header.setUint32(40, dataSize, Endian.little);
      
      final writer = BytesBuilder();
      writer.add(header.buffer.asUint8List());
      writer.add(pcmData);
      
      await file.writeAsBytes(writer.toBytes());
      AppLogger.log('Calibration', 'Saved acoustic training sample: ${file.path}');
    } catch (e) {
      AppLogger.error('Calibration', 'Failed to save WAV file', e);
    }
  }

  Future<void> dispose() async {
    await stopRecording();
    await _eventSub?.cancel();
    await _pipeline.dispose();
    await _resultController.close();
    await _vadStateController.close();
  }
}
