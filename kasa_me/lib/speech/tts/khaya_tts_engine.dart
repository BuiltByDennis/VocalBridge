import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logging/app_logger.dart';
import '../khaya/khaya_api_error.dart';
import '../khaya/khaya_config.dart';
import '../ug_hci_lab/lab_diagnostics_store.dart';
import 'tts_engine.dart';
import 'ug_hci_lab_tts_engine.dart';

/// [TtsEngine] implementation that synthesizes speech through the
/// Khaya AI TTS v2 API (Ghana NLP) — the optional second Ghanaian
/// provider. The UG HCI Lab remains the hackathon path.
///
/// Contract (Khaya's published integration docs, verified Oct 2026):
///   POST {ttsBase}/synthesize  (application/json)
///     { "text": "...", "language": "<ISO 639-3>",
///       "speaker_id": "male_low|male_high|female" (optional),
///       "format": "wav" }
///     header Ocp-Apim-Subscription-Key: <key>
///   Success: the response body IS the audio. Playback still detects
///   the format from the bytes (see [UgHciLabTtsEngine.sniffAudioFormat])
///   rather than trusting headers — the lesson of the Lab path.
///   Errors: {"error": {"code", "message", "details"}} — see
///   [KhayaApiException].
///   No per-request character cap is documented; text is chunked at
///   500 chars anyway (sentence-aware) to bound per-request latency,
///   and the next chunk is synthesized while the current one plays.
class KhayaTtsEngine implements TtsEngine {
  static const int maxCharsPerRequest = 500;

  final KhayaSettings settings;

  /// App-side language this engine was created for (e.g. "twi").
  /// Unlike the Lab's fixed voice, Khaya takes the language in every
  /// request, mapped to ISO 639-3 by [KhayaSettings.khayaLanguageCode].
  final String appLanguage;

  AudioPlayer? _player;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  KhayaTtsEngine(this.settings, {this.appLanguage = 'en_GH'});

