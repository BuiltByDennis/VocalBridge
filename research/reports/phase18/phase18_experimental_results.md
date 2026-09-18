# Phase 18: Experimental Results

## 1. Status of Empirical Data
No physical acoustic models were retrained and compiled for Android during this phase due to Android ONNX runtime constraints. Therefore, **raw experimental WER/CER numbers are classified as NOT YET MEASURED.**

## 2. Simulated Results
Using `adaptation_simulator.py`, we project based on literature (e.g. Project Euphonia):
- **Base ASR on Severe Dysarthria:** ~85% WER.
- **Post-ASR Personalization:** Can recover specific high-value phrases (e.g., "water", "help") if the phonetic destruction is consistent and mappable. Overall WER improvement is low (<10%), but functional communicative success improves significantly.
- **Acoustic Adaptation (LoRA simulation):** 15+ minutes of training data can yield relative WER drops of 40-50%.

## 3. Verdict
Acoustic adaptation is **EXPERIMENTALLY SUPPORTED** in literature, but **RESEARCH ONLY** for Kasa Me until the engineering pipeline for on-device PyTorch-to-ONNX adapter injection is built.
