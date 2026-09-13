import 'dart:async';

abstract class SpeechEngineEvent {}

class SpeechEngineReadyEvent extends SpeechEngineEvent {}
class SpeechEngineListeningEvent extends SpeechEngineEvent {}
class SpeechEngineProcessingEvent extends SpeechEngineEvent {}
class SpeechEngineResultEvent extends SpeechEngineEvent {
  final String transcript;
  SpeechEngineResultEvent(this.transcript);
}
class SpeechEngineErrorEvent extends SpeechEngineEvent {
  final String error;
  SpeechEngineErrorEvent(this.error);
}

abstract class SpeechEngine {
  Future<void> initialize();
  Future<void> dispose();
  Future<void> start();
  Future<void> stop();
  Stream<SpeechEngineEvent> get events;
  bool get isInitialized;
}
