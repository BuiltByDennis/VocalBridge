#!/usr/bin/env python3
import os
import sys
import csv
import json
import re
import math
import argparse

CRITICAL_VOCABULARY = {
    "medicine", "medication", "pain", "water", "food", "doctor",
    "hospital", "help", "mother", "father", "cedis", "money",
    "emergency", "hungry", "thirsty", "sick", "nurse", "ambulance"
}

def normalize_text(text):
    text = text.lower().strip()
    text = re.sub(r"[^\w\s]", "", text)
    text = re.sub(r"\s+", " ", text)
    return text

def levenshtein_distance(ref, hyp):
    m, n = len(ref), len(hyp)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    for i in range(m + 1):
        dp[i][0] = i
    for j in range(n + 1):
        dp[0][j] = j
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if ref[i - 1] == hyp[j - 1]:
                dp[i][j] = dp[i - 1][j - 1]
            else:
                dp[i][j] = 1 + min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])
    return dp[m][n]

def calculate_wer(ref_text, hyp_text):
    ref_words = normalize_text(ref_text).split()
    hyp_words = normalize_text(hyp_text).split()
    if not ref_words:
        return 0.0 if not hyp_words else 1.0
    return levenshtein_distance(ref_words, hyp_words) / len(ref_words)

def calculate_cer(ref_text, hyp_text):
    ref_chars = list(normalize_text(ref_text))
    hyp_chars = list(normalize_text(hyp_text))
    if not ref_chars:
        return 0.0 if not hyp_chars else 1.0
    return levenshtein_distance(ref_chars, hyp_chars) / len(ref_chars)

def is_critical_word_correct(ref_text, hyp_text):
    ref_words = set(normalize_text(ref_text).split())
    hyp_words = set(normalize_text(hyp_text).split())
    crit_in_ref = ref_words.intersection(CRITICAL_VOCABULARY)
    if not crit_in_ref:
        return True, None # No critical word present
    missing_crit = crit_in_ref - hyp_words
    if missing_crit:
        return False, list(missing_crit)
    return True, None

def is_number_correct(ref_text, hyp_text):
    ref_numbers = re.findall(r"\b\d+\b", ref_text) + re.findall(r"\b(one|two|three|four|five|six|seven|eight|nine|ten|twenty|fifty|hundred|thousand)\b", ref_text.lower())
    hyp_numbers = re.findall(r"\b\d+\b", hyp_text) + re.findall(r"\b(one|two|three|four|five|six|seven|eight|nine|ten|twenty|fifty|hundred|thousand)\b", hyp_text.lower())
    if not ref_numbers:
        return True # No numbers to evaluate
    return set(ref_numbers) == set(hyp_numbers)

def extract_substitutions(ref_text, hyp_text):
    ref_words = normalize_text(ref_text).split()
    hyp_words = normalize_text(hyp_text).split()
    subs = []
    min_len = min(len(ref_words), len(hyp_words))
    for i in range(min_len):
        if ref_words[i] != hyp_words[i]:
            subs.append((ref_words[i], hyp_words[i]))
    return subs

