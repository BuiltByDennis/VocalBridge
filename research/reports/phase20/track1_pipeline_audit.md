# Phase 20, Track 1: Speech Pipeline Trace

## Conceptual vs Actual
**Expected**: AUDIO -> VAD -> SpeechEngine -> Raw Transcript -> Personalization -> Ghanaian English -> Safety -> TTS
**Actual**: AUDIO -> VAD (`EnergyVad`) -> SpeechEngine (`SherpaSpeechEngine`) -> Raw Transcript -> Personalization (`PersonalizationPipeline`) -> STOP.

## Trace Analysis
- **Microphone**: `AudioRecorderService`
- **VAD**: `EnergyVad` (called in `StreamingAudioPipeline`)
- **SpeechEngine**: `SherpaSpeechEngine`
- **Personalization**: `PersonalizationPipeline` processes transcript, applying `NumberNormalizationService` and `PersonalizationSafetyGuard`.
- **Ghanaian English**: MISSING. Not invoked.
- **High Impact Safety**: MISSING. Not invoked.
- **TTS**: MISSING. Not invoked.

**Conclusion**: The pipeline is severely truncated due to missing Phase 8-16 files.
