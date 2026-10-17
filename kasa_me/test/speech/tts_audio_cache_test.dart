import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/speech/tts/tts_audio_cache.dart';

/// The TTS cache is the latency fix for phrase-based communication:
/// a repeated phrase must replay instantly instead of paying a slow
/// provider's synthesis time again. These tests pin the keying (a
/// phrase in another language/voice/provider is a DIFFERENT entry)
/// and the bounded LRU behaviour.
void main() {
  setUp(TtsAudioCache.clear);

  String key({
    String provider = 'lab',
    String language = 'tw',
    String voice = 'PT',
    String text = 'Me pɛ aduane',
  }) =>
      TtsAudioCache.keyFor(
          provider: provider, language: language, voice: voice, text: text);

  test('put/get round-trip; a miss returns null', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    TtsAudioCache.put(key(), bytes);
    expect(TtsAudioCache.get(key()), bytes);
    expect(TtsAudioCache.get(key(text: 'other')), isNull);
  });

  test('keys separate provider, language, voice and text', () {
    final base = key();
    expect(key(provider: 'khaya'), isNot(base));
    expect(key(language: 'ee'), isNot(base));
    expect(key(voice: 'female'), isNot(base));
    expect(key(text: 'Me pɛ nsuo'), isNot(base));
  });

  test('text is trimmed for the key (same phrase, stray spaces)', () {
    expect(key(text: '  Me pɛ aduane  '), key());
  });

  test('empty audio is never cached', () {
    TtsAudioCache.put(key(), Uint8List(0));
    expect(TtsAudioCache.get(key()), isNull);
    expect(TtsAudioCache.length, 0);
  });

  test('evicts least-recently-used beyond the cap', () {
    for (var i = 0; i < TtsAudioCache.maxEntries + 5; i++) {
      TtsAudioCache.put(key(text: 'phrase $i'), Uint8List.fromList([i]));
    }
    expect(TtsAudioCache.length, TtsAudioCache.maxEntries);
    expect(TtsAudioCache.get(key(text: 'phrase 0')), isNull);
    expect(TtsAudioCache.get(key(text: 'phrase 4')), isNull);
    expect(TtsAudioCache.get(key(text: 'phrase 5')), isNotNull);
  });

  test('reading an entry protects it from eviction (LRU touch)', () {
    TtsAudioCache.put(key(text: 'old but used'), Uint8List.fromList([9]));
    for (var i = 0; i < TtsAudioCache.maxEntries - 1; i++) {
      TtsAudioCache.put(key(text: 'filler $i'), Uint8List.fromList([i]));
    }
    // Touch the old entry, then overflow by a few: fillers from the
    // front should go first, the touched entry survives.
    expect(TtsAudioCache.get(key(text: 'old but used')), isNotNull);
    for (var i = 0; i < 3; i++) {
      TtsAudioCache.put(key(text: 'extra $i'), Uint8List.fromList([i]));
    }
    expect(TtsAudioCache.get(key(text: 'old but used')), isNotNull);
    expect(TtsAudioCache.get(key(text: 'filler 0')), isNull);
  });
}
