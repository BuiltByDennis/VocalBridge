import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The most recent speech-API exchanges (UG HCI Lab and Khaya AI —
/// each record is tagged with its provider), kept so a failed or
/// empty speech result can be diagnosed from facts instead of guesses.
///
/// The Lab's published docs do not show the exact success-body shapes,
/// and production (release) builds have no visible app logs — so the
/// engines record what actually came back here: status, timing, the raw
/// ASR body (truncated), and the TTS response's content-type / size /
/// detected format. Settings → Speech Provider shows these under
/// "Last API responses", where the user can read or copy them for
/// support. One record per service; every new call overwrites it.
///
/// Stored in secure storage like the other speech settings — it can
/// contain a transcript of the user's own speech, so it gets the same
/// protection as the API key.
class LabDiagnosticsStore {
  static const _asrKey = 'lab_diag_asr_v1';
  static const _ttsKey = 'lab_diag_tts_v1';
  static const _storage = FlutterSecureStorage();

  /// Raw bodies are evidence, not archives — keep the head, which is
  /// where the shape (keys, nesting, envelope) is visible.
  static const int maxBodyChars = 1200;

  static Future<void> recordAsr({
    required int statusCode,
    required String body,
    required Duration elapsed,
    String provider = 'UG HCI Lab',
  }) async {
    try {
      await _storage.write(
        key: _asrKey,
        value: jsonEncode({
          'at': DateTime.now().toIso8601String(),
          'provider': provider,
          'statusCode': statusCode,
          'elapsedMs': elapsed.inMilliseconds,
          'body': body.length > maxBodyChars
              ? '${body.substring(0, maxBodyChars)}…'
              : body,
        }),
      );
    } catch (_) {
      // Diagnostics must never break the speech path.
    }
  }

  static Future<void> recordAsrFailure({
    required String error,
    required Duration elapsed,
    String provider = 'UG HCI Lab',
  }) async {
    try {
      await _storage.write(
        key: _asrKey,
        value: jsonEncode({
          'at': DateTime.now().toIso8601String(),
          'provider': provider,
          'statusCode': 0,
          'elapsedMs': elapsed.inMilliseconds,
          'body': 'Request failed before a response: $error',
        }),
      );
    } catch (_) {}
  }

  static Future<void> recordTts({
    required int statusCode,
    required String contentType,
    required int byteCount,
    required String detectedFormat,
    required Duration elapsed,
    String provider = 'UG HCI Lab',
  }) async {
    try {
      await _storage.write(
        key: _ttsKey,
        value: jsonEncode({
          'at': DateTime.now().toIso8601String(),
          'provider': provider,
          'statusCode': statusCode,
          'elapsedMs': elapsed.inMilliseconds,
          'contentType': contentType,
          'byteCount': byteCount,
          'detectedFormat': detectedFormat,
        }),
      );
    } catch (_) {}
  }

  /// Records a TTS call that failed before any audio existed
  /// (timeout, network, provider error) so the "Last API responses"
  /// card explains a silent app instead of showing a stale success.
  static Future<void> recordTtsFailure({
    required String error,
    required Duration elapsed,
    String provider = 'UG HCI Lab',
  }) async {
    try {
      await _storage.write(
        key: _ttsKey,
        value: jsonEncode({
          'at': DateTime.now().toIso8601String(),
          'provider': provider,
          'statusCode': 0,
          'elapsedMs': elapsed.inMilliseconds,
          'contentType': '',
          'byteCount': 0,
          'detectedFormat': 'failed: $error',
        }),
      );
    } catch (_) {}
  }

  static Future<LabDiagnosticsSnapshot> load() async {
    Map<String, dynamic>? asr;
    Map<String, dynamic>? tts;
    try {
      final rawAsr = await _storage.read(key: _asrKey);
      if (rawAsr != null) asr = jsonDecode(rawAsr) as Map<String, dynamic>;
    } catch (_) {}
    try {
      final rawTts = await _storage.read(key: _ttsKey);
      if (rawTts != null) tts = jsonDecode(rawTts) as Map<String, dynamic>;
    } catch (_) {}
    return LabDiagnosticsSnapshot(asr: asr, tts: tts);
  }
}

/// The last recorded Lab exchanges, as decoded JSON maps (null when a
/// service has not been called yet on this device).
class LabDiagnosticsSnapshot {
  final Map<String, dynamic>? asr;
  final Map<String, dynamic>? tts;

  const LabDiagnosticsSnapshot({this.asr, this.tts});

  bool get isEmpty => asr == null && tts == null;
}
