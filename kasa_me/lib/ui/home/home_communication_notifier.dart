import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/recorder/audio_recorder_service.dart';
import '../../speech/asr/models/asr_model_config.dart';
import '../../speech/asr/models/asr_model_registry.dart';
import '../../speech/engine/speech_engine.dart';
import '../../speech/engine/speech_engine_factory.dart';
import '../../speech/personalization/personalization_pipeline.dart';
import '../../speech/pipeline/streaming_audio_pipeline.dart';
import '../../phrasebook/repositories/phrasebook_repository.dart';
import '../../storage/database/app_database.dart';

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
  final String rawTranscript;
  final String personalizedTranscript;
  final double? confidence;
  final Duration? lastInferenceTime;
  final Duration? lastAudioDuration;
  final String? errorMessage;
  final DateTime? modelLoadedAt;
  final Duration? modelLoadDuration;
  final List<PhrasebookEntry> quickPhrases;

  const HomeCommunicationState({
    this.engineState = UiEngineState.notLoaded,
    this.selectedLanguage = 'English (Ghana)',
    required this.activeModel,
    this.partialTranscript = '',
    this.rawTranscript = '',
    this.personalizedTranscript = '',
    this.confidence,
    this.lastInferenceTime,
    this.lastAudioDuration,
    this.errorMessage,
    this.modelLoadedAt,
    this.modelLoadDuration,
    this.quickPhrases = const [],
  });

  HomeCommunicationState copyWith({
    UiEngineState? engineState,
    String? selectedLanguage,
    AsrModelConfig? activeModel,
    String? partialTranscript,
    String? rawTranscript,
    String? personalizedTranscript,
    double? confidence,
    Duration? lastInferenceTime,
    Duration? lastAudioDuration,
    String? errorMessage,
    DateTime? modelLoadedAt,
    Duration? modelLoadDuration,
    List<PhrasebookEntry>? quickPhrases,
  }) {
    return HomeCommunicationState(
      engineState: engineState ?? this.engineState,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      activeModel: activeModel ?? this.activeModel,
      partialTranscript: partialTranscript ?? this.partialTranscript,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      personalizedTranscript: personalizedTranscript ?? this.personalizedTranscript,
      confidence: confidence ?? this.confidence,
      lastInferenceTime: lastInferenceTime ?? this.lastInferenceTime,
      lastAudioDuration: lastAudioDuration ?? this.lastAudioDuration,
      errorMessage: errorMessage ?? this.errorMessage,
      modelLoadedAt: modelLoadedAt ?? this.modelLoadedAt,
      modelLoadDuration: modelLoadDuration ?? this.modelLoadDuration,
      quickPhrases: quickPhrases ?? this.quickPhrases,
    );
  }
}

class HomeCommunicationNotifier extends StateNotifier<HomeCommunicationState> {
  late SpeechEngine _speechEngine;
  late AudioRecorderService _recorderService;
  late StreamingAudioPipeline _pipeline;
  late PersonalizationPipeline _personalizationPipeline;
  final PhrasebookRepository _phrasebookRepository;
  
  StreamSubscription<SpeechEngineEvent>? _eventSub;
  StreamSubscription<List<PhrasebookEntry>>? _phrasebookSub;

  HomeCommunicationNotifier({required PhrasebookRepository phrasebookRepository})
      : _phrasebookRepository = phrasebookRepository,
        super(HomeCommunicationState(activeModel: AsrModelRegistry.defaultModel)) {
    _personalizationPipeline = PersonalizationPipeline();
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(engineState: UiEngineState.loading);
    final startTime = DateTime.now();

    // Subscribe to Phrasebook
    _phrasebookSub = _phrasebookRepository.watchQuickPhrases().listen((phrases) {
      state = state.copyWith(quickPhrases: phrases);
    });

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
        final pRes = _personalizationPipeline.processTranscript(text, confidence: res?.confidence);
        state = state.copyWith(
          engineState: UiEngineState.ready,
          rawTranscript: text,
          personalizedTranscript: pRes.personalizedTranscript.isNotEmpty ? pRes.personalizedTranscript : state.personalizedTranscript,
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

  void selectQuickPhrase(PhrasebookEntry entry) {
    HapticFeedback.mediumImpact();
    state = state.copyWith(
      rawTranscript: entry.phrase,
      personalizedTranscript: entry.phrase,
      confidence: 1.0,
    );
    
    // Trigger usage count increment to allow dynamic reordering
    _phrasebookRepository.incrementUsage(entry.id);
  }

  void applyWordCorrection(String observed, String intended) {
    _personalizationPipeline.safetyGuard.validateAndAddWordMapping(observed, intended);
    final pRes = _personalizationPipeline.processTranscript(state.rawTranscript, confidence: state.confidence);
    state = state.copyWith(personalizedTranscript: pRes.personalizedTranscript);
  }

  void clearTranscript() {
    state = state.copyWith(rawTranscript: '', personalizedTranscript: '', partialTranscript: '');
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _phrasebookSub?.cancel();
    _pipeline.dispose();
    super.dispose();
  }
}

// Temporary global instance for compilation since riverpod usually requires a provider scope.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase(); // Normally we pass the connection
});

final phrasebookRepositoryProvider = Provider<PhrasebookRepository>((ref) {
  return PhrasebookRepository(ref.watch(databaseProvider));
});

final homeCommunicationProvider =
    StateNotifierProvider<HomeCommunicationNotifier, HomeCommunicationState>((ref) {
  return HomeCommunicationNotifier(
    phrasebookRepository: ref.watch(phrasebookRepositoryProvider),
  );
});
