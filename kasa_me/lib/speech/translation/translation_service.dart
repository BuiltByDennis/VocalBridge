/// Contract for translating recognized speech between the app's languages.
///
/// Implementations must NEVER guess: [translate] returns `null` when no
/// translation is available, and the UI shows an honest "no gloss yet"
/// note instead of a fabricated translation. In a care setting a wrong
/// translation is worse than none.
abstract class TranslationService {
  /// Translates [text] from language [from] to language [to].
  ///
  /// Language codes are the app's codes: 'twi', 'en_GH', 'ewe', 'dagbani'.
  /// Returns `null` when the service cannot translate the text.
  String? translate(String text, {required String from, required String to});

  /// Whether the service can translate the given language pair at all.
  bool supportsPair(String from, String to);
}
