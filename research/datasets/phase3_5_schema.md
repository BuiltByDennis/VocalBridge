# PHASE 3.5 — REAL DATASET ACQUISITION & BASELINE VALIDATION FRAMEWORK

## 1. Overview & Objectives

Phase 3.5 bridges the gap between pipeline validation (`kasa_me_dataset_v0.1_fixture`) and Phase 4 Personalization by establishing the formal protocol, sampling requirements, and experiment matrices for real speech dataset acquisition.

---

## 2. Targeted Sampling Matrix

| Dataset Category | Targeted Speakers | Utterances / Speaker | Total Targeted Utterances | Primary Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Typical Ghanaian English (`en_GH`)** | 15–20 | 30–50 | ~600 – 1,000 | Baseline performance on native Ghanaian accent & terminology |
| **Atypical Ghanaian Speech** | 10–15 | 30–50 | ~300 – 750 | Baseline error analysis for target assistive speech profiles |
| **Multilingual (Twi/Ewe/Dagbani)** | 5–10 | 20–30 | ~100 – 300 | Multi-language capability boundary evaluation |

---

## 3. Five Baseline Experiment Conditions Matrix

Every real baseline dataset evaluation in Phase 3.5 must populate this scorecard:

| Condition | WER (%) | CER (%) | Critical Word Accuracy (%) | Phrase Accuracy (%) | Number Accuracy (%) | Mean RTF |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Generic English Speech (Standard)** | TBD | TBD | TBD | TBD | TBD | TBD |
| **2. Typical Ghanaian English (`en_GH`)** | TBD | TBD | TBD | TBD | TBD | TBD |
| **3. Atypical Ghanaian English Speech** | TBD | TBD | TBD | TBD | TBD | TBD |
| **4. Known Speaker / Held-out Session** | TBD | TBD | TBD | TBD | TBD | TBD |
| **5. Unseen Speaker Evaluation** | TBD | TBD | TBD | TBD | TBD | TBD |

---

## 4. Personalization Evaluation Protocol (Pre-Phase 4 Guarantee)

To prevent data leakage during Phase 4 personalization evaluation:

```text
Speaker Calibration Utterances (Stage 1 / Stage 2)
              ↓
  Personalization Profile Update (Vocab / Bias / Confusion)
              ↓
  Evaluated on UNSEEN Utterances from Same Speaker (Test Set)
              ↓
  Measure Net Adaptation Gain (WER Improvement %)
```

This strict protocol guarantees that Kasa Me is evaluated on whether it genuinely learns **how the speaker communicates**, rather than memorizing evaluated test phrases.
