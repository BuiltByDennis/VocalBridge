import 'twi_phrase_data.dart';
import 'translation_service.dart';

/// Offline Twi ↔ English translation for Kasa Me.
///
/// Coverage is layered, and every layer is deterministic dictionary
/// behaviour — the service never invents a translation:
///
/// 1. **Curated phrases** ([TwiPhraseData], ~60 care/daily-life phrases):
///    exact match on normalized, diacritic-folded text. ASR output that
///    drops ɛ/ɔ still matches, because keys fold ɛ→e and ɔ→o.
/// 2. **Near-miss phrases**: a small edit distance or the same words in a
///    different order still finds the curated phrase (recognition is
///    imperfect, especially for atypical speech).
/// 3. **Word-for-word gloss**: if *every* word of the input is in the
///    vocabulary below, the words' dictionary glosses are joined. This
///    makes simple new sentences understandable ("me pɛ aduane pa" →
///    "I want food good") without pretending to be grammar-aware MT.
///    If even one word is unknown, the result is `null` — no guessing.
/// 4. Otherwise `null`, and the UI honestly says no gloss is available.
///
/// When the UG HCI Lab API offers translation, a [LabTranslationService]
/// can implement [TranslationService] and take over this pair without any
/// UI changes.
class DictionaryTranslationService implements TranslationService {
  late final Map<String, String> _twiToEn = _buildPhraseMap(twiSide: true);
  late final Map<String, String> _enToTwi = _buildPhraseMap(twiSide: false);
  late final Map<String, String> _twiWordToEn = _buildWordMap(twiSide: true);
  late final Map<String, String> _enWordToTwi = _buildWordMap(twiSide: false);

  /// (twi word, english word) vocabulary for the word-for-word gloss.
  /// Multi-word values are fine; an empty English value means the word
  /// carries no separate gloss in that direction (e.g. articles).
  static const List<(String, String)> _words = [
    ('me', 'I'), ('wo', 'you'), ('ɔno', 'he / she'), ('yɛn', 'we'),
    ('mo', 'you all'), ('wɔn', 'they'),
    ('me', 'my'), // possessive "me" precedes the noun in Twi: me tiri = my head
    ('ne', 'his / her'), ('yɛn', 'our'), ('wɔn', 'their'),
    ('pɛ', 'want'), ('hia', 'need'), ('kɔ', 'go'), ('ba', 'come'),
    ('reba', 'is coming'), ('yɛ', 'is'), ('yɛ', 'do'), ('te', 'hear'),
    ('hu', 'see'), ('ka', 'say'), ('ma', 'give'), ('fa', 'take'),
    ('nom', 'drink'), ('da', 'sleep'), ('sɔre', 'get up'),
    ('tena', 'sit'), ('gyina', 'stand'), ('frɛ', 'call'), ('bisa', 'ask'),
    ('boa', 'help'), ('tɔ', 'buy'), ('tɔn', 'sell'), ('kɔm', 'hunger'),
    ('nsuo', 'water'), ('aduane', 'food'), ('aduro', 'medicine'),
    ('dokota', 'doctor'), ('sika', 'money'), ('fie', 'home'),
    ('yareɛ', 'sickness'), ('maame', 'mother'), ('papa', 'father'),
    ('nua', 'sibling'), ('adamfo', 'friend'), ('abɔfra', 'child'),
    ('abusua', 'family'), ('tiri', 'head'), ('yafunu', 'stomach'),
    ('akoma', 'chest'), ('akyi', 'back'), ('nan', 'leg'), ('nsa', 'hand'),
    ('se', 'tooth'), ('kɔn', 'throat'), ('ani', 'eye'), ('aso', 'ear'),
    ('ya', 'pain'), ('hye', 'hot'), ('hye', 'fever'), ('pa', 'good'),
    ('kɛse', 'big'), ('ketewa', 'small'), ('dɛ', 'sweet'), ('brɛ', 'tired'),
    ('suro', 'afraid'), ('din', 'name'), ('da', 'day'), ('bio', 'again'),
    ('kakra', 'a little'), ('nnɛ', 'today'), ('ɔkyena', 'tomorrow'),
    ('nnera', 'yesterday'), ('seesei', 'now'), ('akyiri', 'later'),
    ('he', 'where'), ('dɛn', 'what'), ('bɛn', 'when'), ('sɛn', 'how'),
    ('no', 'the'), ('na', 'and'), ('anaa', 'or'), ('nso', 'also'),
    ('yiye', 'well'), ('ogya', 'fire'), ('mmoa', 'help'),
    ('ho', 'body'), ('ase', 'understanding'),
  ];

