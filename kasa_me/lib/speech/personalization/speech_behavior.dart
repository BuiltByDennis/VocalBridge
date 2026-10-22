/// How Kasa Me should adapt recognition to the person using it.
///
/// A person who stammers, a person with cerebral palsy, a stroke
/// survivor, and a person with a cleft palate do NOT produce speech the
/// same way — so the app must not treat their transcripts the same way.
/// The user (or their caregiver) picks a [SpeechCondition] once in
/// Settings → Personalization; [SpeechBehavior.forCondition] turns it
/// into concrete recognition behaviour that the personalization pipeline
/// and the listening presets actually apply.
///
/// Nothing here retrains the Lab/offline ASR models themselves — those
/// are fixed. What adapts is everything around them: how eagerly the
/// app applies what it has learned about THIS person's speech, how much
/// it trusts raw recognizer confidence, how patiently it listens, and
/// (for stammering) how disfluencies are cleaned before anyone reads
/// the message.
enum SpeechCondition {
  typical('typical', 'Typical speech',
      'Standard recognition behaviour. Choose another profile if a speech condition shapes how you talk — Kasa Me will adapt to you.'),
  stammer('stammer', 'Stammer / stutter',
      'For speech with repetitions, prolongations and blocks. Kasa Me tidies repeated sounds and words out of the written message, and listens patiently through pauses.'),
  cerebralPalsy('cerebralPalsy', 'Cerebral palsy',
      'For dysarthric speech — slower, quieter, or less precise articulation. Kasa Me leans harder on what it has learned about your voice and amplifies the microphone.'),
  stroke('stroke', 'Stroke recovery',
      'For post-stroke speech (dysarthria and/or aphasia). Kasa Me learns your words faster, favours your saved phrases, and listens patiently while you find words.'),
  cleft('cleft', 'Cleft lip / palate',
      'For speech shaped by a cleft — nasal or less distinct consonants. Kasa Me builds your personal sound-to-word corrections quickly and applies them readily.');

  final String key;
  final String label;
  final String description;
  const SpeechCondition(this.key, this.label, this.description);

  static SpeechCondition fromKey(String? key) {
    for (final c in values) {
      if (c.key == key) return c;
    }
    return SpeechCondition.typical;
  }
}

class SpeechBehavior {
  final SpeechCondition condition;

  /// Stammer: collapse immediate repetitions ("I I I want", "wa-wa-water")
  /// in the transcript before display, translation, or read-aloud — the
  /// repetitions are disfluency, not what the person means to say.
  final bool collapseRepetitions;

  /// How readily learned corrections override the recognizer: a
  /// "probable" correction is auto-applied when the recognizer's
  /// confidence is below this gate. Higher gate = the app trusts the
  /// person's learned patterns over the raw recognizer more often.
  /// (Recognizer confidence is systematically unreliable for atypical
  /// speech, so impaired-speech profiles raise the gate.)
  final double correctionConfidenceGate;

  /// How many times a correction must be seen before it activates.
  /// Lower = the app starts adapting to the person sooner.
  final int minMappingFrequency;

  /// Recommended voice-activity sensitivity (0.1 loose – 0.9 strict).
  /// Lower values wait through longer pauses before deciding the
  /// person has finished speaking.
  final double vadSensitivity;

  /// Recommended microphone gain (1.0–4.0) for quieter voices.
  final double micGain;

  /// EnergyVad energy threshold (RMS) derived from [vadSensitivity].
  /// A patient profile (low sensitivity) lowers the threshold so
  /// quiet, slow speech still registers as speech instead of being
  /// treated as silence. Sensitivity 0.50 (typical) reproduces the
  /// EnergyVad default of 250.
  double get vadThresholdRms => 120 + vadSensitivity * 260;

