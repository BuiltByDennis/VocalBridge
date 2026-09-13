class AsrModelConfig {
  final String id;
  final String displayName;
  final String language;
  final String encoderPath;
  final String decoderPath;
  final String joinerPath;
  final String tokensPath;
  final int sampleRate;
  final bool streaming;
  final int estimatedSizeMb;
  final bool isDefault;

  const AsrModelConfig({
    required this.id,
    required this.displayName,
    required this.language,
    required this.encoderPath,
    required this.decoderPath,
    required this.joinerPath,
    required this.tokensPath,
    this.sampleRate = 16000,
    this.streaming = true,
    this.estimatedSizeMb = 44,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'language': language,
        'encoderPath': encoderPath,
        'decoderPath': decoderPath,
        'joinerPath': joinerPath,
        'tokensPath': tokensPath,
        'sampleRate': sampleRate,
        'streaming': streaming,
        'estimatedSizeMb': estimatedSizeMb,
        'isDefault': isDefault,
      };

  factory AsrModelConfig.fromJson(Map<String, dynamic> json) {
    return AsrModelConfig(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      language: json['language'] as String,
      encoderPath: json['encoderPath'] as String,
      decoderPath: json['decoderPath'] as String,
      joinerPath: json['joinerPath'] as String,
      tokensPath: json['tokensPath'] as String,
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 16000,
      streaming: json['streaming'] as bool? ?? true,
      estimatedSizeMb: (json['estimatedSizeMb'] as num?)?.toInt() ?? 44,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
