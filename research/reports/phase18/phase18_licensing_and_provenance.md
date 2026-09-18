# Phase 18: Licensing and Provenance

## 1. The Licensing Gate
Before any model or dataset becomes a candidate for production, it must clear the licensing gate.

### Dataset Verification Status
- **Common Voice (Dagbani, etc):** CC0 - **Production-compatible**.
- **FLEURS (Twi):** CC-BY - **Production-compatible** (Requires attribution).
- **UGAkan (Twi):** Unknown/Academic - **Commercially restricted / License unclear**.
- **Torgo (Atypical English):** Non-Commercial - **Research-only**.
- **Speech Accessibility Project:** Strict DUA - **Blocked**.

### Model Verification Status
- **Sherpa-ONNX (Base):** Apache 2.0 - **Production-compatible** (Already deployed).
- **Meta MMS:** CC-BY-NC - **Commercially restricted / Blocked**.
- **Whisper:** MIT - **Production-compatible** (If performance targets can be met).

## 2. Verdict
The lack of commercially permissive atypical speech datasets is the primary blocker for open-source acoustic adaptation research. Kasa Me must rely on self-collected user data (Strategy B) if it wishes to proceed legally.
