#!/usr/bin/env python3
import os
import sys
import wave
import json
import math
import struct
import argparse

def validate_audio_file(filepath):
    """
    Validates a WAV audio file for quality, clipping, silence, and duration.
    """
    if not os.path.exists(filepath):
        return False, "file_missing", 0.0, 0, 0, 0.0

    try:
        with wave.open(filepath, 'rb') as wf:
            n_channels = wf.getnchannels()
            sampwidth = wf.getsampwidth()
            framerate = wf.getframerate()
            n_frames = wf.getnframes()
            duration = n_frames / float(framerate)

            if duration < 0.1:
                return False, "duration_too_short", duration, framerate, n_channels, 0.0

            if duration > 60.0:
                return False, "duration_too_long", duration, framerate, n_channels, 0.0

            if framerate != 16000:
                return False, f"invalid_sample_rate_{framerate}", duration, framerate, n_channels, 0.0

            if n_channels != 1:
                return False, f"invalid_channels_{n_channels}", duration, framerate, n_channels, 0.0

            raw_bytes = wf.readframes(n_frames)
            num_samples = len(raw_bytes) // 2
            samples = struct.unpack(f"<{num_samples}h", raw_bytes)

            # Check clipping & RMS
            clipped = 0
            sum_sq = 0.0
            for s in samples:
                if abs(s) >= 32700:
                    clipped += 1
                sum_sq += s * s

            rms = math.sqrt(sum_sq / num_samples) if num_samples > 0 else 0.0
            clip_ratio = clipped / float(num_samples) if num_samples > 0 else 0.0

            if clip_ratio > 0.05:
                return False, f"excessive_clipping_{clip_ratio:.2f}", duration, framerate, n_channels, rms

            if rms < 5.0:
                return False, f"excessive_silence_rms_{rms:.2f}", duration, framerate, n_channels, rms

            return True, "valid", duration, framerate, n_channels, rms

    except Exception as e:
        return False, f"corrupt_file_{e}", 0.0, 0, 0, 0.0

def main():
    parser = argparse.ArgumentParser(description="Kasa Me Dataset Quality Validation Utility")
    parser.add_argument("--directory", default="research/datasets/processed", help="Directory of processed audio files")
    parser.add_argument("--report", default="research/evaluation/reports/dataset_validation_report.json", help="Report JSON output path")
    args = parser.parse_args()

    os.makedirs(os.path.dirname(args.report), exist_ok=True)

    report = {
        "total_files": 0,
        "valid_files": 0,
        "invalid_files": 0,
        "duration_statistics": {"total_sec": 0.0, "mean_sec": 0.0, "min_sec": 999.0, "max_sec": 0.0},
        "rejected_files": []
    }

    durations = []

    if os.path.exists(args.directory):
        for root, _, files in os.walk(args.directory):
            for file in files:
                if file.endswith(".wav"):
                    path = os.path.join(root, file)
                    report["total_files"] += 1

                    valid, reason, duration, _, _, _ = validate_audio_file(path)
                    if valid:
                        report["valid_files"] += 1
                        durations.append(duration)
                    else:
                        report["invalid_files"] += 1
                        report["rejected_files"].append({"file": path, "reason": reason})

    if durations:
        report["duration_statistics"]["total_sec"] = sum(durations)
        report["duration_statistics"]["mean_sec"] = sum(durations) / len(durations)
        report["duration_statistics"]["min_sec"] = min(durations)
        report["duration_statistics"]["max_sec"] = max(durations)

    with open(args.report, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    print(f"Dataset Validation Complete: Total={report['total_files']}, Valid={report['valid_files']}, Invalid={report['invalid_files']}")
    print(f"Validation Report saved to {args.report}")

if __name__ == "__main__":
    main()