  String get _language => settings.khayaLanguageCode(appLanguage);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!settings.isConfigured) {
      AppLogger.log('KHAYA', 'KhayaTtsEngine: API key missing — not usable.');
      return;
    }
    _player = AudioPlayer();
    _isInitialized = true;
    AppLogger.log('KHAYA',
        'KhayaTtsEngine initialized (language=$_language, endpoint=${settings.synthesizeUri()}).');
  }

  @override
  Future<void> speak(String text) async {
    if (!_isInitialized || _player == null) {
      AppLogger.log(
          'KHAYA', 'Cannot speak: KhayaTtsEngine not initialized/configured.');
      return;
    }
    if (text.trim().isEmpty) return;
    if (_isSpeaking) await stop();

    _isSpeaking = true;
    try {
      final chunks = chunkText(text.trim());
      AppLogger.log('KHAYA',
          'KhayaTtsEngine synthesizing (${text.length} chars, ${chunks.length} request(s)).');
      // Next chunk synthesizes while the current one plays, so
      // per-request latency never lands between chunks.
      Future<http.Response>? pending;
      for (var i = 0; i < chunks.length; i++) {
        if (!_isSpeaking) break; // stop() called mid-playback
        pending ??= _synthesizeWithRetry(chunks[i]);
        final current = pending;
        pending = null;
        if (i + 1 < chunks.length) {
          pending = _synthesizeWithRetry(chunks[i + 1]);
          // If playback stops before this future is awaited, its
          // error must not become an unhandled async error.
          pending.ignore();
        }
        await _speakChunk(current);
      }
      AppLogger.log('KHAYA', 'KhayaTtsEngine finished speaking.');
    } catch (e, stack) {
      AppLogger.error('KHAYA', 'KhayaTtsEngine failed', e, stack);
    } finally {
      _isSpeaking = false;
      try {
        final dir = await getTemporaryDirectory();
        for (final f in dir.listSync().whereType<File>()) {
          if (f.path.contains('kasa_tts_khaya_')) await f.delete();
        }
      } catch (_) {}
    }
  }

  /// Plays one chunk whose synthesis was already started (see the
  /// prefetch loop in [speak]) and waits for playback to complete.
  Future<void> _speakChunk(Future<http.Response> synthesis) async {
    final stopwatch = Stopwatch()..start();
    final response = await synthesis;

    final extracted = extractAudio(response);
    final audioBytes = extracted.$1;
    final extension = extracted.$2;
    await LabDiagnosticsStore.recordTts(
      statusCode: response.statusCode,
      contentType: response.headers['content-type'] ?? '',
      byteCount: audioBytes.length,
      detectedFormat: extension,
      elapsed: stopwatch.elapsed,
      provider: 'Khaya AI',
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/kasa_tts_khaya_${DateTime.now().millisecondsSinceEpoch}.$extension');
    await file.writeAsBytes(audioBytes);

    await _player!.setFilePath(file.path);
    await _player!.play();
    await _player!.processingStateStream.firstWhere(
      (s) => s == ProcessingState.completed || s == ProcessingState.idle,
    );
  }

  /// POSTs one chunk, retrying transient failures (5xx / SYSTEM_ERROR
  /// / network) up to 3 attempts with growing pauses. Auth and
  /// validation failures are NOT retried — waiting cannot fix them.
  Future<http.Response> _synthesizeWithRetry(String chunk) async {
    KhayaApiException? lastServerError;
    Object? lastNetworkError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      if (attempt > 1) {
        await Future.delayed(Duration(milliseconds: 800 * attempt));
        AppLogger.log('KHAYA', 'Khaya TTS retry $attempt/3.');
      }
      try {
        final response = await http
            .post(
              settings.synthesizeUri(),
              headers: {
                ...settings.authHeaders(),
                'Content-Type': 'application/json',
              },
              body: jsonEncode(buildRequestBody(chunk)),
            )
            .timeout(Duration(
                seconds: settings.timeoutSeconds.clamp(90, 300).toInt()));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        final err =
            KhayaApiException.fromResponse(response.body, response.statusCode);
        if (!err.isServerError) throw err;
        lastServerError = err;
      } on KhayaApiException {
        rethrow;
      } catch (e) {
        lastNetworkError = e;
      }
    }
    if (lastServerError != null) throw lastServerError;
    throw lastNetworkError ?? Exception('Khaya TTS request failed.');
  }

  /// The documented synthesize request body for one chunk.
  Map<String, dynamic> buildRequestBody(String chunk) => {
        'text': chunk,
        'language': _language,
        if (settings.speakerId.isNotEmpty) 'speaker_id': settings.speakerId,
        'format': 'wav',
      };

  /// Extracts (audio bytes, file extension) from a TTS response.
  ///
  /// The bytes decide, not the Content-Type: raw audio is recognised
  /// by its magic bytes (shared sniffer with the Lab engine). A JSON
  /// body is either Khaya's error envelope (surfaced as the real
  /// reason) or, defensively, base64 audio.
  (Uint8List, String) extractAudio(http.Response response) {
    final sniffed =
        UgHciLabTtsEngine.sniffAudioFormat(response.bodyBytes);
    if (sniffed != null) return (response.bodyBytes, sniffed);

    final parsed =
        KhayaApiException.tryParse(response.body, response.statusCode);
    if (parsed != null) throw parsed;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final data = decoded['data'];
        final b64 = (decoded['audio_base64'] ??
                decoded['audio'] ??
                (data is Map ? data['audio_base64'] ?? data['audio'] : null))
            ?.toString();
        if (b64 != null && b64.trim().isNotEmpty) {
          var payload = b64.trim();
          final comma = payload.indexOf(',');
          if (payload.startsWith('data:') && comma > 0) {
            payload = payload.substring(comma + 1);
          }
          final bytes = base64Decode(payload);
          return (
            bytes,
            UgHciLabTtsEngine.sniffAudioFormat(bytes) ?? 'wav'
          );
        }
      }
    } catch (_) {}

    final contentType =
        response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.contains('audio')) {
      return (response.bodyBytes, 'wav');
    }
    throw Exception(
        'Khaya TTS response was not audio (content-type: $contentType).');
  }

  /// Splits [text] into chunks of at most [maxCharsPerRequest]
  /// characters, preferring sentence boundaries, then word
  /// boundaries. (Same splitter shape as the Lab TTS engine.)
  static List<String> chunkText(String text) {
    if (text.length <= maxCharsPerRequest) return [text];
    final sentences = text.split(RegExp(r'(?<=[.!?…])\s+'));
    final chunks = <String>[];
    var current = '';
    void flush() {
      if (current.trim().isNotEmpty) chunks.add(current.trim());
      current = '';
    }

    for (final sentence in sentences) {
      if (sentence.length > maxCharsPerRequest) {
        flush();
        var rest = sentence;
        while (rest.length > maxCharsPerRequest) {
          var cut = rest.lastIndexOf(' ', maxCharsPerRequest);
          if (cut <= 0) cut = maxCharsPerRequest;
          chunks.add(rest.substring(0, cut).trim());
          rest = rest.substring(cut).trim();
        }
        current = rest;
      } else if (current.isEmpty) {
        current = sentence;
      } else if (current.length + 1 + sentence.length <=
          maxCharsPerRequest) {
        current = '$current $sentence';
      } else {
        flush();
        current = sentence;
      }
    }
    flush();
    return chunks;
  }

  @override
  Future<void> stop() async {
    if (!_isSpeaking) return;
    try {
      await _player?.stop();
    } catch (_) {}
    _isSpeaking = false;
    AppLogger.log('KHAYA', 'KhayaTtsEngine stopped.');
  }

  @override
  void dispose() {
    _player?.dispose();
    _player = null;
    _isInitialized = false;
    _isSpeaking = false;
  }
}
