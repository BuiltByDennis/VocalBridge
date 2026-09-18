import os
import json

def main():
    # Attempt to locate Ewe ASR in the workspace
    ewe_paths = []
    for root, dirs, files in os.walk("/home/tjay/VocalBridge"):
        if '.git' in root: continue
        if 'ewe' in root.lower() and ('model' in root.lower() or 'asr' in root.lower()):
            ewe_paths.append(root)
            
    status = "NOT_FOUND" if not ewe_paths else "NOT_INSPECTABLE"
    
    report = {
        "asset": "Ewe ASR Model/Split",
        "status": status,
        "located_paths": ewe_paths,
        "leakage": {
            "speaker_leakage": "NOT_DETERMINED",
            "exact_duplicate_leakage": "NOT_DETERMINED",
            "transcript_overlap": "NOT_DETERMINED",
            "audio_reference_overlap": "NOT_DETERMINED",
            "metadata_leakage": "NOT_DETERMINED",
            "session_leakage": "NOT_DETERMINED"
        }
    }
    
    out_dir = "/home/tjay/VocalBridge/research/reports/phase7"
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, "phase7d_ewe_split_audit.json"), "w") as f:
        json.dump(report, f, indent=2)

if __name__ == "__main__":
    main()
