import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/storage/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('AppDatabase initializes schema v2 and creates all Phase 4 tables', () async {
    final profiles = await database.select(database.personalProfiles).get();
    expect(profiles, isEmpty);

    await database.into(database.personalProfiles).insert(
          PersonalProfilesCompanion.insert(
            profileId: 'default_user',
            preferredLanguage: const Value('en_GH'),
          ),
        );

    final updatedProfiles = await database.select(database.personalProfiles).get();
    expect(updatedProfiles.length, 1);
    expect(updatedProfiles.first.profileId, 'default_user');

    await database.into(database.personalVocabulary).insert(
          PersonalVocabularyCompanion.insert(
            profileId: 'default_user',
            word: 'Kumasi',
            category: const Value('place'),
          ),
        );

    final vocab = await database.select(database.personalVocabulary).get();
    expect(vocab.length, 1);
    expect(vocab.first.word, 'Kumasi');
  });
}