  static Map<String, String> _buildPhraseMap({required bool twiSide}) {
    final map = <String, String>{};
    for (final p in TwiPhraseData.phrases) {
      final from = twiSide ? p.twi : p.english;
      final to = twiSide ? p.english : p.twi;
      map.putIfAbsent(_key(from), () => to);
      if (twiSide) {
        for (final a in p.aliases) {
          map.putIfAbsent(_key(a), () => to);
        }
      }
    }
    return map;
  }

  static Map<String, String> _buildWordMap({required bool twiSide}) {
    final map = <String, String>{};
    for (final (twi, en) in _words) {
      final from = twiSide ? twi : en;
      final to = twiSide ? en : twi;
      // First entry wins for ambiguous words (e.g. 'me' → 'I' before 'my'
      // on the English side, where keys collide less).
      map.putIfAbsent(_key(from), () => to);
    }
    return map;
  }

  /// Lookup key: lowercase, punctuation-light, whitespace-collapsed, and
  /// diacritic-folded (ɛ→e, ɔ→o) so recognition output written without
  /// the special Twi characters still finds its phrase.
  static String _key(String s) {
    var t = s.toLowerCase().trim();
    t = t.replaceAll('\u2019', "'");
    t = t.replaceAll(RegExp(r'[.?!,;:]+'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    t = t.replaceAll('ɛ', 'e').replaceAll('ɔ', 'o');
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
    final key = _key(text);
    if (key.isEmpty) return null;

    final phrases = from == 'twi' ? _twiToEn : _enToTwi;
    final words = from == 'twi' ? _twiWordToEn : _enWordToTwi;

    // 1. Exact curated phrase.
    final exact = phrases[key];
    if (exact != null) return exact;

    // 2. Near-miss curated phrase (small typo / word order shuffle).
    final fuzzy = _fuzzyPhraseMatch(key, phrases);
    if (fuzzy != null) return fuzzy;

    // 3. Word-for-word gloss — only when EVERY word is known.
    return _wordGloss(key, words);
  }

  String? _fuzzyPhraseMatch(String key, Map<String, String> phrases) {
    if (key.length < 5) return null;
    final keyTokens = key.split(' ').toSet();
    String? best;
    var bestScore = 0.0;
    for (final candidate in phrases.keys) {
      if ((candidate.length - key.length).abs() > 4) continue;
      // Same words, different order — recognition often shuffles.
      final candidateTokens = candidate.split(' ').toSet();
      if (candidateTokens.length == keyTokens.length &&
          candidateTokens.containsAll(keyTokens)) {
        return phrases[candidate];
      }
      final dist = _levenshtein(key, candidate);
      final score = 1.0 - dist / (key.length > candidate.length ? key.length : candidate.length);
      if (score > bestScore) {
        bestScore = score;
        best = phrases[candidate];
      }
    }
    // Conservative: ~1 wrong character in 7 or better.
    return bestScore >= 0.86 ? best : null;
  }

  String? _wordGloss(String key, Map<String, String> words) {
    final tokens = key.split(' ');
    if (tokens.length < 2) return null; // single unknown words stay untranslated
    final out = <String>[];
    for (final token in tokens) {
      final gloss = words[token];
      if (gloss == null) return null; // one unknown word → no guessing
      if (gloss.isNotEmpty) out.add(gloss);
    }
    if (out.isEmpty) return null;
    final joined = out.join(' ');
    return joined[0].toUpperCase() + joined.substring(1);
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        var v = prev[j] + 1;
        if (curr[j - 1] + 1 < v) v = curr[j - 1] + 1;
        if (prev[j - 1] + cost < v) v = prev[j - 1] + cost;
        curr[j] = v;
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[b.length];
  }
}
