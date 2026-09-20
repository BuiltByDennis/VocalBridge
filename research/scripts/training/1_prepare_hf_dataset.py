import json
import librosa
import torch
from datasets import Dataset, DatasetDict, Audio
from transformers import Wav2Vec2Processor

# Paths
BASE_DIR = "../../datasets/ugakan_impaired_speech"
SPLITS_DIR = f"{BASE_DIR}/splits"
OUTPUT_DIR = f"{BASE_DIR}/hf_dataset"
MODEL_ID = "asr-africa/wav2vec2-xls-r-akan-50-hours"

def load_jsonl(file_path):
    data = []
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            data.append(json.loads(line))
    return data

def prepare_dataset(batch, processor):
    audio = batch["audio"]
    # Batched output is "input_values"
    batch["input_values"] = processor(audio["array"], sampling_rate=audio["sampling_rate"]).input_values[0]
    
    with processor.as_target_processor():
        # Ensure target text is lowercase and normalized based on Akan characters
        text = batch["transcript"].lower().strip()
        batch["labels"] = processor(text).input_ids
        
    return batch

def main():
    print("Loading processor...")
    processor = Wav2Vec2Processor.from_pretrained(MODEL_ID)

    print("Loading jsonl splits...")
    train_data = load_jsonl(f"{SPLITS_DIR}/train.jsonl")
    dev_data = load_jsonl(f"{SPLITS_DIR}/dev.jsonl")

    # The jsonl files typically have {"audio_filepath": "...", "text": "..."}
    # We will format this into a HuggingFace dictionary format
    def format_to_dict(data):
        return {
            "audio": [item.get("absolute_audio_path") or item.get("audio_filepath") for item in data],
            "transcript": [item.get("transcript_normalized") or item.get("text") or item.get("transcript_original") for item in data]
        }
        
    print("Converting to HF Dataset...")
    train_dataset = Dataset.from_dict(format_to_dict(train_data))
    dev_dataset = Dataset.from_dict(format_to_dict(dev_data))
    
    # Cast audio column to Audio feature with 16kHz resampling
    train_dataset = train_dataset.cast_column("audio", Audio(sampling_rate=16000))
    dev_dataset = dev_dataset.cast_column("audio", Audio(sampling_rate=16000))
    
    dataset = DatasetDict({
        "train": train_dataset,
        "validation": dev_dataset
    })
    
    print("Extracting features and labels (this may take a while)...")
    dataset = dataset.map(prepare_dataset, remove_columns=dataset.column_names["train"], fn_kwargs={"processor": processor}, num_proc=4)
    
    print(f"Saving prepared dataset to {OUTPUT_DIR}...")
    dataset.save_to_disk(OUTPUT_DIR)
    print("Done! You can now proceed to step 2.")

if __name__ == "__main__":
    main()
