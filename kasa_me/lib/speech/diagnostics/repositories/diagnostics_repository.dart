import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:kasa_me/storage/database/app_database.dart';
import 'package:kasa_me/ui/home/home_communication_notifier.dart' show databaseProvider;

final diagnosticsRepositoryProvider = Provider<DiagnosticsRepository>((ref) {
  return DiagnosticsRepository(ref.watch(databaseProvider));
});

class DiagnosticsRepository {
  final AppDatabase _db;

  DiagnosticsRepository(this._db);

  Future<void> logRecognitionEvent({
    required String profileId,
    required String rawTranscript,
    required String personalizedTranscript,
    double? confidence,
    bool wasCorrected = false,
    String context = 'general',
  }) async {
    await _db.into(_db.recognitionEvents).insert(
      RecognitionEventsCompanion.insert(
        profileId: profileId,
        rawTranscript: rawTranscript,
        personalizedTranscript: personalizedTranscript,
        confidence: Value(confidence),
        wasCorrected: Value(wasCorrected),
        context: Value(context),
        timestamp: Value(DateTime.now()),
      ),
    );
  }

  Future<List<RecognitionEventEntity>> getEventsForProfile(String profileId) async {
    return await (_db.select(_db.recognitionEvents)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .get();
  }

  /// Returns up to [limit] most recent recognition events for [profileId].
  Future<List<RecognitionEventEntity>> getRecentEvents({
    required String profileId,
    int limit = 100,
  }) async {
    return await (_db.select(_db.recognitionEvents)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)])
          ..limit(limit))
        .get();
  }
}
