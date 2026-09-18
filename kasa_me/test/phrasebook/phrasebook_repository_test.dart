import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:kasa_me/phrasebook/repositories/phrasebook_repository.dart';
import 'package:kasa_me/storage/database/app_database.dart';

void main() {
  late AppDatabase db;
  late PhrasebookRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = PhrasebookRepository(db);
    
    // Create the default profile used for testing
    await db.into(db.profiles).insert(
      ProfilesCompanion.insert(
        id: const drift.Value(1),
        name: 'Test Profile',
        preferredLanguage: 'en_GH',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('watchQuickPhrases streams inserted phrases and orders by usageCount', () async {
    // Insert some phrases
    await repository.insertCustomPhrase('First phrase', 'Category', 1);
    await repository.insertCustomPhrase('Second phrase', 'Category', 1);
    await repository.insertCustomPhrase('Third phrase', 'Category', 1);

    // Initial stream should have 3 items
    final stream = repository.watchQuickPhrases();
    final firstEmission = await stream.first;
    expect(firstEmission.length, 3);
    
    // All have usage 0 initially, ordered by insertion time normally. Let's find one and increment its usage.
    final targetPhrase = firstEmission.firstWhere((p) => p.phrase == 'Second phrase');
    await repository.incrementUsage(targetPhrase.id);

    // Re-watch the stream to check the ordering
    final secondEmission = await repository.watchQuickPhrases().first;
    
    expect(secondEmission.first.phrase, 'Second phrase');
    expect(secondEmission.first.usageCount, 1);
  });
}
