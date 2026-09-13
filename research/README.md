# Kasa Me Research & Evaluation Workspace (Phase 3)

This directory contains the dataset preparation, manifest validation, inference baseline, and error analysis pipeline for Kasa Me.

## Directory Structure

```text
research/
├── datasets/
│   ├── raw/           # Raw uncompressed speech recordings
│   ├── processed/     # Audio normalized to 16kHz mono PCM16 WAV
│   ├── manifests/     # CSV manifest files with rich metadata
│   ├── fixtures/      # Tiny synthetic/smoke-test audio files for pipeline validation
│   ├── train/         # Training split samples
│   ├── validation/    # Validation split samples
│   └── test/          # Held-out test split samples
├── evaluation/
│   ├── scripts/       # Dataset processing, validation, inference & metric scripts
│   ├── reports/       # Evaluation metrics and error analysis outputs
│   ├── predictions/   # jsonl predictions from baseline inference
│   └── plots/         # Visualizations & distribution charts
├── configs/           # YAML experiment configuration files
└── reports/           # Phase 3 comprehensive markdown research reports
```

## Dataset Manifest Schema

Manifest CSV files must follow the schema:

```csv
audio_path,transcript,speaker_id,language,dialect,condition,session_id,domain,split
```

## Workflow Execution

1. Prepare Audio: `python3 research/evaluation/scripts/prepare_audio.py`
2. Validate Dataset: `python3 research/evaluation/scripts/validate_dataset.py`
3. Split Dataset: `python3 research/evaluation/scripts/split_dataset.py`
4. Validate Manifest: `python3 research/evaluation/scripts/validate_manifest.py`
5. Run Baseline Inference: `python3 research/evaluation/scripts/run_baseline.py --config research/configs/baseline.yaml`
6. Run Error Analysis: `python3 research/evaluation/scripts/error_analysis.py --predictions research/evaluation/predictions/baseline_en_gh_v001_predictions.jsonl`
