import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/logging/app_logger.dart';
import 'speech_behavior.dart';

/// The person's chosen speech profile (their speech condition), kept in
/// secure storage alongside the app's other per-person settings
/// (accessibility, speech provider). Single-user profiles make the DB
/// unnecessary here — and keeping it out of the database schema means
/// this setting can evolve without migrations.
///
/// The value is just the [SpeechCondition] key; [SpeechBehavior] turns
/// it into concrete recognition behaviour wherever it's needed.
class SpeechProfileSettings {
  static const _storageKey = 'speech_profile_settings_v1';
  static const _storage = FlutterSecureStorage();

  final String conditionKey;

  const SpeechProfileSettings({this.conditionKey = 'typical'});

  SpeechCondition get condition => SpeechCondition.fromKey(conditionKey);
  SpeechBehavior get behavior => SpeechBehavior.forCondition(condition);

  Map<String, dynamic> toJson() => {'conditionKey': conditionKey};

  factory SpeechProfileSettings.fromJson(Map<String, dynamic> json) {
    return SpeechProfileSettings(
      conditionKey: json['conditionKey'] as String? ?? 'typical',
    );
  }

  static Future<SpeechProfileSettings> load() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null) return const SpeechProfileSettings();
      return SpeechProfileSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('SPEECH_PROFILE', 'Failed to load speech profile', e);
      return const SpeechProfileSettings();
    }
  }

  Future<void> persist() async {
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(toJson()));
    } catch (e) {
      AppLogger.error('SPEECH_PROFILE', 'Failed to persist speech profile', e);
    }
  }
}

class SpeechProfileSettingsNotifier
    extends StateNotifier<SpeechProfileSettings> {
  SpeechProfileSettingsNotifier() : super(const SpeechProfileSettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await SpeechProfileSettings.load();
  }

  Future<void> update(SpeechProfileSettings settings) async {
    state = settings;
    await settings.persist();
  }

  Future<void> setCondition(SpeechCondition condition) =>
      update(SpeechProfileSettings(conditionKey: condition.key));
}

final speechProfileProvider =
    StateNotifierProvider<SpeechProfileSettingsNotifier, SpeechProfileSettings>(
  (ref) => SpeechProfileSettingsNotifier(),
);
