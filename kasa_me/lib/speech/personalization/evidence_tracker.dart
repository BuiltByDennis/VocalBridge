enum FrequencyTier {
  tentative,
  probable,
  learned,
}

class EvidenceTracker {
  static const int tentativeMinFrequency = 1;
  static const int probableMinFrequency = 3;
  static const int learnedMinFrequency = 5;

  FrequencyTier getTier(int frequency) {
    if (frequency >= learnedMinFrequency) return FrequencyTier.learned;
    if (frequency >= probableMinFrequency) return FrequencyTier.probable;
    return FrequencyTier.tentative;
  }

  bool shouldApplyReplacement({
    required int frequency,
    double? confidence,
  }) {
    final tier = getTier(frequency);

    switch (tier) {
      case FrequencyTier.tentative:
        // Tentative tier matches are not auto-applied.
        return false;
      case FrequencyTier.probable:
        // Probable tier matches are auto-applied if confidence is low/medium (< 0.8)
        // or if confidence is unavailable.
        return confidence == null || confidence < 0.8;
      case FrequencyTier.learned:
        // Learned tier matches are always applied.
        return true;
    }
  }
}
