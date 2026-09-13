import 'dart:async';
import 'dart:typed_data';
import 'speech_engine_event.dart';

export 'speech_engine_event.dart';

abstract class SpeechEngine {
  Future<void> initialize();
  Future<void> dispose();
  Future<void> start();
  Future<void> stop();
  Future<void> acceptAudio(Uint8List pcm16);
  Stream<SpeechEngineEvent> get events;
  bool get isInitialized;
}
