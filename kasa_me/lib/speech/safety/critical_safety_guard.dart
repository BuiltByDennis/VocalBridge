class SafetyEvaluation {
  final bool isHighImpact;
  final List<String> flaggedTerms;

  const SafetyEvaluation({
    required this.isHighImpact,
    this.flaggedTerms = const [],
  });
}

class CriticalSafetyGuard {
  static const List<String> _criticalKeywords = [
    // Medical / Dosage
    'insulin', 'pain', 'pill', 'mg', 'doctor', 'emergency', 'ambulance', 'hospital', 'medicine', 'sick',
    // Financial
    'gh₵', 'cedis', 'momo', 'mobile money', 'bank', 'transfer', 'pay', 'money', 'cash', 'account'
  ];

  static final RegExp _amountPattern = RegExp(r'\b\d+(\.\d{1,2})?\b');

  SafetyEvaluation evaluateTranscript({
    required String rawTranscript,
    required String personalizedTranscript,
    required double? confidence,
  }) {
    final rawLower = rawTranscript.toLowerCase();
    final persLower = personalizedTranscript.toLowerCase();
    
    final List<String> flaggedTerms = [];
    bool isHighImpact = false;

    // Check if any critical term was present
    for (final keyword in _criticalKeywords) {
      final wasInRaw = rawLower.contains(keyword);
      final isInPersonalized = persLower.contains(keyword);

      // If it was rewritten, OR it's present and confidence is low (< 0.70)
      if (isInPersonalized || wasInRaw) {
        if (isInPersonalized != wasInRaw || (confidence != null && confidence < 0.70)) {
          isHighImpact = true;
          flaggedTerms.add(keyword);
        }
      }
    }

    // Check for numerical amounts if they are modified or low confidence
    if (_amountPattern.hasMatch(persLower) || _amountPattern.hasMatch(rawLower)) {
      final rawAmount = _amountPattern.firstMatch(rawLower)?.group(0);
      final persAmount = _amountPattern.firstMatch(persLower)?.group(0);

      if (rawAmount != persAmount || (confidence != null && confidence < 0.70)) {
        isHighImpact = true;
        if (persAmount != null) {
          flaggedTerms.add(persAmount);
        } else if (rawAmount != null) {
          flaggedTerms.add(rawAmount);
        }
      }
    }

    return SafetyEvaluation(
      isHighImpact: isHighImpact,
      flaggedTerms: flaggedTerms.toSet().toList(), // Remove duplicates
    );
  }
}
