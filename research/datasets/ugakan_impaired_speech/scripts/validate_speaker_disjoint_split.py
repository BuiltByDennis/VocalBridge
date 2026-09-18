import os
import json
import sys

def main():
    split_dir = "/home/tjay/VocalBridge/research/datasets/ugakan_impaired_speech/splits"
    
    splits = {'train': [], 'dev': [], 'test': []}
    
    for s in splits:
        path = os.path.join(split_dir, f"{s}.jsonl")
        if os.path.exists(path):
            with open(path, 'r') as f:
                for line in f:
                    splits[s].append(json.loads(line))
                    
    spks = {s: set(r.get('speaker_id') for r in splits[s]) for s in splits}
    grps = {s: set(r.get('duplicate_group_id') for r in splits[s] if r.get('duplicate_group_id')) for s in splits}
    audios = {s: set(r.get('relative_audio_path') for r in splits[s]) for s in splits}
    
    errors = []
    
    if spks['train'].intersection(spks['dev']): errors.append("TRAIN and DEV speaker overlap")
    if spks['train'].intersection(spks['test']): errors.append("TRAIN and TEST speaker overlap")
    if spks['dev'].intersection(spks['test']): errors.append("DEV and TEST speaker overlap")
    
    if grps['train'].intersection(grps['dev']): errors.append("TRAIN and DEV duplicate group overlap")
    if grps['train'].intersection(grps['test']): errors.append("TRAIN and TEST duplicate group overlap")
    if grps['dev'].intersection(grps['test']): errors.append("DEV and TEST duplicate group overlap")

    if audios['train'].intersection(audios['dev']): errors.append("TRAIN and DEV audio reference overlap")
    if audios['train'].intersection(audios['test']): errors.append("TRAIN and TEST audio reference overlap")
    if audios['dev'].intersection(audios['test']): errors.append("DEV and TEST audio reference overlap")
    
    if errors:
        for e in errors:
            print("ERROR:", e)
        sys.exit(1)
        
    print("Split validation PASS. No overlap detected.")
    sys.exit(0)

if __name__ == "__main__":
    main()
