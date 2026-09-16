class CalibrationPhrase {
  final String id;
  final String phrase;
  final String category;
  final String language;

  const CalibrationPhrase({
    required this.id,
    required this.phrase,
    required this.category,
    this.language = 'en_GH',
  });
}

class CalibrationPhraseSet {
  static const List<CalibrationPhrase> defaultPhrases = [
    CalibrationPhrase(id: 'c01', phrase: 'I need water', category: 'everyday'),
    CalibrationPhrase(id: 'c02', phrase: 'Please help me', category: 'everyday'),
    CalibrationPhrase(id: 'c03', phrase: 'I am hungry', category: 'everyday'),
    CalibrationPhrase(id: 'c04', phrase: 'I am in pain', category: 'healthcare'),
    CalibrationPhrase(id: 'c05', phrase: 'I need my medicine', category: 'healthcare'),
    CalibrationPhrase(id: 'c06', phrase: 'Call for help', category: 'emergency'),
    CalibrationPhrase(id: 'c07', phrase: 'Call my mother', category: 'emergency'),
    CalibrationPhrase(id: 'c08', phrase: 'How much does this cost', category: 'commerce'),
    CalibrationPhrase(id: 'c09', phrase: 'Send fifty Ghana cedis', category: 'mobile_money'),
    CalibrationPhrase(id: 'c10', phrase: 'Where is the hospital', category: 'questions'),
  ];
}
