import 'asr_model_config.dart';

class AsrModelRegistry {
  static const AsrModelConfig defaultEnglishModel = AsrModelConfig(
    id: 'english_edge_v1',
    displayName: 'English (Ghana) Edge Zipformer v1',
    language: 'en_GH',
    encoderPath: 'assets/models/asr/english/encoder.onnx',
    decoderPath: 'assets/models/asr/english/decoder.onnx',
    joinerPath: 'assets/models/asr/english/joiner.onnx',
    tokensPath: 'assets/models/asr/english/tokens.txt',
    sampleRate: 16000,
    streaming: true,
    estimatedSizeMb: 44,
    isDefault: true,
  );

  static final List<AsrModelConfig> _registry = [
    defaultEnglishModel,
  ];

  static List<AsrModelConfig> get availableModels => List.unmodifiable(_registry);

  static AsrModelConfig get defaultModel => defaultEnglishModel;

  static AsrModelConfig? getModelById(String id) {
    try {
      return _registry.firstWhere((model) => model.id == id);
    } catch (_) {
      return null;
    }
  }

  static AsrModelConfig? getModelForLanguage(String language) {
    try {
      return _registry.firstWhere((model) => model.language == language);
    } catch (_) {
      return null;
    }
  }

  static void registerModel(AsrModelConfig model) {
    final index = _registry.indexWhere((m) => m.id == model.id);
    if (index >= 0) {
      _registry[index] = model;
    } else {
      _registry.add(model);
    }
  }
}
