import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/core/accessibility/accessibility_settings.dart';

void main() {
  group('AccessibilitySettings text size (WCAG 1.4.4)', () {
    test('defaults to the system text size (factor 1.0)', () {
      expect(const AccessibilitySettings().textScaleFactor, 1.0);
    });

    test('round-trips through JSON with the other settings', () {
      const s = AccessibilitySettings(
        highContrastMode: true,
        textScaleFactor: 1.4,
      );
      final back = AccessibilitySettings.fromJson(s.toJson());
      expect(back.textScaleFactor, 1.4);
      expect(back.highContrastMode, isTrue);
    });

    test('settings saved before text size existed load as 1.0', () {
      final back = AccessibilitySettings.fromJson(const {
        'autoSpeakOnTranscription': true,
      });
      expect(back.textScaleFactor, 1.0);
    });

    test('copyWith changes only the text size', () {
      const s = AccessibilitySettings(micGainMultiplier: 2.0);
      final bigger = s.copyWith(textScaleFactor: 1.3);
      expect(bigger.textScaleFactor, 1.3);
      expect(bigger.micGainMultiplier, 2.0);
    });
  });
}
