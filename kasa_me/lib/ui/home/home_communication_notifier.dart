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
import '../../speech/personalization/speech_behavior.dart';
import '../../speech/personalization/speech_profile_settings.dart';
import '../../speech/pipeline/streaming_audio_pipeline.dart';
import '../../speech/vad/energy_vad.dart';
import '../../speech/tts/tts_engine.dart';
import '../../speech/tts/tts_engine_factory.dart';
import '../../speech/tts/offline_tts_engine.dart';
import '../../speech/translation/translation_service.dart';
import '../../speech/translation/dictionary_translation_service.dart';
import '../../speech/khaya/khaya_config.dart';
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
  // TTS engines for Ghanaian languages OTHER than the profile's own,
  // built lazily when a translation must be spoken in them (an
  // English-profile user translating into Ewe, say). Khaya takes the
  // language per request, so the engine must be built for the text's
  // language — the profile-language engine would send the wrong code.
  final Map<String, TtsEngine> _ghanaTtsEngines = {};
  // Curated Ghanaian ↔ English care glossary (offline, honest about
  // coverage).
  final TranslationService _translationService = DictionaryTranslationService();

  StreamSubscription<SpeechEngineEvent>? _eventSub;
  StreamSubscription<List<PhrasebookEntry>>? _phrasebookSub;

  // Live-refresh state: settings changes rebuild the engines in place.
  SpeechBehavior _behavior = SpeechBehavior.fromKey(null);
  bool _enginesBuilt = false;
  bool _initializing = false;
  bool _refreshing = false;
  bool _pendingRefresh = false;
  bool _ignoreNextEngineResult = false;
  String? _activeSignature;

  /// The behaviour profile currently shaping recognition for this user.
  SpeechBehavior get behavior => _behavior;

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
    _initializing = true;
    try {
      await _initializeBody();
    } finally {
      _initializing = false;
    }
    if (_pendingRefresh) {
      _pendingRefresh = false;
      await refreshConfiguration();
    }
  }

  Future<void> _initializeBody() async {
    state = state.copyWith(engineState: UiEngineState.loading);
    final startTime = DateTime.now();

    // Fetch preferred language
    final profile = await _profileRepository.getActiveProfile('default_user');
    final activeModel = AsrModelRegistry.getModelForLanguage(profile.preferredLanguage) 
        ?? AsrModelRegistry.defaultModel;

    state = state.copyWith(activeModel: activeModel, selectedLanguage: profile.preferredLanguage);

    // Shape recognition around this person: their speech-condition
    // profile decides how the personalization pipeline behaves.
    final speechProfile = await SpeechProfileSettings.load();
    _behavior = speechProfile.behavior;
    _personalizationPipeline = PersonalizationPipeline(
      repository: _personalizationRepository,
      behavior: _behavior,
    );

    // Resolve the speech provider. Ghanaian languages (Twi, Ewe, Dagbani)
    // have no bundled on-device model, so they REQUIRE a cloud provider:
    // the UG HCI Lab API (hackathon path) or Khaya AI. Fail with a clear,
    // actionable message instead of a missing-model crash.
    final labSettings = await UgHciLabSettings.load();
    final khayaSettings = await KhayaSettings.load();
    final khayaReady = labSettings.provider == SpeechProvider.khaya &&
        khayaSettings.isConfigured;
    const ghanaianNames = {'twi': 'Twi', 'ewe': 'Ewe', 'dagbani': 'Dagbani'};
    final ghanaianName = ghanaianNames[profile.preferredLanguage];
    if (ghanaianName != null && !labSettings.isConfigured && !khayaReady) {
      state = state.copyWith(
        engineState: UiEngineState.error,
        errorMessage: labSettings.provider == SpeechProvider.khaya
            ? '$ghanaianName via Khaya needs a Khaya API key — there is no on-device $ghanaianName model. '
                'Open Settings → Speech Provider and add your Khaya subscription key to enable it.'
            : '$ghanaianName needs a cloud speech provider — there is no on-device $ghanaianName model. '
                'Open Settings → Speech Provider and add your UG HCI Lab or Khaya API key to enable it.',
      );
      return;
    }

    state = state.copyWith(providerLabel: labSettings.providerLabel);
    _activeSignature =
        _configSignature(profile, labSettings, speechProfile.conditionKey, khayaSettings);

    // Subscribe to Phrasebook — quick phrases follow the active
    // language (Ghanaian phrases carry a 'Twi · …' / 'Ewe · …'
    // category) so the strip never mixes languages the person isn't
    // speaking.
    _phrasebookSub = _phrasebookRepository.watchAllPhrases().listen((phrases) {
      const prefixes = {'twi': 'Twi', 'ewe': 'Ewe'};
      final prefix = prefixes[state.selectedLanguage];
      bool isGhanaian(PhrasebookEntry p) =>
          (p.category ?? '').startsWith('Twi') ||
          (p.category ?? '').startsWith('Ewe');
      final filtered = phrases
          .where((p) => prefix != null
              ? (p.category ?? '').startsWith(prefix)
              : !isGhanaian(p))
          .take(8)
          .toList();
      state = state.copyWith(quickPhrases: filtered);
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
      useKhayaApi: khayaReady,
      khayaSettings: khayaSettings,
    );
    _ttsEngine = TtsEngineFactory.create(
      provider: labSettings.provider,
      labSettings: labSettings,
      khayaSettings: khayaSettings,
      appLanguage: profile.preferredLanguage,
    );
    _recorderService = AudioRecorderService()
      ..micGainMultiplier = _accessibilitySettings.micGainMultiplier;
    await _recorderService.initialize();

    _pipeline = StreamingAudioPipeline(
      recorderService: _recorderService,
      speechEngine: _speechEngine,
      // The person's speech profile drives the VAD: patient profiles
      // (stammer, cerebral palsy, stroke) get a lower energy
      // threshold and a longer silence patience. Before this the VAD
      // always ran on hardcoded defaults, so the profile's listening
      // presets never reached it.
      vad: EnergyVad(
        thresholdRms: _behavior.vadThresholdRms,
        maxSilenceFrames: _behavior.vadMaxSilenceFrames,
      ),
    );
    _enginesBuilt = true;

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
    // A result the user already cancelled (slow provider) is
    // swallowed: the UI was handed back to them and must not be
    // hijacked by the late transcript or error when it lands.
    if (_ignoreNextEngineResult &&
        (event is FinalTranscript || event is SpeechEngineError)) {
      _ignoreNextEngineResult = false;
      return;
    }
    switch (event) {
      case EngineReady():
        state = state.copyWith(engineState: UiEngineState.ready, partialTranscript: '');
        if (_pendingRefresh) {
          _pendingRefresh = false;
          refreshConfiguration();
        }
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
    // A new recording supersedes any cancelled request still in
    // flight — its late result is no longer the one to swallow.
    _ignoreNextEngineResult = false;
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
    for (final engine in _ghanaTtsEngines.values) {
      await engine.stop();
    }
    state = state.copyWith(isSpeaking: false);
  }

  /// The user gives up waiting on a slow provider: hand the UI back
  /// immediately and swallow the late result when it finally lands
  /// (see [_handleEngineEvent]). The provider may still complete —
  /// and bill — the request in the background; what the user gets
  /// back is their app, responsive, now.
  void cancelProcessing() {
    if (state.engineState != UiEngineState.processing) return;
    _ignoreNextEngineResult = true;
    state = state.copyWith(
      engineState: UiEngineState.ready,
      partialTranscript: '',
    );
  }

  // ── Bidirectional translation (Ghanaian ↔ English, care scenario) ──

  /// Which Ghanaian language an English speaker's speech is translated
  /// INTO — the patient's language. The transcription screen offers
  /// the choice (Twi / Ewe); Twi is the default, as before Ewe opened.
  String _englishTargetLanguage = 'twi';

  /// (from, to) app language codes for the current UI language, or null
  /// when the pair is not supported.
  (String, String)? _translationPair() {
    const ghanaian = {'twi', 'ewe'};
    if (ghanaian.contains(state.selectedLanguage)) {
      return (state.selectedLanguage, 'en_GH');
    }
    if (state.selectedLanguage == 'en_GH') {
      return ('en_GH', _englishTargetLanguage);
    }
    return null;
  }

  static String _languageLabel(String code) =>
      switch (code) { 'twi' => 'Twi', 'ewe' => 'Ewe', _ => 'English' };

  String get _translationSourceLabel =>
      _languageLabel(state.selectedLanguage);

  String get _translationTargetLabel {
    final pair = _translationPair();
    return pair == null ? '' : _languageLabel(pair.$2);
  }

  /// Voice code of the translation target — picks the voice that
  /// reads the translation aloud ('en' → English voice, otherwise the
  /// Ghanaian language code itself: 'twi' / 'ewe').
  String get _translationTargetCode {
    final pair = _translationPair();
    if (pair == null) return '';
    return pair.$2 == 'en_GH' ? 'en' : pair.$2;
  }

  /// Switches the Ghanaian language English speech translates into
  /// and re-glosses the current utterance under the new pair.
  void setEnglishTargetLanguage(String code) {
    if (code != 'twi' && code != 'ewe') return;
    if (_englishTargetLanguage == code) return;
    _englishTargetLanguage = code;
    final current = state.personalizedTranscript.isNotEmpty
        ? state.personalizedTranscript
        : state.rawTranscript;
    final gloss = current.isEmpty ? null : _translateText(current);
    final sourceLabel = _translationSourceLabel;
    final targetLabel = _translationTargetLabel;
    final targetCode = _translationTargetCode;
    // copyWith cannot null the translation out, so rebuild from the
    // cleared state and re-apply the (possibly gloss-less) labels.
    var next = state.clearTranslation().copyWith(
          translationSourceLabel: sourceLabel,
          translationTargetLabel: targetLabel,
          translationTargetCode: targetCode,
        );
    if (gloss != null) next = next.copyWith(translation: gloss);
    state = next;
  }

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

  /// The TTS engine that speaks [appLanguage] ('twi' / 'ewe'): the
  /// main engine when that IS the profile language, otherwise a
  /// lazily built engine for the translation's language.
  Future<TtsEngine> _ttsEngineFor(String appLanguage) async {
    if (appLanguage == state.selectedLanguage) return _ttsEngine;
    final cached = _ghanaTtsEngines[appLanguage];
    if (cached != null) return cached;
    final lab = await UgHciLabSettings.load();
    final khaya = await KhayaSettings.load();
    final engine = TtsEngineFactory.create(
      provider: lab.provider,
      labSettings: lab,
      khayaSettings: khaya,
      appLanguage: appLanguage,
    );
    await engine.initialize();
    _ghanaTtsEngines[appLanguage] = engine;
    return engine;
  }

  /// Speaks [text] in the translation's (target) language — the voice the
  /// other person hears. English always uses the dedicated offline voice;
  /// a Ghanaian target uses an engine built for THAT language (the main
  /// engine when it matches the profile, a dedicated one otherwise).
  ///
  /// [targetCode] is the language THAT translation was made into. The
  /// message list passes its own stored code: using only the current
  /// state's code would read an older message's translation with
  /// whatever language happens to be targeted NOW (e.g. a Twi gloss
  /// read by the English voice after the target was switched).
  Future<void> speakTranslationText(String text, {String? targetCode}) async {
    if (text.trim().isEmpty) return;
    if (state.isHighImpact && !state.hasConfirmedHighImpact) return;

    final code = (targetCode != null && targetCode.isNotEmpty)
        ? targetCode
        : _translationTargetCode;
    state = state.copyWith(isSpeaking: true);
    try {
      if (code == 'en') {
        await _englishTts.speak(text);
      } else {
        final engine = await _ttsEngineFor(code);
        await engine.speak(text);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to speak translation: $e');
    } finally {
      state = state.copyWith(isSpeaking: false);
    }
  }

  /// Everything that decides how the engines are built. When this
  /// changes, the engines must be rebuilt — in place, no app restart.
  String _configSignature(PersonalProfileEntity profile,
          UgHciLabSettings lab, String conditionKey, KhayaSettings khaya) =>
      [
        profile.preferredLanguage,
        conditionKey,
        lab.provider.name,
        lab.baseUrl,
        lab.apiKey,
        lab.asrPath,
        lab.ttsPath,
        khaya.apiKey,
        khaya.speakerId,
      ].join('|');

  Future<void> _teardownEngines() async {
    await _eventSub?.cancel();
    _eventSub = null;
    await _phrasebookSub?.cancel();
    _phrasebookSub = null;
    if (_enginesBuilt) {
      _enginesBuilt = false;
      try {
        await _pipeline.dispose();
      } catch (_) {}
      try {
        _ttsEngine.dispose();
      } catch (_) {}
    }
    // The per-language translation engines must go too — on every
    // teardown, built or not. They are created lazily from the
    // settings of their moment: an engine built before a provider
    // or key was configured is the OFFLINE (en-US) fallback, and one
    // built under an old key keeps that snapshot. Leaving them
    // cached across a rebuild made Twi/Ewe translations keep being
    // read aloud by the English voice (or by a dead engine) long
    // after the provider was fixed.
    for (final engine in _ghanaTtsEngines.values) {
      try {
        engine.dispose();
      } catch (_) {}
    }
    _ghanaTtsEngines.clear();
  }

  /// Re-reads the profile and speech-provider settings and rebuilds the
  /// speech engines IN PLACE when anything relevant changed.
  ///
  /// This is what frees the user from "restart the app to apply": saving
  /// an API key, switching provider, changing language, or picking a
  /// different speech profile takes effect immediately. A refresh asked
  /// for mid-utterance is deferred until the engine is ready again, and
  /// a refresh whose configuration is unchanged is a no-op.
  Future<void> refreshConfiguration() async {
    if (_initializing || _refreshing) {
      _pendingRefresh = true;
      return;
    }
    if (state.engineState == UiEngineState.listening ||
        state.engineState == UiEngineState.processing) {
      _pendingRefresh = true;
      return;
    }
    _refreshing = true;
    try {
      final profile =
          await _profileRepository.getActiveProfile('default_user');
      final lab = await UgHciLabSettings.load();
      final khaya = await KhayaSettings.load();
      final speechProfile = await SpeechProfileSettings.load();
      if (_configSignature(profile, lab, speechProfile.conditionKey, khaya) ==
          _activeSignature) {
        return;
      }
      await _teardownEngines();
      await _initialize();
    } catch (_) {
      // Never strand the user engineless because a refresh failed.
      if (!_enginesBuilt) {
        try {
          await _initialize();
        } catch (_) {}
      }
    } finally {
      _refreshing = false;
    }
    if (_pendingRefresh) {
      _pendingRefresh = false;
      await refreshConfiguration();
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _phrasebookSub?.cancel();
    if (_enginesBuilt) {
      _pipeline.dispose();
      _ttsEngine.dispose();
    }
    try {
      _englishTts.dispose();
    } catch (_) {}
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

/// Bump this after saving a change the speech engines depend on but that
/// lives outside a Riverpod settings object (profile language, speech
/// condition). The home notifier listens and refreshes itself live.
final speechConfigRevisionProvider = StateProvider<int>((ref) => 0);

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
  // Live-apply speech settings: switching provider, saving an API key,
  // or editing endpoint paths rebuilds the engines immediately — the
  // app refreshes itself instead of asking for a restart.
  ref.listen(ugHciLabSettingsProvider, (_, next) {
    notifier.refreshConfiguration();
  });
  ref.listen(speechProfileProvider, (_, next) {
    notifier.refreshConfiguration();
  });
  ref.listen(speechConfigRevisionProvider, (_, next) {
    notifier.refreshConfiguration();
  });
  return notifier;
});
