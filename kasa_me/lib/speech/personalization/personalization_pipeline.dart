import 'safety_guard.dart';
import 'number_normalization.dart';
import 'personalization_repository.dart';
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

  PersonalizationPipeline({
    PersonalizationSafetyGuard? guard,
    CriticalSafetyGuard? criticalGuard,
    this.repository,
  })  : safetyGuard = guard ?? PersonalizationSafetyGuard(),
        criticalSafetyGuard = criticalGuard ?? CriticalSafetyGuard();

  Future<void> initialize(String profileId) async {
    if (repository != null) {
      final mappings = await repository!.loadActiveMappings(profileId: profileId);
      safetyGuard.hydrateMappings(mappings);
    }
  }

  Future<void> applyCorrection({
    required String original,
    required String corrected,
    required String profileId,
    int frequency = 5,
  }) async {
    final isPhrase = original.contains(' ') || corrected.contains(' ');
    
    bool added;
    if (isPhrase) {
      added = safetyGuard.validateAndAddPhraseMapping(original, corrected, frequency: frequency);
    } else {
      added = safetyGuard.validateAndAddWordMapping(original, corrected, frequency: frequency);
    }

    if (added && repository != null) {
      await repository!.recordCorrection(
        original: original,
        corrected: corrected,
        profileId: profileId,
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

    final sanitized = NumberNormalizationService.normalizeGhanainCurrencyAndNumbers(rawTranscript);
    final personalized = safetyGuard.applySafeReplacements(sanitized, baseConfidence: confidence ?? 0.8);

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
