import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logging/app_logger.dart';
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
/// Upload contract (VERIFY against the Lab docs once API access is granted;
/// see `kasa_me/docs/ug-hci-lab-integration.md`):
///   POST {baseUrl}{ttsPath}  (application/json)
///     { "text": "...", "language": "tw" }
///     header Authorization: {scheme} {apiKey}
///   Response: raw audio bytes (audio/*), OR JSON with an "audio_base64"
///   (also accepts "audio") field.
class UgHciLabTtsEngine implements TtsEngine {
  final UgHciLabSettings settings;

  /// Lab language code, e.g. "tw". Resolved via [UgHciLabSettings.labLanguageCode].
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
      AppLogger.log('TTS', 'UgHciLabTtsEngine synthesizing (${text.length} chars).');
      final response = await http
          .post(
            settings.ttsUri(),
            headers: {
              ...settings.authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'text': text, 'language': language}),
          )
          .timeout(Duration(seconds: settings.timeoutSeconds));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
            'TTS request failed (${response.statusCode}): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
      }

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

  Uint8List _extractAudioBytes(http.Response response) {
    final contentType =
        response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.contains('audio')) {
      return response.bodyBytes;
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
