import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/connectivity/network_mode.dart';
import 'package:kasa_me/speech/ug_hci_lab/ug_hci_lab_config.dart';

/// Automatic offline ⇄ online switching (Dennis, 2026-10-22): Khaya
/// is the online mode — no network means the engines are built
/// offline, and they return to Khaya by themselves when the network
/// does. Khaya ONLY: Lab and explicit-offline selections are never
/// overridden.
void main() {
  group('isOnlineConnectivity', () {
    test('any live interface counts as online', () {
      expect(isOnlineConnectivity([ConnectivityResult.wifi]), isTrue);
      expect(isOnlineConnectivity([ConnectivityResult.mobile]), isTrue);
      expect(
          isOnlineConnectivity(
              [ConnectivityResult.none, ConnectivityResult.wifi]),
          isTrue);
    });

    test('none — or an empty report — is offline', () {
      expect(isOnlineConnectivity([ConnectivityResult.none]), isFalse);
      expect(isOnlineConnectivity(const []), isFalse);
    });
  });

  group('effectiveSpeechProvider', () {
    test('Khaya + configured + offline falls back to offline', () {
      expect(
        effectiveSpeechProvider(
          selected: SpeechProvider.khaya,
          khayaConfigured: true,
          online: false,
        ),
        SpeechProvider.offline,
      );
    });

    test('Khaya + configured + online stays Khaya', () {
      expect(
        effectiveSpeechProvider(
          selected: SpeechProvider.khaya,
          khayaConfigured: true,
          online: true,
        ),
        SpeechProvider.khaya,
      );
    });

    test('Khaya without a key is untouched (factory fallback decides)',
        () {
      expect(
        effectiveSpeechProvider(
          selected: SpeechProvider.khaya,
          khayaConfigured: false,
          online: false,
        ),
        SpeechProvider.khaya,
      );
    });

    test('the Lab selection is never auto-switched', () {
      expect(
        effectiveSpeechProvider(
          selected: SpeechProvider.ugHciLab,
          khayaConfigured: true,
          online: false,
        ),
        SpeechProvider.ugHciLab,
      );
    });

    test('an explicit Offline selection stays offline when online', () {
      expect(
        effectiveSpeechProvider(
          selected: SpeechProvider.offline,
          khayaConfigured: true,
          online: true,
        ),
        SpeechProvider.offline,
      );
    });
  });

  group('effectiveSpeechLanguage — automatic English fallback', () {
    test('offline + Twi falls back to English', () {
      expect(
        effectiveSpeechLanguage(
          profileLanguage: 'twi',
          effectiveProvider: SpeechProvider.offline,
        ),
        'en_GH',
      );
    });

    test('offline + Ewe falls back to English', () {
      expect(
        effectiveSpeechLanguage(
          profileLanguage: 'ewe',
          effectiveProvider: SpeechProvider.offline,
        ),
        'en_GH',
      );
    });

    test('Khaya online keeps the Ghanaian language', () {
      expect(
        effectiveSpeechLanguage(
          profileLanguage: 'twi',
          effectiveProvider: SpeechProvider.khaya,
        ),
        'twi',
      );
    });

    test('English stays English in every mode', () {
      expect(
        effectiveSpeechLanguage(
          profileLanguage: 'en_GH',
          effectiveProvider: SpeechProvider.offline,
        ),
        'en_GH',
      );
    });
  });
}
