# Phase 18: Code-Switching

## 1. The Phenomenon
Ghanaian speakers frequently mix English and indigenous languages (e.g., Twi) within the same sentence. 

## 2. Model Failure Modes
1. **Monolingual English Models (Sherpa):** Attempt to phoneticize Twi words into English nonsense words (e.g., "Kofi kɔ fie" becomes "coffee co fee").
2. **Monolingual Twi Models:** Attempt to phoneticize English words into Twi orthography.
3. **Multilingual Models (Whisper/MMS):** Often suffer from "language lock," where the decoder gets stuck in one language state and translates the code-switched words rather than transcribing them.

## 3. Atypical Intersection
For users with atypical speech, code-switching exacerbates the problem. The model cannot rely on standard acoustic cues to determine language boundaries, leading to catastrophic failure of the VAD and decoder.

## 4. Verdict
Offline Code-Switching for Atypical Speech is **NOT YET MEASURED** (no dataset exists) and **BLOCKED BY DATA**. It remains a theoretical research topic with no immediate production pathway.
