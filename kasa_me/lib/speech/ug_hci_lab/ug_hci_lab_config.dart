import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/logging/app_logger.dart';

/// Which speech backend the app should use.
///
/// The hackathon requires ASR/TTS to go through the University of Ghana
/// HCI Lab APIs. The offline engines remain as a fallback so the app keeps
/// working when the API is unreachable or not yet configured.
enum SpeechProvider { offline, ugHciLab }

/// Persisted settings for the UG HCI Lab speech APIs.
///
/// The API key lives in [FlutterSecureStorage] (encrypted), never in plain
/// text, logs, or memory snapshots. Defaults below are the Lab's published
/// contract (HCI Lab API docs, confirmed Oct 2026): gateway at
/// lab-subscription-platform.vercel.app, Bearer token auth,
/// POST /api/v1/asr and POST /api/v1/tts. Paths stay configurable in
/// Settings in case the Lab moves the gateway.
class UgHciLabSettings {
  static const _storageKey = 'ug_hci_lab_settings_v1';
  static const _storage = FlutterSecureStorage();

  final SpeechProvider provider;
  final String baseUrl;
  final String apiKey;
  final String asrPath; // appended to baseUrl
  final String ttsPath; // appended to baseUrl
  final String authScheme; // docs: "Bearer"
  final int timeoutSeconds;

  /// App language code -> Lab API language code.
  ///
  /// NOTE: the Lab's published ASR/TTS contract takes NO language
  /// parameter — ASR infers the language from the audio (the gateway is
  /// built around Akan/Twi) and TTS uses a fixed voice (model_type "ss",
  /// speaker "PT"). This map is retained for logging and for any future
  /// Lab endpoints that do accept a language code; the engines do not
  /// send it today.
  final Map<String, String> languageCodes;

  /// The Lab gateway's published base URL (HCI Lab API docs, Oct 2026).
  static const String defaultBaseUrl =
      'https://lab-subscription-platform.vercel.app';
  static const String defaultAsrPath = '/api/v1/asr';
  static const String defaultTtsPath = '/api/v1/tts';

  const UgHciLabSettings({
    this.provider = SpeechProvider.offline,
    this.baseUrl = defaultBaseUrl,
    this.apiKey = '',
    this.asrPath = defaultAsrPath,
    this.ttsPath = defaultTtsPath,
    this.authScheme = 'Bearer',
    this.timeoutSeconds = 30,
    this.languageCodes = const {
      'en_GH': 'en',
      'twi': 'tw',
      'ewe': 'ee',
      'dagbani': 'dag',
    },
  });

  /// True when the user has entered the minimum needed to call the API.
  bool get isConfigured =>
      baseUrl.trim().isNotEmpty && apiKey.trim().isNotEmpty;

  /// True when the Lab API should actually be used for speech.
  bool get useLabApi => provider == SpeechProvider.ugHciLab && isConfigured;

  String labLanguageCode(String appCode) => languageCodes[appCode] ?? appCode;

  Uri asrUri() => Uri.parse('${_normalizedBase()}$asrPath');
  Uri ttsUri() => Uri.parse('${_normalizedBase()}$ttsPath');

  String _normalizedBase() {
    final b = baseUrl.trim();
    return b.endsWith('/') ? b.substring(0, b.length - 1) : b;
  }

  Map<String, String> authHeaders() => {
        'Authorization': '$authScheme $apiKey',
      };

  String get providerLabel =>
      provider == SpeechProvider.ugHciLab ? 'UG HCI Lab API' : 'Offline';

  UgHciLabSettings copyWith({
    SpeechProvider? provider,
    String? baseUrl,
    String? apiKey,
    String? asrPath,
    String? ttsPath,
    String? authScheme,
    int? timeoutSeconds,
    Map<String, String>? languageCodes,
  }) {
    return UgHciLabSettings(
      provider: provider ?? this.provider,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      asrPath: asrPath ?? this.asrPath,
      ttsPath: ttsPath ?? this.ttsPath,
      authScheme: authScheme ?? this.authScheme,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      languageCodes: languageCodes ?? this.languageCodes,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider.name,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'asrPath': asrPath,
        'ttsPath': ttsPath,
        'authScheme': authScheme,
        'timeoutSeconds': timeoutSeconds,
        'languageCodes': languageCodes,
      };

  static String? _nonEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v;

  factory UgHciLabSettings.fromJson(Map<String, dynamic> json) {
    return UgHciLabSettings(
      provider: SpeechProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => SpeechProvider.offline,
      ),
      // Empty strings fall back to the published defaults so a settings
      // blob saved by an older build (blank URL, guessed paths) still
      // lands on the real gateway.
      baseUrl: _nonEmpty(json['baseUrl'] as String?) ?? defaultBaseUrl,
      apiKey: json['apiKey'] as String? ?? '',
      asrPath: _nonEmpty(json['asrPath'] as String?) ?? defaultAsrPath,
      ttsPath: _nonEmpty(json['ttsPath'] as String?) ?? defaultTtsPath,
      authScheme: json['authScheme'] as String? ?? 'Bearer',
      timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 30,
      languageCodes: (json['languageCodes'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          const {'en_GH': 'en', 'twi': 'tw', 'ewe': 'ee', 'dagbani': 'dag'},
    );
  }

  static Future<UgHciLabSettings> load() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null) return const UgHciLabSettings();
      return UgHciLabSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('UG_HCI_LAB', 'Failed to load Lab settings', e);
      return const UgHciLabSettings();
    }
  }

  Future<void> persist() async {
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(toJson()));
    } catch (e) {
      AppLogger.error('UG_HCI_LAB', 'Failed to persist Lab settings', e);
    }
  }
}

class UgHciLabSettingsNotifier extends StateNotifier<UgHciLabSettings> {
  UgHciLabSettingsNotifier() : super(const UgHciLabSettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await UgHciLabSettings.load();
  }

  Future<void> update(UgHciLabSettings settings) async {
    state = settings;
    await settings.persist();
  }
}

final ugHciLabSettingsProvider =
    StateNotifierProvider<UgHciLabSettingsNotifier, UgHciLabSettings>(
  (ref) => UgHciLabSettingsNotifier(),
);
