import 'dart:io';
import '../asr/models/asr_model_config.dart';
import '../asr/models/asr_model_registry.dart';
import '../ug_hci_lab/ug_hci_lab_config.dart';
import 'mock_speech_engine.dart';
import 'offline_sherpa_speech_engine.dart';
import 'sherpa_speech_engine.dart';
import 'speech_engine.dart';
import 'ug_hci_lab_speech_engine.dart';

class SpeechEngineFactory {
  static bool forceMock = false;

  static SpeechEngine createEngine({
    AsrModelConfig? config,
    bool? useMock,
    bool useLabApi = false,
    UgHciLabSettings? labSettings,
  }) {
    final modelConfig = config ?? AsrModelRegistry.defaultModel;
    final isMock = useMock ?? (forceMock || (!Platform.isAndroid && !Platform.isIOS));

    if (isMock) {
      return MockSpeechEngine(modelConfig);
    }

    // Hackathon-compliant path: UG HCI Lab API. Required for Ghanaian
    // languages (no bundled Twi/Ewe/Dagbani models exist in the app).
    if (useLabApi && labSettings != null && labSettings.isConfigured) {
      return UgHciLabSpeechEngine(modelConfig, labSettings);
    }

    if (modelConfig.architecture == AsrArchitecture.wav2vec2Ctc ||
        modelConfig.architecture == AsrArchitecture.whisper) {
      return OfflineSherpaSpeechEngine(modelConfig);
    }

    return SherpaSpeechEngine(modelConfig);
  }
}
