enum AppLanguage {
  englishGhana,
  twi,
  ewe,
  dagbani,
}

class LanguageConfig {
  final AppLanguage id;
  final String code;
  final String displayName;
  final String nativeName;
  final bool enabled;
  final bool isExperimental;

  const LanguageConfig({
    required this.id,
    required this.code,
    required this.displayName,
    required this.nativeName,
    this.enabled = false,
    this.isExperimental = true,
  });
}

class LanguageRegistry {
  static const List<LanguageConfig> supportedLanguages = [
    LanguageConfig(
      id: AppLanguage.englishGhana,
      code: 'en_GH',
      displayName: 'English (Ghana)',
      nativeName: 'English (Ghana)',
      enabled: true,
      isExperimental: false,
    ),
    LanguageConfig(
      id: AppLanguage.twi,
      code: 'twi',
      displayName: 'Twi',
      nativeName: 'Twi',
      enabled: false,
      isExperimental: true,
    ),
    LanguageConfig(
      id: AppLanguage.ewe,
      code: 'ewe',
      displayName: 'Ewe',
      nativeName: 'Eʋegbe',
      enabled: false,
      isExperimental: true,
    ),
    LanguageConfig(
      id: AppLanguage.dagbani,
      code: 'dagbani',
      displayName: 'Dagbani',
      nativeName: 'Dagbani',
      enabled: false,
      isExperimental: true,
    ),
  ];
}
