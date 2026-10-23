import 'safety_guard.dart';
import 'number_normalization.dart';
import 'personalization_repository.dart';
import 'speech_behavior.dart';
import '../safety/critical_safety_guard.dart';

class PersonalizedTranscriptResult {
  final String rawTranscript;
  final String personalizedTranscript;
  final double? confidence;
  final bool wasPersonalized;
  final bool isHighImpact;
  final List<String> flaggedTerms;

  const PersonalizedTranscriptResult({
    required this.rawTranscript,
    required this.personalizedTranscript,
    this.confidence,
    required this.wasPersonalized,
    this.isHighImpact = false,
    this.flaggedTerms = const [],
  });
}

class PersonalizationPipeline {
  final PersonalizationSafetyGuard safetyGuard;
  final CriticalSafetyGuard criticalSafetyGuard;
  final PersonalizationRepository? repository;

  /// How recognition adapts to this person (their speech condition).
  /// Set at construction; swap the pipeline to change behaviour.
  final SpeechBehavior behavior;

  PersonalizationPipeline({
    PersonalizationSafetyGuard? guard,
    CriticalSafetyGuard? criticalGuard,
    this.repository,
    SpeechBehavior? behavior,
  })  : safetyGuard = guard ?? PersonalizationSafetyGuard(),
        criticalSafetyGuard = criticalGuard ?? CriticalSafetyGuard(),
        behavior = behavior ?? SpeechBehavior.fromKey(null);

  Future<void> initialize(String profileId) async {
    if (repository != null) {
      final mappings = await repository!.loadActiveMappings(
        profileId: profileId,
        minFrequency: behavior.minMappingFrequency,
      );
      safetyGuard.hydrateMappings(mappings);
    }
  }

  /// Persists one calibration attempt so the accuracy score can reflect
  /// training (see HomeStatsNotifier). [verified] distinguishes an
  /// ASR-checked attempt (English — [matched] is meaningful) from a
  /// recorded-only sample (Twi — no recognition quota is spent checking).
  Future<void> recordCalibrationResult({
    required String profileId,
    required String targetPhrase,
    required String recognizedPhrase,
    required bool verified,
    required bool matched,
    double? confidence,
  }) async {
    await repository?.logRecognitionEvent(
      profileId: profileId,
      rawTranscript: recognizedPhrase,
      personalizedTranscript: targetPhrase,
      confidence: confidence,
      wasCorrected: verified && !matched,
      context: verified ? 'calibration' : 'calibration_recorded',
    );
  }

  Future<void> applyCorrection({
    required String original,
    required String corrected,
    required String profileId,
    int frequency = 5,
  }) async {
    final isPhrase = original.contains(' ') || corrected.contains(' ');

    bool added;
    if (corrected.trim().isEmpty) {
      // Word deletion: the user removed a word the recognizer
      // inserted. Teach it as a deletion so the word is dropped —
      // and never spoken — from now on.
      added = safetyGuard.validateAndAddWordDeletion(original, frequency: frequency);
    } else if (isPhrase) {
      added = safetyGuard.validateAndAddPhraseMapping(original, corrected, frequency: frequency);
    } else {
      added = safetyGuard.validateAndAddWordMapping(original, corrected, frequency: frequency);
    }

    if (added && repository != null) {
      await repository!.recordCorrection(
        original: original,
        corrected: corrected,
        profileId: profileId,
        frequency: frequency,
      );
    }
  }

  Future<PersonalizedTranscriptResult> processTranscript(
    String rawTranscript, {
    double? confidence,
    String language = 'en_GH',
    String context = 'general',
    String? profileId,
  }) async {
    if (rawTranscript.trim().isEmpty) {
      return PersonalizedTranscriptResult(
        rawTranscript: rawTranscript,
        personalizedTranscript: rawTranscript,
        confidence: confidence,
        wasPersonalized: false,
      );
    }

    // Stammer profile: tidy disfluencies (repeated words / part-words)
    // out FIRST, so corrections, translation and read-aloud all work on
    // what the person meant, not on the stammer.
    final fluencyCleaned = behavior.collapseRepetitions
        ? DisfluencyNormalizer.collapse(rawTranscript)
        : rawTranscript;
    final sanitized = NumberNormalizationService.normalizeGhanainCurrencyAndNumbers(fluencyCleaned);
    final personalized = safetyGuard.applySafeReplacements(
      sanitized,
      // Pass the recognizer's REAL confidence — including null.
      // Substituting 0.8 for "unknown" (the old behaviour) broke the
      // documented EvidenceTracker rule that an unavailable
      // confidence lets probable corrections apply: providers that
      // return no score (Khaya, the offline engines) behaved like a
      // fake-0.8 engine, so the same speech profile acted
      // differently on every backend.
      baseConfidence: confidence,
      confidenceGate: behavior.correctionConfidenceGate,
      probableMinFrequency: behavior.minMappingFrequency,
    );

    final wasChanged = personalized != rawTranscript;

    if (repository != null && profileId != null) {
      await repository!.logRecognitionEvent(
        profileId: profileId,
        rawTranscript: rawTranscript,
        personalizedTranscript: personalized,
        confidence: confidence,
        wasCorrected: false,
        context: context,
      );
    }

    final safetyEval = criticalSafetyGuard.evaluateTranscript(
      rawTranscript: rawTranscript,
      personalizedTranscript: personalized,
      confidence: confidence,
    );

    return PersonalizedTranscriptResult(
      rawTranscript: rawTranscript,
      personalizedTranscript: personalized,
      confidence: confidence,
      wasPersonalized: wasChanged,
      isHighImpact: safetyEval.isHighImpact,
      flaggedTerms: safetyEval.flaggedTerms,
    );
  }
}
