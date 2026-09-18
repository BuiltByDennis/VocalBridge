# Phase 18: Adaptation Strategy Analysis

## Strategy A - Post-ASR Personalization
- **Mechanism:** Deterministic text replacement based on a user-defined dictionary (Phase 11/13).
- **Pros:** 100% offline, privacy-safe, instantaneous, requires no retraining.
- **Cons:** Cannot recover a word if the acoustic model fundamentally misrecognizes the phonemes so badly that the output is garbage or a completely different valid word sequence that evades regex matching.
- **Verdict:** PROVEN (Currently in production).

## Strategy B - User-Specific Calibration
- **Mechanism:** Using Phase 10 reading tasks to establish baseline WER, speed, and confidence thresholds per user.
- **Pros:** Allows UI adaptation (e.g., prompting the user to slow down).
- **Cons:** Does not alter the underlying acoustic weights.
- **Verdict:** EXPERIMENTALLY SUPPORTED for UI adaptation; NOT YET MEASURED for raw acoustic improvement.

## Strategy C - Lightweight Acoustic Adaptation
- **Mechanism:** Parameter-efficient fine-tuning (PEFT), LoRA, or small adapter layers inserted into the Sherpa Zipformer model.
- **Pros:** Could drastically improve recognition of specific dysarthric patterns with only a few minutes of audio.
- **Cons:** Requires C++ runtime modifications for Sherpa-ONNX. Models must be re-exported from PyTorch.
- **Verdict:** PROMISING BUT INSUFFICIENT EVIDENCE (Blocked by Android runtime constraints).

## Strategy D - Model Fine-Tuning
- **Mechanism:** Full retraining of the Zipformer encoder on a server.
- **Pros:** Highest potential accuracy.
- **Cons:** Breaks offline privacy if user audio is uploaded. Extremely computationally expensive.
- **Verdict:** BLOCKED BY PRIVACY/ETHICS for production; RESEARCH ONLY for controlled server environments.
