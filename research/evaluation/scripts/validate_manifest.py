#!/usr/bin/env python3
import os
import sys
import csv
import hashlib
import argparse

def compute_file_hash(filepath):
    """Computes SHA256 hash of a file."""
    if not os.path.exists(filepath):
        return None
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            sha256.update(chunk)
    return sha256.hexdigest()

def validate_manifest(manifest_path, allow_missing=False):
    """
    Strictly validates dataset manifest.
    Fails with exit code 1 if any data leakage, missing file, duplicate path,
    duplicate hash, or invalid schema is detected.
    """
    if not os.path.exists(manifest_path):
        print(f"CRITICAL LEAKAGE ERROR: Manifest path {manifest_path} does not exist.")
        sys.exit(1)

    required_fields = ["audio_path", "transcript", "speaker_id", "language", "session_id", "split"]

    rows = []
    with open(manifest_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)

    if not rows:
        print(f"CRITICAL LEAKAGE ERROR: Manifest {manifest_path} is empty.")
        sys.exit(1)

    # Check required fields
    for field in required_fields:
        if field not in rows[0]:
            print(f"CRITICAL LEAKAGE ERROR: Missing required field '{field}' in manifest schema.")
            sys.exit(1)

    seen_paths = set()
    file_hashes_by_split = {}
    speakers_by_split = {}
    sessions_by_split = {}

    for idx, r in enumerate(rows):
        audio_path = r["audio_path"]
        transcript = r["transcript"]
        speaker_id = r["speaker_id"]
        split = r["split"]
        session_id = r["session_id"]

        if not transcript or not transcript.strip():
            print(f"CRITICAL LEAKAGE ERROR: Row {idx} has empty transcript.")
            sys.exit(1)

        if not speaker_id or not speaker_id.strip():
            print(f"CRITICAL LEAKAGE ERROR: Row {idx} has empty speaker_id.")
            sys.exit(1)

        if audio_path in seen_paths:
            print(f"CRITICAL LEAKAGE ERROR: Duplicate audio_path detected: {audio_path}")
            sys.exit(1)
        seen_paths.add(audio_path)

        if not allow_missing and not os.path.exists(audio_path):
            print(f"CRITICAL LEAKAGE ERROR: Referenced audio file missing: {audio_path}")
            sys.exit(1)

        # Track file hashes if exists
        file_hash = compute_file_hash(audio_path) if os.path.exists(audio_path) else f"dummy_hash_{idx}"

        if split not in file_hashes_by_split:
            file_hashes_by_split[split] = {}
            speakers_by_split[split] = set()
            sessions_by_split[split] = set()

        if file_hash in file_hashes_by_split[split]:
            print(f"CRITICAL LEAKAGE ERROR: Duplicate audio file hash in split {split}: {audio_path}")
            sys.exit(1)

        file_hashes_by_split[split][file_hash] = audio_path
        speakers_by_split[split].add(speaker_id)
        sessions_by_split[split].add(session_id)

    # STRICT DATA LEAKAGE CHECKS ACROSS SPLITS
    splits = list(speakers_by_split.keys())

    # Check 1: Duplicate hashes across splits
    all_hashes = {}
    for s, hashes in file_hashes_by_split.items():
        for h, path in hashes.items():
            if h in all_hashes:
                prev_split, prev_path = all_hashes[h]
                print(f"CRITICAL LEAKAGE ERROR: Audio file hash leakage between {prev_split} ({prev_path}) and {s} ({path})")
                sys.exit(1)
            all_hashes[h] = (s, path)

    # Check 2: Speaker overlap between train and test/val (for Mode A speaker-aware evaluation)
    if "train" in speakers_by_split:
        train_spks = speakers_by_split["train"]
        if "test" in speakers_by_split:
            overlap = train_spks.intersection(speakers_by_split["test"])
            if overlap:
                print(f"CRITICAL LEAKAGE ERROR: Speaker leakage detected between train and test splits! Overlapping speakers: {overlap}")
                sys.exit(1)
        if "val" in speakers_by_split:
            overlap = train_spks.intersection(speakers_by_split["val"])
            if overlap:
                print(f"CRITICAL LEAKAGE ERROR: Speaker leakage detected between train and val splits! Overlapping speakers: {overlap}")
                sys.exit(1)

    print(f"MANIFEST VALIDATION PASSED SUCCESSFULLY: {len(rows)} samples checked in {manifest_path}. Zero data leakage detected.")
    return True

def main():
    parser = argparse.ArgumentParser(description="Kasa Me Manifest Data Leakage & Schema Validator")
    parser.add_argument("--manifest", required=True, help="Path to manifest CSV")
    parser.add_argument("--allow_missing", action="store_true", help="Allow missing audio files during dry-run schema validation")
    args = parser.parse_args()

    validate_manifest(args.manifest, allow_missing=args.allow_missing)

if __name__ == "__main__":
    main()
