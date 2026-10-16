import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/logging/app_logger.dart';
import '../asr/models/asr_model_config.dart';
import '../khaya/khaya_api_error.dart';
import '../khaya/khaya_config.dart';
import '../ug_hci_lab/lab_diagnostics_store.dart';
import 'speech_engine.dart';
import 'ug_hci_lab_speech_engine.dart';

/// [SpeechEngine] implementation that sends captured audio to the
/// Khaya AI ASR v3 API (Ghana NLP) — the optional second Ghanaian
/// provider, selectable in Settings → Speech Provider. The UG HCI Lab
/// remains the hackathon path; this engine exists so real-world use
/// is not capped by the Lab's per-key quotas and so Ewe gets an
/// explicit-language recognition path.
///
/// Contract (Khaya's published integration docs, verified Oct 2026):
///   POST {asrBase}/transcribe?language=<ISO 639-3>
///     - body: the raw audio bytes (16 kHz mono PCM16 WAV, exactly
///       what the app records), Content-Type: audio/wav
///     - header Ocp-Apim-Subscription-Key: <key>
///   Success: {"text": "...", "timings": {...}} — the shape is
///   documented, unlike the Lab's; parsing still falls back to the
///   deep search in [UgHciLabSpeechEngine.parseTranscript].
///   Errors: {"error": {"code", "message", "details"}} — see
///   [KhayaApiException]. Language is EXPLICIT: the app language is
///   mapped to ISO 639-3 by [KhayaSettings.khayaLanguageCode].
class KhayaSpeechEngine implements SpeechEngine {
  final AsrModelConfig config;
  final KhayaSettings settings;

  final StreamController<SpeechEngineEvent> _eventController =
      StreamController<SpeechEngineEvent>.broadcast();

  bool _initialized = false;
  bool _recording = false;
  final BytesBuilder _audioBuffer = BytesBuilder();
  DateTime? _utteranceStart;

  KhayaSpeechEngine(this.config, this.settings);

  @override
  bool get isInitialized => _initialized;

  @override
  Stream<SpeechEngineEvent> get events => _eventController.stream;

  String get _khayaLanguage => settings.khayaLanguageCode(config.language);

  @override
  Future<void> initialize() async {
    if (!settings.isConfigured) {
      _initialized = false;
      AppLogger.log('KHAYA', 'ASR engine not initialized: API key missing.');
      _eventController.add(const SpeechEngineError(
        'Khaya AI is not configured. Open Settings → Speech Provider and add your Khaya API key.',
      ));
      return;
    }
    _initialized = true;
    AppLogger.log('KHAYA',
        'ASR engine ready (language=$_khayaLanguage, endpoint=${settings.transcribeUri(config.language)}).');
    _eventController.add(const EngineReady());
  }

  @override
  Future<void> start({String hotwords = ''}) async {
    if (!_initialized) {
      _eventController
          .add(const SpeechEngineError('Khaya ASR engine not initialized'));
      return;
    }
    _audioBuffer.clear();
    _utteranceStart = DateTime.now();
    _recording = true;
    _eventController.add(const SpeechStarted());
  }

  @override
  Future<void> acceptAudio(Uint8List pcm16) async {
    if (!_recording) return;
    _audioBuffer.add(pcm16);
  }

