import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/logging/app_logger.dart';
import 'tts_engine.dart';

class OfflineTtsEngine implements TtsEngine {
  /// The app language this engine speaks ('en_GH', 'twi', 'ewe').
  ///
  /// An engine speaks ONE language — the one it was built for. This
  /// engine used to hardwire the system voice to en-US, so any Twi or
  /// Ewe text routed to it (the factory's no-key fallback) was read
  /// aloud as English. It now asks the platform for the voice of ITS
  /// language; devices that ship that voice use it.
  final String appLanguage;

  OfflineTtsEngine({this.appLanguage = 'en_GH'});

  /// flutter_tts (BCP-47) language code for an app language code.
  static String languageCodeFor(String appLanguage) => switch (appLanguage) {
        'twi' => 'tw-GH',
        'ewe' => 'ee-GH',
        _ => 'en-US',
      };

  /// The BCP-47 code this engine requests from the platform.
  String get ttsLanguage => languageCodeFor(appLanguage);

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    AppLogger.log(
        'TTS', 'Initializing OfflineTtsEngine (flutter_tts, $ttsLanguage)...');

    try {
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
        );
      }

      await _flutterTts.awaitSpeakCompletion(true);
      final langResult = await _flutterTts.setLanguage(ttsLanguage);
      // Android reports 1/true when the voice exists, 0/false when it
      // does not (most stock devices ship no Twi/Ewe system voice —
      // the cloud providers are those languages' real voices). Log it
      // plainly; speaking still proceeds with the platform fallback
      // rather than leaving the user silent.
      if (langResult == 0 || langResult == false) {
        AppLogger.log('TTS',
            'No on-device voice for $ttsLanguage on this device; the system fallback voice will be used.');
      }
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _isInitialized = true;
      AppLogger.log('TTS', 'OfflineTtsEngine successfully initialized.');
    } catch (e, stack) {
      AppLogger.error('TTS', 'Failed to initialize flutter_tts', e, stack);
    }
  }

  @override
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      AppLogger.log('TTS', 'Cannot speak, OfflineTtsEngine is not initialized.');
      return;
    }
    
    AppLogger.log('TTS', 'OfflineTtsEngine speaking: "$text"');
    try {
      await _flutterTts.speak(text);
    } catch (e, stack) {
      AppLogger.error('TTS', 'Error during playback', e, stack);
    }
  }

  @override
  Future<void> stop() async {
    if (!_isInitialized) return;
    try {
      await _flutterTts.stop();
      AppLogger.log('TTS', 'OfflineTtsEngine stopped.');
    } catch (e, stack) {
      AppLogger.error('TTS', 'Error stopping playback', e, stack);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _isInitialized = false;
    AppLogger.log('TTS', 'OfflineTtsEngine disposed.');
  }
}
