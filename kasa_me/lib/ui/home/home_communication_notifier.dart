import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/recorder/audio_recorder_service.dart';
import '../../core/accessibility/accessibility_settings.dart';
import '../../core/permissions/permission_service.dart';
import '../../speech/asr/models/asr_model_config.dart';
import '../../speech/asr/models/asr_model_registry.dart';
import '../../speech/engine/speech_engine.dart';
import '../../speech/engine/speech_engine_factory.dart';
import '../../speech/personalization/personalization_pipeline.dart';
import '../../speech/pipeline/streaming_audio_pipeline.dart';
import '../../speech/tts/tts_engine.dart';
import '../../speech/tts/tts_engine_factory.dart';
import '../../speech/tts/offline_tts_engine.dart';
import '../../speech/translation/translation_service.dart';
import '../../speech/translation/dictionary_translation_service.dart';
import '../../speech/ug_hci_lab/ug_hci_lab_config.dart';
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
  final String providerLabel;
  // Bidirectional translation display (e.g. Twi ↔ English for the care scenario).
  final String? translation;
  final String translationSourceLabel;
  final String translationTargetLabel;
  final String translationTargetCode; // 'en' or 'tw' — which voice reads it aloud

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
    this.providerLabel = 'Offline',
    this.translation,
    this.translationSourceLabel = '',
    this.translationTargetLabel = '',
    this.translationTargetCode = '',
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
    String? providerLabel,
    String? translation,
    String? translationSourceLabel,
    String? translationTargetLabel,
    String? translationTargetCode,
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
      providerLabel: providerLabel ?? this.providerLabel,
      translation: translation ?? this.translation,
      translationSourceLabel: translationSourceLabel ?? this.translationSourceLabel,
      translationTargetLabel: translationTargetLabel ?? this.translationTargetLabel,
      translationTargetCode: translationTargetCode ?? this.translationTargetCode,
    );
  }

  /// Clears the translation without touching the other fields (copyWith
  /// cannot set a nullable field back to null).
  HomeCommunicationState clearTranslation() {
    return HomeCommunicationState(
      engineState: engineState,
      isSpeaking: isSpeaking,
      isHighImpact: isHighImpact,
      hasConfirmedHighImpact: hasConfirmedHighImpact,
      selectedLanguage: selectedLanguage,
      activeModel: activeModel,
      partialTranscript: partialTranscript,
      rawTranscript: rawTranscript,
      personalizedTranscript: personalizedTranscript,
      confidence: confidence,
      lastInferenceTime: lastInferenceTime,
      lastAudioDuration: lastAudioDuration,
      errorMessage: errorMessage,
      modelLoadedAt: modelLoadedAt,
      modelLoadDuration: modelLoadDuration,
      quickPhrases: quickPhrases,
      providerLabel: providerLabel,
      translation: null,
      translationSourceLabel: '',
      translationTargetLabel: '',
      translationTargetCode: '',
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
  AccessibilitySettings _accessibilitySettings;
  
  // TTS Engine
  late TtsEngine _ttsEngine;
  // Dedicated English voice for reading translations aloud to the caregiver.
  // The main engine speaks the user's own language; this one always speaks
  // English (offline system voice is reliable for en-US).
  late final TtsEngine _englishTts = OfflineTtsEngine();
  // Curated Twi ↔ English care glossary (offline, honest about coverage).
  final TranslationService _translationService = DictionaryTranslationService();

  StreamSubscription<SpeechEngineEvent>? _eventSub;
  StreamSubscription<List<PhrasebookEntry>>? _phrasebookSub;

  HomeCommunicationNotifier({
    required PhrasebookRepository phrasebookRepository,
    required ProfileRepository profileRepository,
    required DiagnosticsRepository diagnosticsRepository,
    required PersonalizationRepository personalizationRepository,
    AccessibilitySettings? accessibilitySettings,
  })  : _phrasebookRepository = phrasebookRepository,
        _profileRepository = profileRepository,
        _diagnosticsRepository = diagnosticsRepository,
        _personalizationRepository = personalizationRepository,
        _accessibilitySettings = accessibilitySettings ?? const AccessibilitySettings(),
        super(HomeCommunicationState(activeModel: AsrModelRegistry.defaultModel)) {
    _personalizationPipeline = PersonalizationPipeline(repository: _personalizationRepository);
    _initialize();
  }

  /// Called by the provider when accessibility settings change reactively.
  void updateAccessibilitySettings(AccessibilitySettings settings) {
    _accessibilitySettings = settings;
    // Apply mic gain immediately — _recorderService is late so guard with try/catch
    try {
      _recorderService.micGainMultiplier = settings.micGainMultiplier;
    } catch (_) {
      // Recorder not yet initialized; gain will be applied in _initialize()
    }
  }

  Future<void> _initialize() async {
    state = state.copyWith(engineState: UiEngineState.loading);
    final startTime = DateTime.now();

    // Fetch preferred language
    final profile = await _profileRepository.getActiveProfile('default_user');
    final activeModel = AsrModelRegistry.getModelForLanguage(profile.preferredLanguage) 
        ?? AsrModelRegistry.defaultModel;

    state = state.copyWith(activeModel: activeModel, selectedLanguage: profile.preferredLanguage);

    // Resolve the speech provider. Ghanaian languages (Twi, Ewe, Dagbani)
    // have no bundled on-device model, so they REQUIRE the UG HCI Lab API.
    // Fail with a clear, actionable message instead of a missing-model crash.
    final labSettings = await UgHciLabSettings.load();
    if (profile.preferredLanguage == 'twi' && !labSettings.isConfigured) {
      state = state.copyWith(
        engineState: UiEngineState.error,
        errorMessage:
            'Twi needs the UG HCI Lab speech API — there is no on-device Twi model. '
            'Open Settings → Speech Provider and add your API key to enable it.',
      );
      return;
    }

    state = state.copyWith(providerLabel: labSettings.providerLabel);

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

    _speechEngine = SpeechEngineFactory.createEngine(
      config: state.activeModel,
      useLabApi: labSettings.useLabApi,
      labSettings: labSettings,
    );
    _ttsEngine = TtsEngineFactory.create(
      provider: labSettings.provider,
      labSettings: labSettings,
      appLanguage: profile.preferredLanguage,
    );
    _recorderService = AudioRecorderService()
      ..micGainMultiplier = _accessibilitySettings.micGainMultiplier;
    await _recorderService.initialize();

    _pipeline = StreamingAudioPipeline(
      recorderService: _recorderService,
      speechEngine: _speechEngine,
    );

    _eventSub = _speechEngine.events.listen(_handleEngineEvent);

    try {
      await _ttsEngine.initialize();
      await _englishTts.initialize();
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
        final finalText = pRes.personalizedTranscript.isNotEmpty ? pRes.personalizedTranscript : text;
        
        // Log telemetry
        await _diagnosticsRepository.logRecognitionEvent(
          profileId: 'default_user',
          rawTranscript: text,
          personalizedTranscript: finalText,
          confidence: res?.confidence,
          wasCorrected: false,
        );

        state = state.clearTranslation().copyWith(
          engineState: UiEngineState.ready,
          rawTranscript: text,
          personalizedTranscript: finalText,
          partialTranscript: '',
          confidence: res?.confidence,
          isHighImpact: pRes.isHighImpact,
          hasConfirmedHighImpact: false,
          lastInferenceTime: res?.processingTime,
          lastAudioDuration: res?.audioDuration,
          translation: _translateText(finalText),
          translationSourceLabel: _translationSourceLabel,
          translationTargetLabel: _translationTargetLabel,
          translationTargetCode: _translationTargetCode,
        );

        // 3.1 Auto-Speak: if enabled and not a high-impact message, speak immediately.
        // When a translation exists, speak the CAREGIVER-facing text (the completed
        // task: the nurse hears English) instead of the original utterance.
        if (_accessibilitySettings.autoSpeakOnTranscription &&
            finalText.isNotEmpty &&
            !pRes.isHighImpact) {
          final t = state.translation;
          if (t != null && t.isNotEmpty) {
            await speakTranslationText(t);
          } else {
            await speakText(finalText);
          }
        }
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
    state = state.clearTranslation().copyWith(
      rawTranscript: entry.phrase,
      personalizedTranscript: entry.phrase,
      confidence: 1.0,
      translation: _translateText(entry.phrase),
      translationSourceLabel: _translationSourceLabel,
      translationTargetLabel: _translationTargetLabel,
      translationTargetCode: _translationTargetCode,
    );
    
    // Trigger usage count increment to allow dynamic reordering
    _phrasebookRepository.incrementUsage(entry.id);
  }

  Future<String> applyWordCorrection(String observed, String intended, String rawTranscriptContext) async {
    await _personalizationPipeline.applyCorrection(
      original: observed,
      corrected: intended,
      profileId: 'default_user',
    );
    final pRes = await _personalizationPipeline.processTranscript(rawTranscriptContext, confidence: state.confidence);
    
    // Log telemetry for the correction
    await _diagnosticsRepository.logRecognitionEvent(
      profileId: 'default_user',
      rawTranscript: rawTranscriptContext,
      personalizedTranscript: pRes.personalizedTranscript,
      confidence: state.confidence,
      wasCorrected: true,
      context: 'word_correction_chip',
    );

    // If we're correcting the most recent utterance, update global state
    if (rawTranscriptContext == state.rawTranscript) {
      final newPersonalized = pRes.personalizedTranscript;
      state = state.clearTranslation().copyWith(
        personalizedTranscript: newPersonalized,
        translation: _translateText(newPersonalized),
        translationSourceLabel: _translationSourceLabel,
        translationTargetLabel: _translationTargetLabel,
        translationTargetCode: _translationTargetCode,
      );
    }
    
    return pRes.personalizedTranscript;
  }

  void clearTranscript() {
    state = state.clearTranslation().copyWith(
        rawTranscript: '', personalizedTranscript: '', partialTranscript: '');
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

    await speakText(textToSpeak);
  }
  
  Future<void> speakText(String text) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(isSpeaking: true);
    try {
      await _ttsEngine.speak(text);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to speak: $e');
    } finally {
      state = state.copyWith(isSpeaking: false);
    }
  }

  Future<void> stopSpeaking() async {
    await _ttsEngine.stop();
    await _englishTts.stop();
    state = state.copyWith(isSpeaking: false);
  }

  // ── Bidirectional translation (Twi ↔ English, care scenario) ──

  /// (from, to) app language codes for the current UI language, or null
  /// when the pair is not supported.
  (String, String)? _translationPair() {
    if (state.selectedLanguage == 'twi') return ('twi', 'en_GH');
    if (state.selectedLanguage == 'en_GH') return ('en_GH', 'twi');
    return null;
  }

  String get _translationSourceLabel =>
      state.selectedLanguage == 'twi' ? 'Twi' : 'English';

  String get _translationTargetLabel =>
      state.selectedLanguage == 'twi' ? 'English' : 'Twi';

  /// Lab language code of the translation target — picks the voice that
  /// reads the translation aloud ('en' → English voice, 'tw' → Twi voice).
  String get _translationTargetCode =>
      state.selectedLanguage == 'twi' ? 'en' : 'tw';

  /// Translates [text] for the current language pair. Returns null when
  /// unsupported or when the glossary has no entry (never a guess).
  String? _translateText(String text) {
    final pair = _translationPair();
    if (pair == null) return null;
    return _translationService.translate(text, from: pair.$1, to: pair.$2);
  }

  /// Public helper so the UI can re-translate corrected text.
  String? translateFor(String text) => _translateText(text);
  String get translationSourceLabel => _translationSourceLabel;
  String get translationTargetLabel => _translationTargetLabel;
  String get translationTargetCode => _translationTargetCode;

  /// Speaks [text] in the user's own (source) language.
  Future<void> speakOriginalText(String text) async {
    if (state.isHighImpact && !state.hasConfirmedHighImpact) return;
    await speakText(text);
  }

  /// Speaks [text] in the translation's (target) language — the voice the
  /// other person hears. English always uses the dedicated offline voice;
  /// Twi uses the main engine (Lab TTS when the API is configured).
  Future<void> speakTranslationText(String text) async {
    if (text.trim().isEmpty) return;
    if (state.isHighImpact && !state.hasConfirmedHighImpact) return;

    state = state.copyWith(isSpeaking: true);
    try {
      if (state.translationTargetCode == 'en') {
        await _englishTts.speak(text);
      } else {
        await _ttsEngine.speak(text);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to speak translation: $e');
    } finally {
      state = state.copyWith(isSpeaking: false);
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _phrasebookSub?.cancel();
    _pipeline.dispose();
    _ttsEngine.dispose();
    _englishTts.dispose();
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
  final notifier = HomeCommunicationNotifier(
    phrasebookRepository: ref.watch(phrasebookRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    diagnosticsRepository: ref.watch(diagnosticsRepositoryProvider),
    personalizationRepository: ref.watch(personalizationRepositoryProvider),
    accessibilitySettings: ref.read(accessibilitySettingsProvider),
  );
  // Keep notifier in sync when accessibility settings change
  ref.listen(accessibilitySettingsProvider, (_, next) {
    notifier.updateAccessibilitySettings(next);
  });
  return notifier;
});
