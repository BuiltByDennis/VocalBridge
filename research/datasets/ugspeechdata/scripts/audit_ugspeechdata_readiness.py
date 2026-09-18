import os
import json

def main():
    base_dir = "/home/tjay/VocalBridge/research/datasets/ugspeechdata/source"
    
    # Check if dir exists
    if not os.path.exists(base_dir):
        status = "NOT_AVAILABLE"
    else:
        # Check for csv or audio files (wav, mp3, flac)
        has_audio = False
        has_metadata = False
        for root, dirs, files in os.walk(base_dir):
            # Exclude .git
            if '.git' in root:
                continue
            for f in files:
                if f.endswith('.csv') or f.endswith('.json'):
                    has_metadata = True
                if f.endswith('.wav') or f.endswith('.mp3') or f.endswith('.flac'):
                    has_audio = True
                    
        if has_audio and has_metadata:
            status = "AVAILABLE"
        elif has_audio or has_metadata:
            status = "PARTIALLY_AVAILABLE"
        else:
            status = "NOT_AVAILABLE"
            
    report = {
        "dataset": "UGSpeechData",
        "status": status,
        "languages": {
            "Akan": "NOT_AVAILABLE",
            "Ewe": "NOT_AVAILABLE",
            "Dagbani": "NOT_AVAILABLE",
            "Dagaare": "NOT_AVAILABLE",
            "Ikposo": "NOT_AVAILABLE"
        }
    }
    
    out_dir = "/home/tjay/VocalBridge/research/reports/phase7"
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, "phase7d_ugspeechdata_readiness.json"), "w") as f:
        json.dump(report, f, indent=2)

if __name__ == "__main__":
    main()
