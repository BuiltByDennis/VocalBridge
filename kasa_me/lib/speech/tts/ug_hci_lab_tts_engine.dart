import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logging/app_logger.dart';
import '../ug_hci_lab/lab_api_error.dart';
import '../ug_hci_lab/lab_diagnostics_store.dart';
import '../ug_hci_lab/ug_hci_lab_config.dart';
import 'tts_engine.dart';

/// [TtsEngine] implementation that synthesizes speech through the
/// University of Ghana HCI Lab TTS API.
///
/// This is the hackathon-compliant TTS path and the only in-app way to
/// speak Ghanaian languages today — the offline engine is hardcoded to
/// en-US. Returned audio is written to a temp file and played with
/// just_audio (already a project dependency).
///
/// Upload contract (HCI Lab API docs, confirmed Oct 2026):
///   POST {baseUrl}/api/v1/tts  (application/json)
///     { "text": "...", "model_type": "ss", "speaker": "PT" }
///     header Authorization: Bearer {apiKey}
///   The voice is fixed by the Lab — model_type is always "ss" and the
///   speaker always "PT"; there is no language parameter.
///   Success per the docs: the response body IS the WAV audio. Field
///   reports (Oct 2026) showed successful requests whose audio then
///   did not play, so extraction does NOT trust the docs or the
///   Content-Type: it sniffs the actual bytes (WAV/MP3/OGG), and also
///   accepts a JSON envelope carrying base64 audio or an audio URL —
///   see [extractAudio]. Errors: JSON envelope, see [LabApiException].
///   Limit: 250 characters per request, so longer text is split into
///   sentence-sized chunks (one request each); the next chunk is
///   synthesized while the current one plays, so the Lab's latency
///   does not land between chunks.
class UgHciLabTtsEngine implements TtsEngine {
  /// The Lab's per-request character cap.
  static const int maxCharsPerRequest = 250;

  final UgHciLabSettings settings;

  /// App-side language this engine was created for (e.g. "tw"). Kept for
  /// logging only — the Lab TTS contract has no language field.
  final String language;

