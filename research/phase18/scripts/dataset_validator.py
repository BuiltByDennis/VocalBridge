import json
import sys
from pathlib import Path

def validate_manifest(manifest_path: str):
    """
    Validates an experimental dataset manifest.
    Ensures TRAIN \u2229 TEST = \u2205 (speaker-disjoint).
    """
    path = Path(manifest_path)
    if not path.exists():
        print(f"Error: Manifest {manifest_path} not found.")
        return False
        
    with open(path, 'r') as f:
        data = json.load(f)
        
    print(f"Validating Dataset: {data.get('dataset_name', 'Unknown')}")
    print(f"License: {data.get('license', 'Unknown')} | Provenance: {data.get('provenance', 'Unknown')}")
    
    train_speakers = set(data.get("train_speakers", []))
    test_speakers = set(data.get("test_speakers", []))
    
    intersection = train_speakers.intersection(test_speakers)
    
    if len(intersection) > 0:
        print(f"CRITICAL ERROR: TRAIN \u2229 TEST = \u2205 VIOLATION!")
        print(f"Overlapping speakers: {intersection}")
        return False
        
    print("Speaker-disjoint split verified: PASS.")
    
    if not data.get("commercial_use", False):
        print("WARNING: Dataset commercial use restricted. RESEARCH ONLY.")
        
    return True

if __name__ == "__main__":
    if len(sys.argv) > 1:
        validate_manifest(sys.argv[1])
    else:
        print("Usage: python dataset_validator.py <manifest.json>")
