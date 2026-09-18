# Phase 17 TTS Research

## 1. The TTS Licensing Blocker (Phase 9)
Phase 9 successfully integrated an offline TTS architecture (Sherpa-ONNX / VITS), but it is severely blocked by licensing. Most high-quality open-source VITS models (e.g., VCTK-based) are Non-Commercial.

## 2. Ghanaian Language TTS Availability
- **MMS TTS:** Meta provides TTS for many Ghanaian languages. However, the models are CC-BY-NC 4.0 (Non-Commercial), disqualifying them for a production product without specialized licensing.
- **Coqui / Piper:** Piper is highly optimized for Android (offline, fast, MIT/Apache licensed). However, it lacks out-of-the-box voices for Akan, Ewe, or Ga.
- **Google TTS (On-Device):** Google's Android TTS engine does not currently support full offline synthesis for Ghanaian indigenous languages.

## 3. Feasibility of Training
Training a Piper or VITS model requires approximately 10-20 hours of high-quality, single-speaker, studio-recorded audio with perfectly aligned phonetic transcripts. 
- **Datasets:** FLEURS is multi-speaker and not suited for single-voice TTS training. UGAkan is variable quality. 
- **Gap:** There is no publicly available, commercially cleared, single-speaker studio dataset for Akan TTS.

## 4. Conclusion
Ghanaian-language TTS faces a harder barrier than ASR. Without a dedicated data collection effort to record 10 hours of a single voice actor speaking Twi, we cannot build a legally sound, high-quality offline TTS model for Kasa Me.