def main():
    parser = argparse.ArgumentParser(description="Kasa Me Error Analysis & Assistive Scorecard Utility")
    parser.add_argument("--predictions", required=True, help="Input predictions jsonl")
    parser.add_argument("--reports_dir", default="research/evaluation/reports", help="Reports output directory")
    args = parser.parse_args()

    os.makedirs(args.reports_dir, exist_ok=True)

    records = []
    with open(args.predictions, "r", encoding="utf-8") as f:
        for line in f:
            if line.strip():
                records.append(json.loads(line))

    if not records:
        print(f"Error: No predictions found in {args.predictions}")
        sys.exit(1)

    eval_records = [r for r in records if r.get("status") == "success"]
    unsupported_records = [r for r in records if r.get("status") == "unsupported_model_capability"]

    total_words = 0
    total_word_errors = 0
    total_chars = 0
    total_char_errors = 0

    critical_word_count = 0
    critical_word_correct_count = 0

    phrase_count = len(eval_records)
    phrase_correct_count = 0

    number_count = 0
    number_correct_count = 0

    latencies_ms = []
    rtfs = []

    substitutions_freq = {}
    speaker_stats = {}
    domain_stats = {}

    for r in eval_records:
        ref = r["reference"]
        hyp = r["prediction"]
        spk = r.get("speaker_id", "unknown")
        domain = r.get("domain", "general")
        proc_ms = r.get("processing_ms", 0)
        dur_sec = r.get("audio_duration_sec", 0.0)

        latencies_ms.append(proc_ms)
        if dur_sec > 0:
            rtfs.append((proc_ms / 1000.0) / dur_sec)

        norm_ref_words = normalize_text(ref).split()
        norm_hyp_words = normalize_text(hyp).split()

        w_errs = levenshtein_distance(norm_ref_words, norm_hyp_words)
        c_errs = levenshtein_distance(list(normalize_text(ref)), list(normalize_text(hyp)))

        total_words += len(norm_ref_words)
        total_word_errors += w_errs
        total_chars += len(list(normalize_text(ref)))
        total_char_errors += c_errs

        # Critical words
        is_crit_ok, missing_crit = is_critical_word_correct(ref, hyp)
        if any(w in CRITICAL_VOCABULARY for w in norm_ref_words):
            critical_word_count += 1
            if is_crit_ok:
                critical_word_correct_count += 1

        # Phrase accuracy
        if normalize_text(ref) == normalize_text(hyp):
            phrase_correct_count += 1

        # Number accuracy
        if re.search(r"\b\d+\b", ref) or any(n in ref.lower() for n in ["one", "five", "ten", "fifty", "hundred"]):
            number_count += 1
            if is_number_correct(ref, hyp):
                number_correct_count += 1

        # Substitutions
        subs = extract_substitutions(ref, hyp)
        for ref_w, hyp_w in subs:
            pair = (ref_w, hyp_w)
            substitutions_freq[pair] = substitutions_freq.get(pair, 0) + 1

        # Speaker stats
        if spk not in speaker_stats:
            speaker_stats[spk] = {"count": 0, "ref_words": 0, "word_errs": 0}
        speaker_stats[spk]["count"] += 1
        speaker_stats[spk]["ref_words"] += len(norm_ref_words)
        speaker_stats[spk]["word_errs"] += w_errs

        # Domain stats
        if domain not in domain_stats:
            domain_stats[domain] = {"count": 0, "ref_words": 0, "word_errs": 0}
        domain_stats[domain]["count"] += 1
        domain_stats[domain]["ref_words"] += len(norm_ref_words)
        domain_stats[domain]["word_errs"] += w_errs

    overall_wer = (total_word_errors / total_words) if total_words > 0 else 0.0
    overall_cer = (total_char_errors / total_chars) if total_chars > 0 else 0.0
    crit_word_acc = (critical_word_correct_count / critical_word_count) if critical_word_count > 0 else 1.0
    phrase_acc = (phrase_correct_count / phrase_count) if phrase_count > 0 else 0.0
    number_acc = (number_correct_count / number_count) if number_count > 0 else 1.0

    latencies_ms.sort()
    mean_lat = sum(latencies_ms) / len(latencies_ms) if latencies_ms else 0.0
    median_lat = latencies_ms[len(latencies_ms) // 2] if latencies_ms else 0.0
    p90_lat = latencies_ms[int(len(latencies_ms) * 0.9)] if latencies_ms else 0.0
    p95_lat = latencies_ms[int(len(latencies_ms) * 0.95)] if latencies_ms else 0.0
    mean_rtf = sum(rtfs) / len(rtfs) if rtfs else 0.0

    # Save confusions CSV
    confusions_csv_path = os.path.join(args.reports_dir, "confusions.csv")
    with open(confusions_csv_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["reference", "prediction", "count"])
        for (ref_w, hyp_w), count in sorted(substitutions_freq.items(), key=lambda x: x[1], reverse=True):
            writer.writerow([ref_w, hyp_w, count])

    scorecard = {
        "total_predictions": len(records),
        "evaluated_english_samples": len(eval_records),
        "unsupported_capability_samples": len(unsupported_records),
        "metrics": {
            "overall_wer": f"{overall_wer * 100:.2f}%",
            "overall_cer": f"{overall_cer * 100:.2f}%",
            "critical_word_accuracy": f"{crit_word_acc * 100:.2f}%",
            "phrase_accuracy": f"{phrase_acc * 100:.2f}%",
            "number_accuracy": f"{number_acc * 100:.2f}%"
        },
        "latency_ms": {
            "mean": mean_lat,
            "median": median_lat,
            "p90": p90_lat,
            "p95": p95_lat,
            "mean_rtf": round(mean_rtf, 3)
        },
        "speaker_breakdown": {
            spk: {
                "count": data["count"],
                "wer": f"{(data['word_errs'] / data['ref_words'] * 100 if data['ref_words'] > 0 else 0):.2f}%"
            }
            for spk, data in speaker_stats.items()
        },
        "domain_breakdown": {
            dom: {
                "count": data["count"],
                "wer": f"{(data['word_errs'] / data['ref_words'] * 100 if data['ref_words'] > 0 else 0):.2f}%"
            }
            for dom, data in domain_stats.items()
        }
    }

    scorecard_path = os.path.join(args.reports_dir, "assistive_scorecard.json")
    with open(scorecard_path, "w", encoding="utf-8") as f:
        json.dump(scorecard, f, indent=2)

    print("=== KASA ME ASSISTIVE COMMUNICATION SCORECARD ===")
    print(f"Evaluated English Samples: {len(eval_records)}")
    print(f"Overall WER: {scorecard['metrics']['overall_wer']}")
    print(f"Overall CER: {scorecard['metrics']['overall_cer']}")
    print(f"Critical Word Accuracy: {scorecard['metrics']['critical_word_accuracy']}")
    print(f"Phrase Accuracy: {scorecard['metrics']['phrase_accuracy']}")
    print(f"Number Accuracy: {scorecard['metrics']['number_accuracy']}")
    print(f"Mean Latency: {mean_lat:.1f} ms | Mean RTF: {mean_rtf:.3f}")
    print(f"Confusions written to: {confusions_csv_path}")
    print(f"Scorecard JSON written to: {scorecard_path}")

if __name__ == "__main__":
    main()
