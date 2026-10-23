import 'evidence_tracker.dart';

class PersonalizationSafetyGuard {
  final Map<String, ({String intended, int frequency})> _learnedWordMappings = {};
  final Map<String, ({String intended, int frequency})> _learnedPhraseMappings = {};
  final EvidenceTracker _evidenceTracker;

  PersonalizationSafetyGuard({EvidenceTracker? evidenceTracker})
      : _evidenceTracker = evidenceTracker ?? EvidenceTracker();

  bool validateAndAddWordMapping(String observed, String intended, {String language = 'en_GH', int frequency = 1}) {
    final obs = _normalize(observed);
    final intd = _normalize(intended);

    if (obs.isEmpty || intd.isEmpty) return false;
    if (obs == intd) return false;

    // Cycle / Loop Detection (A -> B -> A)
    if (_learnedWordMappings[intd]?.intended == obs) {
      return false;
    }

    // Cascading Rewrite Prevention (A -> B, B -> C)
    if (_learnedWordMappings.containsKey(intd) || _learnedWordMappings.values.any((v) => v.intended == obs)) {
      return false; // Prevents multi-step chain
    }

    _learnedWordMappings[obs] = (intended: intd, frequency: frequency);
    return true;
  }

  /// Teaches that [observed] should be DELETED: the recognizer
  /// inserted a word the person never said, and they removed it in
  /// the correction dialog. Stored as a mapping to the empty string —
  /// [applySafeReplacements] drops the word from every future
  /// transcript, so it is never displayed or spoken again. Deliberately
  /// separate from [validateAndAddWordMapping], whose empty-target
  /// rejection protects normal corrections from blank saves.
  bool validateAndAddWordDeletion(String observed, {int frequency = 1}) {
    final obs = _normalize(observed);
    if (obs.isEmpty || obs.contains(' ')) return false;
    _learnedWordMappings[obs] = (intended: '', frequency: frequency);
    return true;
  }

  bool validateAndAddPhraseMapping(String observedPhrase, String intendedPhrase, {int frequency = 1}) {
    final obs = _normalize(observedPhrase);
    final intd = _normalize(intendedPhrase);

    if (obs.isEmpty || intd.isEmpty) return false;
    if (obs == intd) return false;

    if (_learnedPhraseMappings[intd]?.intended == obs) return false;

    _learnedPhraseMappings[obs] = (intended: intd, frequency: frequency);
    return true;
  }

  String applySafeReplacements(String rawTranscript, {double? baseConfidence, double minConfidenceThreshold = 0.5, double confidenceGate = 0.8, int probableMinFrequency = 3}) {
    if (rawTranscript.trim().isEmpty) return rawTranscript;

    final normRaw = _normalize(rawTranscript);

    // Single pass phrase correction check
    if (_learnedPhraseMappings.containsKey(normRaw)) {
      final mapping = _learnedPhraseMappings[normRaw]!;
      if (_evidenceTracker.shouldApplyReplacement(frequency: mapping.frequency, confidence: baseConfidence, confidenceGate: confidenceGate, probableMinFrequency: probableMinFrequency)) {
        // Deletions still apply to the corrected phrase — returning
        // early here used to bypass word-level processing entirely.
        return _applyDeletions(mapping.intended,
            baseConfidence: baseConfidence,
            confidenceGate: confidenceGate,
            probableMinFrequency: probableMinFrequency);
      }
    }

    // Word level single-pass replacement
    final words = rawTranscript.split(' ');
    final resultWords = <String>[];

    for (final word in words) {
      final cleanWord = _normalize(word);
      if (_learnedWordMappings.containsKey(cleanWord)) {
        final mapping = _learnedWordMappings[cleanWord]!;
        if (_evidenceTracker.shouldApplyReplacement(frequency: mapping.frequency, confidence: baseConfidence, confidenceGate: confidenceGate, probableMinFrequency: probableMinFrequency)) {
          final replacement = mapping.intended;
          if (replacement.isEmpty) {
            // Learned deletion — the word is dropped entirely, so it
            // is neither shown nor spoken.
            continue;
          }
          if (word.isNotEmpty && word[0] == word[0].toUpperCase()) {
            resultWords.add(replacement[0].toUpperCase() + replacement.substring(1));
          } else {
            resultWords.add(replacement);
          }
        } else {
          resultWords.add(word);
        }
      } else {
        resultWords.add(word);
      }
    }

    return _applyDeletions(resultWords.join(' '),
        baseConfidence: baseConfidence,
        confidenceGate: confidenceGate,
        probableMinFrequency: probableMinFrequency);
  }

  /// Final pass: learned deletions apply to the RESULT, whichever
  /// path produced it — a phrase correction returning early used to
  /// bypass word-level processing, so a deleted word inside a
  /// corrected phrase could never be removed.
  String _applyDeletions(String text,
      {required double? baseConfidence,
      required double confidenceGate,
      required int probableMinFrequency}) {
    if (text.trim().isEmpty) return text;
    if (!_learnedWordMappings.values.any((m) => m.intended.isEmpty)) {
      return text;
    }
    final kept = <String>[];
    for (final word in text.split(' ')) {
      final mapping = _learnedWordMappings[_normalize(word)];
      if (mapping != null &&
          mapping.intended.isEmpty &&
          _evidenceTracker.shouldApplyReplacement(
              frequency: mapping.frequency,
              confidence: baseConfidence,
              confidenceGate: confidenceGate,
              probableMinFrequency: probableMinFrequency)) {
        continue; // deleted — never displayed, never spoken
      }
      kept.add(word);
    }
    return kept.join(' ');
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  void clear() {
    _learnedWordMappings.clear();
    _learnedPhraseMappings.clear();
  }

  void hydrateMappings(Map<String, ({String intended, int frequency})> mappings) {
    for (final entry in mappings.entries) {
      if (entry.key.contains(' ')) {
        _learnedPhraseMappings[entry.key] = entry.value;
      } else {
        _learnedWordMappings[entry.key] = entry.value;
      }
    }
  }
}
