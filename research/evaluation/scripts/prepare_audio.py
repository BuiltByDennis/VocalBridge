#!/usr/bin/env python3
import os
import sys
import wave
import json
import argparse
import struct

def check_and_convert_wav(input_path, output_path):
    """
    Validates audio file format.
    Ensures 16000 Hz, 1 channel (mono), PCM16 WAV.
    Resamples or converts if necessary, rejecting corrupt files.
    """
    if not os.path.exists(input_path):
        return False, "File does not exist"

    try:
        with wave.open(input_path, 'rb') as wf:
            n_channels = wf.getnchannels()
            sampwidth = wf.getsampwidth()
            framerate = wf.getframerate()
            n_frames = wf.getnframes()
            duration = n_frames / float(framerate)

            if duration < 0.1:
                return False, "Audio duration too short (<0.1s)"

            raw_bytes = wf.readframes(n_frames)

        # Check if already 16kHz mono PCM16
        if n_channels == 1 and sampwidth == 2 and framerate == 16000:
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with wave.open(output_path, 'wb') as out_wf:
                out_wf.setnchannels(1)
                out_wf.setsampwidth(2)
                out_wf.setframerate(16000)
                out_wf.writeframes(raw_bytes)
            return True, f"Valid 16kHz mono PCM16 ({duration:.2f}s)"

        # Simple conversion for stereo to mono or 16bit PCM resampling
        samples = []
        if sampwidth == 2:
            num_samples = len(raw_bytes) // (2 * n_channels)
            unpacked = struct.unpack(f"<{num_samples * n_channels}h", raw_bytes)
            for i in range(num_samples):
                if n_channels == 2:
                    mix = (unpacked[i * 2] + unpacked[i * 2 + 1]) // 2
                    samples.append(mix)
                else:
                    samples.append(unpacked[i])
        else:
            return False, f"Unsupported sample width: {sampwidth} bytes"

        # Simple linear interpolation resampling if framerate != 16000
        if framerate != 16000:
            ratio = 16000.0 / framerate
            new_len = int(len(samples) * ratio)
            resampled = []
            for i in range(new_len):
                orig_idx = int(i / ratio)
                if orig_idx < len(samples):
                    resampled.append(samples[orig_idx])
            samples = resampled

        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        out_bytes = struct.pack(f"<{len(samples)}h", *samples)
        with wave.open(output_path, 'wb') as out_wf:
            out_wf.setnchannels(1)
            out_wf.setsampwidth(2)
            out_wf.setframerate(16000)
            out_wf.writeframes(out_bytes)

        return True, f"Converted to 16kHz mono PCM16 (orig: {framerate}Hz {n_channels}ch)"

    except Exception as e:
        return False, f"Corrupted or invalid WAV file: {e}"

def main():
    parser = argparse.ArgumentParser(description="Kasa Me Audio Preprocessing Utility")
    parser.add_argument("--input_dir", default="research/datasets/raw", help="Input directory containing raw audio")
    parser.add_argument("--output_dir", default="research/datasets/processed", help="Output directory for processed WAVs")
    parser.add_argument("--report", default="research/evaluation/reports/audio_preparation_report.json", help="Path for report JSON")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)
    os.makedirs(os.path.dirname(args.report), exist_ok=True)

    results = {"total": 0, "processed": 0, "rejected": 0, "details": []}

    if os.path.exists(args.input_dir):
        for root, _, files in os.walk(args.input_dir):
            for file in files:
                if file.endswith((".wav", ".pcm")):
                    in_path = os.path.join(root, file)
                    rel_path = os.path.relpath(in_path, args.input_dir)
                    out_path = os.path.join(args.output_dir, rel_path)

                    results["total"] += 1
                    success, msg = check_and_convert_wav(in_path, out_path)
                    if success:
                        results["processed"] += 1
                    else:
                        results["rejected"] += 1

                    results["details"].append({"file": in_path, "status": "ok" if success else "rejected", "message": msg})

    with open(args.report, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)

    print(f"Audio Preprocessing Complete: Total={results['total']}, Processed={results['processed']}, Rejected={results['rejected']}")
    print(f"Report saved to {args.report}")

if __name__ == "__main__":
    main()
