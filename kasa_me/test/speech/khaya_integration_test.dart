import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kasa_me/speech/asr/models/asr_model_registry.dart';
import 'package:kasa_me/speech/engine/khaya_speech_engine.dart';
import 'package:kasa_me/speech/engine/speech_engine_factory.dart';
import 'package:kasa_me/speech/khaya/khaya_api_error.dart';
import 'package:kasa_me/speech/khaya/khaya_config.dart';
import 'package:kasa_me/speech/tts/khaya_tts_engine.dart';
import 'package:kasa_me/speech/tts/offline_tts_engine.dart';
import 'package:kasa_me/speech/tts/tts_engine_factory.dart';
import 'package:kasa_me/speech/ug_hci_lab/ug_hci_lab_config.dart';

/// Tests for the Khaya AI (Ghana NLP) second-provider integration.
///
/// Built Oct 2026 against Khaya's published API contract (the success
/// shapes are documented this time — ASR returns {"text": ...}, TTS
/// returns raw audio), so these tests pin the contract itself, the
/// ISO 639-3 language mapping (two-letter codes are rejected by the
/// API), factory routing, and the graceful fallbacks.
void main() {
  // OfflineTtsEngine constructs a FlutterTts (platform channel) in a
  // field initializer — the binding must exist before the factory
  // routing tests can build one.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KhayaSettings', () {
    const settings = KhayaSettings(apiKey: 'key-123');

    test('language codes are ISO 639-3 (two-letter codes are rejected '
        'by the API)', () {
      expect(settings.khayaLanguageCode('twi'), 'twi');
      expect(settings.khayaLanguageCode('ewe'), 'ewe');
      expect(settings.khayaLanguageCode('dagbani'), 'dag');
      expect(settings.khayaLanguageCode('en_GH'), 'eng');
    });

    test('transcribe URI carries the explicit language', () {
      final uri = settings.transcribeUri('ewe');
      expect(uri.path, endsWith('/transcribe'));
      expect(uri.queryParameters['language'], 'ewe');
    });

    test('auth header is the APIM subscription key header', () {
      expect(settings.authHeaders(),
          {'Ocp-Apim-Subscription-Key': 'key-123'});
    });

    test('isConfigured requires a key', () {
      expect(settings.isConfigured, isTrue);
      expect(const KhayaSettings().isConfigured, isFalse);
    });

    test('JSON round-trip preserves fields and validates speaker', () {
      const original =
          KhayaSettings(apiKey: 'k', speakerId: 'female', timeoutSeconds: 90);
      final restored = KhayaSettings.fromJson(original.toJson());
      expect(restored.apiKey, 'k');
      expect(restored.speakerId, 'female');
      expect(restored.timeoutSeconds, 90);
      expect(
          KhayaSettings.fromJson({'speakerId': 'bogus'}).speakerId, '');
    });
  });

  group('SpeechProvider.khaya persistence', () {
    test('provider survives the Lab settings JSON by name', () {
      final restored = UgHciLabSettings.fromJson({'provider': 'khaya'});
      expect(restored.provider, SpeechProvider.khaya);
      expect(restored.providerLabel, 'Khaya AI (Ghana NLP)');
    });
  });

  group('KhayaApiException parsing', () {
    test('documented validation envelope with details', () {
      final e = KhayaApiException.tryParse(
        jsonEncode({
          'error': {
            'code': 'VALIDATION_FAILED',
            'message': 'Validation failed',
            'details': [
              {
                'code': 'UNSUPPORTED_LANGUAGE',
                'target': 'language',
                'message': "Use 'twi' instead",
              }
            ],
          }
        }),
        400,
      );
      expect(e, isNotNull);
      expect(e!.isValidation, isTrue);
      expect(e.details, ["Use 'twi' instead"]);
      expect(e.userMessage, contains("Use 'twi' instead"));
    });

    test('Azure APIM auth shape', () {
      final e = KhayaApiException.tryParse(
        jsonEncode({
          'statusCode': 401,
          'message': 'Access denied due to missing subscription key.',
        }),
        401,
      );
      expect(e, isNotNull);
      expect(e!.isAuth, isTrue);
      expect(e.userMessage, contains('rejected the API key'));
    });

    test('success body is not an error', () {
      expect(
          KhayaApiException.tryParse('{"text": "akwaaba"}', 200), isNull);
    });
  });

  group('Khaya ASR transcript parsing', () {
    test('documented flat text shape', () {
      expect(
          KhayaSpeechEngine.parseKhayaTranscript(
              '{"text": "Me pɛ aduane"}'),
          'Me pɛ aduane');
    });

    test('text with timings block', () {
      expect(
          KhayaSpeechEngine.parseKhayaTranscript(
              '{"text": "akwaaba", "timings": {"unit": "seconds"}}'),
          'akwaaba');
    });

    test('error envelope yields no transcript', () {
      expect(
          KhayaSpeechEngine.parseKhayaTranscript(
              '{"error": {"code": "SYSTEM_ERROR", "message": "boom"}}'),
          isEmpty);
    });

    test('unexpected nesting falls back to the deep search', () {
      expect(
          KhayaSpeechEngine.parseKhayaTranscript(
              '{"data": {"transcript": "medaase"}}'),
          'medaase');
    });

    test('plain-text body is the transcript', () {
      expect(KhayaSpeechEngine.parseKhayaTranscript('Me din de Ama'),
          'Me din de Ama');
    });
  });

  group('KhayaTtsEngine', () {
    final engine = KhayaTtsEngine(
      const KhayaSettings(apiKey: 'k', speakerId: 'female'),
      appLanguage: 'twi',
    );

    test('request body follows the documented synthesize shape', () {
      final body = engine.buildRequestBody('Wo ho te sɛn?');
      expect(body['text'], 'Wo ho te sɛn?');
      expect(body['language'], 'twi');
      expect(body['speaker_id'], 'female');
      expect(body['format'], 'wav');
    });

    test('speaker_id is omitted when set to the default voice', () {
      final defaultEngine = KhayaTtsEngine(
        const KhayaSettings(apiKey: 'k'),
        appLanguage: 'ewe',
      );
      final body = defaultEngine.buildRequestBody('Ŋdi na wò');
      expect(body.containsKey('speaker_id'), isFalse);
      expect(body['language'], 'ewe');
    });

    test('chunkText splits long text under the cap', () {
      const sentence = 'Me pɛ aduane ne nsuo. ';
      final chunks = KhayaTtsEngine.chunkText(sentence * 60);
      expect(chunks.length, greaterThan(1));
      for (final c in chunks) {
        expect(c.length, lessThanOrEqualTo(KhayaTtsEngine.maxCharsPerRequest));
        expect(c.trim(), isNotEmpty);
      }
    });

    test('chunkText passes short text through untouched', () {
      expect(KhayaTtsEngine.chunkText('Akwaaba'), ['Akwaaba']);
    });

    final wavBytes = Uint8List.fromList(
        [0x52, 0x49, 0x46, 0x46, ...List.filled(64, 7)]);

    test('raw WAV is accepted even with a non-audio content-type',
        () {
      final response = http.Response.bytes(wavBytes, 200,
          headers: {'content-type': 'application/octet-stream'});
      final (bytes, ext) = engine.extractAudio(response);
      expect(ext, 'wav');
      expect(bytes, wavBytes);
    });

    test('JSON error envelope surfaces the Khaya error', () {
      final response = http.Response(
        jsonEncode({
          'error': {'code': 'SYSTEM_ERROR', 'message': 'boom'}
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
      expect(() => engine.extractAudio(response),
          throwsA(isA<KhayaApiException>()));
    });
  });

  group('Factory routing', () {
    const configured = KhayaSettings(apiKey: 'k');

    test('TTS factory builds Khaya when selected and configured', () {
      final engine = TtsEngineFactory.create(
        provider: SpeechProvider.khaya,
        khayaSettings: configured,
        appLanguage: 'twi',
      );
      expect(engine, isA<KhayaTtsEngine>());
    });

    test('TTS factory falls back to offline when Khaya has no key',
        () {
      final engine = TtsEngineFactory.create(
        provider: SpeechProvider.khaya,
        khayaSettings: const KhayaSettings(),
      );
      expect(engine, isA<OfflineTtsEngine>());
    });

    test('ASR factory builds Khaya when requested and configured', () {
      final engine = SpeechEngineFactory.createEngine(
        config: AsrModelRegistry.defaultModel,
        useMock: false,
        useKhayaApi: true,
        khayaSettings: configured,
      );
      expect(engine, isA<KhayaSpeechEngine>());
    });

    test('ASR factory does not build Khaya without a key', () {
      final engine = SpeechEngineFactory.createEngine(
        config: AsrModelRegistry.defaultModel,
        useMock: false,
        useKhayaApi: true,
        khayaSettings: const KhayaSettings(),
      );
      expect(engine, isNot(isA<KhayaSpeechEngine>()));
    });
  });
}
