import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        _personalizationPipeline.safetyGuard.validateAndAddPhraseMapping(recognized, target);
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
    await _pipeline.startPushToTalkSession();
  }

  Future<void> stopRecording() async {
    await _pipeline.stopPushToTalkSession();
  }

  Future<void> dispose() async {
    await stopRecording();
    await _eventSub?.cancel();
    await _pipeline.dispose();
    await _resultController.close();
    await _vadStateController.close();
  }
}
