/// The single source of truth for curated Ewe ↔ English phrases in
/// Kasa Me — the mirror of [TwiPhraseData] for Ewe (Eʋegbe).
///
/// The translation glossary, the Ewe phrasebook seed, and the Ewe voice
/// calibration set are ALL built from this list, so the three can never
/// drift apart: if a phrase is in the phrasebook, it translates, and
/// if it's a calibration phrase, it's in the phrasebook.
///
/// The English side deliberately mirrors the Twi set phrase-for-phrase
/// (same care needs, same categories), so an Ewe-speaking patient gets
/// exactly the communication coverage a Twi-speaking patient gets.
///
/// Phrases are written in standard Ewe orthography (ɛ, ɔ, ŋ, ƒ, ɖ, ɣ).
/// [aliases] hold common spelling variants (including forms written
/// without the special characters) that recognition may produce.
///
/// REVIEW NOTE: these translations were authored carefully for the
/// hackathon build and should be confirmed by a native Ewe speaker
/// before clinical use — the same standard the team applies to every
/// language it ships. The app never invents translations beyond this
/// curated set.
class EwePhrase {
  final String ewe;
  final String english;

  /// Phrasebook category (shown without the "Ewe · " prefix the
  /// phrasebook seed adds).
  final String category;

  final List<String> aliases;

  /// Whether this phrase is one of the Ewe voice-calibration phrases —
  /// chosen to cover Ewe's distinctive sounds (ɛ, ɔ, ŋ, ƒ, ɖ, the gb
  /// and ɣ consonants, nasal vowels) inside phrases a patient actually
  /// needs.
  final bool calibration;

  const EwePhrase(
    this.ewe,
    this.english, {
    required this.category,
    this.aliases = const [],
    this.calibration = false,
  });
}

