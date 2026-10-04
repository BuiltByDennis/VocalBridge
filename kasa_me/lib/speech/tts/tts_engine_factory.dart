import '../ug_hci_lab/ug_hci_lab_config.dart';
import 'mock_tts_engine.dart';
import 'offline_tts_engine.dart';
import 'tts_engine.dart';
import 'ug_hci_lab_tts_engine.dart';

/// Creates the [TtsEngine] matching the user's chosen speech provider.
///
/// When the UG HCI Lab provider is selected but not configured (no API key
/// yet), it gracefully falls back to the offline engine rather than
/// leaving the app silent.
class TtsEngineFactory {
  static TtsEngine create({
    SpeechProvider provider = SpeechProvider.offline,
    UgHciLabSettings? labSettings,
    String appLanguage = 'en_GH',
    bool useMock = false,
  }) {
    if (useMock) return MockTtsEngine();

    if (provider == SpeechProvider.ugHciLab &&
        labSettings != null &&
        labSettings.isConfigured) {
      return UgHciLabTtsEngine(
        labSettings,
        language: labSettings.labLanguageCode(appLanguage),
      );
    }
    return OfflineTtsEngine();
  }
}
