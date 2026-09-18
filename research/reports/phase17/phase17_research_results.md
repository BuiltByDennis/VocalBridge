# Phase 17 Research Results & Final Decision Matrix

## 1. Decision Matrix

| Language | Data Availability | Model Availability | Licensing | Offline Feasible | Atypical Speech Data | TTS Availability |
| --- | --- | --- | --- | --- | --- | --- |
| **Akan (Twi)** | Medium (FLEURS, UGAkan) | Very Low (Sherpa) | Mixed (UGAkan is restricted) | Yes (If trained) | ZERO | None (Commercially) |
| **Dagbani** | Medium (Common Voice) | Very Low | Clear (CC0) | Yes (If trained) | ZERO | None |
| **Ewe** | Low | Very Low | Clear | Yes (If trained) | ZERO | None |
| **Ga** | Very Low | Very Low | Clear | Yes (If trained) | ZERO | None |

## 2. Major Risks Identified
1. **The Model Void:** There are no commercially cleared, highly performant, offline-ready ONNX models for Ghanaian languages that we can simply plug into the existing architecture.
2. **The Atypical Gap:** There is absolutely zero data available for atypical Ghanaian speech.
3. **Safety Breakage:** Loading a Ghanaian ASR model inherently bypasses the English-based Phase 12 High-Impact Safety Analyzer.
4. **Code-Switching:** Users will mix English and Twi, which small offline models cannot handle without severe hallucination.

## 3. Recommended Path Forward (Phase 18)
Given the massive data and licensing gaps for genuine Ghanaian-language ASR, the most scientifically defensible and commercially viable path forward is to **pivot back to the core mission: Atypical Speech**.

**Recommendation for Phase 18:**
Instead of attempting to build a general Akan ASR model from scratch (which does not solve the atypical speech problem), Phase 18 should focus on **Atypical-Speech Adaptation for the existing English model**. 
By building infrastructure to fine-tune or adapt the Sherpa engine to a specific user's dysarthric English speech locally, Kasa Me directly solves its primary accessibility mandate. 

*True Ghanaian-language ASR should be deferred until commercially permissive, offline-capable ONNX weights are released by the broader open-source community.*
