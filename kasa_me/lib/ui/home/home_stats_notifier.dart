import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../speech/diagnostics/repositories/diagnostics_repository.dart';
import '../../speech/personalization/personalization_repository.dart';
import '../../storage/database/app_database.dart';
import '../home/home_communication_notifier.dart' show databaseProvider;

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
      // Count recognition events (sessions)
      final events = await _diagnosticsRepository.getRecentEvents(profileId: 'default_user', limit: 1000);
      final sessionCount = events.length;

      // Average confidence as accuracy score
      final confidenceValues = events
          .where((e) => e.confidence != null)
          .map((e) => e.confidence!)
          .toList();
      final avgConfidence = confidenceValues.isEmpty
          ? 0.0
          : confidenceValues.reduce((a, b) => a + b) / confidenceValues.length;

      // Count learned word corrections (vocabulary)
      final wordCount = await _personalizationRepository.getWordCorrectionCount('default_user');

      // Count phrasebook entries
      final phrases = await _db.select(_db.phrasebookEntries).get();
      final phraseCount = phrases.length;

      state = state.copyWith(
        sessionCount: sessionCount,
        accuracyScore: avgConfidence * 100,
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
  return HomeStatsNotifier(
    diagnosticsRepository: DiagnosticsRepository(db),
    personalizationRepository: PersonalizationRepository(db),
    db: db,
  );
});
