# Phase 17 Code-Switching Research

## 1. Phenomenon
Ghanaian speakers frequently code-switch between English and their native language (e.g., Twi-English, Ga-English) within a single utterance.
*Example: "Mepawokyew, open the door for me."*

## 2. Dataset Support
- **FLEURS / Common Voice:** These datasets explicitly prioritize clean, monolingual read speech. They aggressively scrub or penalize code-switching during the validation phase.
- **Result:** No high-quality, large-scale, publicly licensed Ghanaian code-switching datasets currently exist.

## 3. Model Handling
- **Monolingual Models:** Will force a phonetic mapping of the foreign words into the target language, resulting in severe hallucination (e.g., English words recognized as nonsense Twi syllables).
- **Whisper Multilingual:** Often attempts to auto-detect language every 30 seconds. Code-switching mid-sentence routinely breaks the transformer state, causing infinite loops or sudden translation rather than transcription.

## 4. Conclusion
Code-switching is a fundamental barrier to natural Ghanaian ASR. Given the lack of datasets, attempting to support seamless code-switching in Phase 18 is impossible. 

**Recommendation:** Enforce a strict monolingual UI constraint for early iterations. Users must manually toggle between English mode and Twi mode, accepting that foreign loan words will be handled poorly by the models.
