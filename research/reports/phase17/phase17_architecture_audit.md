# Phase 17 Architecture Audit

## 1. Current State
The existing Kasa Me application uses a highly deterministic, offline-first pipeline:
**RAW AUDIO** → **ASR (Sherpa-ONNX)** → **PERSONALIZATION** → **GHANAIAN ENGLISH ENHANCEMENT** → **SAFETY** → **TTS**

Key components:
- `SpeechEngine`: Abstract wrapper around the Sherpa-ONNX runtime.
- `PersonalizationPipeline`: Sequences number normalization, Ghanaian English Enhancement (Phase 16), personal vocabulary (Phase 11), and trusted corrections (Phase 13).
- `HighImpactSafetyAnalyzer`: Assesses final transcripts against critical emergency/financial thresholds (Phase 12).
- `HomeCommunicationNotifier`: Manages state machine orchestration, driving UI updates, timeouts, and state transitions.

## 2. Potential Ghanaian Language ASR Integration Points

### A. Routing Before ASR
If a language-specific ASR model is used alongside the English model, a routing mechanism must exist *before* or *during* the ASR phase.
- **Language Detection (Automatic):** Very difficult to perform efficiently and offline ahead of time without massive latency costs on mobile.
- **Manual User Toggle:** Introducing a `SpeechLanguage` enum and `LanguageModelDescriptor` would allow users to select "English" or "Twi" explicitly, loading the respective Sherpa/ONNX model into memory.

### B. Impact on Post-ASR Pipeline
- **Ghanaian English Enhancement:** Must be bypassed if the output is not English. (Running English proper noun rules over Akan could be destructive).
- **Personalization:** `PersonalVocabulary` relies heavily on exact character boundary matching. Akan/Ga have different morphological structures and diacritics (e.g., `ɛ`, `ɔ`). Personalization must be language-aware.
- **Safety Analyzer:** Current regex patterns (`_financialCurrencyRegex`) are English/symbol focused. Akan phrases for emergencies (e.g., "Gyae" for stop, "Mepawokyew" variations) would need translated, language-specific analyzers.
- **TTS:** Currently hardcoded to expect English phonetic boundaries.

## 3. Conclusions
To support a Ghanaian language, Kasa Me requires:
1. A **Model Registry** that can dynamically swap or run parallel ONNX graphs based on user language preference.
2. A **Language Context Flag** (`language_code`) passed down the entire pipeline so Personalization, Safety, and TTS know which rulesets/voices to apply.

*Note: No production code modifications were made during this audit.*
