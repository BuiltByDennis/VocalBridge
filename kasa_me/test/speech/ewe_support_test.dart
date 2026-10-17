import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/language/language_registry.dart';
import 'package:kasa_me/speech/asr/models/asr_model_registry.dart';
import 'package:kasa_me/speech/calibration/calibration_service.dart';
import 'package:kasa_me/speech/engine/khaya_speech_engine.dart';
import 'package:kasa_me/speech/engine/speech_engine_factory.dart';
import 'package:kasa_me/speech/engine/ug_hci_lab_speech_engine.dart';
import 'package:kasa_me/speech/khaya/khaya_config.dart';
import 'package:kasa_me/speech/translation/dictionary_translation_service.dart';
import 'package:kasa_me/speech/translation/ewe_phrase_data.dart';
import 'package:kasa_me/speech/translation/twi_phrase_data.dart';
import 'package:kasa_me/speech/tts/khaya_tts_engine.dart';
import 'package:kasa_me/speech/tts/tts_engine_factory.dart';
import 'package:kasa_me/speech/ug_hci_lab/ug_hci_lab_config.dart';

/// Ewe opened with the FULL Twi feature set (2026-10-17): phrase data,
/// dictionary both directions, phrasebook seed source, record-only
/// calibration, and routing through BOTH cloud providers. These tests
/// pin the parity so Ewe can never silently fall behind Twi again.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EwePhraseData parity with TwiPhraseData', () {
    test('covers the same English care phrases as Twi', () {
      final twiEnglish =
          TwiPhraseData.phrases.map((p) => p.english).toSet();
      final eweEnglish =
          EwePhraseData.phrases.map((p) => p.english).toSet();
      expect(eweEnglish, twiEnglish);
    });

    test('uses the same categories as Twi', () {
      final twiCats = TwiPhraseData.phrases.map((p) => p.category).toSet();
      final eweCats = EwePhraseData.phrases.map((p) => p.category).toSet();
      expect(eweCats, twiCats);
    });

    test('every phrase is complete and the set is substantial', () {
      expect(EwePhraseData.phrases.length, greaterThanOrEqualTo(60));
      for (final p in EwePhraseData.phrases) {
        expect(p.ewe.trim(), isNotEmpty);
        expect(p.english.trim(), isNotEmpty);
        expect(p.category.trim(), isNotEmpty);
      }
    });

    test('calibration set mirrors Twi in size', () {
      expect(EwePhraseData.calibrationSet.length,
          TwiPhraseData.calibrationSet.length);
      expect(EwePhraseData.calibrationSet.length,
          greaterThanOrEqualTo(12));
    });
  });

  group('Dictionary translation — Ewe pairs', () {
    final service = DictionaryTranslationService();

    test('supports Ewe pairs both directions, not Dagbani', () {
      expect(service.supportsPair('ewe', 'en_GH'), isTrue);
      expect(service.supportsPair('en_GH', 'ewe'), isTrue);
      expect(service.supportsPair('dagbani', 'en_GH'), isFalse);
    });

    test('exact curated phrase, Ewe → English', () {
      expect(service.translate('Mehiã tsi', from: 'ewe', to: 'en_GH'),
          'I would like some water');
      expect(service.translate('Akpe kaka', from: 'ewe', to: 'en_GH'),
          'Thank you very much');
      expect(service.translate('Kpe ɖe ŋunye', from: 'ewe', to: 'en_GH'),
          'Help me');
    });

    test('ASCII-folded recognition output still finds its phrase', () {
      // Recognizers drop ŋ/ɖ/ã — the phrase must still match.
      expect(service.translate('mehia tsi', from: 'ewe', to: 'en_GH'),
          'I would like some water');
      expect(service.translate('kpe de ngunye', from: 'ewe', to: 'en_GH'),
          'Help me');
    });

    test('exact curated phrase, English → Ewe', () {
      // Values come back in the phrase data's stored form (lowercase,
      // exactly as Twi's do).
      expect(service.translate('I need medicine', from: 'en_GH', to: 'ewe'),
          'mehiã atike');
      expect(service.translate('Help me', from: 'en_GH', to: 'ewe'),
          'kpe ɖe ŋunye');
    });

    test('a hand is never glossed as a head (strictness carries over)',
        () {
      expect(service.translate('Asi le ve nam', from: 'ewe', to: 'en_GH'),
          'My hand hurts');
      expect(service.translate('Ta le ve nam', from: 'ewe', to: 'en_GH'),
          'I have a headache');
    });

    test('unknown Ewe returns null — never an invented translation', () {
      expect(
          service.translate('nyemede ame aɖeke o fifi',
              from: 'ewe', to: 'en_GH'),
          isNull);
    });
  });

  group('Calibration — Ewe record-only set', () {
    test('phrasesForLanguage returns the Ewe calibration set', () {
      final phrases = CalibrationService.phrasesForLanguage('ewe');
      expect(phrases.length, EwePhraseData.calibrationSet.length);
      expect(phrases, contains('kpe ɖe ŋunye'));
      expect(phrases, contains('mehiã tsi'));
    });

    test('Twi and English calibration sets are unchanged', () {
      expect(CalibrationService.phrasesForLanguage('twi').length,
          TwiPhraseData.calibrationSet.length);
      expect(CalibrationService.phrasesForLanguage('en_GH'),
          CalibrationService.calibrationPhrases);
    });
  });

  group('Registry — Ewe enabled, Dagbani still off', () {
    test('language flags tell the truth', () {
      final byCode = {
        for (final l in LanguageRegistry.supportedLanguages) l.code: l
      };
      expect(byCode['twi']!.enabled, isTrue);
      expect(byCode['ewe']!.enabled, isTrue);
      expect(byCode['dagbani']!.enabled, isFalse);
    });
  });

  group('Provider routing — Ewe through BOTH providers', () {
    const khaya = KhayaSettings(apiKey: 'k');
    const lab = UgHciLabSettings(
      provider: SpeechProvider.ugHciLab,
      apiKey: 'k',
    );
    final eweConfig = AsrModelRegistry.getModelForLanguage('ewe')!;

    test('Khaya language code for Ewe is the ISO 639-3 code', () {
      expect(const KhayaSettings().khayaLanguageCode('ewe'), 'ewe');
      expect(eweConfig.language, 'ewe');
    });

    test('ASR factory builds Khaya for Ewe', () {
      final engine = SpeechEngineFactory.createEngine(
        config: eweConfig,
        useMock: false,
        useKhayaApi: true,
        khayaSettings: khaya,
      );
      expect(engine, isA<KhayaSpeechEngine>());
    });

    test('ASR factory builds the Lab engine for Ewe', () {
      final engine = SpeechEngineFactory.createEngine(
        config: eweConfig,
        useMock: false,
        useLabApi: true,
        labSettings: lab,
      );
      expect(engine, isA<UgHciLabSpeechEngine>());
    });

    test('TTS factory builds Khaya for Ewe', () {
      final engine = TtsEngineFactory.create(
        provider: SpeechProvider.khaya,
        khayaSettings: khaya,
        appLanguage: 'ewe',
      );
      expect(engine, isA<KhayaTtsEngine>());
    });
  });
}
