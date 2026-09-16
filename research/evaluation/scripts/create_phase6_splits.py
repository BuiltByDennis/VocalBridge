#!/usr/bin/env python3
import os
import sys
import json
import csv
import argparse

def main():
    parser = argparse.ArgumentParser(description="Kasa Me Phase 6 Adaptation Splitter")
    parser.add_argument("--manifest", default="research/datasets/manifests/phase6_dataset_manifest.csv", help="Manifest path")
    args = parser.parse_args()

    if not os.path.exists(args.manifest):
        print(f"Error: Manifest {args.manifest} missing.")
        sys.exit(1)

    rows = []
    with open(args.manifest, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append(r)

    train_spks = set(r["speaker_id"] for r in rows if r["split"] == "train")
    test_spks = set(r["speaker_id"] for r in rows if r["split"] == "test")

    overlap = train_spks.intersection(test_spks)
    if overlap:
        print(f"CRITICAL DATA LEAKAGE DETECTED in Phase 6 Splitter! Overlapping speakers: {overlap}")
        sys.exit(1)

    print(f"Phase 6 Splits Verified Successfully. Train Speakers: {len(train_spks)}, Test Speakers: {len(test_spks)}. Zero leakage.")

if __name__ == "__main__":
    main()
