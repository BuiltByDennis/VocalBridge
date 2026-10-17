import 'dart:typed_data';

/// In-memory cache of synthesized speech, keyed by provider +
/// language + voice + text.
///
/// Kasa Me communication is phrase-based: the same sentences ("I
/// need water", "my head hurts") are spoken again and again. Without
/// a cache, every repetition pays the provider's full synthesis
/// latency — seconds each, on a slow gateway. With it, a repeated
/// phrase replays from memory instantly.
///
/// In-memory only, for the life of the process: nothing is written
/// to disk, and the cache holds audio of the user's own phrases —
/// the same data the provider already synthesized for them. Bounded
/// at [maxEntries] with least-recently-used eviction.
class TtsAudioCache {
  static const int maxEntries = 40;

  // Dart's default Map preserves insertion order — used as the LRU
  // order (oldest first).
  static final Map<String, Uint8List> _entries = {};

  static String keyFor({
    required String provider,
    required String language,
    required String voice,
    required String text,
  }) =>
      '$provider|$language|$voice|${text.trim()}';

  /// Returns the cached audio and marks it most-recently-used.
  static Uint8List? get(String key) {
    final value = _entries.remove(key);
    if (value != null) _entries[key] = value;
    return value;
  }

  static void put(String key, Uint8List bytes) {
    if (bytes.isEmpty) return;
    _entries.remove(key);
    _entries[key] = bytes;
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  static int get length => _entries.length;

  static void clear() => _entries.clear();
}
