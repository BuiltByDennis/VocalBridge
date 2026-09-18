# Phase 16 Architecture Audit

## 1. Goal
Evaluate where Ghanaian English Enhancement should be inserted into the Kasa Me offline ASR pipeline without duplicating existing logic and while fully respecting Phase 8 (Persistent Personalization), Phase 11 (Personal Vocabulary), Phase 12 (Safety), and Phase 13 (Passive Personalization).

## 2. Pipeline Analysis

### ASR & Transcription
- `StreamingAudioPipeline` (`lib/speech/pipeline/streaming_audio_pipeline.dart`) manages audio capture and passes it to `SpeechEngine`.
- The `SpeechEngine` emits `SpeechEngineEvent.finalResult` when transcription completes.

### Post-ASR Personalization
- Handled by `PersonalizationPipeline` (`lib/speech/personalization/personalization_pipeline.dart`).
- Existing order of operations:
  1. `NumberNormalizationService.normalizeGhanainCurrencyAndNumbers`
  2. `_applyVocabulary` (Phase 11 Personal Vocabulary)
  3. `safetyGuard.applySafeReplacements` (Phase 8/13 Learned Corrections & Trusted Rules)

### Safety Analysis (Phase 12)
- Handled by `HighImpactSafetyAnalyzer` (`lib/speech/safety/high_impact_safety_analyzer.dart`).
- Contains existing regex for `_financialCurrencyRegex` (e.g., `gh₵`).
- Invoked in `HomeCommunicationNotifier` via `_safetyNotifier.requestSpeak(session.finalTranscript)`. This correctly operates on the **Final** transcript, after all normalizations have completed.

### TTS (Phase 9)
- `TtsPreprocessor` (`lib/speech/tts/tts_preprocessor.dart`) handles spoken expansions for TTS.
- Already expands `GH₵` to "Ghana cedis" cleanly. We should not duplicate this in the Ghanaian English Enhancer.

## 3. Ghanaian English Enhancer Insertion Point

To guarantee the precedence rule:
1. User-configured trusted personalization (Phase 13)
2. Personal vocabulary (Phase 11)
3. High-confidence Ghanaian English normalization (Phase 16)
4. Generic deterministic normalization (Numbers/Currency)

The text replacement operations must execute from most generic to most specific, allowing the user's specific rules to overwrite the generic rules.
However, because regex replacements can interfere with each other, we will insert Phase 16 between Number Normalization and Personal Vocabulary:

```dart
// PersonalizationPipeline.processTranscript
final sanitized = NumberNormalizationService.normalizeGhanainCurrencyAndNumbers(rawTranscript);
final ghanaEnhanced = GhanaianEnglishEnhancer.enhance(sanitized);
final vocabularized = _applyVocabulary(ghanaEnhanced);
final personalized = safetyGuard.applySafeReplacements(vocabularized, baseConfidence: confidence ?? 0.8);
```

**Why this works:**
- `NumberNormalization` converts numeric text into digits.
- `GhanaianEnglishEnhancer` normalizes entities, places, and abbreviations.
- `_applyVocabulary` uses a case-insensitive boundary regex (`\b`), so even if `GhanaianEnglishEnhancer` changed "umat" to "UMaT", the personal vocabulary for "umat" will still match and apply the user's custom replacement.
- `safetyGuard` (Phase 13) runs last, guaranteeing it has the final say over the transcript.
- `HighImpactSafetyAnalyzer` will then process this final string.

## 4. Subsystem Design
We will create `lib/speech/ghanaian_english/`:
- `ghanaian_english_enhancer.dart`: Main entrypoint.
- `ghanaian_english_dictionary.dart`: Contains the controlled vocabulary (Universities, Places, Expressions).
- `ghanaian_english_rules.dart`: Normalization rules and exact match definitions.

## 5. Avoiding Duplication
- **Currency**: `HighImpactSafetyAnalyzer` and `TtsPreprocessor` already handle `GH₵`. The Enhancer will only normalize spoken forms like "Ghana cedis" into the standard `GH₵` representation if it's safe to do so.
- **Numbers**: `NumberNormalizationService` exists. The Enhancer will focus specifically on formatting recognized digit strings (like 10-digit strings starting with `024`) into readable phone numbers.

## 6. Schema & Data
- No database changes are required for Phase 16. The enhancement is a stateless, in-memory, deterministic rules engine.
- Schema version remains `7`.
