# Phase 18: Reproducibility

## 1. Experimental Manifests
Every experiment conducted in `research/phase18/experiments/` must output a JSON manifest detailing the exact parameters used. The `dataset_validator.py` ensures the integrity of the data split before execution.

## 2. Manifest Schema
```json
{
  "dataset_name": "Torgo",
  "dataset_version": "1.0",
  "license": "Non-Commercial",
  "train_speakers": ["F01", "F03", "M01", "M02"],
  "test_speakers": ["F04", "M03", "M04"],
  "model_base": "zipformer_en",
  "adaptation_technique": "LoRA",
  "evaluation_script_version": "v1",
  "hardware_environment": "RTX 4090 (Simulation)",
  "baseline_wer": 0.85,
  "adapted_wer": 0.42
}
```

## 3. Transparency
Another researcher examining the `research/phase18/` directory should be able to reproduce the exact WER drops claimed by running `evaluation_harness.py` against the documented manifest.
