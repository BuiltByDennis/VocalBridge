import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/logging/app_logger.dart';

/// Persisted settings for the Khaya AI speech APIs (Ghana NLP) — the
/// optional second Ghanaian provider, added Oct 2026.
///
/// Contract (Khaya's published integration docs, verified Oct 2026):
///   ASR v3: POST https://translation-api.ghananlp.org/asr/v3/transcribe
///           ?language=<ISO 639-3> with the RAW audio bytes as the body
///           (Content-Type matching the format, e.g. audio/wav).
///           Success: {"text": "...", "timings": {...}}.
///   TTS v2: POST https://translation-api.ghananlp.org/tts/v2/synthesize
///           {"text", "language", "speaker_id"?, "format"?} → the
///           response body IS the audio. Voices: male_low / male_high /
///           female (same three for every language).
///   Auth (both): header `Ocp-Apim-Subscription-Key: <key>` — an Azure
///   APIM subscription key obtained at translation.ghananlp.org.
///   Errors: {"error": {"code", "message", "details": [...]}}.
///
/// The key lives in [FlutterSecureStorage], never in plain text, logs,
/// or memory snapshots — same rule as the Lab key. Pricing and plan
/// limits are set by the user's Khaya subscription (not published in
/// the API docs); nothing in the app assumes a quota either way.
class KhayaSettings {
  static const _storageKey = 'khaya_settings_v1';
  static const _storage = FlutterSecureStorage();

  static const String asrBaseUrl = 'https://translation-api.ghananlp.org/asr/v3';
  static const String ttsBaseUrl = 'https://translation-api.ghananlp.org/tts/v2';

  /// Speaker choices offered by Khaya TTS v2. '' means "omit the
  /// field" — Khaya then uses the language's default voice.
  static const List<String> speakerIds = ['', 'male_low', 'male_high', 'female'];

  final String apiKey;
  final String speakerId;
  final int timeoutSeconds;

  const KhayaSettings({
    this.apiKey = '',
    this.speakerId = '',
    this.timeoutSeconds = 60,
  });

  /// True when the user has entered a Khaya subscription key.
  bool get isConfigured => apiKey.trim().isNotEmpty;

  /// App language code -> Khaya ISO 639-3 code. Khaya REJECTS
  /// two-letter codes (tw, ee) with a 400 naming the correct code —
  /// the map below is the contract, not a nicety.
  String khayaLanguageCode(String appCode) => switch (appCode) {
        'twi' => 'twi',
        'ewe' => 'ewe',
        'dagbani' => 'dag',
        'en_GH' || 'en' => 'eng',
        _ => appCode,
      };

  Map<String, String> authHeaders() => {
        'Ocp-Apim-Subscription-Key': apiKey,
      };

  /// ASR endpoint for one language, e.g. .../transcribe?language=twi
  Uri transcribeUri(String appLanguage) => Uri.parse(
      '$asrBaseUrl/transcribe?language=${khayaLanguageCode(appLanguage)}');

  /// TTS endpoint (language travels in the JSON body).
  Uri synthesizeUri() => Uri.parse('$ttsBaseUrl/synthesize');

  /// Language list — used by Settings' Test connection to validate
  /// the key WITHOUT spending a synthesis/recognition request.
  Uri languagesUri() => Uri.parse('$asrBaseUrl/languages');

  KhayaSettings copyWith({
    String? apiKey,
    String? speakerId,
    int? timeoutSeconds,
  }) {
    return KhayaSettings(
      apiKey: apiKey ?? this.apiKey,
      speakerId: speakerId ?? this.speakerId,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'speakerId': speakerId,
        'timeoutSeconds': timeoutSeconds,
      };

  factory KhayaSettings.fromJson(Map<String, dynamic> json) {
    final speaker = json['speakerId'] as String? ?? '';
    return KhayaSettings(
      apiKey: json['apiKey'] as String? ?? '',
      speakerId: speakerIds.contains(speaker) ? speaker : '',
      timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 60,
    );
  }

  static Future<KhayaSettings> load() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null) return const KhayaSettings();
      return KhayaSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('KHAYA', 'Failed to load Khaya settings', e);
      return const KhayaSettings();
    }
  }

  Future<void> persist() async {
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(toJson()));
    } catch (e) {
      AppLogger.error('KHAYA', 'Failed to persist Khaya settings', e);
    }
  }
}

class KhayaSettingsNotifier extends StateNotifier<KhayaSettings> {
  KhayaSettingsNotifier() : super(const KhayaSettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await KhayaSettings.load();
  }

  Future<void> update(KhayaSettings settings) async {
    state = settings;
    await settings.persist();
  }
}

final khayaSettingsProvider =
    StateNotifierProvider<KhayaSettingsNotifier, KhayaSettings>(
  (ref) => KhayaSettingsNotifier(),
);
