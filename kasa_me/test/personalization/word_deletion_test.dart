import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/personalization/personalization_pipeline.dart';
import 'package:kasa_me/speech/personalization/safety_guard.dart';

/// Word deletion in corrections (Dennis, 2026-10-22): the user can
/// delete a word the recognizer inserted, and the app must not speak
/// it after deletion — the word is dropped from the current message
/// AND learned, so future transcripts drop it too. Before this, an
/// empty correction was rejected at every layer (dialog, guard,
/// repository), so deletion was impossible.
void main() {
  group('Safety guard — deletion mappings', () {
    test('a taught deletion drops the word mid-sentence', () {
      final guard = PersonalizationSafetyGuard();
      expect(guard.validateAndAddWordDeletion('um', frequency: 5), isTrue);
      expect(
        guard.applySafeReplacements('I want um water',
            baseConfidence: null),
        'I want water',
      );
    });

    test('drops the word at the start and end, without a crash', () {
      final guard = PersonalizationSafetyGuard();
      guard.validateAndAddWordDeletion('um', frequency: 5);
      expect(guard.applySafeReplacements('Um I am here', baseConfidence: null),
          'I am here');
      expect(guard.applySafeReplacements('I am here um', baseConfidence: null),
          'I am here');
    });

    test('capitalized occurrences are dropped too', () {
      final guard = PersonalizationSafetyGuard();
      guard.validateAndAddWordDeletion('like', frequency: 5);
      expect(
        guard.applySafeReplacements('Like I said so', baseConfidence: null),
        'I said so',
      );
    });

    test('other words and normal corrections are unaffected', () {
      final guard = PersonalizationSafetyGuard();
      guard.validateAndAddWordDeletion('um', frequency: 5);
      guard.validateAndAddWordMapping('wawa', 'water', frequency: 5);
      expect(
        guard.applySafeReplacements('I um need wawa', baseConfidence: null),
        'I need water',
      );
      expect(
        guard.applySafeReplacements('I need water', baseConfidence: null),
        'I need water',
      );
    });

    test('deletions survive hydration (the relaunch path)', () {
      final guard = PersonalizationSafetyGuard();
      guard.hydrateMappings({
        'um': (intended: '', frequency: 5),
      });
      expect(guard.applySafeReplacements('I um go', baseConfidence: null),
          'I go');
    });

    test('blank or multi-word deletions are rejected', () {
      final guard = PersonalizationSafetyGuard();
      expect(guard.validateAndAddWordDeletion(''), isFalse);
      expect(guard.validateAndAddWordDeletion('two words'), isFalse);
    });

    test('a normal blank correction is still rejected', () {
      final guard = PersonalizationSafetyGuard();
      expect(guard.validateAndAddWordMapping('wawa', ''), isFalse);
    });
  });

  group('Pipeline — correction with an empty target deletes', () {
    test('applyCorrection teaches the deletion; later speech drops it',
        () async {
      final pipeline = PersonalizationPipeline(
        guard: PersonalizationSafetyGuard(),
      );
      await pipeline.applyCorrection(
        original: 'um',
        corrected: '',
        profileId: 'p1',
      );
      final result = await pipeline.processTranscript('I want um water');
      expect(result.personalizedTranscript, 'I want water');
    });

    test('before teaching, the word is left alone', () async {
      final pipeline = PersonalizationPipeline(
        guard: PersonalizationSafetyGuard(),
      );
      final result = await pipeline.processTranscript('I want um water');
      expect(result.personalizedTranscript, 'I want um water');
    });
  });
}
