import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kasa_me/speech/engine/ug_hci_lab_speech_engine.dart';
import 'package:kasa_me/speech/tts/ug_hci_lab_tts_engine.dart';
import 'package:kasa_me/speech/ug_hci_lab/lab_api_error.dart';
import 'package:kasa_me/speech/ug_hci_lab/ug_hci_lab_config.dart';

/// Response-handling tests for the UG HCI Lab engines.
///
/// Written after the Oct 2026 field report: requests succeeded on the
/// Lab's dashboard (HTTP 200) while the app showed an empty
/// transcript and played no audio. The old code read only top-level
/// ASR keys and trusted the TTS Content-Type header; these tests pin
/// the hardened behaviour — deep JSON search for ASR, byte-sniffing
/// for TTS — so the shapes that failed in the field stay fixed.
void main() {
  group('Lab ASR transcript parsing', () {
    test('flat transcript key (the documented guess)', () {
      final (text, _) = UgHciLabSpeechEngine.parseTranscript(
          '{"transcript": "Me pɛ aduane", "confidence": 0.87}');
      expect(text, 'Me pɛ aduane');
    });

    test('confidence is read at the top level', () {
      final (_, confidence) = UgHciLabSpeechEngine.parseTranscript(
          '{"transcript": "akwaaba", "confidence": 0.5}');
      expect(confidence, 0.5);
    });

    test('transcript nested under a data envelope', () {
      final (text, _) = UgHciLabSpeechEngine.parseTranscript(
          '{"status": "success", "data": {"transcript": "Wo ho te sɛn?"}}');
      expect(text, 'Wo ho te sɛn?');
    });

    test('text nested under a result envelope', () {
      final (text, _) = UgHciLabSpeechEngine.parseTranscript(
          '{"request_id": "req_1", "result": {"text": "medaase"}}');
      expect(text, 'medaase');
    });

    test('transcription key variant', () {
      final (text, _) = UgHciLabSpeechEngine.parseTranscript(
          '{"transcription": "yɛfrɛ me Kofi"}');
      expect(text, 'yɛfrɛ me Kofi');
    });

    test('segments list is walked', () {
      final (text, _) = UgHciLabSpeechEngine.parseTranscript(
          '{"segments": [{"text": "maakye"}, {"text": "maaha"}]}');
      expect(text, 'maakye');
    });

    test('plain-text body is the transcript', () {
      final (text, _) =
          UgHciLabSpeechEngine.parseTranscript('Me din de Ama');
      expect(text, 'Me din de Ama');
    });

    test('JSON string body is the transcript', () {
      final (text, _) =
          UgHciLabSpeechEngine.parseTranscript('"Me din de Ama"');
      expect(text, 'Me din de Ama');
    });

    test('error envelope yields no transcript (never shown as speech)',
        () {
      final (text, _) = UgHciLabSpeechEngine.parseTranscript(
          '{"request_id": "req_2", "error": {"code": "quota", "message": "x"}}');
      expect(text, isEmpty);
    });

    test('empty JSON object yields empty, not the raw JSON', () {
      final (text, _) = UgHciLabSpeechEngine.parseTranscript('{}');
      expect(text, isEmpty);
    });
  });

  group('Lab TTS audio format sniffing', () {
    Uint8List bytes(List<int> head) =>
        Uint8List.fromList([...head, ...List.filled(32, 0)]);

    test('WAV (RIFF)', () {
      expect(
          UgHciLabTtsEngine.sniffAudioFormat(
              bytes([0x52, 0x49, 0x46, 0x46])),
          'wav');
    });

    test('MP3 (ID3 tag)', () {
      expect(
          UgHciLabTtsEngine.sniffAudioFormat(bytes([0x49, 0x44, 0x33])),
          'mp3');
    });

    test('MP3 (frame sync)', () {
      expect(
          UgHciLabTtsEngine.sniffAudioFormat(bytes([0xFF, 0xFB])), 'mp3');
    });

    test('OGG (OggS)', () {
      expect(
          UgHciLabTtsEngine.sniffAudioFormat(
              bytes([0x4F, 0x67, 0x67, 0x53])),
          'ogg');
    });

    test('M4A (ftyp)', () {
      expect(
          UgHciLabTtsEngine.sniffAudioFormat(
              bytes([0, 0, 0, 0, 0x66, 0x74, 0x79, 0x70])),
          'm4a');
    });

    test('unknown bytes are not guessed', () {
      expect(UgHciLabTtsEngine.sniffAudioFormat(bytes([1, 2, 3, 4])), isNull);
    });
  });

  group('Lab TTS audio extraction', () {
    final engine = UgHciLabTtsEngine(
      const UgHciLabSettings(baseUrl: 'https://example.test', apiKey: 'k'),
    );

    final wavBytes = Uint8List.fromList(
        [0x52, 0x49, 0x46, 0x46, ...List.filled(64, 7)]);

    test('raw WAV is accepted even with a non-audio content-type',
        () async {
      // The field failure: a successful response whose header did not
      // say "audio" must still play.
      final response = http.Response.bytes(wavBytes, 200,
          headers: {'content-type': 'application/octet-stream'});
      final (bytes, ext) = await engine.extractAudio(response);
      expect(ext, 'wav');
      expect(bytes, wavBytes);
    });

    test('base64 audio nested in a JSON envelope', () async {
      final body = jsonEncode({
        'status': 'success',
        'data': {'audio_base64': base64Encode(wavBytes)},
      });
      final response = http.Response(body, 200,
          headers: {'content-type': 'application/json'});
      final (bytes, ext) = await engine.extractAudio(response);
      expect(ext, 'wav');
      expect(bytes, wavBytes);
    });

    test('base64 with a data-URI prefix', () async {
      final body = jsonEncode(
          {'audio': 'data:audio/wav;base64,${base64Encode(wavBytes)}'});
      final response = http.Response(body, 200,
          headers: {'content-type': 'application/json'});
      final (bytes, ext) = await engine.extractAudio(response);
      expect(ext, 'wav');
      expect(bytes, wavBytes);
    });

    test('JSON error envelope surfaces the Lab error', () async {
      final body = jsonEncode({
        'request_id': 'req_9',
        'error': {'code': 'quota_exceeded', 'message': 'TTS quota used up'},
      });
      final response = http.Response(body, 200,
          headers: {'content-type': 'application/json'});
      await expectLater(
        engine.extractAudio(response),
        throwsA(isA<LabApiException>()),
      );
    });

    test('non-audio, non-JSON response throws a clear error', () async {
      final response = http.Response('<html>oops</html>', 200,
          headers: {'content-type': 'text/html'});
      await expectLater(
        engine.extractAudio(response),
        throwsA(isA<Exception>()),
      );
    });
  });
}
