import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/personalization/speech_behavior.dart';

/// Stammer-mode tidying. The recognizer rarely emits the tidy
/// hyphenated forms — real transcripts carry SPACED part-words and
/// phrase restarts, which the first version of the normalizer let
/// through (Dennis's field report, 2026-10-22). These tests pin the
/// real patterns AND the safety cases that must never be "cleaned".
void main() {
  group('whole-word repetitions', () {
    test('collapses immediate repeats', () {
      expect(DisfluencyNormalizer.collapse('I I I want water'),
          'I want water');
      expect(DisfluencyNormalizer.collapse('water water please'),
          'water please');
    });

    test('punctuation and case do not hide a repeat', () {
      expect(DisfluencyNormalizer.collapse('I, I, I want water'),
          'I, want water');
    });
  });

  group('hyphenated part-words (original behaviour)', () {
    test('collapses prefix chains to the full word', () {
      expect(DisfluencyNormalizer.collapse('wa-wa-water'), 'water');
      expect(DisfluencyNormalizer.collapse('m-m-me'), 'me');
      expect(DisfluencyNormalizer.collapse('t-t-today we go'),
          'today we go');
    });

    test('legitimate hyphenated words are untouched', () {
      expect(DisfluencyNormalizer.collapse('my well-known mother-in-law'),
          'my well-known mother-in-law');
    });
  });

  group('spaced part-words — the field-reported gap', () {
    test('a run of fragments before the full word collapses', () {
      expect(DisfluencyNormalizer.collapse('wa wa water'), 'water');
      expect(DisfluencyNormalizer.collapse('w w want'), 'want');
      expect(DisfluencyNormalizer.collapse('ca ca can'), 'can');
      expect(DisfluencyNormalizer.collapse('s s school'), 'school');
    });

    test('a single fragment before the full word is dropped', () {
      expect(DisfluencyNormalizer.collapse('wa water'), 'water');
      expect(DisfluencyNormalizer.collapse('th the nurse'), 'the nurse');
      expect(DisfluencyNormalizer.collapse('I wa want water'),
          'I want water');
    });

    test('hyphen fragments combine with spaced ones', () {
      expect(DisfluencyNormalizer.collapse('wa-wa water please'),
          'water please');
    });
  });

  group('phrase restarts — the other field-reported gap', () {
    test('an immediately repeated phrase collapses to one instance', () {
      expect(DisfluencyNormalizer.collapse('I want I want water'),
          'I want water');
      expect(DisfluencyNormalizer.collapse('let me let me go'),
          'let me go');
      expect(DisfluencyNormalizer.collapse('call the call the nurse'),
          'call the nurse');
    });
  });

  group('safety — fluent speech must pass through unchanged', () {
    test('complete words that begin the next word are kept', () {
      expect(DisfluencyNormalizer.collapse('we went to school'),
          'we went to school');
      expect(DisfluencyNormalizer.collapse('he held the door'),
          'he held the door');
      expect(DisfluencyNormalizer.collapse('a nurse is here'),
          'a nurse is here');
      expect(DisfluencyNormalizer.collapse('I am in school'),
          'I am in school');
      expect(DisfluencyNormalizer.collapse('to go to school'),
          'to go to school');
    });

    test('Twi function words are kept', () {
      // "na" (and/with) before "nana" (grandparent) is real Twi,
      // not a stammer fragment.
      expect(DisfluencyNormalizer.collapse('na nana'), 'na nana');
      expect(DisfluencyNormalizer.collapse('me pɛ nsuo'), 'me pɛ nsuo');
    });

    test('ordinary sentences are unchanged', () {
      expect(DisfluencyNormalizer.collapse('I want water please'),
          'I want water please');
      expect(DisfluencyNormalizer.collapse(''), '');
      expect(DisfluencyNormalizer.collapse('   '), '   ');
    });
  });
}
