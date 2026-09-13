import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/recorder/audio_recorder_service.dart';
import '../../speech/asr/models/asr_model_config.dart';
import '../../speech/asr/models/asr_model_registry.dart';
import '../../speech/engine/speech_engine.dart';
import '../../speech/engine/speech_engine_factory.dart';
import '../../speech/pipeline/streaming_audio_pipeline.dart';

enum UiEngineState {
  notLoaded,
  loading,
  ready,
  listening,
  processing,
  error,
}

class HomeCommunicationState {
  final UiEngineState engineState;
  final String selectedLanguage;
  final AsrModelConfig activeModel;
  final String partialTranscript;
  final String finalTranscript;
  final double? confidence;
  final Duration? lastInferenceTime;
  final Duration? lastAudioDuration;
  final String? errorMessage;
  final DateTime? modelLoadedAt;
  final Duration? modelLoadDuration;

  const HomeCommunicationState({
    this.engineState = UiEngineState.notLoaded,
    this.selectedLanguage = 'English (Ghana)',
    required this.activeModel,
    this.partialTranscript = '',
    this.finalTranscript = '',
    this.confidence,
    this.lastInferenceTime,
    this.lastAudioDuration,
    this.errorMessage,
    this.modelLoadedAt,
    this.modelLoadDuration,
  });

  HomeCommunicationState copyWith({
    UiEngineState? engineState,
    String? selectedLanguage,
    AsrModelConfig? activeModel,
    String? partialTranscript,
    String? finalTranscript,
    double? confidence,
    Duration? lastInferenceTime,
    Duration? lastAudioDuration,
    String? errorMessage,
    DateTime? modelLoadedAt,
    Duration? modelLoadDuration,
  }) {
    return HomeCommunicationState(
      engineState: engineState ?? this.engineState,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      activeModel: activeModel ?? this.activeModel,
      partialTranscript: partialTranscript ?? this.partialTranscript,
      finalTranscript: finalTranscript ?? this.finalTranscript,
      confidence: confidence ?? this.confidence,
      lastInferenceTime: lastInferenceTime ?? this.lastInferenceTime,
      lastAudioDuration: lastAudioDuration ?? this.lastAudioDuration,
      errorMessage: errorMessage ?? this.errorMessage,
      modelLoadedAt: modelLoadedAt ?? this.modelLoadedAt,
      modelLoadDuration: modelLoadDuration ?? this.modelLoadDuration,
    );
  }
}

class HomeCommunicationNotifier extends StateNotifier<HomeCommunicationState> {
  late SpeechEngine _speechEngine;
  late AudioRecorderService _recorderService;
  late StreamingAudioPipeline _pipeline;
  StreamSubscription<SpeechEngineEvent>? _eventSub;

  HomeCommunicationNotifier()
      : super(HomeCommunicationState(activeModel: AsrModelRegistry.defaultModel)) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(engineState: UiEngineState.loading);
    final startTime = DateTime.now();

    _speechEngine = SpeechEngineFactory.createEngine(config: state.activeModel);
    _recorderService = AudioRecorderService();
    await _recorderService.initialize();

    _pipeline = StreamingAudioPipeline(
      recorderService: _recorderService,
      speechEngine: _speechEngine,
    );

    _eventSub = _speechEngine.events.listen(_handleEngineEvent);

    try {
      await _pipeline.initialize();
      final loadTime = DateTime.now().difference(startTime);
      state = state.copyWith(
        engineState: UiEngineState.ready,
        modelLoadedAt: DateTime.now(),
        modelLoadDuration: loadTime,
      );
    } catch (e) {
      state = state.copyWith(
        engineState: UiEngineState.error,
        errorMessage: 'Failed to initialize ASR model: $e',
      );
    }
  }

  void _handleEngineEvent(SpeechEngineEvent event) {
    switch (event) {
      case EngineReady():
        state = state.copyWith(engineState: UiEngineState.ready, partialTranscript: '');
        break;
      case SpeechStarted():
        state = state.copyWith(
          engineState: UiEngineState.listening,
          partialTranscript: '',
          errorMessage: null,
        );
        break;
      case PartialTranscript(text: final text):
        state = state.copyWith(
          engineState: UiEngineState.listening,
          partialTranscript: text,
        );
        break;
      case SpeechProcessing():
        state = state.copyWith(engineState: UiEngineState.processing);
        break;
      case FinalTranscript(text: final text, result: final res):
        state = state.copyWith(
          engineState: UiEngineState.ready,
          finalTranscript: text.isNotEmpty ? text : state.finalTranscript,
          partialTranscript: '',
          confidence: res?.confidence,
          lastInferenceTime: res?.processingTime,
          lastAudioDuration: res?.audioDuration,
        );
        break;
      case SpeechEngineError(message: final msg):
        state = state.copyWith(
          engineState: UiEngineState.error,
          errorMessage: msg,
        );
        break;
    }
  }

  Future<void> startPushToTalk() async {
    if (state.engineState != UiEngineState.ready) return;
    try {
      await _pipeline.startPushToTalkSession();
    } catch (e) {
      state = state.copyWith(
        engineState: UiEngineState.error,
        errorMessage: 'Failed to start recording: $e',
      );
    }
  }

  Future<void> stopPushToTalk() async {
    if (state.engineState != UiEngineState.listening) return;
    try {
      await _pipeline.stopPushToTalkSession();
    } catch (e) {
      state = state.copyWith(
        engineState: UiEngineState.error,
        errorMessage: 'Failed to stop recording: $e',
      );
    }
  }

  void clearTranscript() {
    state = state.copyWith(finalTranscript: '', partialTranscript: '');
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _pipeline.dispose();
    super.dispose();
  }
}

final homeCommunicationProvider =
    StateNotifierProvider<HomeCommunicationNotifier, HomeCommunicationState>((ref) {
  return HomeCommunicationNotifier();
});
