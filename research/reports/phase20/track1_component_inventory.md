# Phase 20, Track 1: Component Inventory

## Production Components Found
- `lib/speech/engine/`: `speech_engine.dart`, `sherpa_speech_engine.dart` (Phase 2)
- `lib/speech/pipeline/streaming_audio_pipeline.dart` (Phase 2/3)
- `lib/speech/personalization/personalization_pipeline.dart` (Phase 4)
- `lib/ui/home/home_communication_notifier.dart` (Phase 4, missing Phase 14 enhancements)
- `lib/storage/database/`: `app_database.dart` (Drift baseline)
- `lib/audio/recorder/`: `audio_recorder_service.dart`

## Missing Components (Lost in Phase 19 Incident)
- **Phase 8-11 Persistence**: `lib/profile/repositories/` is completely empty. `PersonalizationService`, phrasebook, vocabulary are missing.
- **Phase 12 Safety**: `lib/speech/safety/` is empty except for an empty `models/` dir. HighImpactSafetyAnalyzer and SafetyNotifier are missing.
- **Phase 14 State Machine**: `HomeCommunicationNotifier` lacks `SPEAKING` and `CONFIRMATION_REQUIRED` states.
- **Phase 15 Accessibility**: `lib/ui/components/accessibility/` is empty.
- **Phase 16 Ghanaian English**: `lib/speech/ghanaian_english/` is empty. GhanaianEnglishEnhancer is missing.
- **Phase 17/18 Research**: Not present in `lib/` (which is technically correct for isolation, but research files were also lost/uncommitted).
- **TTS**: `lib/speech/tts/` is empty.

**Status**: CRITICAL GAPS FOUND.
