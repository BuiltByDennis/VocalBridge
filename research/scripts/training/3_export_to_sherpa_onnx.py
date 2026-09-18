import os
import json
import torch
from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor

MODEL_DIR = "../../models/wav2vec2_finetuned"
OUTPUT_DIR = "../../models/sherpa_onnx_export"

def export_to_onnx():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
        
    print(f"Loading finetuned model from {MODEL_DIR}...")
    processor = Wav2Vec2Processor.from_pretrained(MODEL_DIR)
    model = Wav2Vec2ForCTC.from_pretrained(MODEL_DIR)
    model.eval()
    
    # 1. Export the ONNX model
    # We create dummy input features to trace the model
    dummy_input = torch.randn(1, 16000) # 1 second of audio at 16kHz
    input_values = processor(dummy_input, return_tensors="pt", sampling_rate=16000).input_values
    
    onnx_path = os.path.join(OUTPUT_DIR, "model.onnx")
    print(f"Exporting ONNX model to {onnx_path}...")
    
    torch.onnx.export(
        model, 
        input_values, 
        onnx_path, 
        export_params=True,
        opset_version=13,
        do_constant_folding=True,
        input_names=['input'], 
        output_names=['output'], 
        dynamic_axes={
            'input': {0: 'batch_size', 1: 'sequence_length'},
            'output': {0: 'batch_size', 1: 'sequence_length'}
        }
    )
    
    # 2. Extract tokens.txt
    print("Generating tokens.txt for sherpa-onnx...")
    vocab = processor.tokenizer.get_vocab()
    
    # Sort vocab by token id
    sorted_vocab = sorted(vocab.items(), key=lambda item: item[1])
    
    tokens_path = os.path.join(OUTPUT_DIR, "tokens.txt")
    with open(tokens_path, 'w', encoding='utf-8') as f:
        for token, token_id in sorted_vocab:
            # sherpa-onnx tokens.txt format: token id
            f.write(f"{token} {token_id}\n")
            
    print("Export complete!")
    print(f"Your model and tokens are ready in {OUTPUT_DIR}")
    print("You can now transfer these files to your Kasa Me flutter assets!")

if __name__ == "__main__":
    export_to_onnx()
