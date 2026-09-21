import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/logging/app_logger.dart';
import 'tts_engine.dart';

class OfflineTtsEngine implements TtsEngine {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    AppLogger.log('TTS', 'Initializing OfflineTtsEngine (flutter_tts)...');
    
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
      await _flutterTts.setLanguage("en-US");
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
