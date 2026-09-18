# Phase 18: Evaluation Methodology

## 1. The Chain of Evidence
All Phase 18 and future Kasa Me experiments must adhere to the following chain:
`Dataset -> Speaker-Disjoint Split -> Baseline ASR -> Experimental Adaptation -> Same Test Set -> Evaluation -> Statistical Analysis`

## 2. Evaluation Harness
The Python script `evaluation_harness.py` serves as the prototype for this logic. It explicitly separates the pipeline into:
- A. Base ASR
- B. Generic Normalization
- C. Kasa Me Personalization
- D. Ghanaian English Enhancement
- E. Experimental Adaptation

## 3. Core Metrics
Every experiment must report:
- Word Error Rate (WER)
- Character Error Rate (CER)
- False-correction rate
- Entity accuracy (Names, Currency, Phone Numbers)

## 4. Speaker-Disjoint Mandate
`TRAIN ∩ TEST = ∅`
If a speaker's audio is used to fine-tune an adapter, that speaker's evaluation data must be strictly separated. The `dataset_validator.py` script enforces this rule.
