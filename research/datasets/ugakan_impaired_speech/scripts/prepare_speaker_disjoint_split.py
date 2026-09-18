import os
import json
import random

def main():
    manifest_path = "/home/tjay/VocalBridge/research/datasets/ugakan_impaired_speech/manifests/canonical_audio_manifest.jsonl"
    out_dir = "/home/tjay/VocalBridge/research/datasets/ugakan_impaired_speech/splits"
    os.makedirs(out_dir, exist_ok=True)
    
    if not os.path.exists(manifest_path):
        print("Manifest not found")
        return
        
    records = []
    with open(manifest_path, 'r') as f:
        for line in f:
            records.append(json.loads(line))
            
    # Duplicate group contamination analysis
    contaminated_groups = set()
    safe_groups = set()
    
    group_speakers = {}
    for r in records:
        grp = r.get('duplicate_group_id')
        if grp:
            if grp not in group_speakers:
                group_speakers[grp] = set()
            group_speakers[grp].add(r.get('speaker_id'))
            
    for grp, spks in group_speakers.items():
        if len(spks) > 1:
            contaminated_groups.add(grp)
        else:
            safe_groups.add(grp)
            
    # Filter records, excluding contaminated
    safe_records = []
    excluded_records = []
    for r in records:
        grp = r.get('duplicate_group_id')
        if grp in contaminated_groups:
            r['split'] = 'EXCLUDED'
            excluded_records.append(r)
        else:
            safe_records.append(r)
            
    # Group by speaker
    speaker_recs = {}
    for r in safe_records:
        spk = r.get('speaker_id')
        if spk not in speaker_recs:
            speaker_recs[spk] = []
        speaker_recs[spk].append(r)
        
    # Simple deterministic speaker split
    speakers = sorted(list(speaker_recs.keys()))
    random.seed(42)
    random.shuffle(speakers)
    
    n_speakers = len(speakers)
    test_idx = int(n_speakers * 0.1)
    dev_idx = test_idx + int(n_speakers * 0.1)
    
    # Ensure at least 1 speaker per partition if enough speakers exist
    if test_idx == 0 and n_speakers >= 3:
        test_idx = 1
        dev_idx = 2

    test_spks = set(speakers[:test_idx])
    dev_spks = set(speakers[test_idx:dev_idx])
    train_spks = set(speakers[dev_idx:])
    
    train_recs = []
    dev_recs = []
    test_recs = []
    
    for r in safe_records:
        spk = r.get('speaker_id')
        r['split_seed'] = 42
        r['split_algorithm_version'] = "1.0"
        
        if spk in test_spks:
            r['split'] = 'test'
            test_recs.append(r)
        elif spk in dev_spks:
            r['split'] = 'dev'
            dev_recs.append(r)
        else:
            r['split'] = 'train'
            train_recs.append(r)
            
    for name, data in [("train.jsonl", train_recs), ("dev.jsonl", dev_recs), ("test.jsonl", test_recs)]:
        with open(os.path.join(out_dir, name), 'w') as f:
            for r in data:
                f.write(json.dumps(r) + "\n")
                
    manifest = {
        "dataset_id": "UGAkan-ImpairedSpeechData",
        "dataset_version": "1",
        "split_seed": 42,
        "split_algorithm_version": "1.0",
        "train_speakers": len(train_spks),
        "dev_speakers": len(dev_spks),
        "test_speakers": len(test_spks),
        "train_utterances": len(train_recs),
        "dev_utterances": len(dev_recs),
        "test_utterances": len(test_recs),
        "excluded_utterances": len(excluded_records),
        "contaminated_duplicate_groups": len(contaminated_groups)
    }
    
    with open(os.path.join(out_dir, "split_manifest.json"), 'w') as f:
        json.dump(manifest, f, indent=2)

if __name__ == "__main__":
    main()
