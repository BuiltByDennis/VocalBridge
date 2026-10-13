import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../speech/diagnostics/repositories/diagnostics_repository.dart';
import '../../speech/personalization/personalization_repository.dart';
import '../../storage/database/app_database.dart';
import '../home/home_communication_notifier.dart'
    show databaseProvider, speechConfigRevisionProvider;

class HomeStatsState {
  final int wordCount;
  final int phraseCount;
  final int sessionCount;
  final double accuracyScore;
  final bool isLoading;

  const HomeStatsState({
    this.wordCount = 0,
    this.phraseCount = 0,
    this.sessionCount = 0,
    this.accuracyScore = 0.0,
    this.isLoading = true,
  });

  HomeStatsState copyWith({
    int? wordCount,
    int? phraseCount,
    int? sessionCount,
    double? accuracyScore,
    bool? isLoading,
  }) {
    return HomeStatsState(
      wordCount: wordCount ?? this.wordCount,
      phraseCount: phraseCount ?? this.phraseCount,
      sessionCount: sessionCount ?? this.sessionCount,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeStatsNotifier extends StateNotifier<HomeStatsState> {
  final DiagnosticsRepository _diagnosticsRepository;
  final PersonalizationRepository _personalizationRepository;
  final AppDatabase _db;

  HomeStatsNotifier({
    required DiagnosticsRepository diagnosticsRepository,
    required PersonalizationRepository personalizationRepository,
    required AppDatabase db,
  })  : _diagnosticsRepository = diagnosticsRepository,
        _personalizationRepository = personalizationRepository,
        _db = db,
        super(const HomeStatsState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);

    try {
      final events = await _diagnosticsRepository.getRecentEvents(profileId: 'default_user', limit: 1000);

      // ── Accuracy Score — deliberately TRAINING-DRIVEN ──────────────
      // The score answers "how well does Kasa Me understand THIS
      // person?", so it is built from their training and its effect:
      //   50% recognizer confidence on everyday utterances
      //   30% calibration performance (phrases checked by recognition,
      //       plus half credit for recorded Twi voice samples — those
      //       train the app without spending Lab recognition quota)
      //   20% correction-free rate: how rarely the person still has to
      //       fix what the app heard (training working = fewer fixes)
      // Components with no data yet simply drop out of the weighted
      // average, so a new user starts from recognizer confidence alone
      // and training visibly moves the score as sessions accumulate.
      bool isCalibration(RecognitionEventEntity e) =>
          e.context.startsWith('calibration');
      final usage = events.where((e) => !isCalibration(e)).toList();
      final calib = events.where(isCalibration).toList();
      final sessionCount = usage.length;

      final confidenceValues = usage
          .where((e) => e.confidence != null)
          .map((e) => e.confidence!)
          .toList();
      final double? engineScore = confidenceValues.isEmpty
          ? null
          : confidenceValues.reduce((a, b) => a + b) / confidenceValues.length;

      double? calibrationScore;
      if (calib.isNotEmpty) {
        final matched = calib
            .where((e) => e.context == 'calibration' && !e.wasCorrected)
            .length;
        final recorded =
            calib.where((e) => e.context == 'calibration_recorded').length;
        calibrationScore = (matched + 0.5 * recorded) / calib.length;
      }

      double? correctionFreeScore;
      if (usage.isNotEmpty) {
        final fixes = usage.where((e) => e.wasCorrected).length;
        correctionFreeScore = 1.0 - fixes / usage.length;
      }

      var weightSum = 0.0;
      var weighted = 0.0;
      void addComponent(double? value, double weight) {
        if (value == null) return;
        weighted += value * weight;
        weightSum += weight;
      }

      addComponent(engineScore, 0.5);
      addComponent(calibrationScore, 0.3);
      addComponent(correctionFreeScore, 0.2);
      final accuracy = weightSum == 0 ? 0.0 : weighted / weightSum;

      // Count learned word corrections (vocabulary)
      final wordCount = await _personalizationRepository.getWordCorrectionCount('default_user');

      // Count phrasebook entries
      final phrases = await _db.select(_db.phrasebookEntries).get();
      final phraseCount = phrases.length;

      state = state.copyWith(
        sessionCount: sessionCount,
        accuracyScore: accuracy * 100,
        wordCount: wordCount,
        phraseCount: phraseCount,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Call after a new session or correction to refresh stats.
  Future<void> refresh() => _load();
}

final homeStatsProvider = StateNotifierProvider<HomeStatsNotifier, HomeStatsState>((ref) {
  final db = ref.watch(databaseProvider);
  final notifier = HomeStatsNotifier(
    diagnosticsRepository: DiagnosticsRepository(db),
    personalizationRepository: PersonalizationRepository(db),
    db: db,
  );
  // The accuracy score is training-driven: whenever training data
  // changes (calibration finished, speech profile changed, a word was
  // corrected), recompute it — the user sees training pay off.
  ref.listen(speechConfigRevisionProvider, (_, next) {
    notifier.refresh();
  });
  return notifier;
});
