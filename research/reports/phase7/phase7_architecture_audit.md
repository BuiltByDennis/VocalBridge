# Kasa Me — Phase 7A Architecture Audit Report

## 1. Executive Overview

This report presents a comprehensive audit of the **Kasa Me** production codebase and research infrastructure prior to Phase 7 dataset integration. Kasa Me is an offline-first, Flutter-based assistive communication application designed for individuals with atypical speech.

The core design principle of Kasa Me is:
> **"The system adapts to the speaker rather than forcing the speaker to adapt to the system."**

---

## 2. Flutter Client Architecture

* **Framework & Language:** Flutter (Dart 3.x) targeting Android-first with iOS compatibility.
* **Routing:** `go_router` (`lib/app/router.dart`) handling screen navigation between Welcome, Home, Language Selection, Settings, Diagnostics, and Personalization.
* **Theme & Accessibility:** `AccessibleTheme` (`lib/ui/theme/accessible_theme.dart`) enforcing Material 3 soft pastel styling, high-contrast text, large touch targets, and dynamic push-to-talk button sizing.
* **State Management:** Riverpod (`flutter_riverpod`) orchestrating reactive state via notifier controllers such as `HomeCommunicationNotifier` (`lib/ui/home/home_communication_notifier.dart`).

---

## 3. Audio & ASR Engine Pipeline

```text
  [ Microhone ] ─────► [ AudioRecorderService ] ──► PCM16 16kHz
                                                           │
                                                           ▼
  [ Speech Engine Result ] ◄─── [ SherpaSpeechEngine ] ◄─── [ EnergyVad ]
```

1. **Audio Recorder Service:** `AudioRecorderService` (`lib/audio/recorder/audio_recorder_service.dart`) captures PCM16 audio at 16,000 Hz sample rate in mono channel format.
2. **Voice Activity Detection (VAD):** `EnergyVad` (`lib/speech/vad/energy_vad.dart`) measures Root Mean Square (RMS) energy against a configurable threshold (`thresholdRms = 250.0`, `maxSilenceFrames = 15`) to track `speech` vs `silence` frames.
3. **Streaming Audio Pipeline:** `StreamingAudioPipeline` (`lib/speech/pipeline/streaming_audio_pipeline.dart`) pipes PCM16 audio frames directly into the ASR engine.
4. **Sherpa-ONNX Integration:** `SherpaSpeechEngine` (`lib/speech/engine/sherpa_speech_engine.dart`) wraps `sherpa_onnx` C++ / ONNX Runtime bindings. It copies ONNX asset files from `assets/models/asr/english/` to local app storage on boot and streams 80-dimensional log-mel filterbank feature vectors into an ONNX Streaming Zipformer Transducer.

---

## 4. Personalization Layer & Storage Architecture

* **Philosophy:** On-device, 100% offline text/vocabulary/phrase bias layer operating without modifying underlying neural ASR weights.
* **Components:**
  * `PersonalizationPipeline` (`lib/speech/personalization/personalization_pipeline.dart`): Reranks candidate transcripts and applies personal vocabulary and phrase bias.
  * `PersonalizationSafetyGuard` (`lib/speech/personalization/safety_guard.dart`): Prevents cycle rewrites (e.g. A -> B -> A loops).
  * `NumberNormalization` (`lib/speech/personalization/number_normalization.dart`): Normalizes Ghanaian monetary and numerical speech expressions (e.g. "500 Ghana cedis").
* **Database & Storage:**
  * Drift ORM database `AppDatabase` (`lib/storage/database/app_database.dart`) with SQLite backing file `kasa_me.sqlite`.
  * Schema Version 2 maintaining tables for `Profiles`, `SpeechCorrections`, `PhrasebookEntries`, `PersonalProfiles`, `PersonalVocabulary`, `PersonalPhrases`, `WordCorrections`, `PhraseCorrections`, and `RecognitionEvents`.

---

## 5. Research Workspace & Phase 7 Scaffold

* **Workspace Layout:**
  ```text
  research/
  ├── configs/                 # YAML evaluation configurations
  ├── datasets/                # Dataset workspace
  │   ├── fixtures/            # Pipeline synthetic fixtures
  │   ├── manifests/           # CSV manifests
  │   └── ugspeechdata/        # Phase 7 Ghanaian language scaffold
  ├── evaluation/              # Inference, validation & error scripts
  ├── models/
  │   ├── baseline/            # Production baseline manifest & verification script
  │   └── experimental/        # Research checkpoints
  └── reports/
      └── phase7/              # Phase 7 markdown and JSON reports
  ```
* **Dataset Boundary Notice:**
  The `research/datasets/ugspeechdata/` scaffold has been created for future Ghanaian-language research (Phase 7B). **UGSpeechData is a general Ghanaian speech resource, NOT atypical speech data.**

---

## 6. Offline Operational Integrity

* The mobile production runtime (`kasa_me/`) contains **zero** HTTP client calls, telemetry services, or remote ASR API dependencies.
* All model files, tokenizers, database migrations, and voice activity algorithms execute locally on-device.
