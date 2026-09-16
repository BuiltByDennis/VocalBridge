#!/usr/bin/env python3
"""
Baseline ASR Model Integrity Verification Tool for Kasa Me.

Verifies the cryptographic SHA-256 hashes, file existence, and file sizes
of the immutable production model assets (english_edge_v1).
"""

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path


def compute_sha256(filepath: Path) -> str:
    """Calculates the SHA-256 hash of a file in chunks."""
    sha256_hash = hashlib.sha256()
    with open(filepath, "rb") as f:
        for byte_block in iter(lambda: f.read(65536), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()


def verify_baseline(
    manifest_path: Path, repo_root: Path, quiet: bool = False
) -> tuple[bool, dict]:
    """
    Verifies production model files against the baseline manifest.
    Returns (success_boolean, verification_report_dict).
    """
    if not manifest_path.exists():
        report = {
            "status": "FAIL",
            "error": f"Manifest file not found at {manifest_path}",
            "verified_files": [],
        }
        return False, report

    try:
        with open(manifest_path, "r", encoding="utf-8") as f:
            manifest = json.load(f)
    except Exception as e:
        report = {
            "status": "FAIL",
            "error": f"Failed to parse manifest JSON: {e}",
            "verified_files": [],
        }
        return False, report

    model_id = manifest.get("model_id", "unknown")
    files_spec = manifest.get("files", {})

    all_passed = True
    verified_files = []

    for name, spec in files_spec.items():
        rel_path = spec.get("relative_path", "")
        expected_size = spec.get("size_bytes", -1)
        expected_sha256 = spec.get("sha256", "")

        full_path = repo_root / rel_path

        file_status = "PASS"
        issues = []

        if not full_path.exists():
            file_status = "FAIL"
            issues.append("FILE_MISSING")
            actual_size = 0
            actual_sha256 = "MISSING"
            all_passed = False
        else:
            actual_size = full_path.stat().st_size
            if actual_size != expected_size:
                file_status = "FAIL"
                issues.append(
                    f"SIZE_MISMATCH (expected {expected_size}, got {actual_size})"
                )
                all_passed = False

            actual_sha256 = compute_sha256(full_path)
            if actual_sha256.lower() != expected_sha256.lower():
                file_status = "FAIL"
                issues.append(
                    f"HASH_MISMATCH (expected {expected_sha256}, got {actual_sha256})"
                )
                all_passed = False

        verified_files.append(
            {
                "file_key": name,
                "path": rel_path,
                "exists": full_path.exists(),
                "status": file_status,
                "expected_size_bytes": expected_size,
                "actual_size_bytes": actual_size,
                "expected_sha256": expected_sha256,
                "actual_sha256": actual_sha256,
                "issues": issues,
            }
        )

    overall_status = "PASS" if all_passed else "FAIL"

    report = {
        "status": overall_status,
        "model_id": model_id,
        "version": manifest.get("version", "1.0.0"),
        "base_model": manifest.get("base_model", ""),
        "architecture": manifest.get("architecture", ""),
        "quantization": manifest.get("quantization", ""),
        "sample_rate": manifest.get("sample_rate", 16000),
        "runtime": manifest.get("runtime", "sherpa_onnx"),
        "manifest_path": str(manifest_path),
        "verified_files": verified_files,
    }

    if not quiet:
        print("=" * 80)
        print(f"KASA ME BASELINE ASR MODEL VERIFICATION — [{model_id}]")
        print("=" * 80)
        print(f"Overall Status: {overall_status}")
        print(f"Manifest Path : {manifest_path}")
        print("-" * 80)
        print(
            f"{'File Name':<15} {'Status':<8} {'Size (Bytes)':<14} {'SHA-256 Hash':<64}"
        )
        print("-" * 80)
        for vf in verified_files:
            print(
                f"{vf['file_key']:<15} {vf['status']:<8} {vf['actual_size_bytes']:<14} {vf['actual_sha256']}"
            )
            if vf["issues"]:
                for issue in vf["issues"]:
                    print(f"   └── ERROR: {issue}")
        print("=" * 80)

    return all_passed, report


def main():
    parser = argparse.ArgumentParser(
        description="Verify cryptographic baseline integrity of Kasa Me production ASR assets."
    )
    repo_root_default = Path(__file__).resolve().parents[3]
    manifest_default = (
        repo_root_default / "research/models/baseline/baseline_manifest.json"
    )

    parser.add_argument(
        "--manifest",
        type=Path,
        default=manifest_default,
        help="Path to baseline manifest JSON file.",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=repo_root_default,
        help="Repository root directory path.",
    )
    parser.add_argument(
        "--json-output",
        type=Path,
        default=None,
        help="Optional path to save verification report as JSON.",
    )
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress console table stdout output.",
    )

    args = parser.parse_args()

    success, report = verify_baseline(
        manifest_path=args.manifest,
        repo_root=args.repo_root,
        quiet=args.quiet,
    )

    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        with open(args.json_output, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2)

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
