import 'translation_service.dart';

/// Offline Twi ↔ English glossary for the care scenario
/// (hospital ward: patient ↔ nurse/caregiver).
///
/// This is a **curated phrasebook**, not full machine translation: it covers
/// the high-frequency needs of a non-verbal patient (pain, water, medicine,
/// help, calling the doctor) plus common caregiver prompts. Lookup is
/// exact-match on normalized text, so coverage is honest and predictable —
/// anything outside the glossary returns `null` and the UI says so.
///
/// When the UG HCI Lab API offers translation, a [LabTranslationService]
/// can implement [TranslationService] and take over this pair without any
/// UI changes.
class DictionaryTranslationService implements TranslationService {
  /// (twi, english) pairs. Aliases cover common spelling variants.
  static const List<(String, String, List<String>)> _pairs = [
    // ── Patient needs (Twi → English) ──
    ('me ho yɛ me hye', 'I feel feverish', []),
    ('me tiri yɛ me ya', 'I have a headache', []),
    ('me yafunu yɛ me ya', 'I have stomach ache', []),
    ('me akoma yɛ me ya', 'I have chest pain', []),
    ('me pɛ nsuo', 'I would like some water', ['me pɛ nsu']),
    ('me pɛ aduro', 'I need medicine', []),
    ('frɛ dokota ma me', 'Please call the doctor for me', ['frɛ dokota']),
    ('boa me', 'Help me', []),
    ('mepa wo kyɛw', 'Please / excuse me', ['mepa wo kyew']),
    ('me da w\u2019ase', 'Thank you', ['me da wase', 'me da ase']),
    ('yiw', 'Yes', []),
    ('daabi', 'No', ['dabi']),
    ('ɛyɛ', 'It is okay', ['eyɛ']),
    ('me nte aseɛ', 'I don\u2019t understand', ['me nte asee', 'me nte ase']),
    ('wo ho te sɛn', 'How are you feeling?', []),
    ('me ho yɛ', 'I am fine', []),
    ('maakye', 'Good morning', []),
    ('maaha', 'Good afternoon', []),
    ('maadwo', 'Good evening', []),
    ('me kɔm de me', 'I am hungry', ['me kom de me']),
    ('ka biom', 'Please say that again', []),
    ('bisa dokota', 'Ask the doctor', []),
    ('nsuo', 'Water', ['nsu']),
    ('aduro', 'Medicine', []),
    ('yareɛ', 'Sickness', ['yaree']),
    // ── Caregiver prompts (English → Twi) ──
    ('wo ho te sɛn', 'How are you feeling?', []), // shared, both directions
    ('wo pɛ aduro', 'Do you need medicine?', ['wo pɛ aduro?']),
    ('wo pɛ nsuo', 'Would you like some water?', ['wo pɛ nsuo?']),
    ('dokota no reba', 'The doctor is coming', []),
    ('mɛfrɛ dokota', 'I will call the doctor', ['mefrɛ dokota']),
    ('twɛn kakra', 'Please wait a moment', ['mepa wo kyɛw, twɛn kakra']),
    ('ɛhefa na ɛyɛ wo ya', 'Where does it hurt?', ['ɛhefa na ɛyɛ wo ya?']),
  ];

  late final Map<String, String> _twiToEn = _buildMap((twi, en) => MapEntry(twi, en));
  late final Map<String, String> _enToTwi = _buildMap((twi, en) => MapEntry(en, twi));

  static Map<String, String> _buildMap(MapEntry<String, String> Function(String twi, String en) dir) {
    final map = <String, String>{};
    for (final (twi, en, aliases) in _pairs) {
      final entry = dir(_normalize(twi), _normalize(en));
      map.putIfAbsent(entry.key, () => entry.value);
      if (entry.key == _normalize(twi)) {
        for (final a in aliases) {
          map.putIfAbsent(_normalize(a), () => entry.value);
        }
      }
    }
    return map;
  }

  static String _normalize(String s) {
    var t = s.toLowerCase().trim();
    t = t.replaceAll(RegExp(r'[.?!\u2026]+$'), '');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }

  @override
  bool supportsPair(String from, String to) {
    return (from == 'twi' && to == 'en_GH') ||
        (from == 'en_GH' && to == 'twi');
  }

  @override
  String? translate(String text, {required String from, required String to}) {
    if (!supportsPair(from, to)) return null;
    final key = _normalize(text);
    if (key.isEmpty) return null;
    if (from == 'twi') return _twiToEn[key];
    return _enToTwi[key];
  }
}
