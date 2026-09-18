abstract class TtsEngine {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  void dispose();
}
