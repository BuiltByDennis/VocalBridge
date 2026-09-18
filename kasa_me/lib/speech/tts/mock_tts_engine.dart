import 'dart:async';
import '../../core/logging/app_logger.dart';
import 'tts_engine.dart';

class MockTtsEngine implements TtsEngine {
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    AppLogger.log('TTS', 'Initializing MockTtsEngine...');
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    AppLogger.log('TTS', 'MockTtsEngine successfully initialized.');
  }

  @override
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      AppLogger.log('TTS', 'Cannot speak, MockTtsEngine is not initialized.');
      return;
    }
    if (_isPlaying) {
      await stop();
    }
    
    _isPlaying = true;
    AppLogger.log('TTS', 'MockTtsEngine speaking: "$text"');
    
    // Simulate speaking time based on text length
    final speakingDuration = Duration(milliseconds: text.length * 50);
    await Future.delayed(speakingDuration);
    
    if (_isPlaying) {
      AppLogger.log('TTS', 'MockTtsEngine finished speaking.');
      _isPlaying = false;
    }
  }

  @override
  Future<void> stop() async {
    if (_isPlaying) {
      AppLogger.log('TTS', 'MockTtsEngine stopped.');
      _isPlaying = false;
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    _isPlaying = false;
    AppLogger.log('TTS', 'MockTtsEngine disposed.');
  }
}
