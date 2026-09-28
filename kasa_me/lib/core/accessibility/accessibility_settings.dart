import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Central store for all accessibility preferences.
/// Persisted to secure storage so settings survive app restarts.
class AccessibilitySettings {
  final bool autoSpeakOnTranscription;
  final bool highContrastMode;
  final bool simplifiedUiMode;
  final bool dwellControlEnabled;
  final double dwellDelaySeconds; // 0.5 – 3.0
  final double micGainMultiplier;  // 1.0 (off) – 4.0 (4x gain)
  final double vadSensitivity;     // 0.1 (loose) – 0.9 (strict)

  const AccessibilitySettings({
    this.autoSpeakOnTranscription = false,
    this.highContrastMode = false,
    this.simplifiedUiMode = false,
    this.dwellControlEnabled = false,
    this.dwellDelaySeconds = 1.5,
    this.micGainMultiplier = 1.0,
    this.vadSensitivity = 0.5,
  });

  AccessibilitySettings copyWith({
    bool? autoSpeakOnTranscription,
    bool? highContrastMode,
    bool? simplifiedUiMode,
    bool? dwellControlEnabled,
    double? dwellDelaySeconds,
    double? micGainMultiplier,
    double? vadSensitivity,
  }) {
    return AccessibilitySettings(
      autoSpeakOnTranscription: autoSpeakOnTranscription ?? this.autoSpeakOnTranscription,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      simplifiedUiMode: simplifiedUiMode ?? this.simplifiedUiMode,
      dwellControlEnabled: dwellControlEnabled ?? this.dwellControlEnabled,
      dwellDelaySeconds: dwellDelaySeconds ?? this.dwellDelaySeconds,
      micGainMultiplier: micGainMultiplier ?? this.micGainMultiplier,
      vadSensitivity: vadSensitivity ?? this.vadSensitivity,
    );
  }

  Map<String, dynamic> toJson() => {
        'autoSpeakOnTranscription': autoSpeakOnTranscription,
        'highContrastMode': highContrastMode,
        'simplifiedUiMode': simplifiedUiMode,
        'dwellControlEnabled': dwellControlEnabled,
        'dwellDelaySeconds': dwellDelaySeconds,
        'micGainMultiplier': micGainMultiplier,
        'vadSensitivity': vadSensitivity,
      };

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      autoSpeakOnTranscription: json['autoSpeakOnTranscription'] as bool? ?? false,
      highContrastMode: json['highContrastMode'] as bool? ?? false,
      simplifiedUiMode: json['simplifiedUiMode'] as bool? ?? false,
      dwellControlEnabled: json['dwellControlEnabled'] as bool? ?? false,
      dwellDelaySeconds: (json['dwellDelaySeconds'] as num?)?.toDouble() ?? 1.5,
      micGainMultiplier: (json['micGainMultiplier'] as num?)?.toDouble() ?? 1.0,
      vadSensitivity: (json['vadSensitivity'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

class AccessibilitySettingsNotifier extends StateNotifier<AccessibilitySettings> {
  static const _storageKey = 'accessibility_settings';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AccessibilitySettingsNotifier() : super(const AccessibilitySettings()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null) {
        state = AccessibilitySettings.fromJson(json.decode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // Corrupt data — start with defaults
    }
  }

  Future<void> _save() async {
    await _storage.write(key: _storageKey, value: json.encode(state.toJson()));
  }

  Future<void> setAutoSpeak(bool value) async {
    state = state.copyWith(autoSpeakOnTranscription: value);
    await _save();
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrastMode: value);
    await _save();
  }

  Future<void> setSimplifiedUi(bool value) async {
    state = state.copyWith(simplifiedUiMode: value);
    await _save();
  }

  Future<void> setDwellControl(bool value) async {
    state = state.copyWith(dwellControlEnabled: value);
    await _save();
  }

  Future<void> setDwellDelay(double value) async {
    state = state.copyWith(dwellDelaySeconds: value.clamp(0.5, 3.0));
    await _save();
  }

  Future<void> setMicGain(double value) async {
    state = state.copyWith(micGainMultiplier: value.clamp(1.0, 4.0));
    await _save();
  }

  Future<void> setVadSensitivity(double value) async {
    state = state.copyWith(vadSensitivity: value.clamp(0.1, 0.9));
    await _save();
  }
}

final accessibilitySettingsProvider =
    StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
  (ref) => AccessibilitySettingsNotifier(),
);

/// Convenience extension so widgets can read the active theme easily.
extension AccessibilityTheme on AccessibilitySettings {
  /// Returns true if the app should use the high-contrast colour palette.
  bool get useHighContrast => highContrastMode;
}
