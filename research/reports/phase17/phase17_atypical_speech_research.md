# Phase 17 Atypical Speech Research

## 1. Track Separation
As requested, research is separated into distinct tracks:

### TRACK A: Ghanaian-Language ASR
- **Status:** Sparse but existence proven (FLEURS, Common Voice). Primarily neurotypical read-speech.

### TRACK B: Atypical-Speech ASR (English)
- **Status:** Established research domain (e.g., Google's Project Euphonia). Datasets are tightly guarded due to medical privacy concerns. Very few open-source datasets exist. Adaptation techniques (fine-tuning on few-shot personalized data) are proven to work well for English.

### TRACK C: Intersection (Ghanaian-Language + Atypical Speech)
- **Status:** **COMPLETE RESEARCH GAP.**
- **Evidence:** There are zero publicly available datasets containing dysarthric or atypical speech recorded in Akan, Ewe, Ga, or Dagbani. 

## 2. Implications for Kasa Me
The core mission of Kasa Me is assisting users with atypical speech. Because Track C has zero data, it is mathematically impossible to train a general "Atypical Ghanaian Language" foundation model today.

**The only viable paths forward:**
1. **Personalized Adaptation:** Provide a mechanism for the user to record themselves speaking Twi (Phase 10 Calibration style) and fine-tune a baseline Twi model specifically to their voice using edge-based learning or zero-shot voice conversion.
2. **Deterministic Personalization:** Rely entirely on Phase 11 (Personal Vocabulary) and Phase 13 (Passive Personalization) to bridge the gap, accepting that the base model will struggle initially.

## 3. Conclusion
The intersection of Ghanaian Languages and Atypical Speech is a severe data void. Kasa Me must rely on system-level personalization (Phase 13) rather than expecting the acoustic models to naturally handle atypical Ghanaian speech out of the box.
