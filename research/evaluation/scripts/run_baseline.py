#!/usr/bin/env python3
import os
import sys
import csv
import json
import time
import wave
import hashlib
import platform
import datetime
import argparse
import yaml
import numpy as np
import sherpa_onnx

def compute_file_hash(filepath):
    if not os.path.exists(filepath):
        return "missing"
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            sha256.update(chunk)
    return sha256.hexdigest()

def read_wav_pcm16_samples(filepath):
    with wave.open(filepath, "rb") as wf:
        sample_rate = wf.getframerate()
        n_channels = wf.getnchannels()
        sampwidth = wf.getsampwidth()
        n_frames = wf.getnframes()
        raw_bytes = wf.readframes(n_frames)

        if sampwidth == 2:
            int16_samples = np.frombuffer(raw_bytes, dtype=np.int16)
        else:
            raise ValueError(f"Unsupported sampwidth: {sampwidth}")

        if n_channels > 1:
            int16_samples = int16_samples.reshape(-1, n_channels).mean(axis=1).astype(np.int16)

        float32_samples = int16_samples.astype(np.float32) / 32768.0
        duration_sec = n_frames / float(sample_rate)

        return float32_samples, sample_rate, duration_sec

def main():
    parser = argparse.ArgumentParser(description="Kasa Me Sherpa-ONNX Baseline Inference Runner")
    parser.add_argument("--config", default="research/configs/baseline.yaml", help="Path to experiment config YAML")
    parser.add_argument("--manifest", help="Override manifest path")
    parser.add_argument("--output", help="Override output predictions jsonl path")
    args = parser.parse_args()

    if not os.path.exists(args.config):
        print(f"Error: Config file {args.config} does not exist.")
        sys.exit(1)

    with open(args.config, "r", encoding="utf-8") as f:
        cfg = yaml.safe_load(f)

    exp_id = cfg.get("experiment_id", "baseline_v001")
    dataset_ver = cfg.get("dataset", {}).get("version", "v0.1")
    manifest_path = args.manifest or cfg.get("dataset", {}).get("manifest", "research/datasets/manifests/kasa_me_test_manifest.csv")
    out_path = args.output or f"research/evaluation/predictions/{exp_id}_predictions.jsonl"

    model_cfg = cfg.get("model", {})
    encoder_path = os.path.abspath(model_cfg.get("encoder_path", "kasa_me/assets/models/asr/english/encoder.onnx"))
    decoder_path = os.path.abspath(model_cfg.get("decoder_path", "kasa_me/assets/models/asr/english/decoder.onnx"))
    joiner_path = os.path.abspath(model_cfg.get("joiner_path", "kasa_me/assets/models/asr/english/joiner.onnx"))
    tokens_path = os.path.abspath(model_cfg.get("tokens_path", "kasa_me/assets/models/asr/english/tokens.txt"))
    sample_rate = model_cfg.get("sample_rate", 16000)

    # Validate model files
    for p in [encoder_path, decoder_path, joiner_path, tokens_path]:
        if not os.path.exists(p):
            print(f"Error: Model asset {p} missing.")
            sys.exit(1)

    # Compute provenance hashes
    manifest_hash = compute_file_hash(manifest_path)
    model_hash = compute_file_hash(encoder_path)[:16]
    model_config_hash = compute_file_hash(args.config)[:16]

    provenance = {
        "experiment_id": exp_id,
        "dataset_version": dataset_ver,
        "manifest_hash": manifest_hash,
        "model_id": model_cfg.get("id", "english_edge_v1"),
        "model_hash": model_hash,
        "model_config_hash": model_config_hash,
        "runtime_version": f"sherpa_onnx_{getattr(sherpa_onnx, '__version__', '1.13.8')}",
        "evaluation_script_version": "v3.0.0",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "device_environment": {
            "os": platform.system(),
            "arch": platform.machine(),
            "python_version": platform.python_version()
        }
    }

    # Initialize Sherpa-ONNX recognizer
    recognizer = sherpa_onnx.OnlineRecognizer.from_transducer(
        tokens=tokens_path,
        encoder=encoder_path,
        decoder=decoder_path,
        joiner=joiner_path,
        num_threads=2,
        sample_rate=sample_rate,
        feature_dim=80,
        decoding_method="greedy_search"
    )

    rows = []
    with open(manifest_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append(r)

    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    predictions = []
    for r in rows:
        audio_path = r["audio_path"]
        reference = r["transcript"]
        lang = r.get("language", "en_GH")
        speaker_id = r.get("speaker_id", "unknown")
        domain = r.get("domain", "general")

        # Non-English explicit check requirement
        if lang not in ["en", "en_GH"]:
            pred_record = {
                "provenance": provenance,
                "audio_path": audio_path,
                "reference": reference,
                "prediction": "",
                "status": "unsupported_model_capability",
                "reason": "selected baseline model is not validated for this language",
                "speaker_id": speaker_id,
                "language": lang,
                "domain": domain,
                "processing_ms": 0,
                "audio_duration_sec": 0.0
            }
            predictions.append(pred_record)
            continue

        if not os.path.exists(audio_path):
            pred_record = {
                "provenance": provenance,
                "audio_path": audio_path,
                "reference": reference,
                "prediction": "",
                "status": "file_missing",
                "speaker_id": speaker_id,
                "language": lang,
                "domain": domain,
                "processing_ms": 0,
                "audio_duration_sec": 0.0
            }
            predictions.append(pred_record)
            continue

        samples, sr, duration_sec = read_wav_pcm16_samples(audio_path)
        stream = recognizer.create_stream()

        start_time = time.time()
        stream.accept_waveform(sr, samples)
        while recognizer.is_ready(stream):
            recognizer.decode_stream(stream)
        hypothesis = recognizer.get_result(stream).strip()
        elapsed_ms = int((time.time() - start_time) * 1000)

        pred_record = {
            "provenance": provenance,
            "audio_path": audio_path,
            "reference": reference,
            "prediction": hypothesis,
            "status": "success",
            "speaker_id": speaker_id,
            "language": lang,
            "domain": domain,
            "processing_ms": elapsed_ms,
            "audio_duration_sec": duration_sec
        }
        predictions.append(pred_record)

    with open(out_path, "w", encoding="utf-8") as f:
        for p in predictions:
            f.write(json.dumps(p) + "\n")

    print(f"Baseline Inference Complete: {len(predictions)} utterances processed.")
    print(f"Predictions written to {out_path}")

if __name__ == "__main__":
    main()
