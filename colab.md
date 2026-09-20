# Colab Execution Prompts for Kasa Me ASR Training

Copy and paste these prompts phase-by-phase into your Google Colab AI assistant (or run the underlying commands directly in Colab cells) to execute our training pipeline.

## Phase 1: Environment Setup & Data Extraction

**Prompt to paste in Colab:**
> "I have cloned the `VocalBridge` repository, and there is a dataset file named `UGAkan-ImpairedSpeechData A Dataset of Impaired Speech in the Akan Language.zip` in the root directory. 
> 
> Please create a Colab cell to:
> 1. Unzip this file directly into `VocalBridge/research/datasets/ugakan_impaired_speech/raw/`. 
> 2. The zip contains several `.tar.gz` files (Stroke, Cleft, Stammering, Cerebral palsy). Please write a bash command to extract all of these `.tar.gz` archives into the same `raw/` directory.
> 3. Install the required HuggingFace dependencies: `pip install transformers datasets evaluate librosa onnx`."

---

## Phase 2: Dataset Preparation

**Prompt to paste in Colab:**
> "Now that the environment is set up, I need to convert the JSONL split files into a HuggingFace Arrow Dataset.
> 
> I have already written a Python script for this at `VocalBridge/research/scripts/training/1_prepare_hf_dataset.py`. 
> 
> Please create a Colab cell to run this script using `!python VocalBridge/research/scripts/training/1_prepare_hf_dataset.py`. Let me know when the dataset is saved to disk so we can proceed to training."

---

## Phase 3: Fine-Tuning Wav2Vec2

**Prompt to paste in Colab:**
> "The dataset is ready. We will now fine-tune the `asr-africa/wav2vec2-xls-r-akan-50-hours` model. 
> 
> Please verify that the Colab runtime is set to GPU (T4 or better). Then, create a Colab cell to run my training script: `!python VocalBridge/research/scripts/training/2_finetune_wav2vec2.py`. 
> 
> This will take some time. Monitor the output for the Word Error Rate (WER) and let me know when the training successfully completes and the model is saved to `VocalBridge/research/models/wav2vec2_finetuned`."

---

## Phase 4: Sherpa-ONNX Export

**Prompt to paste in Colab:**
> "Training is complete! Kasa Me uses `sherpa-onnx` for offline mobile inference, so we must export this PyTorch model to ONNX.
> 
> Please create a Colab cell to run my export script: `!python VocalBridge/research/scripts/training/3_export_to_sherpa_onnx.py`. 
> 
> Once it finishes, provide me with the code to download the resulting `model.onnx` and `tokens.txt` files from `VocalBridge/research/models/sherpa_onnx_export/` so I can move them into my Flutter project's assets."
