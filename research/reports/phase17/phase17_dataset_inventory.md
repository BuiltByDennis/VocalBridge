# Phase 17 Dataset Inventory

## 1. Publicly Available Datasets

### A. Mozilla Common Voice (Ghanaian Languages)
- **Languages:** Dagbani, Kinyarwanda (regional), small amounts of Twi.
- **Size:** Dagbani has seen massive growth (hundreds of hours). Twi is currently limited.
- **Speaker Demographics:** High gender/age diversity, typically healthy speakers reading prompts.
- **Conditions:** Crowdsourced, variable mic quality.
- **License:** CC0 (Public Domain).
- **COMMERCIAL_USE_ALLOWED**: Yes.

### B. ALFFA (African Languages in the Field)
- **Languages:** Amharic, Swahili, Wolof, Fongbe. No major Ghanaian language explicitly covered, though often cited in African NLP.
- **Relevance:** Low for Ghana specifically.

### C. FLEURS (Few-shot Learning Evaluation of Universal Representations of Speech)
- **Languages:** Includes Akan (Twi) and Ewe.
- **Size:** ~12 hours of training data per language.
- **Conditions:** High quality, clean read speech.
- **License:** CC-BY 4.0.
- **COMMERCIAL_USE_ALLOWED**: Yes (with attribution).

### D. OpenSLR (Various African sets)
- **Languages:** Primarily West African (Yoruba, Hausa, Igbo) and East/South African. 
- **Relevance:** Limited for Ghana beyond Hausa (which is spoken as a trade language in Zongo communities).

## 2. Proprietary / Local Datasets
No proprietary datasets beyond UGAkan were provided or discovered during this phase.

## 3. Conclusions
For Akan (Twi), the largest freely available, commercially usable dataset for general ASR is FLEURS, which is very small (~12 hours) and suitable for fine-tuning or evaluation, but insufficient for training a robust model from scratch.

*Dataset licensing classifications are based on official repository texts. Legal review is always recommended before bundling model weights derived from them.*