class EwePhraseData {
  static const List<EwePhrase> phrases = [
    // ── Greetings & courtesy ──────────────────────────────────────────
    EwePhrase('woezɔ', 'Welcome', category: 'Greetings', aliases: ['woezo'], calibration: true),
    EwePhrase('ŋdi na wò', 'Good morning', category: 'Greetings', aliases: ['ndi na wo'], calibration: true),
    EwePhrase('ŋdɔ na wò', 'Good afternoon', category: 'Greetings', aliases: ['ndo na wo']),
    EwePhrase('fiɛyi na wò', 'Good evening', category: 'Greetings', aliases: ['fieyi na wo']),
    EwePhrase('ele ŋutifafa me a', 'How are you?', category: 'Greetings', aliases: ['efɔ̃ a', 'ele ŋutifafa me a?'], calibration: true),
    EwePhrase('meli nyuie', 'I am fine', category: 'Greetings', calibration: true),
    EwePhrase('akpe', 'Thank you', category: 'Greetings'),
    EwePhrase('akpe kaka', 'Thank you very much', category: 'Greetings'),
    EwePhrase('meɖe kuku', 'Please / excuse me', category: 'Greetings', aliases: ['medze kuku', 'meɖe kuku na wò']),
    EwePhrase('hede nyuie', 'Goodbye', category: 'Greetings'),
    EwePhrase('míado go emegbe', 'See you again', category: 'Greetings'),
    EwePhrase('ɖɔ nyuie', 'Sleep well', category: 'Greetings', aliases: ['dzo nyuie']),
    EwePhrase('ɛ̃', 'Yes', category: 'Greetings', aliases: ['ɛɛ̃']),
    EwePhrase('o', 'No', category: 'Greetings'),

    // ── Healthcare ────────────────────────────────────────────────────
    EwePhrase('meɖe kuku, yɔ dokita la nam', 'Please call the doctor for me', category: 'Healthcare', aliases: ['yɔ dokita la nam'], calibration: true),
    EwePhrase('mehiã dokita', 'I need a doctor', category: 'Healthcare', aliases: ['mehia dokita']),
    EwePhrase('mehiã atike', 'I need medicine', category: 'Healthcare', aliases: ['mehia atike'], calibration: true),
    EwePhrase('dɔ le mem', 'I am sick', category: 'Healthcare'),
    EwePhrase('ŋutinye le dzo lém', 'I feel feverish', category: 'Healthcare', aliases: ['ngutinye le dzo lem'], calibration: true),
    EwePhrase('mehiã be makpɔ dokita la', 'I need to see the doctor', category: 'Healthcare'),
    EwePhrase('bia dokita la se', 'Ask the doctor', category: 'Healthcare'),
    EwePhrase('dokita la gbɔna', 'The doctor is coming', category: 'Healthcare'),
    EwePhrase('mayɔ dokita la', 'I will call the doctor', category: 'Healthcare'),
    EwePhrase('atike', 'Medicine', category: 'Healthcare'),
    EwePhrase('dɔléle', 'Sickness', category: 'Healthcare', aliases: ['dolele']),
    EwePhrase('mehiã atike ake', 'I need more medicine', category: 'Healthcare', aliases: ['mehia atike ake']),
    EwePhrase('dɔ le mem ŋutɔ', 'I am very sick', category: 'Healthcare', aliases: ['do le mem nguto']),

    // ── Pain & body ───────────────────────────────────────────────────
    EwePhrase('mele veve me', 'I am in pain', category: 'Pain & Body'),
    EwePhrase('ta le ve nam', 'I have a headache', category: 'Pain & Body', calibration: true),
    EwePhrase('dɔme le ve nam', 'I have a stomach ache', category: 'Pain & Body', aliases: ['dzome le ve nam']),
    EwePhrase('akɔta le ve nam', 'I have chest pain', category: 'Pain & Body', aliases: ['akota le ve nam']),
    EwePhrase('megbe le ve nam', 'My back hurts', category: 'Pain & Body'),
    EwePhrase('afɔ le ve nam', 'My leg hurts', category: 'Pain & Body', aliases: ['afo le ve nam']),
    EwePhrase('asi le ve nam', 'My hand hurts', category: 'Pain & Body'),
    EwePhrase('aɖu le ve nam', 'I have a toothache', category: 'Pain & Body', aliases: ['adzu le ve nam']),
    EwePhrase('kɔ le ve nam', 'I have a sore throat', category: 'Pain & Body', aliases: ['ko le ve nam']),
    EwePhrase('klo le ve nam', 'My knee hurts', category: 'Pain & Body'),
    EwePhrase('ŋku le ve nam', 'My eye hurts', category: 'Pain & Body', aliases: ['nku le ve nam']),
    EwePhrase('to le ve nam', 'My ear hurts', category: 'Pain & Body'),
    EwePhrase('afi ka ve le', 'Where does it hurt?', category: 'Pain & Body', aliases: ['afi ka ve le?']),

    // ── Daily needs ───────────────────────────────────────────────────
    EwePhrase('mehiã tsi', 'I would like some water', category: 'Daily Needs', aliases: ['mehia tsi'], calibration: true),
    EwePhrase('tsi', 'Water', category: 'Daily Needs'),
    EwePhrase('dɔ le wum', 'I am hungry', category: 'Daily Needs', calibration: true),
    EwePhrase('mehiã nuɖuɖu', 'I want food', category: 'Daily Needs', aliases: ['mehia nududu']),
    EwePhrase('mehiã be maɖɔ', 'I want to sleep', category: 'Daily Needs'),
    EwePhrase('meŋu tsɔ̃', 'I am tired', category: 'Daily Needs', aliases: ['mengu tso']),
    EwePhrase('mehiã be mayi ʋɔsaɖe', 'I need the bathroom', category: 'Daily Needs'),
    EwePhrase('mehiã be manɔ anyi', 'I want to sit down', category: 'Daily Needs'),
    EwePhrase('kpe ɖe ŋunye matsi tre', 'Help me get up', category: 'Daily Needs'),
    EwePhrase('tsi akaɖi la', 'Turn on the light', category: 'Daily Needs', aliases: ['tsi akadi la']),
    EwePhrase('tsikɔ le wum', 'I am thirsty', category: 'Daily Needs', aliases: ['tsiko le wum']),
    EwePhrase('mehiã be mayi aƒe me', 'I want to go home', category: 'Daily Needs', aliases: ['mehia be mayi afe me']),
    EwePhrase('mehiã nuɖuɖu ake', 'I want more food', category: 'Daily Needs', aliases: ['mehia nududu ake']),
    EwePhrase('tu akaɖi la', 'Turn off the light', category: 'Daily Needs', aliases: ['tu akadi la']),
    EwePhrase('ʋu ʋɔtru la', 'Open the door', category: 'Daily Needs', aliases: ['vu votru la']),
    EwePhrase('tu ʋɔtru la', 'Close the door', category: 'Daily Needs', aliases: ['tu votru la']),

    // ── Feelings ──────────────────────────────────────────────────────
    EwePhrase('mele vɔ̃m', 'I am afraid', category: 'Feelings', aliases: ['mele vom']),
    EwePhrase('mele nuxaxa me', 'I am sad', category: 'Feelings'),
    EwePhrase('dzidzɔ le ŋunye', 'I am happy', category: 'Feelings', aliases: ['dzidzo le ngunye']),
    EwePhrase('mele nyuie wu tsã', 'I feel better', category: 'Feelings'),
    EwePhrase('vuvɔ le ŋunye', 'I feel cold', category: 'Feelings', aliases: ['vuvo le ngunye']),
    EwePhrase('enyo', 'It is okay', category: 'Feelings'),

    // ── Questions & understanding ─────────────────────────────────────
    EwePhrase('nyemese egɔme o', 'I don\u2019t understand', category: 'Questions', aliases: ['nyemese o', 'nyemese egome o'], calibration: true),
    EwePhrase('gbloe ake', 'Please say that again', category: 'Questions', calibration: true),
    EwePhrase('àte ŋu agbloe ake a', 'Can you repeat that', category: 'Questions'),
    EwePhrase('ŋkɔwò ɖe', 'What is your name?', category: 'Questions', aliases: ['nkowo de', 'ŋkɔwò ɖe?']),
    EwePhrase('nu ka nèhiã', 'What do you want?', category: 'Questions', aliases: ['nu ka nehia', 'nu ka nèhiã?']),
    EwePhrase('ɣe ka ɣi nàva', 'When will you come?', category: 'Questions', aliases: ['ghe ka ghi nava', 'ɣe ka ɣi nàva?']),
    EwePhrase('èhiã atike a', 'Do you need medicine?', category: 'Questions', aliases: ['ehia atike a', 'èhiã atike a?']),
    EwePhrase('èhiã tsi a', 'Would you like some water?', category: 'Questions', aliases: ['ehia tsi a', 'èhiã tsi a?']),
    EwePhrase('meɖe kuku, lala ɣaɖe', 'Please wait a moment', category: 'Questions', aliases: ['lala ɣaɖe', 'lala gade'], calibration: true),
    EwePhrase('ese gɔme a', 'Do you understand?', category: 'Questions', aliases: ['ese gome a', 'ese gɔme a?']),
    EwePhrase('meŋlɔ be', 'I forgot', category: 'Questions', aliases: ['menglo be']),

    // ── Family & people ───────────────────────────────────────────────
    EwePhrase('meɖe kuku, yɔ danye nam', 'Please call my mother for me', category: 'Family & People'),
    EwePhrase('meɖe kuku, yɔ tɔnye nam', 'Please call my father for me', category: 'Family & People'),
    EwePhrase('mehiã be makpɔ ƒonyemetɔwo', 'I want to see my family', category: 'Family & People', aliases: ['mehia be makpo fonyemetowo']),
    EwePhrase('danye gbɔna', 'My mother is coming', category: 'Family & People'),
    EwePhrase('tɔnye gbɔna', 'My father is coming', category: 'Family & People'),
    EwePhrase('mehiã be makpɔ wò', 'I want to see you', category: 'Family & People', aliases: ['mehia be makpo wo']),

    // ── Money & market ────────────────────────────────────────────────
    EwePhrase('nenie', 'How much is it?', category: 'Money & Market', aliases: ['nenie?', 'eƒe homee nenie?']),
    EwePhrase('ga le asinye', 'I have money', category: 'Money & Market'),
    EwePhrase('ga la mesu o', 'The money is not enough', category: 'Money & Market'),
    EwePhrase('mehiã be maƒle nuɖuɖu', 'I want to buy food', category: 'Money & Market', aliases: ['mehia be mafle nududu']),
    EwePhrase('afi ka bank la le', 'Where is the bank?', category: 'Money & Market', aliases: ['afi ka bank la le?']),
    EwePhrase('mehiã be maɖe ga le bank', 'I want to withdraw money', category: 'Money & Market'),
    EwePhrase('ga mele asinye o', 'I have no money', category: 'Money & Market'),
    EwePhrase('mehiã be maƒle tsi', 'I want to buy water', category: 'Money & Market', aliases: ['mehia be mafle tsi']),
    EwePhrase('afi ka station la le', 'Where is the station?', category: 'Travel', aliases: ['afi ka station la le?']),
    EwePhrase('afi ka asi la le', 'Where is the market?', category: 'Travel', aliases: ['afi ka asi la le?']),

    // ── Emergency ─────────────────────────────────────────────────────
    EwePhrase('kpe ɖe ŋunye', 'Help me', category: 'Emergency', aliases: ['kpe de ngunye'], calibration: true),
    EwePhrase('mehiã kpeɖeŋu', 'I need help', category: 'Emergency', aliases: ['mehia kpedzenu']),
    EwePhrase('yɔ ambulance la', 'Call an ambulance', category: 'Emergency'),
    EwePhrase('dzo', 'Fire!', category: 'Emergency'),
    EwePhrase('kpe ɖe ŋunye kaba', 'Help me quickly', category: 'Emergency', aliases: ['kpe de ngunye kaba']),
    EwePhrase('va kaba', 'Come quickly', category: 'Emergency'),
  ];

  /// The Ewe voice-calibration set, in teaching order.
  static List<EwePhrase> get calibrationSet =>
      phrases.where((p) => p.calibration).toList(growable: false);
}
