import 'package:drift/drift.dart';
import 'package:kasa_me/storage/database/app_database.dart';

class PersonalizationRepository {
  final AppDatabase _db;

  PersonalizationRepository(this._db);

  Future<void> recordCorrection({
    required String original,
    required String corrected,
    required String profileId,
    String context = 'general',
  }) async {
    final obs = _normalize(original);
    final intd = _normalize(corrected);

    if (obs.isEmpty || intd.isEmpty || obs == intd) return;

    final isPhrase = obs.contains(' ') || intd.contains(' ');

    if (isPhrase) {
      final existing = await (_db.select(_db.phraseCorrections)
            ..where((t) => t.profileId.equals(profileId) & t.observedPhrase.equals(obs) & t.intendedPhrase.equals(intd)))
          .getSingleOrNull();

      if (existing != null) {
        await (_db.update(_db.phraseCorrections)
              ..where((t) => t.id.equals(existing.id)))
            .write(
          PhraseCorrectionsCompanion(
            frequency: Value(existing.frequency + 1),
            lastCorrectedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await _db.into(_db.phraseCorrections).insert(
              PhraseCorrectionsCompanion.insert(
                profileId: profileId,
                observedPhrase: obs,
                intendedPhrase: intd,
                context: Value(context),
              ),
            );
      }
    } else {
      final existing = await (_db.select(_db.wordCorrections)
            ..where((t) => t.profileId.equals(profileId) & t.observed.equals(obs) & t.intended.equals(intd)))
          .getSingleOrNull();

      if (existing != null) {
        await (_db.update(_db.wordCorrections)
              ..where((t) => t.id.equals(existing.id)))
            .write(
          WordCorrectionsCompanion(
            frequency: Value(existing.frequency + 1),
            lastCorrectedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await _db.into(_db.wordCorrections).insert(
              WordCorrectionsCompanion.insert(
                profileId: profileId,
                observed: obs,
                intended: intd,
                context: Value(context),
              ),
            );
      }
    }
  }

  Future<Map<String, ({String intended, int frequency})>> loadActiveMappings({
    required String profileId,
    int minFrequency = 3,
  }) async {
    final mappings = <String, ({String intended, int frequency})>{};

    final words = await (_db.select(_db.wordCorrections)
          ..where((t) => t.profileId.equals(profileId) & t.frequency.isBiggerOrEqualValue(minFrequency))
          ..orderBy([(t) => OrderingTerm(expression: t.frequency, mode: OrderingMode.desc)]))
        .get();

    for (final w in words) {
      mappings[w.observed] = (intended: w.intended, frequency: w.frequency);
    }

    final phrases = await (_db.select(_db.phraseCorrections)
          ..where((t) => t.profileId.equals(profileId) & t.frequency.isBiggerOrEqualValue(minFrequency))
          ..orderBy([(t) => OrderingTerm(expression: t.frequency, mode: OrderingMode.desc)]))
        .get();

    for (final p in phrases) {
      mappings[p.observedPhrase] = (intended: p.intendedPhrase, frequency: p.frequency);
    }

    return mappings;
  }

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
          ),
        );
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }
}
