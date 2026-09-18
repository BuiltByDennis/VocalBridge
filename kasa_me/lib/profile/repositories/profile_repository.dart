import 'package:drift/drift.dart';
import 'package:kasa_me/storage/database/app_database.dart';

class ProfileRepository {
  final AppDatabase _db;

  ProfileRepository(this._db);

  Future<PersonalProfileEntityData> getActiveProfile(String profileId) async {
    final existing = await (_db.select(_db.personalProfiles)
          ..where((t) => t.profileId.equals(profileId)))
        .getSingleOrNull();

    if (existing != null) {
      return existing;
    }

    final newProfile = await _db.into(_db.personalProfiles).insertReturning(
          PersonalProfilesCompanion.insert(
            profileId: profileId,
          ),
        );
    return newProfile;
  }

  Future<void> updateSettings({
    required String profileId,
    bool? enablePersonalVocabulary,
    bool? enablePhraseBiasing,
    bool? enableCorrectionMemory,
    double? minConfidenceThreshold,
    bool? isCalibrated,
  }) async {
    await (_db.update(_db.personalProfiles)..where((t) => t.profileId.equals(profileId))).write(
      PersonalProfilesCompanion(
        enablePersonalVocabulary: enablePersonalVocabulary != null ? Value(enablePersonalVocabulary) : const Value.absent(),
        enablePhraseBiasing: enablePhraseBiasing != null ? Value(enablePhraseBiasing) : const Value.absent(),
        enableCorrectionMemory: enableCorrectionMemory != null ? Value(enableCorrectionMemory) : const Value.absent(),
        minConfidenceThreshold: minConfidenceThreshold != null ? Value(minConfidenceThreshold) : const Value.absent(),
        isCalibrated: isCalibrated != null ? Value(isCalibrated) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
