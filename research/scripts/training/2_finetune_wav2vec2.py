import torch
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Union
from datasets import load_from_disk
from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor, Trainer, TrainingArguments
import evaluate
import numpy as np

# Paths
DATASET_DIR = "../../datasets/ugakan_impaired_speech/hf_dataset"
MODEL_ID = "asr-africa/wav2vec2-xls-r-akan-50-hours"
OUTPUT_DIR = "../../models/wav2vec2_finetuned"

@dataclass
class DataCollatorCTCWithPadding:
    processor: Wav2Vec2Processor
    padding: Union[bool, str] = True
    max_length: Optional[int] = None
    max_length_labels: Optional[int] = None
    pad_to_multiple_of: Optional[int] = None
    pad_to_multiple_of_labels: Optional[int] = None

    def __call__(self, features: List[Dict[str, Union[List[int], torch.Tensor]]]) -> Dict[str, torch.Tensor]:
        input_features = [{"input_values": feature["input_values"]} for feature in features]
        label_features = [{"input_ids": feature["labels"]} for feature in features]

        batch = self.processor.pad(
            input_features,
            padding=self.padding,
            max_length=self.max_length,
            pad_to_multiple_of=self.pad_to_multiple_of,
            return_tensors="pt",
        )

        with self.processor.as_target_processor():
            labels_batch = self.processor.pad(
                label_features,
                padding=self.padding,
                max_length=self.max_length_labels,
                pad_to_multiple_of=self.pad_to_multiple_of_labels,
                return_tensors="pt",
            )

        # replace padding with -100 to ignore loss correctly
        labels = labels_batch["input_ids"].masked_fill(labels_batch.attention_mask.ne(1), -100)
        batch["labels"] = labels

        return batch

def main():
    print("Loading prepared dataset...")
    dataset = load_from_disk(DATASET_DIR)
    
    print("Loading processor and model...")
    processor = Wav2Vec2Processor.from_pretrained(MODEL_ID)
    
    # We load the model for fine-tuning. The CTC vocabulary size should match the processor.
    model = Wav2Vec2ForCTC.from_pretrained(
        MODEL_ID, 
        ctc_loss_reduction="mean", 
        pad_token_id=processor.tokenizer.pad_token_id,
        ignore_mismatched_sizes=True # In case custom vocab was added
    )
    
    # Freeze the feature extractor for stability
    model.freeze_feature_extractor()

    data_collator = DataCollatorCTCWithPadding(processor=processor, padding=True)
    
    wer_metric = evaluate.load("wer")

    def compute_metrics(pred):
        pred_logits = pred.predictions
        pred_ids = np.argmax(pred_logits, axis=-1)

        pred.label_ids[pred.label_ids == -100] = processor.tokenizer.pad_token_id

        pred_str = processor.batch_decode(pred_ids)
        label_str = processor.batch_decode(pred.label_ids, group_tokens=False)

        wer = wer_metric.compute(predictions=pred_str, references=label_str)
        return {"wer": wer}

    training_args = TrainingArguments(
        output_dir=OUTPUT_DIR,
        group_by_length=True,
        per_device_train_batch_size=8,
        gradient_accumulation_steps=4,
        evaluation_strategy="steps",
        num_train_epochs=10,
        fp16=True, # Important for Colab T4
        save_steps=500,
        eval_steps=500,
        logging_steps=100,
        learning_rate=1e-4,
        weight_decay=0.005,
        warmup_steps=1000,
        save_total_limit=2,
    )

    trainer = Trainer(
        model=model,
        data_collator=data_collator,
        args=training_args,
        compute_metrics=compute_metrics,
        train_dataset=dataset["train"],
        eval_dataset=dataset["validation"],
        tokenizer=processor.feature_extractor,
    )
    
    print("Starting training...")
    trainer.train()
    
    print(f"Saving final model to {OUTPUT_DIR}...")
    trainer.save_model(OUTPUT_DIR)
    processor.save_pretrained(OUTPUT_DIR)
    print("Training complete! Proceed to export.")

if __name__ == "__main__":
    main()
