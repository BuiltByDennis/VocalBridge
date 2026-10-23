/// The single source of truth for curated Twi ↔ English phrases in Kasa Me.
///
/// The translation glossary, the Twi phrasebook seed, and the Twi voice
/// calibration set are ALL built from this list, so the three can never
/// drift apart: if a phrase is in the phrasebook, it translates, and if
/// it's a calibration phrase, it's in the phrasebook.
///
/// Phrases are written in standard Asante Twi orthography (with ɛ and ɔ).
/// [aliases] hold common spelling variants (including forms written
/// without the special characters) that recognition may produce.
class TwiPhrase {
  final String twi;
  final String english;

  /// Phrasebook category (shown without the "Twi · " prefix the
  /// phrasebook seed adds).
  final String category;

  final List<String> aliases;

  /// Whether this phrase is one of the Twi voice-calibration phrases —
  /// chosen to cover Twi's distinctive sounds (ɛ, ɔ, ky/gy/tw/dw
  /// digraphs, common syllable patterns) inside phrases a patient
  /// actually needs.
  final bool calibration;

  const TwiPhrase(
    this.twi,
    this.english, {
    required this.category,
    this.aliases = const [],
    this.calibration = false,
  });
}

class TwiPhraseData {
  static const List<TwiPhrase> phrases = [
    // ── Greetings & courtesy ──────────────────────────────────────────
    TwiPhrase('akwaaba', 'Welcome', category: 'Greetings'),
    TwiPhrase('maakye', 'Good morning', category: 'Greetings', calibration: true),
    TwiPhrase('maaha', 'Good afternoon', category: 'Greetings'),
    TwiPhrase('maadwo', 'Good evening', category: 'Greetings'),
    TwiPhrase('wo ho te sɛn', 'How are you?', category: 'Greetings', aliases: ['wo ho te sɛn?'], calibration: true),
    TwiPhrase('me ho yɛ', 'I am fine', category: 'Greetings', calibration: true),
    TwiPhrase('me da w\u2019ase', 'Thank you', category: 'Greetings', aliases: ['me da wase', 'me da ase'], calibration: true),
    TwiPhrase('me da w\u2019ase paa', 'Thank you very much', category: 'Greetings'),
    TwiPhrase('mepa wo kyɛw', 'Please / excuse me', category: 'Greetings', aliases: ['mepa wo kyew']),
    TwiPhrase('nante yie', 'Goodbye', category: 'Greetings'),
    TwiPhrase('yɛbɛhyia bio', 'See you again', category: 'Greetings'),
    TwiPhrase('da yiye', 'Sleep well', category: 'Greetings'),
    TwiPhrase('yiw', 'Yes', category: 'Greetings'),
    TwiPhrase('daabi', 'No', category: 'Greetings', aliases: ['dabi']),

    // ── Healthcare ────────────────────────────────────────────────────
    TwiPhrase('frɛ dokota ma me', 'Please call the doctor for me', category: 'Healthcare', aliases: ['frɛ dokota'], calibration: true),
    TwiPhrase('me hia dokota', 'I need a doctor', category: 'Healthcare'),
    TwiPhrase('me pɛ aduro', 'I need medicine', category: 'Healthcare', calibration: true),
    TwiPhrase('me yare', 'I am sick', category: 'Healthcare'),
    TwiPhrase('me ho yɛ me hye', 'I feel feverish', category: 'Healthcare', calibration: true),
    TwiPhrase('me pɛ hu dokota', 'I need to see the doctor', category: 'Healthcare'),
    TwiPhrase('bisa dokota', 'Ask the doctor', category: 'Healthcare'),
    TwiPhrase('dokota no reba', 'The doctor is coming', category: 'Healthcare'),
    TwiPhrase('mɛfrɛ dokota', 'I will call the doctor', category: 'Healthcare', aliases: ['mefrɛ dokota']),
    TwiPhrase('aduro', 'Medicine', category: 'Healthcare'),
    TwiPhrase('yareɛ', 'Sickness', category: 'Healthcare', aliases: ['yaree']),
    TwiPhrase('me pɛ aduro bio', 'I need more medicine', category: 'Healthcare'),
    TwiPhrase('me yare paa', 'I am very sick', category: 'Healthcare'),

    // ── Pain & body ───────────────────────────────────────────────────
    TwiPhrase('me ho yɛ me ya', 'I am in pain', category: 'Pain & Body'),
    TwiPhrase('me tiri yɛ me ya', 'I have a headache', category: 'Pain & Body', calibration: true),
    TwiPhrase('me yafunu yɛ me ya', 'I have a stomach ache', category: 'Pain & Body'),
    TwiPhrase('me akoma yɛ me ya', 'I have chest pain', category: 'Pain & Body'),
    TwiPhrase('me akyi yɛ me ya', 'My back hurts', category: 'Pain & Body'),
    TwiPhrase('me nan yɛ me ya', 'My leg hurts', category: 'Pain & Body'),
    TwiPhrase('me nsa yɛ me ya', 'My hand hurts', category: 'Pain & Body'),
    TwiPhrase('me se yɛ me ya', 'I have a toothache', category: 'Pain & Body'),
    TwiPhrase('me kɔn yɛ me ya', 'I have a sore throat', category: 'Pain & Body'),
    TwiPhrase('me nkotodwe yɛ me ya', 'My knee hurts', category: 'Pain & Body'),
    TwiPhrase('me ani yɛ me ya', 'My eye hurts', category: 'Pain & Body'),
    TwiPhrase('me aso yɛ me ya', 'My ear hurts', category: 'Pain & Body'),
    TwiPhrase('ɛhefa na ɛyɛ wo ya', 'Where does it hurt?', category: 'Pain & Body', aliases: ['ɛhefa na ɛyɛ wo ya?']),

    // ── Daily needs ───────────────────────────────────────────────────
    TwiPhrase('me pɛ nsuo', 'I would like some water', category: 'Daily Needs', aliases: ['me pɛ nsu'], calibration: true),
    TwiPhrase('nsuo', 'Water', category: 'Daily Needs', aliases: ['nsu']),
    TwiPhrase('me kɔm de me', 'I am hungry', category: 'Daily Needs', aliases: ['me kom de me'], calibration: true),
    TwiPhrase('me pɛ aduane', 'I want food', category: 'Daily Needs'),
    TwiPhrase('me pɛ me da', 'I want to sleep', category: 'Daily Needs'),
    TwiPhrase('me yɛ brɛ', 'I am tired', category: 'Daily Needs'),
    TwiPhrase('me pɛ kɔ aguarebea', 'I need the bathroom', category: 'Daily Needs'),
    TwiPhrase('me pɛ tena ase', 'I want to sit down', category: 'Daily Needs'),
    TwiPhrase('boa me ma mensɔre', 'Help me get up', category: 'Daily Needs'),
    TwiPhrase('sɔ kanea no', 'Turn on the light', category: 'Daily Needs'),
    TwiPhrase('sukɔm de me', 'I am thirsty', category: 'Daily Needs', aliases: ['sukom de me']),
    TwiPhrase('me pɛ kɔ fie', 'I want to go home', category: 'Daily Needs'),
    TwiPhrase('me pɛ aduane bio', 'I want more food', category: 'Daily Needs'),
    TwiPhrase('kum kanea no', 'Turn off the light', category: 'Daily Needs'),
    TwiPhrase('bue ɛpono no', 'Open the door', category: 'Daily Needs'),
    TwiPhrase('to ɛpono no mu', 'Close the door', category: 'Daily Needs'),

    // ── Feelings ──────────────────────────────────────────────────────
    TwiPhrase('me suro', 'I am afraid', category: 'Feelings'),
    TwiPhrase('me werɛ aho', 'I am sad', category: 'Feelings'),
    TwiPhrase('me ani gye', 'I am happy', category: 'Feelings'),
    TwiPhrase('me ho atɔ me', 'I feel better', category: 'Feelings'),
    TwiPhrase('awɔ de me', 'I feel cold', category: 'Feelings'),
    TwiPhrase('ɛyɛ', 'It is okay', category: 'Feelings', aliases: ['eyɛ']),

    // ── Questions & understanding ─────────────────────────────────────
    TwiPhrase('me nte aseɛ', 'I don\u2019t understand', category: 'Questions', aliases: ['me nte asee', 'me nte ase'], calibration: true),
    TwiPhrase('ka biom', 'Please say that again', category: 'Questions', calibration: true),
    TwiPhrase('ka biom', 'Can you repeat that', category: 'Questions'),
    TwiPhrase('wo din de sɛn', 'What is your name?', category: 'Questions', aliases: ['wo din de sɛn?']),
    TwiPhrase('wopɛ dɛn', 'What do you want?', category: 'Questions', aliases: ['wopɛ dɛn?']),
    TwiPhrase('wobɛba da bɛn', 'When will you come?', category: 'Questions', aliases: ['wobɛba da bɛn?']),
    TwiPhrase('wo pɛ aduro', 'Do you need medicine?', category: 'Questions', aliases: ['wo pɛ aduro?']),
    TwiPhrase('wo pɛ nsuo', 'Would you like some water?', category: 'Questions', aliases: ['wo pɛ nsuo?']),
    TwiPhrase('twɛn kakra', 'Please wait a moment', category: 'Questions', aliases: ['mepa wo kyɛw, twɛn kakra'], calibration: true),
    TwiPhrase('wo te aseɛ', 'Do you understand?', category: 'Questions', aliases: ['wo te aseɛ?']),
    TwiPhrase('me werɛ afiri', 'I forgot', category: 'Questions'),

    // ── Family & people ───────────────────────────────────────────────
    TwiPhrase('frɛ me maame ma me', 'Please call my mother for me', category: 'Family & People'),
    TwiPhrase('frɛ me papa ma me', 'Please call my father for me', category: 'Family & People'),
    TwiPhrase('me pɛ hu me abusua', 'I want to see my family', category: 'Family & People'),
    TwiPhrase('me maame reba', 'My mother is coming', category: 'Family & People'),
    TwiPhrase('me papa reba', 'My father is coming', category: 'Family & People'),
    TwiPhrase('me pɛ hu wo', 'I want to see you', category: 'Family & People'),

    // ── Money & market ────────────────────────────────────────────────
    TwiPhrase('ɛyɛ sɛn', 'How much is it?', category: 'Money & Market', aliases: ['ɛyɛ sɛn?']),
    TwiPhrase('me wɔ sika', 'I have money', category: 'Money & Market'),
    TwiPhrase('sika no sua', 'The money is not enough', category: 'Money & Market'),
    TwiPhrase('me pɛ tɔ aduane', 'I want to buy food', category: 'Money & Market'),
    TwiPhrase('bank no wɔ he', 'Where is the bank?', category: 'Money & Market'),
    TwiPhrase('me pɛ twe sika', 'I want to withdraw money', category: 'Money & Market'),
    TwiPhrase('me nni sika', 'I have no money', category: 'Money & Market'),
    TwiPhrase('me pɛ tɔ nsuo', 'I want to buy water', category: 'Money & Market'),
    TwiPhrase('station no wɔ he', 'Where is the station?', category: 'Travel'),
    TwiPhrase('dwa no wɔ he', 'Where is the market?', category: 'Travel', aliases: ['dwa no wɔ he?']),

    // ── Emergency ─────────────────────────────────────────────────────
    TwiPhrase('boa me', 'Help me', category: 'Emergency', calibration: true),
    TwiPhrase('me hia mmoa', 'I need help', category: 'Emergency'),
    TwiPhrase('frɛ ambulance', 'Call an ambulance', category: 'Emergency'),
    TwiPhrase('ogya', 'Fire!', category: 'Emergency'),
    TwiPhrase('boa me ntem', 'Help me quickly', category: 'Emergency'),
    TwiPhrase('bra ntem', 'Come quickly', category: 'Emergency'),
  ];

  /// The Twi voice-calibration set, in teaching order.
  static List<TwiPhrase> get calibrationSet =>
      phrases.where((p) => p.calibration).toList(growable: false);
}
