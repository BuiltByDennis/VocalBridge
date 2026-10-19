enum FrequencyTier {
  tentative,
  probable,
  learned,
}

class EvidenceTracker {
  static const int tentativeMinFrequency = 1;
  static const int probableMinFrequency = 3;
  static const int learnedMinFrequency = 5;

  /// [probableMinFrequency] is the frequency at which a correction
  /// becomes "probable". It is NOT fixed: the person's SpeechBehavior
  /// sets it (SpeechBehavior.minMappingFrequency — 2 for cerebral
  /// palsy / stroke / cleft, whose Settings copy promises corrections
  /// after 2 examples; 3 otherwise). Before it was plumbed through,
  /// this class silently used 3 for everyone, so frequency-2
  /// corrections the repository had loaded for those profiles were
  /// classified tentative here and never applied.
  FrequencyTier getTier(int frequency, {int probableMinFrequency = 3}) {
    if (frequency >= learnedMinFrequency) return FrequencyTier.learned;
    if (frequency >= probableMinFrequency) return FrequencyTier.probable;
    return FrequencyTier.tentative;
  }

  bool shouldApplyReplacement({
    required int frequency,
    double? confidence,
    double confidenceGate = 0.8,
    int probableMinFrequency = 3,
  }) {
    final tier = getTier(frequency, probableMinFrequency: probableMinFrequency);

    switch (tier) {
      case FrequencyTier.tentative:
        // Tentative tier matches are not auto-applied.
        return false;
      case FrequencyTier.probable:
        // Probable tier matches are auto-applied if confidence is below
        // [confidenceGate] or if confidence is unavailable. The gate
        // comes from the person's SpeechBehavior: for atypical speech
        // the recognizer's confidence is unreliable, so their profile
        // raises the gate and their learned patterns win more often.
        return confidence == null || confidence < confidenceGate;
      case FrequencyTier.learned:
        // Learned tier matches are always applied.
        return true;
    }
  }
}
