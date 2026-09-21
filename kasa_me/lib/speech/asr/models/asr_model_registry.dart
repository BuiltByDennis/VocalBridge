import 'asr_model_config.dart';

class AsrModelRegistry {
  static const AsrModelConfig defaultEnglishModel = AsrModelConfig(
    id: 'english_edge_v1',
    displayName: 'English (Ghana) Whisper Tiny',
    language: 'en_GH',
    architecture: AsrArchitecture.whisper,
    encoderPath: 'assets/models/asr/english/whisper-tiny/tiny.en-encoder.int8.onnx',
    decoderPath: 'assets/models/asr/english/whisper-tiny/tiny.en-decoder.int8.onnx',
    tokensPath: 'assets/models/asr/english/whisper-tiny/tiny.en-tokens.txt',
    sampleRate: 16000,
    streaming: false,
    estimatedSizeMb: 75,
    isDefault: true,
  );

  static const AsrModelConfig twiModel = AsrModelConfig(
    id: 'twi_ugakan_hf_v1',
    displayName: 'Twi (Akan) - HuggingFace Wav2Vec2',
    language: 'twi',
    architecture: AsrArchitecture.wav2vec2Ctc,
    modelPath: 'assets/models/asr/twi/model.onnx',
    tokensPath: 'assets/models/asr/twi/tokens.txt',
    sampleRate: 16000,
    streaming: false,
    estimatedSizeMb: 1200,
    isDefault: false,
  );

  static const AsrModelConfig eweModel = AsrModelConfig(
    id: 'ewe_edge_v1',
    displayName: 'Ewe (UG Dataset) Edge v1',
    language: 'ewe',
    encoderPath: 'assets/models/asr/ewe/encoder.onnx',
    decoderPath: 'assets/models/asr/ewe/decoder.onnx',
    joinerPath: 'assets/models/asr/ewe/joiner.onnx',
    tokensPath: 'assets/models/asr/ewe/tokens.txt',
    sampleRate: 16000,
    streaming: true,
    estimatedSizeMb: 45,
    isDefault: false,
  );

  static const AsrModelConfig dagbaniModel = AsrModelConfig(
    id: 'dagbani_edge_v1',
    displayName: 'Dagbani (UG Dataset) Edge v1',
    language: 'dagbani',
    encoderPath: 'assets/models/asr/dagbani/encoder.onnx',
    decoderPath: 'assets/models/asr/dagbani/decoder.onnx',
    joinerPath: 'assets/models/asr/dagbani/joiner.onnx',
    tokensPath: 'assets/models/asr/dagbani/tokens.txt',
    sampleRate: 16000,
    streaming: true,
    estimatedSizeMb: 45,
    isDefault: false,
  );

  static final List<AsrModelConfig> _registry = [
    defaultEnglishModel,
    twiModel,
    eweModel,
    dagbaniModel,
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
