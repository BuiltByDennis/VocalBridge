# Phase 17 Model Landscape

## 1. Candidate Architectures

### A. Meta MMS (Massively Multilingual Speech)
- **Architecture:** wav2vec 2.0 based.
- **Supported Languages:** 1,000+ languages, including Akan, Ewe, Ga, and Dagbani.
- **Size:** Typically 300M to 1B parameters. Very large for edge devices.
- **Offline / Android:** Very difficult to run the 1B parameter model locally in real-time on standard Android phones. 300M is feasible but heavy.
- **Licensing:** CC-BY-NC 4.0 (Non-Commercial). 
- **Blocker:** Highly problematic for Kasa Me if the app aims for a commercial release.

### B. Whisper (OpenAI)
- **Architecture:** Transformer based sequence-to-sequence.
- **Supported Languages:** Twi/Akan is *not* officially in the 99 languages trained by Whisper, though it might hallucinate or attempt transliteration. Hausa and Yoruba are supported.
- **Offline / Android:** `whisper.cpp` runs exceptionally well on Android. `tiny` (39M), `base` (74M).
- **Licensing:** MIT. Very safe.
- **Blocker:** Doesn't support Ghanaian languages out of the box. Would require massive fine-tuning.

### C. Seamless M4T (Meta)
- **Architecture:** Multitask (ASR, Translation, TTS).
- **Supported Languages:** Includes some African languages, but heavy bias toward major languages.
- **Offline / Android:** Extremely massive models. Highly infeasible for offline edge.
- **Licensing:** CC-BY-NC 4.0. Commercial blocked.

### D. Sherpa-ONNX (Current Provider)
- **Architecture:** Supports various backends (Zipformer, Transducer, Whisper, Paraformer).
- **Supported Languages:** Relies purely on the provided model weights. Pre-trained weights for Twi/Ewe in Sherpa are virtually non-existent.
- **Offline / Android:** Exceptional performance, C++ native, highly optimized for Android.
- **Licensing:** Apache 2.0.
- **Blocker:** Requires us to train our own Zipformer/Transducer model using Kaldi/Icefall, which requires hundreds of hours of data we don't have.

## 2. Conclusions
The model landscape is hostile to offline, commercially-viable Ghanaian ASR.
- The models that *support* the languages (MMS) are **commercially blocked (NC license)** and too heavy.
- The models that are **fast, offline, and commercially free** (Sherpa/Whisper) have **no Ghanaian language weights**.

To proceed, we would either need to fine-tune a Whisper model on FLEURS/UGAkan (if UGAkan permits commercial use), or train a small Sherpa Zipformer model from scratch.
