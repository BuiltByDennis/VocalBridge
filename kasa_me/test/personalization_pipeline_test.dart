import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/personalization/safety_guard.dart';
import 'package:kasa_me/speech/personalization/number_normalization.dart';
import 'package:kasa_me/speech/personalization/personalization_pipeline.dart';

void main() {
  test('PersonalizationSafetyGuard prevents cycles and cascading rewrites', () {
    final guard = PersonalizationSafetyGuard();

    // Valid word replacement
    expect(guard.validateAndAddWordMapping('waiter', 'water'), true);

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

  test('PersonalizationPipeline preserves rawTranscript and yields personalizedTranscript', () {
    final guard = PersonalizationSafetyGuard();
    guard.validateAndAddWordMapping('waiter', 'doctor');

    final pipeline = PersonalizationPipeline(guard: guard);
    final res = pipeline.processTranscript('I need to see the waiter');

    expect(res.rawTranscript, 'I need to see the waiter');
    expect(res.personalizedTranscript, 'I need to see the doctor');
    expect(res.wasPersonalized, true);
  });
}
