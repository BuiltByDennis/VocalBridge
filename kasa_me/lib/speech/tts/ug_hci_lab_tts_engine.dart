import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logging/app_logger.dart';
import '../ug_hci_lab/lab_api_error.dart';
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
///   Success: the response body IS the WAV audio (Content-Type:
///   audio/wav), metadata in headers. Errors: JSON envelope, see
///   [LabApiException] — so the Content-Type is checked before decoding.
///   Limit: 250 characters per request, so longer text is split into
///   sentence-sized chunks and played back-to-back (one request each).
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
      for (final chunk in chunks) {
        if (!_isSpeaking) break; // stop() called mid-playback
        await _speakChunk(chunk);
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

  /// Synthesizes one ≤250-char chunk and plays it to completion.
  Future<void> _speakChunk(String chunk) async {
    final response = await _synthesizeWithRetry(chunk);

    final audioBytes = _extractAudioBytes(response);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/kasa_tts_${DateTime.now().millisecondsSinceEpoch}.wav');
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
            .timeout(Duration(seconds: settings.timeoutSeconds));
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

  Uint8List _extractAudioBytes(http.Response response) {
    final contentType =
        response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.contains('audio')) {
      return response.bodyBytes;
    }
    // Per the docs, a JSON body on this endpoint is an error envelope —
    // surface the Lab's real reason (quota, validation, …) instead of a
    // generic "not audio" failure.
    if (contentType.contains('json')) {
      final parsed = LabApiException.tryParse(
          response.body, response.statusCode);
      if (parsed != null) throw parsed;
    }
    // Fallback: JSON envelope carrying base64 audio.
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final b64 =
          (decoded['audio_base64'] ?? decoded['audio'] ?? '').toString();
      if (b64.isNotEmpty) return base64Decode(b64);
    } catch (_) {}
    throw Exception(
        'TTS response was not audio (content-type: $contentType).');
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
