import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/translation/dictionary_translation_service.dart';

void main() {
  final t = DictionaryTranslationService();

  group('curated phrases', () {
    test('exact Twi phrase translates', () {
      expect(t.translate('Me pɛ nsuo', from: 'twi', to: 'en_GH'),
          'I would like some water');
    });

    test('diacritic-free ASR output still matches (folded keys)', () {
      expect(t.translate('me ho ye me hye', from: 'twi', to: 'en_GH'),
          'I feel feverish');
    });

    test('joined-word ASR output matches (space-insensitive)', () {
      expect(t.translate('mepɛ aduro', from: 'twi', to: 'en_GH'),
          'I need medicine');
    });

    test('intensifier around a known phrase still matches', () {
      expect(t.translate('Me pɛ nsuo paa', from: 'twi', to: 'en_GH'),
          'I would like some water');
    });
  });

  group('the app\u2019s own seeded phrases must translate', () {
    final seeded = {
      'I need water': isNotNull,
      'I need help': isNotNull,
      'I am in pain': 'me ho yɛ me ya',
      'Please call my mother': isNotNull,
      'I need to see the doctor': 'me pɛ hu dokota',
      'Where is the bank': 'bank no wɔ he',
      'I want to withdraw money': 'me pɛ twe sika',
    };
    seeded.forEach((en, expected) {
      test('"$en" has a Twi gloss', () {
        expect(t.translate(en, from: 'en_GH', to: 'twi'), expected);
      });
    });
  });

  group('word gloss layers', () {
    test('full-coverage composition works for new simple sentences', () {
      expect(t.translate('I need some water please', from: 'en_GH', to: 'twi'),
          isNotNull);
    });

    test('partial gloss carries unknown words through, never invents', () {
      final r = t.translate('my head hurts', from: 'en_GH', to: 'twi');
      expect(r, isNotNull);
      expect(r, contains('tiri')); // head glossed
      expect(r, contains('hurts')); // unknown word visible, not fabricated
      expect(r, isNot(contains('nsa'))); // NOT misread as "my hand hurts"
    });

    test('true gibberish still returns null — no guessing', () {
      expect(t.translate('quantum physics lecture', from: 'en_GH', to: 'twi'),
          isNull);
      expect(t.translate('abɔnten so nnoɔma', from: 'twi', to: 'en_GH'),
          isNull);
    });

    test('unsupported pairs return null', () {
      expect(t.translate('Me pɛ nsuo', from: 'twi', to: 'ewe'), isNull);
    });
  });
}
