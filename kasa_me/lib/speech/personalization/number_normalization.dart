class NumberNormalizationService {
  static const Map<String, String> wordToNumber = {
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9',
    'ten': '10',
    'twenty': '20',
    'fifty': '50',
    'hundred': '100',
  };

  static String normalizeGhanainCurrencyAndNumbers(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // Ghanaian cedi expressions
    result = result.replaceAll(RegExp(r'\bghana cedis\b', caseSensitive: false), 'GH₵');
    result = result.replaceAll(RegExp(r'\bcedis\b', caseSensitive: false), 'GH₵');
    result = result.replaceAll(RegExp(r'\bcedi\b', caseSensitive: false), 'GH₵');

    // Mobile Money expressions
    result = result.replaceAll(RegExp(r'\bmomo\b', caseSensitive: false), 'MoMo');
    result = result.replaceAll(RegExp(r'\bmobile money\b', caseSensitive: false), 'MoMo');

    return result;
  }
}
