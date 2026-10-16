import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../core/logging/app_logger.dart';
import '../asr/models/asr_model_config.dart';
import '../ug_hci_lab/lab_api_error.dart';
import '../ug_hci_lab/lab_diagnostics_store.dart';
import '../ug_hci_lab/ug_hci_lab_config.dart';
import 'speech_engine.dart';

/// [SpeechEngine] implementation that sends captured audio to the
/// University of Ghana HCI Lab ASR API.
///
/// This is the hackathon-compliant speech path: Ghanaian languages
/// (Twi, Ewe, Dagbani) are recognised through the Lab's models rather than
/// the bundled offline models. Audio is buffered during [start]/[stop]
/// and uploaded as a 16 kHz mono PCM16 WAV on [stop].
///
/// Upload contract (HCI Lab API docs, confirmed Oct 2026):
///   POST {baseUrl}/api/v1/asr  (multipart/form-data)
///     - file field "file": utterance.wav (16 kHz mono PCM16 WAV,
///       sent with an audio/wav content type so the format is detected)
///     - header Authorization: Bearer {apiKey}
///   The API takes NO language parameter — it infers the language from
///   the audio. Limits: 120 s and 10 MB per request.
///   Errors use the documented JSON envelope (see [LabApiException]).
///   The success body's shape is not spelled out in the docs, so parsing
///   deep-searches the decoded JSON for a transcript string (see
///   [parseTranscript]) and falls back to treating a non-JSON body as
///   the transcript itself. Every exchange is recorded in
///   [LabDiagnosticsStore] — field reports (Oct 2026) showed requests
///   succeeding on the Lab's dashboard (HTTP 200) while the app read
///   an empty transcript, so the raw body is kept where support can
///   see it (Settings → Speech Provider → Last API responses).
class UgHciLabSpeechEngine implements SpeechEngine {
  final AsrModelConfig config;
  final UgHciLabSettings settings;

  final StreamController<SpeechEngineEvent> _eventController =
      StreamController<SpeechEngineEvent>.broadcast();

  bool _initialized = false;
  bool _recording = false;
  final BytesBuilder _audioBuffer = BytesBuilder();
  DateTime? _utteranceStart;

  UgHciLabSpeechEngine(this.config, this.settings);

  @override
  bool get isInitialized => _initialized;

  @override
  Stream<SpeechEngineEvent> get events => _eventController.stream;

  String get _labLanguage => settings.labLanguageCode(config.language);

  @override
  Future<void> initialize() async {
    if (!settings.isConfigured) {
      _initialized = false;
      AppLogger.log('UG_HCI_LAB',
          'ASR engine not initialized: API base URL / key missing.');
      _eventController.add(const SpeechEngineError(
        'UG HCI Lab API is not configured. Open Settings → Speech Provider and add your API key.',
      ));
      return;
    }
    _initialized = true;
    AppLogger.log('UG_HCI_LAB',
        'ASR engine ready (language=$_labLanguage, endpoint=${settings.asrUri()}).');
    _eventController.add(const EngineReady());
  }