  @override
  Future<void> stop() async {
    if (!_recording) return;
    _recording = false;
    _eventController.add(const SpeechProcessing());

    final audioDuration = DateTime.now().difference(
        _utteranceStart ?? DateTime.now().subtract(const Duration(seconds: 1)));
    final pcmBytes = _audioBuffer.toBytes();
    _audioBuffer.clear();

    if (pcmBytes.isEmpty) {
      _eventController.add(const FinalTranscript(''));
      _eventController.add(const EngineReady());
      return;
    }

    // Utterances in this app are short care phrases; a 2-minute cap
    // keeps a runaway recording from becoming a huge upload.
    final seconds = pcmBytes.length / (config.sampleRate * 2);
    if (seconds > 120) {
      _eventController.add(const SpeechEngineError(
        'That recording is over 2 minutes — please record a shorter message.',
      ));
      _eventController.add(const FinalTranscript(''));
      _eventController.add(const EngineReady());
      return;
    }

    final startedAt = DateTime.now();
    var responseRecorded = false;
    try {
      final wav = _encodeWav(pcmBytes, sampleRate: config.sampleRate);
      // Recognition can take a while — the wait has a floor so the
      // client never abandons a request the service is completing
      // (the exact failure the Lab path suffered with a 30 s cap).
      final timeout = Duration(
          seconds: settings.timeoutSeconds.clamp(120, 300).toInt());
      final response = await http
          .post(
            settings.transcribeUri(config.language),
            headers: {
              ...settings.authHeaders(),
              'Content-Type': 'audio/wav',
            },
            body: wav,
          )
          .timeout(timeout);
      final elapsed = DateTime.now().difference(startedAt);
      await LabDiagnosticsStore.recordAsr(
        statusCode: response.statusCode,
        body: response.body,
        elapsed: elapsed,
        provider: 'Khaya AI',
      );
      responseRecorded = true;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw KhayaApiException.fromResponse(
            response.body, response.statusCode);
      }

      final transcript = parseKhayaTranscript(response.body);
      if (transcript.trim().isEmpty) {
        AppLogger.log('KHAYA',
            'ASR 200 response held no readable transcript. Body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
        _eventController.add(const SpeechEngineError(
          'Khaya answered, but its response held no transcript we '
          'could read. Please try again — and if it repeats, the '
          'response is saved under Settings → Speech Provider → '
          'Last API responses.',
        ));
        _eventController.add(const FinalTranscript(''));
        return;
      }

      final result = RecognitionResult(
        text: transcript,
        confidence: null, // Khaya ASR v3 returns no confidence score.
        processingTime: elapsed,
        audioDuration: audioDuration,
      );
      AppLogger.log(
          'KHAYA', 'Transcript received (${transcript.length} chars).');
      _eventController.add(FinalTranscript(transcript, result: result));
    } catch (e, stack) {
      if (!responseRecorded) {
        await LabDiagnosticsStore.recordAsrFailure(
          error: e.toString(),
          elapsed: DateTime.now().difference(startedAt),
          provider: 'Khaya AI',
        );
      }
      AppLogger.error('KHAYA', 'ASR request failed', e, stack);
      _eventController.add(SpeechEngineError(
        e is KhayaApiException
            ? e.userMessage
            : 'Could not reach the Khaya speech API. Check your connection and API key in Settings → Speech Provider.',
        error: e,
      ));
      _eventController.add(const FinalTranscript(''));
    } finally {
      _eventController.add(const EngineReady());
    }
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
    _recording = false;
    await _eventController.close();
  }

  /// Extracts the transcript from a Khaya ASR success body.
  ///
  /// The documented shape is a flat {"text": "..."}; anything else
  /// falls back to the tolerant deep search shared with the Lab
  /// engine. An error envelope yields '' (never shown as speech).
  static String parseKhayaTranscript(String body) {
    final trimmed = body.trim();
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('error')) return '';
        final text = decoded['text'];
        if (text is String && text.trim().isNotEmpty) return text;
      }
    } catch (_) {
      // Not JSON — fall through.
    }
    return UgHciLabSpeechEngine.parseTranscript(body).$1;
  }

  /// Wraps raw PCM16 mono samples in a minimal WAV header.
  /// (Same encoding as the Lab engine's — kept local so the two
  /// providers stay independent.)
  static Uint8List _encodeWav(Uint8List pcm16, {required int sampleRate}) {
    const headerSize = 44;
    final dataSize = pcm16.length;
    final out = ByteData(headerSize + dataSize);

    void writeString(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        out.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    out.setUint32(4, 36 + dataSize, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    out.setUint32(16, 16, Endian.little);
    out.setUint16(20, 1, Endian.little); // PCM
    out.setUint16(22, 1, Endian.little); // mono
    out.setUint32(24, sampleRate, Endian.little);
    out.setUint32(28, sampleRate * 2, Endian.little);
    out.setUint16(32, 2, Endian.little);
    out.setUint16(34, 16, Endian.little);
    writeString(36, 'data');
    out.setUint32(40, dataSize, Endian.little);
    for (var i = 0; i < dataSize; i++) {
      out.setUint8(headerSize + i, pcm16[i]);
    }
    return out.buffer.asUint8List();
  }
}
