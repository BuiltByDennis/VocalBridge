import 'package:drift/drift.dart';
import 'package:kasa_me/storage/database/app_database.dart';

class PhrasebookRepository {
  final AppDatabase _db;

  PhrasebookRepository(this._db);

  Stream<List<PhrasebookEntry>> watchQuickPhrases({String? category, int limit = 8}) {
    final query = _db.select(_db.phrasebookEntries)
      ..orderBy([(t) => OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc)])
      ..limit(limit);

    if (category != null) {
      query.where((t) => t.category.equals(category));
    }

    return query.watch();
  }

  Future<void> incrementUsage(int id) async {
    final phrase = await (_db.select(_db.phrasebookEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (phrase != null) {
      await (_db.update(_db.phrasebookEntries)..where((t) => t.id.equals(id))).write(
        PhrasebookEntriesCompanion(
          usageCount: Value(phrase.usageCount + 1),
        ),
      );
    }
  }

  Future<void> insertCustomPhrase(String text, String category, int profileId) async {
    final existing = await (_db.select(_db.phrasebookEntries)
          ..where((t) => t.phrase.equals(text) & t.profileId.equals(profileId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.phrasebookEntries).insert(
            PhrasebookEntriesCompanion.insert(
              profileId: Value(profileId),
              phrase: text,
              category: Value(category),
            ),
          );
    }
  }
}
