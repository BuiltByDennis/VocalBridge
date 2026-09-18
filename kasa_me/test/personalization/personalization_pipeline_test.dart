import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:kasa_me/speech/personalization/evidence_tracker.dart';
import 'package:kasa_me/speech/personalization/personalization_pipeline.dart';
import 'package:kasa_me/speech/personalization/personalization_repository.dart';
import 'package:kasa_me/storage/database/app_database.dart';
import 'package:kasa_me/speech/personalization/safety_guard.dart';

void main() {
  late AppDatabase db;
  late PersonalizationRepository repository;
  late PersonalizationPipeline pipeline;
  const String testProfileId = 'test-profile-1';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = PersonalizationRepository(db);
    pipeline = PersonalizationPipeline(
      guard: PersonalizationSafetyGuard(evidenceTracker: EvidenceTracker()),
      repository: repository,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('Corrections below tier 2 (Probable) are not auto-applied', () async {
    await pipeline.initialize(testProfileId);

    // Provide 1 correction (Tentative tier)
    await pipeline.applyCorrection(
      original: 'gonna',
      corrected: 'going to',
      profileId: testProfileId,
    );

    // Reload mappings via new pipeline
    final newPipeline = PersonalizationPipeline(
      guard: PersonalizationSafetyGuard(evidenceTracker: EvidenceTracker()),
      repository: repository,
    );
    await newPipeline.initialize(testProfileId);

    final result = await newPipeline.processTranscript('i am gonna go');
    expect(result.personalizedTranscript, 'i am gonna go', reason: 'Tentative mappings should not apply');
  });

  test('Corrections at tier 2 (Probable) apply on low confidence', () async {
    await pipeline.initialize(testProfileId);

    // Provide 3 corrections to reach Probable tier
    for (int i = 0; i < 3; i++) {
      await pipeline.applyCorrection(
        original: 'wata',
        corrected: 'water',
        profileId: testProfileId,
      );
    }

    final newPipeline = PersonalizationPipeline(
      guard: PersonalizationSafetyGuard(evidenceTracker: EvidenceTracker()),
      repository: repository,
    );
    await newPipeline.initialize(testProfileId);

    // High confidence ignores probable tier
    final highConfResult = await newPipeline.processTranscript('i need wata', confidence: 0.9);
    expect(highConfResult.personalizedTranscript, 'i need wata', reason: 'Probable mappings do not apply if confidence >= 0.8');

    // Low confidence applies probable tier
    final lowConfResult = await newPipeline.processTranscript('i need wata', confidence: 0.6);
    expect(lowConfResult.personalizedTranscript, 'i need water');
  });

  test('Corrections at tier 3 (Learned) apply regardless of confidence', () async {
    await pipeline.initialize(testProfileId);

    // Provide 5 corrections to reach Learned tier
    for (int i = 0; i < 5; i++) {
      await pipeline.applyCorrection(
        original: 'medcine',
        corrected: 'medicine',
        profileId: testProfileId,
      );
    }

    final newPipeline = PersonalizationPipeline(
      guard: PersonalizationSafetyGuard(evidenceTracker: EvidenceTracker()),
      repository: repository,
    );
    await newPipeline.initialize(testProfileId);

    final highConfResult = await newPipeline.processTranscript('take my medcine', confidence: 0.9);
    expect(highConfResult.personalizedTranscript, 'take my medicine', reason: 'Learned mappings apply even with high confidence');
  });
}
