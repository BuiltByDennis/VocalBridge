import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/translation/dictionary_translation_service.dart';

/// The v1.3.7 gloss expansion (Dennis asked for more Twi and Ewe
/// gloss): 21 new care phrases in each language — more body parts,
/// daily needs, family, market — translating in BOTH directions.
void main() {
  final t = DictionaryTranslationService();

  group('expanded Twi gloss', () {
    test('new phrases translate Twi → English', () {
      expect(t.translate('me nkotodwe yɛ me ya', from: 'twi', to: 'en_GH'),
          'My knee hurts');
      expect(t.translate('sukɔm de me', from: 'twi', to: 'en_GH'),
          'I am thirsty');
      expect(t.translate('me pɛ kɔ fie', from: 'twi', to: 'en_GH'),
          'I want to go home');
      expect(t.translate('boa me ntem', from: 'twi', to: 'en_GH'),
          'Help me quickly');
    });

    test('new phrases translate English → Twi', () {
      expect(t.translate('My eye hurts', from: 'en_GH', to: 'twi'),
          'me ani yɛ me ya');
      expect(t.translate('Turn off the light', from: 'en_GH', to: 'twi'),
          'kum kanea no');
      expect(t.translate('Where is the market?', from: 'en_GH', to: 'twi'),
          'dwa no wɔ he');
    });
  });

  group('expanded Ewe gloss', () {
    test('new phrases translate Ewe → English', () {
      expect(t.translate('ŋku le ve nam', from: 'ewe', to: 'en_GH'),
          'My eye hurts');
      expect(t.translate('tsikɔ le wum', from: 'ewe', to: 'en_GH'),
          'I am thirsty');
      expect(t.translate('mehiã be mayi aƒe me', from: 'ewe', to: 'en_GH'),
          'I want to go home');
      expect(t.translate('va kaba', from: 'ewe', to: 'en_GH'),
          'Come quickly');
    });

    test('new phrases translate English → Ewe', () {
      expect(t.translate('My knee hurts', from: 'en_GH', to: 'ewe'),
          'klo le ve nam');
      expect(t.translate('Open the door', from: 'en_GH', to: 'ewe'),
          'ʋu ʋɔtru la');
      expect(t.translate('I forgot', from: 'en_GH', to: 'ewe'), 'meŋlɔ be');
    });
  });
}
