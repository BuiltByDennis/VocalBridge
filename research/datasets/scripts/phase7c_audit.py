import os
import csv
import json
import hashlib
import unicodedata
import statistics
import re
from collections import defaultdict
from mutagen.mp3 import MP3

def calculate_sha256(filepath):
    sha256_hash = hashlib.sha256()
    try:
        with open(filepath, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    except Exception:
        return None

def normalize_aetiology(aet):
    return aet.lower().strip().replace(" ", "_")

def normalize_transcript(txt):
    if txt is None:
        return ""
    txt = str(txt)
    txt = unicodedata.normalize('NFKC', txt)
    txt = txt.casefold()
    txt = re.sub(r'\s+', ' ', txt)
    return txt.strip()

def check_transcript_anomalies(txt):
    if not txt or txt.isspace():
        return "MISSING_OR_EMPTY"
    try:
        txt.encode('utf-8')
    except UnicodeEncodeError:
        return "INVALID_ENCODING"
    if len(txt) < 2:
        return "TOO_SHORT"
    if len(txt) > 500:
        return "TOO_LONG"
    return "OK"

def main():
    ugakan_path = "/home/tjay/VocalBridge/research/datasets/ugakan_impaired_speech/raw/UGAkan-ImpairedSpeechData A Dataset of Impaired Speech in the Akan Language/UGAkan-ImpairedSpeechData"
    
    csv_files = []
    for root, dirs, files in os.walk(ugakan_path):
        for file in files:
            if file.endswith('.csv'):
                csv_files.append(os.path.join(root, file))

    records = []
    durations = []
    
    hash_to_records = defaultdict(list)
    normalized_transcript_to_records = defaultdict(list)
    speaker_info = defaultdict(lambda: {'count': 0, 'duration': 0.0, 'aetiologies': set(), 'environments': set(), 'genders': set()})
    
    for csv_file in csv_files:
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            base_dir = os.path.dirname(csv_file)
            for row in reader:
                rel_path = row.get('orig_file_name', '')
                if not rel_path: continue
                abs_path = os.path.join(base_dir, "audios", rel_path)
                if not os.path.exists(abs_path):
                    abs_path = os.path.join(base_dir, rel_path)
                
                # Default empty states
                duration = 0.0
                file_size = 0
                sha = ""
                codec = ""
                sample_rate = 0
                channels = 0
                
                if os.path.exists(abs_path):
                    sha = calculate_sha256(abs_path)
                    file_size = os.path.getsize(abs_path)
                    try:
                        audio = MP3(abs_path)
                        duration = audio.info.length
                        sample_rate = audio.info.sample_rate
                        channels = audio.info.channels
                        codec = "mp3"
                    except Exception:
                        pass
                
                orig_txt = row.get('text', '')
                norm_txt = normalize_transcript(orig_txt)
                orig_aet = row.get('condition', '')
                norm_aet = normalize_aetiology(orig_aet)
                speaker_id = row.get('speaker_id', '')
                gender = row.get('gender', '')
                env = row.get('environment', '')
                
                rec = {
                    'sample_id': f"ugakan_{len(records)}",
                    'relative_audio_path': rel_path,
                    'absolute_audio_path': abs_path,
                    'audio_filename': os.path.basename(abs_path),
                    'audio_sha256': sha,
                    'file_size_bytes': file_size,
                    'duration_seconds': duration,
                    'sample_rate': sample_rate,
                    'channels': channels,
                    'codec/container': codec,
                    'transcript_original': orig_txt,
                    'transcript_analysis_normalized': norm_txt,
                    'transcript_anomaly': check_transcript_anomalies(orig_txt),
                    'language': 'Akan',
                    'speaker_id': speaker_id,
                    'gender': gender,
                    'aetiology_original': orig_aet,
                    'aetiology_normalized': norm_aet,
                    'environment': env,
                    'source_metadata_file': os.path.basename(csv_file),
                    'dataset_id': 'UGAkan-ImpairedSpeechData',
                    'dataset_version': '1',
                    'manifest_version': '1',
                }
                records.append(rec)
                durations.append(duration)
                
                hash_to_records[sha].append(rec)
                normalized_transcript_to_records[norm_txt].append(rec)
                
                spk = speaker_info[speaker_id]
                spk['count'] += 1
                spk['duration'] += duration
                spk['aetiologies'].add(norm_aet)
                spk['environments'].add(env)
                spk['genders'].add(gender)

    # Calculate exact duplicates
    duplicate_groups = {}
    cross_speaker_exact = 0
    cross_aet_exact = 0
    cross_env_exact = 0
    for sha, recs in hash_to_records.items():
        if len(recs) > 1 and sha:
            spks = set(r['speaker_id'] for r in recs)
            aets = set(r['aetiology_normalized'] for r in recs)
            envs = set(r['environment'] for r in recs)
            group_id = f"sha256:{sha}"
            duplicate_groups[group_id] = {
                'sha256': sha,
                'file_count': len(recs),
                'files': [r['relative_audio_path'] for r in recs],
                'speaker_ids': list(spks),
                'aetiologies': list(aets),
                'environments': list(envs),
                'transcripts': list(set(r['transcript_analysis_normalized'] for r in recs)),
            }
            if len(spks) > 1: cross_speaker_exact += 1
            if len(aets) > 1: cross_aet_exact += 1
            if len(envs) > 1: cross_env_exact += 1
            
            for r in recs:
                r['duplicate_group_id'] = group_id
                r['cross_speaker_duplicate'] = len(spks) > 1

    # Near duplicate candidates (same duration & transcript, diff speaker or diff file)
    near_dup_count = 0
    for norm_txt, recs in normalized_transcript_to_records.items():
        if len(recs) > 1 and norm_txt:
            # group by rounded duration to find candidates
            dur_groups = defaultdict(list)
            for r in recs:
                dur_groups[round(r['duration_seconds'], 1)].append(r)
            for d, dr in dur_groups.items():
                if len(dr) > 1:
                    # found near duplicates
                    spks = set(r['speaker_id'] for r in dr)
                    for r in dr:
                        if 'duplicate_group_id' not in r: # only flag if not exact duplicate
                            r['near_duplicate_candidate'] = True
                            r['near_duplicate_reason'] = 'same duration and transcript'
                            near_dup_count += 1
                            
    # Finalize canonical manifest
    out_dir = "/home/tjay/VocalBridge/research/datasets/ugakan_impaired_speech/manifests"
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, "canonical_audio_manifest.jsonl"), "w") as f:
        for r in records:
            f.write(json.dumps(r) + "\\n")
            
    all_keys = set()
    for r in records:
        all_keys.update(r.keys())
        
    with open(os.path.join(out_dir, "canonical_audio_manifest.csv"), "w", newline='') as f:
        writer = csv.DictWriter(f, fieldnames=list(all_keys))
        writer.writeheader()
        writer.writerows(records)

    # Duplicate analysis report
    reports_dir = "/home/tjay/VocalBridge/research/reports/phase7"
    os.makedirs(reports_dir, exist_ok=True)
    
    with open(os.path.join(reports_dir, "duplicate_analysis.json"), "w") as f:
        json.dump(duplicate_groups, f, indent=2)

    # Consolidated stats
    stats = {
        'total_files': len(records),
        'total_duration': sum(durations) / 3600.0,
        'mean_duration': statistics.mean(durations) if durations else 0,
        'median_duration': statistics.median(durations) if durations else 0,
        'std_duration': statistics.stdev(durations) if len(durations)>1 else 0,
        'min_duration': min(durations) if durations else 0,
        'max_duration': max(durations) if durations else 0,
        'duplicate_groups': len(duplicate_groups),
        'duplicate_files': sum(g['file_count'] for g in duplicate_groups.values()),
        'cross_speaker_exact': cross_speaker_exact,
        'cross_aet_exact': cross_aet_exact,
        'cross_env_exact': cross_env_exact,
        'near_duplicate_candidates': near_dup_count,
        'speaker_count': len(speaker_info),
        'smallest_speaker_count': min(s['count'] for s in speaker_info.values()) if speaker_info else 0,
        'largest_speaker_count': max(s['count'] for s in speaker_info.values()) if speaker_info else 0,
    }
    
    with open(os.path.join(reports_dir, "phase7c_data_quality_leakage_report.json"), "w") as f:
        json.dump(stats, f, indent=2)
        
    print("Audit Complete.")

if __name__ == "__main__":
    main()
