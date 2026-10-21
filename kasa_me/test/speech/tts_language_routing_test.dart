import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/khaya/khaya_config.dart';
import 'package:kasa_me/speech/tts/khaya_tts_engine.dart';
import 'package:kasa_me/speech/tts/offline_tts_engine.dart';
import 'package:kasa_me/speech/tts/tts_engine_factory.dart';
import 'package:kasa_me/speech/tts/ug_hci_lab_tts_engine.dart';
import 'package:kasa_me/speech/ug_hci_lab/ug_hci_lab_config.dart';

/// Every voice in the app must speak the language of the text it is
/// given: English as English, Twi as Twi, Ewe as Ewe.
///
/// Regression history: v1.3.2 fixed translation engines cached across
/// settings changes (Twi read by an English voice). The remaining
/// hole was structural — OfflineTtsEngine hardwired the system voice
/// to en-US and the factory dropped the language when falling back
/// to it, so ANY offline-fallback speak of Ghanaian text (phrasebook
/// taps before a cloud key is configured, translation engines) came
/// out in an American English voice. These tests pin the routing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineTtsEngine language mapping', () {
    test('each app language maps to its own BCP-47 voice code', () {
      expect(OfflineTtsEngine.languageCodeFor('en_GH'), 'en-US');
      expect(OfflineTtsEngine.languageCodeFor('en'), 'en-US');
      expect(OfflineTtsEngine.languageCodeFor('twi'), 'tw-GH');
      expect(OfflineTtsEngine.languageCodeFor('ewe'), 'ee-GH');
    });

    test('the dedicated English engine defaults to English', () {
      expect(OfflineTtsEngine().ttsLanguage, 'en-US');
      expect(OfflineTtsEngine().appLanguage, 'en_GH');
    });
  });

  group('Factory — offline provider keeps the text language', () {
    test('Twi text gets a Twi offline engine, not the English one', () {
      final engine = TtsEngineFactory.create(appLanguage: 'twi');
      expect(engine, isA<OfflineTtsEngine>());
      expect((engine as OfflineTtsEngine).ttsLanguage, 'tw-GH');
    });

    test('Ewe text gets an Ewe offline engine', () {
      final engine = TtsEngineFactory.create(appLanguage: 'ewe');
      expect(engine, isA<OfflineTtsEngine>());
      expect((engine as OfflineTtsEngine).ttsLanguage, 'ee-GH');
    });

    test('English text gets the English offline engine', () {
      final engine = TtsEngineFactory.create(appLanguage: 'en_GH');
      expect(engine, isA<OfflineTtsEngine>());
      expect((engine as OfflineTtsEngine).ttsLanguage, 'en-US');
    });
  });

  group('Factory — unconfigured cloud falls back in the SAME language',
      () {
    test('Khaya selected without a key: Ewe falls back as Ewe', () {
      final engine = TtsEngineFactory.create(
        provider: SpeechProvider.khaya,
        khayaSettings: const KhayaSettings(),
        appLanguage: 'ewe',
      );
      expect(engine, isA<OfflineTtsEngine>());
      expect((engine as OfflineTtsEngine).ttsLanguage, 'ee-GH');
    });

    test('Lab selected without a key: Twi falls back as Twi', () {
      final engine = TtsEngineFactory.create(
        provider: SpeechProvider.ugHciLab,
        labSettings: const UgHciLabSettings(),
        appLanguage: 'twi',
      );
      expect(engine, isA<OfflineTtsEngine>());
      expect((engine as OfflineTtsEngine).ttsLanguage, 'tw-GH');
    });
  });

  group('Factory — configured cloud engines carry their language', () {
    test('Khaya builds for Twi and for Ewe', () {
      const khaya = KhayaSettings(apiKey: 'k');
      expect(
        TtsEngineFactory.create(
          provider: SpeechProvider.khaya,
          khayaSettings: khaya,
          appLanguage: 'twi',
        ),
        isA<KhayaTtsEngine>(),
      );
      expect(
        TtsEngineFactory.create(
          provider: SpeechProvider.khaya,
          khayaSettings: khaya,
          appLanguage: 'ewe',
        ),
        isA<KhayaTtsEngine>(),
      );
    });

    test('Lab builds for Twi and for Ewe', () {
      const lab = UgHciLabSettings(
        provider: SpeechProvider.ugHciLab,
        apiKey: 'k',
      );
      expect(
        TtsEngineFactory.create(
          provider: SpeechProvider.ugHciLab,
          labSettings: lab,
          appLanguage: 'twi',
        ),
        isA<UgHciLabTtsEngine>(),
      );
      expect(
        TtsEngineFactory.create(
          provider: SpeechProvider.ugHciLab,
          labSettings: lab,
          appLanguage: 'ewe',
        ),
        isA<UgHciLabTtsEngine>(),
      );
    });
  });
}
