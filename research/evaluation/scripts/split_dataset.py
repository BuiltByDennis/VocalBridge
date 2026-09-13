#!/usr/bin/env python3
import os
import sys
import csv
import random
import argparse

def split_dataset(input_manifest, output_dir, seed=42, mode="mode_a", train_ratio=0.7, val_ratio=0.15):
    """
    Splits dataset manifest into train, validation, and test sets.
    Mode A: Speaker-aware split (Train speakers != Test/Val speakers).
    Mode B: Session-aware split (Same speaker, held-out session).
    """
    random.seed(seed)
    os.makedirs(output_dir, exist_ok=True)

    rows = []
    with open(input_manifest, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append(r)

    if not rows:
        print(f"Error: Manifest {input_manifest} is empty.")
        sys.exit(1)

    fieldnames = list(rows[0].keys())
    if "split" not in fieldnames:
        fieldnames.append("split")

    if mode == "mode_a":
        # Group by speaker
        speakers = list(set(r["speaker_id"] for r in rows))
        random.shuffle(speakers)

        n_spks = len(speakers)
        n_train = max(1, int(n_spks * train_ratio))
        n_val = max(1, int(n_spks * val_ratio)) if n_spks > 2 else 0

        train_spks = set(speakers[:n_train])
        val_spks = set(speakers[n_train:n_train + n_val])
        test_spks = set(speakers[n_train + n_val:])

        for r in rows:
            spk = r["speaker_id"]
            if spk in train_spks:
                r["split"] = "train"
            elif spk in val_spks:
                r["split"] = "val"
            else:
                r["split"] = "test"

    elif mode == "mode_b":
        # Group by speaker & session (held out sessions)
        sessions_by_spk = {}
        for r in rows:
            spk = r["speaker_id"]
            sess = r["session_id"]
            if spk not in sessions_by_spk:
                sessions_by_spk[spk] = set()
            sessions_by_spk[spk].add(sess)

        train_sessions = set()
        test_sessions = set()

        for spk, sessions in sessions_by_spk.items():
            sess_list = sorted(list(sessions))
            if len(sess_list) > 1:
                train_sessions.update(sess_list[:-1])
                test_sessions.add(sess_list[-1])
            else:
                train_sessions.update(sess_list)

        for r in rows:
            sess = r["session_id"]
            if sess in test_sessions:
                r["split"] = "test"
            else:
                r["split"] = "train"

    train_rows = [r for r in rows if r["split"] == "train"]
    val_rows = [r for r in rows if r["split"] == "val"]
    test_rows = [r for r in rows if r["split"] == "test"]

    out_main = os.path.join(output_dir, "split_manifest.csv")
    out_train = os.path.join(output_dir, "train.csv")
    out_val = os.path.join(output_dir, "val.csv")
    out_test = os.path.join(output_dir, "test.csv")

    def write_csv(path, data):
        with open(path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(data)

    write_csv(out_main, rows)
    write_csv(out_train, train_rows)
    write_csv(out_val, val_rows)
    write_csv(out_test, test_rows)

    print(f"Dataset Split Complete ({mode}): Train={len(train_rows)}, Val={len(val_rows)}, Test={len(test_rows)}")
    print(f"Manifests written to {output_dir}")

def main():
    parser = argparse.ArgumentParser(description="Kasa Me Speaker-Aware Dataset Splitter")
    parser.add_argument("--manifest", required=True, help="Input manifest CSV")
    parser.add_argument("--output_dir", default="research/datasets/manifests", help="Output directory")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    parser.add_argument("--mode", choices=["mode_a", "mode_b"], default="mode_a", help="Split mode")
    args = parser.parse_args()

    split_dataset(args.manifest, args.output_dir, seed=args.seed, mode=args.mode)

if __name__ == "__main__":
    main()
