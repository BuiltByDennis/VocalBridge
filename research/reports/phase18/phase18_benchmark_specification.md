# Phase 18: Benchmark Specification

## Kasa Me Atypical Speech Benchmark

### 1. Speaker Groups
- Typical Speech (Control)
- Atypical Speech (Dysarthria - Mild, Moderate, Severe)
- Atypical Speech (Stuttering)

### 2. Languages
- English (Ghanaian Accent)
- Twi (Asante) - *Pending data collection*

### 3. Speech Conditions
- Quiet Environment (SNR > 20dB)
- Realistic Background Noise (Marketplace, Traffic, SNR < 10dB)

### 4. Content Categories
- Conversational
- Medical/Emergency (e.g., "I need a doctor", "Dosage")
- Financial (e.g., "Send 50 cedis to MTN")
- Proper Nouns (Ghanaian names and institutions)

### 5. Evaluation
- Strict Speaker-Disjoint splits.
- Metric tracking per-etiology and per-severity.
- Explicit tracking of Safety-Critical Phrase Accuracy (vital for Phase 12 validation).
