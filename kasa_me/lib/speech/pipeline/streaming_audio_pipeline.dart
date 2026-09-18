import 'dart:async';
import 'dart:typed_data';

import '../../audio/recorder/audio_recorder_service.dart';
import '../../core/logging/app_logger.dart';
import '../engine/speech_engine.dart';
import '../vad/energy_vad.dart';

class StreamingAudioPipeline {
  final AudioRecorderService _recorderService;
  final SpeechEngine _speechEngine;
  final EnergyVad _vad;

  StreamSubscription<Uint8List>? _audioSubscription;
  StreamSubscription<SpeechEngineEvent>? _engineEventSubscription;

  bool _isPipelineActive = false;
  bool get isPipelineActive => _isPipelineActive;

  StreamingAudioPipeline({
    required AudioRecorderService recorderService,
    required SpeechEngine speechEngine,
    EnergyVad? vad,
  })  : _recorderService = recorderService,
        _speechEngine = speechEngine,
        _vad = vad ?? EnergyVad();

  Future<void> initialize() async {
    await _speechEngine.initialize();
  }

  Future<void> startPushToTalkSession({String hotwords = ''}) async {
    if (_isPipelineActive) return;
    _isPipelineActive = true;
    _vad.reset();

    await _speechEngine.start(hotwords: hotwords);
    await _recorderService.start();

    _audioSubscription = _recorderService.audioStream.listen((pcmData) async {
      if (!_isPipelineActive) return;

      final vadState = _vad.processFrame(pcmData);
      AppLogger.log('Pipeline', 'VAD state: $vadState, chunk: ${pcmData.length} bytes');

      await _speechEngine.acceptAudio(pcmData);
    });
  }

  Future<void> stopPushToTalkSession() async {
    if (!_isPipelineActive) return;
    _isPipelineActive = false;

    await _audioSubscription?.cancel();
    _audioSubscription = null;

    await _recorderService.stop();
    await _speechEngine.stop();
  }

  Future<void> dispose() async {
    await stopPushToTalkSession();
    await _engineEventSubscription?.cancel();
    await _speechEngine.dispose();
    await _recorderService.dispose();
  }
}
