import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/personalization/evidence_tracker.dart';
import 'package:kasa_me/speech/personalization/personalization_pipeline.dart';
import 'package:kasa_me/speech/personalization/safety_guard.dart';
import 'package:kasa_me/speech/personalization/speech_behavior.dart';

/// Regression tests for the two defects that made speech-condition
/// personalization behave differently (or not at all) depending on
/// the speech backend:
///
/// 1. EvidenceTracker used a fixed probable threshold of 3, ignoring
///    SpeechBehavior.minMappingFrequency — so the "corrections after
///    2 examples" promise for cerebral palsy / stroke / cleft was
///    dead code.
/// 2. The pipeline replaced an unavailable confidence with 0.8, which
///    broke the documented "no confidence score → probable
///    corrections apply" rule for Khaya and the offline engines.
void main() {
  group('EvidenceTracker honours the profile probable threshold', () {
    final tracker = EvidenceTracker();

    test('frequency 2 is probable when the profile threshold is 2', () {
      expect(
        tracker.shouldApplyReplacement(
          frequency: 2,
          confidence: null,
          confidenceGate: 0.95,
          probableMinFrequency: 2,
        ),
        isTrue,
      );
    });

    test('frequency 2 stays tentative under the default threshold', () {
      expect(
        tracker.shouldApplyReplacement(
          frequency: 2,
          confidence: null,
          confidenceGate: 0.95,
        ),
        isFalse,
      );
    });

    test('probable tier still respects the gate when confidence is real', () {
      // Recognizer is MORE confident than the gate → keep its word.
      expect(
        tracker.shouldApplyReplacement(
          frequency: 2,
          confidence: 0.99,
          confidenceGate: 0.95,
          probableMinFrequency: 2,
        ),
        isFalse,
      );
      // Recognizer is less confident than the gate → learned pattern wins.
      expect(
        tracker.shouldApplyReplacement(
          frequency: 2,
          confidence: 0.90,
          confidenceGate: 0.95,
          probableMinFrequency: 2,
        ),
        isTrue,
      );
    });

    test('learned tier (5+) always applies, whatever the confidence', () {
      expect(
        tracker.shouldApplyReplacement(
          frequency: 5,
          confidence: 0.99,
          confidenceGate: 0.80,
        ),
        isTrue,
      );
    });
  });

  group('Guard applies frequency-2 corrections for CP profile settings', () {
    test('applied with probableMinFrequency 2 and unknown confidence', () {
      final guard = PersonalizationSafetyGuard();
      guard.validateAndAddWordMapping('wawa', 'water', frequency: 2);
      final out = guard.applySafeReplacements(
        'I need wawa',
        baseConfidence: null,
        confidenceGate: 0.95,
        probableMinFrequency: 2,
      );
      expect(out, 'I need water');
    });

    test('not applied when the profile threshold is left at 3', () {
      final guard = PersonalizationSafetyGuard();
      guard.validateAndAddWordMapping('wawa', 'water', frequency: 2);
      final out = guard.applySafeReplacements(
        'I need wawa',
        baseConfidence: null,
        confidenceGate: 0.95,
      );
      expect(out, 'I need wawa');
    });
  });

  group('Pipeline passes unknown confidence through honestly', () {
    test('CP behavior + frequency-2 mapping + null confidence → corrected',
        () async {
      final guard = PersonalizationSafetyGuard();
      guard.validateAndAddWordMapping('wawa', 'water', frequency: 2);
      final pipeline = PersonalizationPipeline(
        guard: guard,
        behavior: SpeechBehavior.forCondition(SpeechCondition.cerebralPalsy),
      );
      final res = await pipeline.processTranscript('I need wawa');
      expect(res.personalizedTranscript, 'I need water');
      expect(res.wasPersonalized, isTrue);
    });

    test('typical behavior + frequency-2 mapping → not yet applied',
        () async {
      final guard = PersonalizationSafetyGuard();
      guard.validateAndAddWordMapping('wawa', 'water', frequency: 2);
      final pipeline = PersonalizationPipeline(
        guard: guard,
        behavior: SpeechBehavior.forCondition(SpeechCondition.typical),
      );
      final res = await pipeline.processTranscript('I need wawa');
      expect(res.personalizedTranscript, 'I need wawa');
    });
  });

  group('SpeechBehavior VAD mapping', () {
    test('typical reproduces the EnergyVad defaults', () {
      final b = SpeechBehavior.forCondition(SpeechCondition.typical);
      expect(b.vadThresholdRms, 250.0);
      expect(b.vadMaxSilenceFrames, 18);
    });

    test('patient profiles lower the threshold and wait longer', () {
      final cp = SpeechBehavior.forCondition(SpeechCondition.cerebralPalsy);
      expect(cp.vadThresholdRms, 185.0);
      expect(cp.vadMaxSilenceFrames, 24);

      final stammer = SpeechBehavior.forCondition(SpeechCondition.stammer);
      expect(stammer.vadThresholdRms, 198.0);
      expect(stammer.vadMaxSilenceFrames, 23);
      expect(stammer.vadMaxSilenceFrames,
          greaterThan(cp.vadMaxSilenceFrames - 2));
    });
  });
}
