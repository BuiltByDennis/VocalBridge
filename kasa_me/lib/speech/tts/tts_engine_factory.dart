import '../khaya/khaya_config.dart';
import '../ug_hci_lab/ug_hci_lab_config.dart';
import 'khaya_tts_engine.dart';
import 'mock_tts_engine.dart';
import 'offline_tts_engine.dart';
import 'tts_engine.dart';
import 'ug_hci_lab_tts_engine.dart';

/// Creates the [TtsEngine] matching the user's chosen speech provider.
///
/// When a cloud provider (UG HCI Lab or Khaya AI) is selected but not
/// configured (no API key yet), it gracefully falls back to the
/// offline engine rather than leaving the app silent.
class TtsEngineFactory {
  static TtsEngine create({
    SpeechProvider provider = SpeechProvider.offline,
    UgHciLabSettings? labSettings,
    KhayaSettings? khayaSettings,
    String appLanguage = 'en_GH',
    bool useMock = false,
  }) {
    if (useMock) return MockTtsEngine();

    if (provider == SpeechProvider.khaya &&
        khayaSettings != null &&
        khayaSettings.isConfigured) {
      return KhayaTtsEngine(
        khayaSettings,
        appLanguage: appLanguage,
      );
    }

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