  /// EnergyVad patience: how many consecutive silent frames pass
  /// before the listener decides the person has finished. A patient
  /// profile waits through far more frames. Sensitivity 0.50
  /// (typical) gives ~18 frames, near the EnergyVad default of 15.
  int get vadMaxSilenceFrames => (25 * (1.0 - vadSensitivity) + 5).round();

  /// Plain-language summary of what changes, shown in Settings so the
  /// person knows exactly how the app treats them differently.
  final List<String> changes;

  const SpeechBehavior({
    required this.condition,
    required this.collapseRepetitions,
    required this.correctionConfidenceGate,
    required this.minMappingFrequency,
    required this.vadSensitivity,
    required this.micGain,
    required this.changes,
  });

  factory SpeechBehavior.forCondition(SpeechCondition condition) {
    switch (condition) {
      case SpeechCondition.stammer:
        return const SpeechBehavior(
          condition: SpeechCondition.stammer,
          collapseRepetitions: true,
          correctionConfidenceGate: 0.85,
          minMappingFrequency: 3,
          vadSensitivity: 0.30,
          micGain: 1.0,
          changes: [
            'Repeated sounds and words are tidied out of your messages ("wa-wa-water" becomes "water")',
            'The microphone waits patiently through blocks and pauses',
            'Your learned corrections apply a little more readily',
          ],
        );
      case SpeechCondition.cerebralPalsy:
        return const SpeechBehavior(
          condition: SpeechCondition.cerebralPalsy,
          collapseRepetitions: false,
          correctionConfidenceGate: 0.95,
          minMappingFrequency: 2,
          vadSensitivity: 0.25,
          micGain: 1.5,
          changes: [
            'Your learned word corrections apply much more readily — the recognizer\u2019s confidence is not trusted over your patterns',
            'Corrections start working after 2 examples instead of 3',
            'Microphone gain is raised for a quieter voice, and listening waits through slow speech',
          ],
        );
      case SpeechCondition.stroke:
        return const SpeechBehavior(
          condition: SpeechCondition.stroke,
          collapseRepetitions: false,
          correctionConfidenceGate: 0.95,
          minMappingFrequency: 2,
          vadSensitivity: 0.30,
          micGain: 1.5,
          changes: [
            'Your learned words and phrases apply much more readily',
            'Corrections start working after 2 examples instead of 3',
            'Listening is patient while you search for words, and the microphone is amplified',
          ],
        );
      case SpeechCondition.cleft:
        return const SpeechBehavior(
          condition: SpeechCondition.cleft,
          collapseRepetitions: false,
          correctionConfidenceGate: 0.90,
          minMappingFrequency: 2,
          vadSensitivity: 0.40,
          micGain: 1.25,
          changes: [
            'Your personal sound-to-word corrections build up faster (2 examples instead of 3)',
            'Learned corrections apply more readily when consonants are unclear',
            'Microphone gain is raised slightly',
          ],
        );
      case SpeechCondition.typical:
        return const SpeechBehavior(
          condition: SpeechCondition.typical,
          collapseRepetitions: false,
          correctionConfidenceGate: 0.80,
          minMappingFrequency: 3,
          vadSensitivity: 0.50,
          micGain: 1.0,
          changes: [
            'Standard recognition behaviour',
            'Corrections start working after 3 examples',
          ],
        );
    }
  }

  factory SpeechBehavior.fromKey(String? key) =>
      SpeechBehavior.forCondition(SpeechCondition.fromKey(key));
}

