class RecognitionResult {
  final String text;
  final double? confidence;
  final Duration processingTime;
  final Duration audioDuration;

  const RecognitionResult({
    required this.text,
    this.confidence,
    required this.processingTime,
    required this.audioDuration,
  });

  @override
  String toString() =>
      'RecognitionResult(text: "$text", confidence: $confidence, processingTime: ${processingTime.inMilliseconds}ms, audioDuration: ${audioDuration.inMilliseconds}ms)';
}

sealed class SpeechEngineEvent {
  const SpeechEngineEvent();
}

class EngineReady extends SpeechEngineEvent {
  const EngineReady();
}

class SpeechStarted extends SpeechEngineEvent {
  const SpeechStarted();
}

class PartialTranscript extends SpeechEngineEvent {
  final String text;
  const PartialTranscript(this.text);
}

class FinalTranscript extends SpeechEngineEvent {
  final String text;
  final RecognitionResult? result;
  const FinalTranscript(this.text, {this.result});
}

class SpeechProcessing extends SpeechEngineEvent {
  const SpeechProcessing();
}

class SpeechEngineError extends SpeechEngineEvent {
  final String message;
  final Object? error;
  const SpeechEngineError(this.message, {this.error});
}
