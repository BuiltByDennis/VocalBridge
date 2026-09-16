import 'package:drift/drift.dart';

@DataClassName('Profile')
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get preferredLanguage => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SpeechCorrection')
class SpeechCorrections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get originalTranscript => text()();
  TextColumn get correctedTranscript => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PhrasebookEntry')
class PhrasebookEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get phrase => text()();
  TextColumn get category => text().nullable()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Phase 4 New Tables

@DataClassName('PersonalProfileEntity')
class PersonalProfiles extends Table {
  TextColumn get profileId => text()();
  TextColumn get preferredLanguage => text().withDefault(const Constant('en_GH'))();
  TextColumn get secondaryLanguages => text().withDefault(const Constant(''))();
  RealColumn get minConfidenceThreshold => real().withDefault(const Constant(0.6))();
  BoolColumn get enablePersonalVocabulary => boolean().withDefault(const Constant(true))();
  BoolColumn get enablePhraseBiasing => boolean().withDefault(const Constant(true))();
  BoolColumn get enableCorrectionMemory => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {profileId};
}

@DataClassName('PersonalVocabularyEntity')
class PersonalVocabulary extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text()();
  TextColumn get word => text()();
  TextColumn get language => text().withDefault(const Constant('en_GH'))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  TextColumn get pronunciationHint => text().nullable()();
  RealColumn get biasWeight => real().withDefault(const Constant(1.5))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PersonalPhraseEntity')
class PersonalPhrases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text()();
  TextColumn get phrase => text()();
  TextColumn get language => text().withDefault(const Constant('en_GH'))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  TextColumn get priority => text().withDefault(const Constant('normal'))(); // critical, high, normal, low
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('WordCorrectionEntity')
class WordCorrections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text()();
  TextColumn get observed => text()();
  TextColumn get intended => text()();
  TextColumn get language => text().withDefault(const Constant('en_GH'))();
  TextColumn get context => text().withDefault(const Constant('general'))();
  IntColumn get frequency => integer().withDefault(const Constant(1))();
  RealColumn get confidence => real().withDefault(const Constant(0.5))();
  DateTimeColumn get lastCorrectedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PhraseCorrectionEntity')
class PhraseCorrections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text()();
  TextColumn get observedPhrase => text()();
  TextColumn get intendedPhrase => text()();
  TextColumn get language => text().withDefault(const Constant('en_GH'))();
  TextColumn get context => text().withDefault(const Constant('general'))();
  IntColumn get frequency => integer().withDefault(const Constant(1))();
  RealColumn get confidence => real().withDefault(const Constant(0.5))();
  DateTimeColumn get lastCorrectedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('RecognitionEventEntity')
class RecognitionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text()();
  TextColumn get rawTranscript => text()();
  TextColumn get personalizedTranscript => text()();
  RealColumn get confidence => real().nullable()();
  TextColumn get context => text().withDefault(const Constant('general'))();
  BoolColumn get wasCorrected => boolean().withDefault(const Constant(false))();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}
