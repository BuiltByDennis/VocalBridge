import 'safety_guard.dart';
import 'number_normalization.dart';

class PersonalizedTranscriptResult {
  final String rawTranscript;
  final String personalizedTranscript;
  final double? confidence;
  final bool wasPersonalized;

  const PersonalizedTranscriptResult({
    required this.rawTranscript,
    required this.personalizedTranscript,
    this.confidence,
    required this.wasPersonalized,
  });
}

class PersonalizationPipeline {
  final PersonalizationSafetyGuard safetyGuard;

  PersonalizationPipeline({PersonalizationSafetyGuard? guard})
      : safetyGuard = guard ?? PersonalizationSafetyGuard();

  PersonalizedTranscriptResult processTranscript(
    String rawTranscript, {
    double? confidence,
    String language = 'en_GH',
    String context = 'general',
  }) {
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

    return PersonalizedTranscriptResult(
      rawTranscript: rawTranscript,
      personalizedTranscript: personalized,
      confidence: confidence,
      wasPersonalized: wasChanged,
    );
  }
}