/// Tidies stammering disfluencies out of a transcript.
///
/// Only *immediate* repetitions are touched — a repeated word the person
/// clearly said twice for emphasis in separate clauses is rare in AAC
/// use, and the safety rule here favours cleaning the common stammer
/// patterns:
///   "I I I want water"     → "I want water"   (repeated whole word)
///   "wa-wa-water"          → "water"          (hyphenated part-words)
///   "m-m-me"               → "me"
///   "t-t-today we go"      → "today we go"
///   "wa wa water"          → "water"          (spaced part-words —
///   "wa water"             → "water"           recognizers rarely
///   "w w want"             → "want"            emit the hyphens)
///   "I want I want water"  → "I want water"   (phrase restart)
///
/// Safety: a fragment is only dropped when it is the beginning of the
/// very next word AND is not itself a complete word — "we went",
/// "he held", "a nurse" and Twi's "na nana" pass through untouched.
/// Legitimate hyphenated words ("well-known", "mother-in-law") are
/// left alone: their parts are not prefixes of the final part.
class DisfluencyNormalizer {
  /// Complete words (English + Twi function words) that begin longer
  /// words but must never be treated as a stammer fragment.
  static const _notFragments = {
    'a', 'i', 'an', 'as', 'at', 'be', 'by', 'do', 'go', 'he', 'if',
    'in', 'is', 'it', 'me', 'my', 'no', 'of', 'oh', 'on', 'or', 'so',
    'to', 'up', 'us', 'we', 'am',
    // Twi function words that begin longer Twi words.
    'na', 'ne', 'wo', 'se', 'ma', 'da', 'ya', 'ye',
  };

  static String collapse(String input) {
    if (input.trim().isEmpty) return input;
    var tokens =
        input.split(RegExp(r'\s+')).map(_collapsePartWord).toList();
    tokens = _collapsePhraseRestarts(tokens);
    final out = <String>[];
    for (final token in tokens) {
      final key = _wordKey(token);
      if (out.isNotEmpty && key.isNotEmpty) {
        final prevKey = _wordKey(out.last);
        if (key == prevKey) {
          continue; // immediate repetition — disfluency, keep the first
        }
        // Spaced part-word: the previous token was only the beginning
        // of THIS word ("wa water", "th the nurse") — the person has
        // now said the whole word, so the fragment goes.
        if (_isFragmentOf(prevKey, key)) {
          out[out.length - 1] = token;
          continue;
        }
      }
      out.add(token);
    }
    return out.join(' ');
  }

  /// True when [fragment] reads as a stammered start of [word]: a
  /// short (1–3 letter) strict prefix that is not a complete word.
  static bool _isFragmentOf(String fragment, String word) {
    if (fragment.isEmpty || fragment.length > 3) return false;
    if (word.length <= fragment.length) return false;
    if (_notFragments.contains(fragment)) return false;
    return word.startsWith(fragment);
  }

  /// Collapses immediately repeated 2–3 word sequences ("I want I want
  /// water", "let me let me go") — the phrase-restart pattern, where
  /// the speaker starts the phrase again — to a single instance.
  static List<String> _collapsePhraseRestarts(List<String> tokens) {
    final list = List<String>.of(tokens);
    var changed = true;
    while (changed) {
      changed = false;
      restart:
      for (var n = 3; n >= 2; n--) {
        for (var i = 0; i + 2 * n <= list.length; i++) {
          var same = true;
          for (var k = 0; k < n; k++) {
            if (_wordKey(list[i + k]) != _wordKey(list[i + n + k])) {
              same = false;
              break;
            }
          }
          if (same) {
            list.removeRange(i + n, i + 2 * n);
            changed = true;
            break restart;
          }
        }
      }
    }
    return list;
  }

  static String _collapsePartWord(String token) {
    if (!token.contains('-')) return token;
    final parts = token.split('-');
    if (parts.length < 2) return token;
    final last = _wordKey(parts.last);
    if (last.isEmpty) return token;
    for (var i = 0; i < parts.length - 1; i++) {
      final part = _wordKey(parts[i]);
      if (part.isEmpty || !last.startsWith(part)) return token;
    }
    // Keep any punctuation that trailed the original token.
    final trail = RegExp(r'[^\w-]*$').firstMatch(token)?.group(0) ?? '';
    final core = parts.last.replaceAll(RegExp(r'[^\w]*$'), '');
    return '$core$trail';
  }

  static String _wordKey(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
}
