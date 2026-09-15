class PersonalizationSafetyGuard {
  final Map<String, String> _learnedWordMappings = {};
  final Map<String, String> _learnedPhraseMappings = {};

  bool validateAndAddWordMapping(String observed, String intended, {String language = 'en_GH', int frequency = 1}) {
    final obs = _normalize(observed);
    final intd = _normalize(intended);

    if (obs.isEmpty || intd.isEmpty) return false;
    if (obs == intd) return false;

    // Cycle / Loop Detection (A -> B -> A)
    if (_learnedWordMappings[intd] == obs) {
      return false;
    }

    // Cascading Rewrite Prevention (A -> B, B -> C)
    if (_learnedWordMappings.containsKey(intd) || _learnedWordMappings.containsValue(obs)) {
      return false; // Prevents multi-step chain
    }

    _learnedWordMappings[obs] = intd;
    return true;
  }

  bool validateAndAddPhraseMapping(String observedPhrase, String intendedPhrase, {int frequency = 1}) {
    final obs = _normalize(observedPhrase);
    final intd = _normalize(intendedPhrase);

    if (obs.isEmpty || intd.isEmpty) return false;
    if (obs == intd) return false;

    if (_learnedPhraseMappings[intd] == obs) return false;

    _learnedPhraseMappings[obs] = intd;
    return true;
  }

  String applySafeReplacements(String rawTranscript, {double baseConfidence = 0.8, double minConfidenceThreshold = 0.5}) {
    if (rawTranscript.trim().isEmpty) return rawTranscript;

    final normRaw = _normalize(rawTranscript);

    // Single pass phrase correction check
    if (_learnedPhraseMappings.containsKey(normRaw)) {
      return _learnedPhraseMappings[normRaw]!;
    }

    // Word level single-pass replacement
    final words = rawTranscript.split(' ');
    final resultWords = <String>[];

    for (final word in words) {
      final cleanWord = _normalize(word);
      if (_learnedWordMappings.containsKey(cleanWord)) {
        final replacement = _learnedWordMappings[cleanWord]!;
        if (word.isNotEmpty && word[0] == word[0].toUpperCase()) {
          resultWords.add(replacement[0].toUpperCase() + replacement.substring(1));
        } else {
          resultWords.add(replacement);
        }
      } else {
        resultWords.add(word);
      }
    }

    return resultWords.join(' ');
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  void clear() {
    _learnedWordMappings.clear();
    _learnedPhraseMappings.clear();
  }
}