  @override
  Future<void> start({String hotwords = ''}) async {
    if (!_initialized) {
      _eventController
          .add(const SpeechEngineError('Lab ASR engine not initialized'));
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

    // The Lab caps ASR at 120 s per request — fail here with a message
    // the user can act on instead of burning an upload on a rejection.
    final seconds = pcmBytes.length / (config.sampleRate * 2);
    if (seconds > 120) {
      _eventController.add(const SpeechEngineError(
        'That recording is over 2 minutes — the UG HCI Lab API accepts '
        'up to 2 minutes at a time. Please record a shorter message.',
      ));
      _eventController.add(const FinalTranscript(''));
      _eventController.add(const EngineReady());
      return;
    }

    final startedAt = DateTime.now();
    var responseRecorded = false;
    try {
      final wav = _encodeWav(pcmBytes, sampleRate: config.sampleRate);
      final request =
          http.MultipartRequest('POST', settings.asrUri())
            ..headers.addAll(settings.authHeaders())
            ..files.add(http.MultipartFile.fromBytes(
              'file',
              wav,
              filename: 'utterance.wav',
              contentType: MediaType('audio', 'wav'),
            ));

      // Recognition of impaired speech on the Lab's side can take far
      // longer than the stored 30 s default — a request the Lab
      // completes successfully (HTTP 200 on its dashboard) must not be
      // abandoned by our own client first, so the wait has a floor.
      final timeout = Duration(
          seconds: settings.timeoutSeconds.clamp(120, 300).toInt());
      final streamed = await request.send().timeout(timeout);
      final body = await streamed.stream.bytesToString();
      final elapsed = DateTime.now().difference(startedAt);
      await LabDiagnosticsStore.recordAsr(
        statusCode: streamed.statusCode,
        body: body,
        elapsed: elapsed,
      );
      responseRecorded = true;

      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw LabApiException.fromResponse(body, streamed.statusCode);
      }

      final parsed = parseTranscript(body);
      final transcript = parsed.$1;
      final confidence = parsed.$2;

      if (transcript.trim().isEmpty) {
        // The Lab answered 200 but no transcript could be read from
        // its response. Say so — a silent blank looks like the app
        // ignored the user. The raw body is in Settings → Speech
        // Provider → Last API responses, where support can read the
        // actual shape and pin the parser to it.
        AppLogger.log('UG_HCI_LAB',
            'ASR 200 response held no readable transcript. Body: ${body.substring(0, body.length > 300 ? 300 : body.length)}');
        _eventController.add(const SpeechEngineError(
          'The Lab API answered, but its response held no transcript '
          'we could read. Please try again — and if it repeats, the '
          'response is saved under Settings → Speech Provider → '
          'Last API responses.',
        ));
        _eventController.add(const FinalTranscript(''));
        return;
      }

      final result = RecognitionResult(
        text: transcript,
        confidence: confidence,
        processingTime: elapsed,
        audioDuration: audioDuration,
      );
      AppLogger.log('UG_HCI_LAB',
          'Transcript received (${transcript.length} chars, confidence=$confidence).');
      _eventController.add(FinalTranscript(transcript, result: result));
    } catch (e, stack) {
      if (!responseRecorded) {
        await LabDiagnosticsStore.recordAsrFailure(
          error: e.toString(),
          elapsed: DateTime.now().difference(startedAt),
        );
      }
      AppLogger.error('UG_HCI_LAB', 'ASR request failed', e, stack);
      _eventController.add(SpeechEngineError(
        e is LabApiException
            ? e.userMessage
            : 'Could not reach the UG HCI Lab speech API. Check your connection and API key in Settings → Speech Provider.',
        error: e,
      ));
      // Emit an empty final transcript so the UI returns to a usable state.
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

  /// Wraps raw PCM16 mono samples in a minimal WAV header.
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
    out.setUint32(16, 16, Endian.little); // fmt chunk size
    out.setUint16(20, 1, Endian.little); // PCM
    out.setUint16(22, 1, Endian.little); // mono
    out.setUint32(24, sampleRate, Endian.little);
    out.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    out.setUint16(32, 2, Endian.little); // block align
    out.setUint16(34, 16, Endian.little); // bits per sample
    writeString(36, 'data');
    out.setUint32(40, dataSize, Endian.little);
    for (var i = 0; i < dataSize; i++) {
      out.setUint8(headerSize + i, pcm16[i]);
    }
    return out.buffer.asUint8List();
  }

  /// Keys that may carry the transcript, in preference order.
  static const _transcriptKeys = [
    'transcript',
    'transcription',
    'text',
    'recognized_text',
    'recognition',
    'output',
    'result_text',
    'prediction',
  ];

  /// Extracts (transcript, confidence) from an ASR success body.
  ///
  /// The docs don't spell out the success shape, and the first
  /// field-tested build proved the payload is NOT a flat map with a
  /// top-level transcript key (requests succeeded with HTTP 200 while
  /// the app read an empty transcript). So the decoded JSON is
  /// searched deeply: envelope wrappers (`data`, `result`, …) are
  /// unwrapped, transcript-shaped keys are preferred at every level,
  /// and lists are walked. A non-JSON body is treated as the
  /// transcript itself.
  static (String, double?) parseTranscript(String body) {
    final trimmed = body.trim();
    try {
      final decoded = jsonDecode(trimmed);
      final transcript = _findTranscript(decoded);
      if (transcript != null && transcript.trim().isNotEmpty) {
        return (transcript, _findConfidence(decoded));
      }
      if (decoded is String && decoded.trim().isNotEmpty) {
        return (decoded, null);
      }
    } catch (_) {
      // Not JSON — fall through to the plain-text transcript.
    }
    return (trimmed.startsWith('{') || trimmed.startsWith('[')
        ? ('', null)
        : (trimmed, null));
  }

  /// Depth-first search for a transcript string. At each map, direct
  /// transcript keys win first, then nested containers are searched —
  /// so a shallow correct value beats a deep speculative one.
  static String? _findTranscript(Object? node, [int depth = 0]) {
    if (node == null || depth > 6) return null;
    if (node is Map) {
      for (final key in _transcriptKeys) {
        final value = node[key];
        if (value is String && value.trim().isNotEmpty) return value;
        if (value is Map || value is List) {
          final nested = _findTranscript(value, depth + 1);
          if (nested != null) return nested;
        }
      }
      for (final value in node.values) {
        if (value is Map || value is List) {
          final nested = _findTranscript(value, depth + 1);
          if (nested != null) return nested;
        }
      }
    } else if (node is List) {
      for (final item in node) {
        final nested = _findTranscript(item, depth + 1);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  static double? _findConfidence(Object? node, [int depth = 0]) {
    if (node == null || depth > 6) return null;
    if (node is Map) {
      final direct = node['confidence'];
      if (direct is num) return direct.toDouble();
      for (final value in node.values) {
        if (value is Map || value is List) {
          final nested = _findConfidence(value, depth + 1);
          if (nested != null) return nested;
        }
      }
    } else if (node is List) {
      for (final item in node) {
        final nested = _findConfidence(item, depth + 1);
        if (nested != null) return nested;
      }
    }
    return null;
  }
}