  AudioPlayer? _player;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  UgHciLabTtsEngine(this.settings, {this.language = 'en'});

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!settings.isConfigured) {
      AppLogger.log(
          'TTS', 'UgHciLabTtsEngine: API base URL / key missing — not usable.');
      return;
    }
    _player = AudioPlayer();
    _isInitialized = true;
    AppLogger.log('TTS',
        'UgHciLabTtsEngine initialized (language=$language, endpoint=${settings.ttsUri()}).');
  }

  @override
  Future<void> speak(String text) async {
    if (!_isInitialized || _player == null) {
      AppLogger.log(
          'TTS', 'Cannot speak: UgHciLabTtsEngine not initialized/configured.');
      return;
    }
    if (text.trim().isEmpty) return;
    if (_isSpeaking) await stop();

    _isSpeaking = true;
    try {
      final chunks = _chunkText(text.trim());
      AppLogger.log('TTS',
          'UgHciLabTtsEngine synthesizing (${text.length} chars, ${chunks.length} request(s)).');
      // The next chunk is synthesized while the current one plays —
      // with strictly serial synthesize-then-play, the Lab's
      // per-request latency landed between chunks and speech arrived
      // late and in pieces (field report, Oct 2026).
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
      AppLogger.log('TTS', 'UgHciLabTtsEngine finished speaking.');
    } catch (e, stack) {
      AppLogger.error('TTS', 'UgHciLabTtsEngine failed', e, stack);
    } finally {
      _isSpeaking = false;
      // Best-effort cleanup of temp audio files.
      try {
        final dir = await getTemporaryDirectory();
        for (final f in dir.listSync().whereType<File>()) {
          if (f.path.contains('kasa_tts_')) await f.delete();
        }
      } catch (_) {}
    }
  }

  /// Plays one chunk whose synthesis was already started (see the
  /// prefetch loop in [speak]) and waits for playback to complete.
  Future<void> _speakChunk(Future<http.Response> synthesis) async {
    final stopwatch = Stopwatch()..start();
    final response = await synthesis;

    final extracted = await extractAudio(response);
    final audioBytes = extracted.$1;
    final extension = extracted.$2;
    await LabDiagnosticsStore.recordTts(
      statusCode: response.statusCode,
      contentType: response.headers['content-type'] ?? '',
      byteCount: audioBytes.length,
      detectedFormat: extension,
      elapsed: stopwatch.elapsed,
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/kasa_tts_${DateTime.now().millisecondsSinceEpoch}.$extension');
    await file.writeAsBytes(audioBytes);

    await _player!.setFilePath(file.path);
    await _player!.play();
    // Wait until playback finishes (or is stopped).
    await _player!.processingStateStream.firstWhere(
      (s) => s == ProcessingState.completed || s == ProcessingState.idle,
    );
  }

  /// POSTs one chunk to the Lab TTS endpoint, retrying transient
  /// failures (the Lab's TTS backend occasionally reports itself
  /// "temporarily unavailable", and networks drop) up to 3 attempts
  /// with growing pauses. Quota and auth failures are NOT retried —
  /// waiting will not fix them, and retries must never multiply
  /// against the user's quota without cause.
  Future<http.Response> _synthesizeWithRetry(String chunk) async {
    LabApiException? lastLabError;
    Object? lastNetworkError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      if (attempt > 1) {
        await Future.delayed(Duration(milliseconds: 800 * attempt));
        AppLogger.log(
            'TTS', 'Lab TTS retry $attempt/3 — the service may be recovering.');
      }
      try {
        final response = await http
            .post(
              settings.ttsUri(),
              headers: {
                ...settings.authHeaders(),
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'text': chunk,
                'model_type': 'ss',
                'speaker': 'PT',
              }),
            )
            // Synthesis can legitimately take longer than the stored
            // 30 s default — don't abandon a request the Lab is still
            // completing successfully.
            .timeout(Duration(
                seconds: settings.timeoutSeconds.clamp(90, 300).toInt()));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        final err =
            LabApiException.fromResponse(response.body, response.statusCode);
        if (err.isQuota || err.isAuth || response.statusCode < 500) {
          throw err; // will not fix itself — surface it now
        }
        lastLabError = err; // 5xx / upstream unavailable → try again
      } on LabApiException {
        rethrow;
      } catch (e) {
        lastNetworkError = e; // timeouts, socket errors → try again
      }
    }
    if (lastLabError != null) throw lastLabError;
    throw lastNetworkError ?? Exception('Lab TTS request failed.');
  }

  /// Extracts (audio bytes, file extension) from a TTS response.
  ///
  /// The bytes decide, not the Content-Type: raw audio is recognised
  /// by its magic bytes whatever the header claims. A JSON body is
  /// searched deeply for base64 audio or an audio URL; a JSON error
  /// envelope surfaces the Lab's real reason (quota, validation, …).
  Future<(Uint8List, String)> extractAudio(http.Response response) async {
    final contentType =
        response.headers['content-type']?.toLowerCase() ?? '';
    final sniffed = sniffAudioFormat(response.bodyBytes);
    if (sniffed != null) return (response.bodyBytes, sniffed);

    // Not raw audio — try JSON shapes.
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }
    if (decoded != null) {
      final parsed = LabApiException.tryParse(
          response.body, response.statusCode);
      if (parsed != null) throw parsed;

      final b64 = _findStringValue(decoded, const [
        'audio_base64',
        'audioBase64',
        'audio_content',
        'audioContent',
        'audio',
        'data',
      ]);
      if (b64 != null && b64.trim().isNotEmpty) {
        var payload = b64.trim();
        final comma = payload.indexOf(',');
        if (payload.startsWith('data:') && comma > 0) {
          payload = payload.substring(comma + 1);
        }
        try {
          final bytes = base64Decode(payload);
          return (bytes, sniffAudioFormat(bytes) ?? 'wav');
        } catch (_) {
          // Not valid base64 — keep looking (it may be a URL).
        }
      }

      final url = _findStringValue(
          decoded, const ['audio_url', 'audioUrl', 'url', 'href', 'audio']);
      if (url != null && url.startsWith('http')) {
        final uri = Uri.parse(url);
        final headers = <String, String>{};
        if (uri.host == settings.ttsUri().host) {
          headers.addAll(settings.authHeaders());
        }
        final download = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 60));
        if (download.statusCode >= 200 && download.statusCode < 300) {
          return (
            download.bodyBytes,
            sniffAudioFormat(download.bodyBytes) ?? 'wav'
          );
        }
        throw Exception(
            'TTS audio URL download failed (HTTP ${download.statusCode}).');
      }
    }

    if (contentType.contains('audio')) {
      // Header claims audio but the bytes matched no known format —
      // hand them to the player anyway; it sniffs content itself.
      return (response.bodyBytes, 'wav');
    }
    throw Exception(
        'TTS response was not audio (content-type: $contentType).');
  }

  /// Identifies an audio format from its magic bytes, or null.
  static String? sniffAudioFormat(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x52 && // R
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x46) {
      // F
      return 'wav';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0x49 && // I
        bytes[1] == 0x44 && // D
        bytes[2] == 0x33) {
      // 3 (ID3 tag)
      return 'mp3';
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
      return 'mp3'; // MPEG audio frame sync
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x4F && // O
        bytes[1] == 0x67 && // g
        bytes[2] == 0x67 && // g
        bytes[3] == 0x53) {
      // S
      return 'ogg';
    }
    if (bytes.length >= 8 &&
        bytes[4] == 0x66 && // f
        bytes[5] == 0x74 && // t
        bytes[6] == 0x79 && // y
        bytes[7] == 0x70) {
      // p (ISO BMFF / M4A)
      return 'm4a';
    }
    return null;
  }

  /// Depth-first search for the first non-empty string stored under
  /// any of [keys], at any nesting level.
  static String? _findStringValue(Object? node, List<String> keys,
      [int depth = 0]) {
    if (node == null || depth > 6) return null;
    if (node is Map) {
      for (final key in keys) {
        final value = node[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
      for (final value in node.values) {
        final nested = _findStringValue(value, keys, depth + 1);
        if (nested != null) return nested;
      }
    } else if (node is List) {
      for (final item in node) {
        final nested = _findStringValue(item, keys, depth + 1);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  /// Splits [text] into chunks of at most [maxCharsPerRequest]
  /// characters, preferring sentence boundaries, then word boundaries,
  /// so long messages survive the Lab's 250-character cap.
  static List<String> _chunkText(String text) {
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
    AppLogger.log('TTS', 'UgHciLabTtsEngine stopped.');
  }

  @override
  void dispose() {
    _player?.dispose();
    _player = null;
    _isInitialized = false;
    _isSpeaking = false;
  }
}
