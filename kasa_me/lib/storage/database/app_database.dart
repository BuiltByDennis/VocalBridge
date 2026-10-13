import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import '../../speech/translation/twi_phrase_data.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Profiles,
  SpeechCorrections,
  PhrasebookEntries,
  PersonalProfiles,
  PersonalVocabulary,
  PersonalPhrases,
  WordCorrections,
  PhraseCorrections,
  RecognitionEvents,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  /// Seeds the curated Twi phrasebook for [profileId] from the shared
  /// [TwiPhraseData] list (the same source as the translation glossary),
  /// so every phrasebook phrase is guaranteed to have a translation.
  Future<void> _seedTwiPhrases(int profileId) async {
    final seen = <String>{};
    for (final p in TwiPhraseData.phrases) {
      // A Twi phrase with two English renderings is ONE phrasebook row.
      if (!seen.add(p.twi)) continue;
      await into(phrasebookEntries).insert(
        PhrasebookEntriesCompanion.insert(
          profileId: profileId,
          phrase: p.twi,
          category: Value('Twi · ${p.category}'),
        ),
      );
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          
          // Seed default Profile
          final defaultProfileId = await into(profiles).insert(
            ProfilesCompanion.insert(
              name: 'Default User',
              preferredLanguage: 'en_GH',
            ),
          );

          // Seed default Ghanaian communication phrases
          final defaultPhrases = [
            (phrase: 'I need water', category: 'Daily Needs'),
            (phrase: 'I need help', category: 'Healthcare'),
            (phrase: 'I am in pain', category: 'Healthcare'),
            (phrase: 'Please call my mother', category: 'Daily Needs'),
            (phrase: 'I need to see the doctor', category: 'Healthcare'),
            (phrase: 'Where is the bank', category: 'Banking'),
            (phrase: 'I want to withdraw money', category: 'Banking'),
          ];

          for (final p in defaultPhrases) {
            await into(phrasebookEntries).insert(
              PhrasebookEntriesCompanion.insert(
                profileId: defaultProfileId,
                phrase: p.phrase,
                category: Value(p.category),
              ),
            );
          }

          // Seed the Twi phrasebook (same install gets both languages).
          await _seedTwiPhrases(defaultProfileId);
        },
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await m.createTable(personalProfiles);
            await m.createTable(personalVocabulary);
            await m.createTable(personalPhrases);
            await m.createTable(wordCorrections);
            await m.createTable(phraseCorrections);
            await m.createTable(recognitionEvents);
          }
          if (from < 3) {
            // Give existing installs the Twi phrasebook too (once).
            final allProfiles = await select(profiles).get();
            if (allProfiles.isNotEmpty) {
              final existingTwi = await (select(phrasebookEntries)
                    ..where((t) => t.category.like('Twi%'))
                    ..limit(1))
                  .get();
              if (existingTwi.isEmpty) {
                await _seedTwiPhrases(allProfiles.first.id);
              }
            }
          }
        },
      );

  Future<int> insertProfile(ProfilesCompanion profile) => into(profiles).insert(profile);
  Future<List<Profile>> getAllProfiles() => select(profiles).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kasa_me.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
