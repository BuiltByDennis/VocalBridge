import 'dart:async';
import 'dart:typed_data';

import '../asr/models/asr_model_config.dart';
import 'speech_engine.dart';

class MockSpeechEngine implements SpeechEngine {
  final AsrModelConfig config;
  final StreamController<SpeechEngineEvent> _eventController =
      StreamController<SpeechEngineEvent>.broadcast();

  bool _initialized = false;
  bool _recording = false;
  final StringBuffer _audioBuffer = StringBuffer();
  DateTime? _speechStartTime;

  MockSpeechEngine(this.config);

  @override
  bool get isInitialized => _initialized;

  @override
  Stream<SpeechEngineEvent> get events => _eventController.stream;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _initialized = true;
    _eventController.add(const EngineReady());
  }

  @override
  Future<void> start({String hotwords = ''}) async {
    if (!_initialized) {
      _eventController.add(const SpeechEngineError('Engine not initialized'));
      return;
    }
    _recording = true;
    _speechStartTime = DateTime.now();
    _audioBuffer.clear();
    _eventController.add(const SpeechStarted());
  }

  @override
  Future<void> stop() async {
    if (!_recording) return;
    _recording = false;
    _eventController.add(const SpeechProcessing());

    final duration = DateTime.now().difference(_speechStartTime ?? DateTime.now());
    await Future.delayed(const Duration(milliseconds: 30));

    final text = _audioBuffer.isEmpty ? "I need to see the doctor" : _audioBuffer.toString().trim();
    final result = RecognitionResult(
      text: text,
      confidence: 0.95,
      processingTime: const Duration(milliseconds: 45),
      audioDuration: duration.inMilliseconds > 0 ? duration : const Duration(seconds: 2),
    );

    _eventController.add(FinalTranscript(text, result: result));
    _eventController.add(const EngineReady());
  }

  @override
  Future<void> acceptAudio(Uint8List pcm16) async {
    if (!_recording) return;
    if (_audioBuffer.isEmpty) {
      _audioBuffer.write("I need");
      _eventController.add(const PartialTranscript("I need"));
    } else if (_audioBuffer.toString() == "I need") {
      _audioBuffer.write(" to see");
      _eventController.add(const PartialTranscript("I need to see"));
    } else if (_audioBuffer.toString() == "I need to see") {
      _audioBuffer.write(" the doctor");
      _eventController.add(const PartialTranscript("I need to see the doctor"));
    }
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
    _recording = false;
    await _eventController.close();
  }
}
