import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/personalization/safety_guard.dart';
import 'package:kasa_me/speech/personalization/number_normalization.dart';
import 'package:kasa_me/speech/personalization/personalization_pipeline.dart';

void main() {
  test('PersonalizationSafetyGuard prevents cycles and cascading rewrites', () {
    final guard = PersonalizationSafetyGuard();

    // Valid word replacement. Frequency 5 is the "learned" tier —
    // the frequency PersonalizationPipeline.applyCorrection uses for
    // corrections the person explicitly teaches. (At the default
    // frequency of 1 a mapping is only tentative and, by design,
    // never auto-applies; no production caller adds one that low.)
    expect(
        guard.validateAndAddWordMapping('waiter', 'water', frequency: 5),
        true);

    // Cycle attempt (water -> waiter)
    expect(guard.validateAndAddWordMapping('water', 'waiter'), false);

    // Cascading chain attempt (water -> doctor)
    expect(guard.validateAndAddWordMapping('water', 'doctor'), false);

    // Replacement application
    final output = guard.applySafeReplacements('I need to see the waiter');
    expect(output, 'I need to see the water');
  });

  test('NumberNormalizationService formats Ghanaian monetary expressions', () {
    final formatted = NumberNormalizationService.normalizeGhanainCurrencyAndNumbers('send fifty Ghana cedis via momo');
    expect(formatted, 'send fifty GH₵ via MoMo');
  });

  test('PersonalizationPipeline preserves rawTranscript and yields personalizedTranscript', () async {
    final guard = PersonalizationSafetyGuard();
    // Frequency 5 = learned tier, as taught corrections are recorded.
    guard.validateAndAddWordMapping('waiter', 'doctor', frequency: 5);

    final pipeline = PersonalizationPipeline(guard: guard);
    final res = await pipeline.processTranscript('I need to see the waiter');

    expect(res.rawTranscript, 'I need to see the waiter');
    expect(res.personalizedTranscript, 'I need to see the doctor');
    expect(res.wasPersonalized, true);
  });
}
