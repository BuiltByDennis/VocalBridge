import 'dart:async';
import 'dart:typed_data';
import 'speech_engine_event.dart';

export 'speech_engine_event.dart';

abstract class SpeechEngine {
  Future<void> initialize();
  Future<void> dispose();
  /// Begins a new listening session, allocating a new audio stream.
  /// Optional [hotwords] can be provided to bias the recognizer.
  Future<void> start({String hotwords = ''});
  Future<void> stop();
  Future<void> acceptAudio(Uint8List pcm16);
  Stream<SpeechEngineEvent> get events;
  bool get isInitialized;
}
