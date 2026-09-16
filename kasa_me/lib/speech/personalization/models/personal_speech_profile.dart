class PersonalSpeechProfile {
  final String profileId;
  final String preferredLanguage;
  final List<String> secondaryLanguages;
  final double minConfidenceThreshold;
  final bool enablePersonalVocabulary;
  final bool enablePhraseBiasing;
  final bool enableCorrectionMemory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PersonalSpeechProfile({
    required this.profileId,
    this.preferredLanguage = 'en_GH',
    this.secondaryLanguages = const [],
    this.minConfidenceThreshold = 0.6,
    this.enablePersonalVocabulary = true,
    this.enablePhraseBiasing = true,
    this.enableCorrectionMemory = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'preferredLanguage': preferredLanguage,
        'secondaryLanguages': secondaryLanguages,
        'minConfidenceThreshold': minConfidenceThreshold,
        'enablePersonalVocabulary': enablePersonalVocabulary,
        'enablePhraseBiasing': enablePhraseBiasing,
        'enableCorrectionMemory': enableCorrectionMemory,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PersonalSpeechProfile.fromJson(Map<String, dynamic> json) {
    return PersonalSpeechProfile(
      profileId: json['profileId'] as String,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en_GH',
      secondaryLanguages: (json['secondaryLanguages'] as List<dynamic>?)?.cast<String>() ?? const [],
      minConfidenceThreshold: (json['minConfidenceThreshold'] as num?)?.toDouble() ?? 0.6,
      enablePersonalVocabulary: json['enablePersonalVocabulary'] as bool? ?? true,
      enablePhraseBiasing: json['enablePhraseBiasing'] as bool? ?? true,
      enableCorrectionMemory: json['enableCorrectionMemory'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class BiasingConfig {
  final bool enabled;
  final double maxBiasWeight;
  final double minConfidenceToApply;
  final double criticalPhraseBoost;
  final double personalWordBoost;

  const BiasingConfig({
    this.enabled = true,
    this.maxBiasWeight = 3.0,
    this.minConfidenceToApply = 0.5,
    this.criticalPhraseBoost = 2.0,
    this.personalWordBoost = 1.5,
  });
}
