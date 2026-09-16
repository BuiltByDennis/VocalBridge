#!/usr/bin/env python3
import os
import sys
import json
import csv
import argparse

def main():
    parser = argparse.ArgumentParser(description="Kasa Me Phase 6 Dataset Preparer")
    parser.add_argument("--manifest", default="research/datasets/manifests/kasa_me_test_manifest.csv", help="Manifest CSV")
    parser.add_argument("--output", default="research/datasets/manifests/phase6_dataset_manifest.csv", help="Output CSV")
    args = parser.parse_args()

    if not os.path.exists(args.manifest):
        print(f"Error: Manifest {args.manifest} missing.")
        sys.exit(1)

    os.makedirs(os.path.dirname(args.output), exist_ok=True)

    rows = []
    with open(args.manifest, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append(r)

    fieldnames = list(rows[0].keys())
    with open(args.output, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Phase 6 Dataset Prepared: {len(rows)} samples written to {args.output}")

if __name__ == "__main__":
    main()
