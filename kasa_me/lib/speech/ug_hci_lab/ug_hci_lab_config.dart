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
/// text, logs, or memory snapshots. Endpoint paths are configurable because
/// the exact Lab API routes are confirmed when API access is granted —
/// see `kasa_me/docs/ug-hci-lab-integration.md`.
class UgHciLabSettings {
  static const _storageKey = 'ug_hci_lab_settings_v1';
  static const _storage = FlutterSecureStorage();

  final SpeechProvider provider;
  final String baseUrl; // e.g. https://speech.hcilab.ug.edu.gh  (VERIFY)
  final String apiKey;
  final String asrPath; // appended to baseUrl, e.g. /asr  (VERIFY)
  final String ttsPath; // appended to baseUrl, e.g. /tts  (VERIFY)
  final String authScheme; // e.g. "Bearer"
  final int timeoutSeconds;

  /// App language code -> Lab API language code.
  /// These are best-guess ISO-style codes — VERIFY against the Lab docs
  /// once API access is granted, then update here (no code changes needed).
  final Map<String, String> languageCodes;

  const UgHciLabSettings({
    this.provider = SpeechProvider.offline,
    this.baseUrl = '',
    this.apiKey = '',
    this.asrPath = '/asr',
    this.ttsPath = '/tts',
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

  factory UgHciLabSettings.fromJson(Map<String, dynamic> json) {
    return UgHciLabSettings(
      provider: SpeechProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => SpeechProvider.offline,
      ),
      baseUrl: json['baseUrl'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      asrPath: json['asrPath'] as String? ?? '/asr',
      ttsPath: json['ttsPath'] as String? ?? '/tts',
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
