# Phase 17 Evaluation Methodology

## 1. Core Principles
When a Ghanaian-language ASR model is eventually built or acquired, it must be evaluated under the following strict methodology to ensure research integrity and real-world applicability for Kasa Me.

### A. Speaker-Disjoint Testing
- **Rule:** No speaker present in the test set may exist in the training or fine-tuning set.
- **Why:** Prevents the model from merely memorizing the acoustic signature of the training participants, ensuring true generalizability.

### B. Segmented Metric Reporting
Metrics must be reported in isolation to prevent blurring performance gains:
- **Base ASR WER/CER:** The raw text output of the ONNX model compared to the ground truth.
- **Personalized WER/CER:** The final output *after* Phase 11/13 processing.
- **Entity Accuracy:** Specific pass/fail tracking for proper nouns, local institutions, and numbers.

## 2. Benchmark Design Schema
Future benchmarks will follow this JSON structure:
```json
{
  "benchmark_id": "akan_conversational_01",
  "language": "akan",
  "dialect": "asante_twi",
  "speech_type": "ordinary_conversational",
  "ground_truth": "mepawokyew mmarima no kɔ",
  "asr_output": "mepawo kyew mmarima no ko",
  "wer": 0.20,
  "cer": 0.05,
  "notes": "Failed to map ɔ correctly."
}
```

## 3. Atypical Speech Evaluation
Atypical speech (Track C) must be evaluated on its own distinct benchmark. Neurotypical Ghanaian speech performance cannot be used to infer Atypical Ghanaian speech performance.
