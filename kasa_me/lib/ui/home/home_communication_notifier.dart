import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/recorder/audio_recorder_service.dart';
import '../../core/permissions/permission_service.dart';
import '../../speech/asr/models/asr_model_config.dart';
import '../../speech/asr/models/asr_model_registry.dart';
import '../../speech/engine/speech_engine.dart';
import '../../speech/engine/speech_engine_factory.dart';
import '../../speech/personalization/personalization_pipeline.dart';
import '../../speech/pipeline/streaming_audio_pipeline.dart';
import '../../speech/tts/tts_engine.dart';
import '../../speech/tts/offline_tts_engine.dart';
import '../../phrasebook/repositories/phrasebook_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../speech/diagnostics/repositories/diagnostics_repository.dart';
import '../../speech/personalization/personalization_repository.dart';
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
  final bool isSpeaking;
  final bool isHighImpact;
  final bool hasConfirmedHighImpact;
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
    this.isSpeaking = false,
    this.isHighImpact = false,
    this.hasConfirmedHighImpact = false,
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
    bool? isSpeaking,
    bool? isHighImpact,
    bool? hasConfirmedHighImpact,
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
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isHighImpact: isHighImpact ?? this.isHighImpact,
      hasConfirmedHighImpact: hasConfirmedHighImpact ?? this.hasConfirmedHighImpact,
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
  final ProfileRepository _profileRepository;
  final DiagnosticsRepository _diagnosticsRepository;
  final PersonalizationRepository _personalizationRepository;
  
  // TTS Engine
  late final TtsEngine _ttsEngine;

  StreamSubscription<SpeechEngineEvent>? _eventSub;
  StreamSubscription<List<PhrasebookEntry>>? _phrasebookSub;

  HomeCommunicationNotifier({
    required PhrasebookRepository phrasebookRepository,
    required ProfileRepository profileRepository,
    required DiagnosticsRepository diagnosticsRepository,
    required PersonalizationRepository personalizationRepository,
  })  : _phrasebookRepository = phrasebookRepository,
        _profileRepository = profileRepository,
        _diagnosticsRepository = diagnosticsRepository,
        _personalizationRepository = personalizationRepository,
        super(HomeCommunicationState(activeModel: AsrModelRegistry.defaultModel)) {
    _personalizationPipeline = PersonalizationPipeline(repository: _personalizationRepository);
    _ttsEngine = OfflineTtsEngine();
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(engineState: UiEngineState.loading);
    final startTime = DateTime.now();

    // Fetch preferred language
    final profile = await _profileRepository.getActiveProfile('default_user');
    final activeModel = AsrModelRegistry.getModelForLanguage(profile.preferredLanguage) 
        ?? AsrModelRegistry.defaultModel;

    state = state.copyWith(activeModel: activeModel, selectedLanguage: profile.preferredLanguage);

    // Subscribe to Phrasebook
    _phrasebookSub = _phrasebookRepository.watchQuickPhrases().listen((phrases) {
      state = state.copyWith(quickPhrases: phrases);
    });

    // Request microphone permission before initializing the recorder.
    // On Android this triggers the system permission dialog.
    final hasMicPermission = await PermissionService.requestMicrophonePermission();
    if (!hasMicPermission) {
      state = state.copyWith(
        engineState: UiEngineState.error,
        errorMessage: 'Microphone access is required for speech recognition. Please grant permission in Settings.',
      );
      return;
    }

    _speechEngine = SpeechEngineFactory.createEngine(config: state.activeModel);
    _recorderService = AudioRecorderService();
    await _recorderService.initialize();

    _pipeline = StreamingAudioPipeline(
      recorderService: _recorderService,
      speechEngine: _speechEngine,
    );

    _eventSub = _speechEngine.events.listen(_handleEngineEvent);

    try {
      await _ttsEngine.initialize();
      await _pipeline.initialize();
      await _personalizationPipeline.initialize('default_user');

      // Explicitly verify the speech engine actually initialized successfully.
      // SherpaSpeechEngine catches internal errors and emits them via the stream
      // rather than rethrowing, so we must check isInitialized directly to avoid
      // a race condition where we set state to 'ready' while the engine is broken.
      if (!_speechEngine.isInitialized) {
        // The stream handler (_handleEngineEvent) has already set a specific error
        // message from the Sherpa engine. Only set a fallback if nothing was set.
        if (state.engineState != UiEngineState.error) {
          state = state.copyWith(
            engineState: UiEngineState.error,
            errorMessage: 'Speech recognition model failed to load. Please reinstall the app.',
          );
        }
        return;
      }

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

  Future<void> _handleEngineEvent(SpeechEngineEvent event) async {
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
        final pRes = await _personalizationPipeline.processTranscript(text, confidence: res?.confidence);
        
        // Log telemetry
        await _diagnosticsRepository.logRecognitionEvent(
          profileId: 'default_user',
          rawTranscript: text,
          personalizedTranscript: pRes.personalizedTranscript.isNotEmpty ? pRes.personalizedTranscript : text,
          confidence: res?.confidence,
          wasCorrected: false,
        );

        state = state.copyWith(
          engineState: UiEngineState.ready,
          rawTranscript: text,
          personalizedTranscript: pRes.personalizedTranscript.isNotEmpty ? pRes.personalizedTranscript : state.personalizedTranscript,
          partialTranscript: '',
          confidence: res?.confidence,
          isHighImpact: pRes.isHighImpact,
          hasConfirmedHighImpact: false,
          lastInferenceTime: res?.processingTime,
          lastAudioDuration: res?.audioDuration,
        );
        break;
      case SpeechEngineError(message: final msg):
        HapticFeedback.vibrate();
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
      HapticFeedback.heavyImpact();
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
      HapticFeedback.heavyImpact();
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

  Future<void> applyWordCorrection(String observed, String intended) async {
    await _personalizationPipeline.applyCorrection(
      original: observed,
      corrected: intended,
      profileId: 'default_user',
    );
    final pRes = await _personalizationPipeline.processTranscript(state.rawTranscript, confidence: state.confidence);
    
    // Log telemetry for the correction
    await _diagnosticsRepository.logRecognitionEvent(
      profileId: 'default_user',
      rawTranscript: state.rawTranscript,
      personalizedTranscript: pRes.personalizedTranscript,
      confidence: state.confidence,
      wasCorrected: true,
      context: 'word_correction_chip',
    );

    state = state.copyWith(personalizedTranscript: pRes.personalizedTranscript);
  }

  void clearTranscript() {
    state = state.copyWith(rawTranscript: '', personalizedTranscript: '', partialTranscript: '');
  }

  void confirmHighImpact() {
    state = state.copyWith(hasConfirmedHighImpact: true);
  }

  Future<void> speakTranscript() async {
    if (state.isHighImpact && !state.hasConfirmedHighImpact) {
      return;
    }

    final textToSpeak = state.personalizedTranscript.isNotEmpty 
        ? state.personalizedTranscript 
        : state.rawTranscript;

    if (textToSpeak.trim().isEmpty) return;

    state = state.copyWith(isSpeaking: true);
    try {
      await _ttsEngine.speak(textToSpeak);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to speak: $e');
    } finally {
      state = state.copyWith(isSpeaking: false);
    }
  }

  Future<void> stopSpeaking() async {
    await _ttsEngine.stop();
    state = state.copyWith(isSpeaking: false);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _phrasebookSub?.cancel();
    _pipeline.dispose();
    _ttsEngine.dispose();
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

final personalizationRepositoryProvider = Provider<PersonalizationRepository>((ref) {
  return PersonalizationRepository(ref.watch(databaseProvider));
});

final homeCommunicationProvider =
    StateNotifierProvider<HomeCommunicationNotifier, HomeCommunicationState>((ref) {
  return HomeCommunicationNotifier(
    phrasebookRepository: ref.watch(phrasebookRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    diagnosticsRepository: ref.watch(diagnosticsRepositoryProvider),
    personalizationRepository: ref.watch(personalizationRepositoryProvider),
  );
});
