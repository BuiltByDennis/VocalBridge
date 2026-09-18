# Phase 18: Atypical Speech Landscape

## 1. Etiologies and Acoustic Manifestations
Atypical speech is not a monolithic category. It encompasses:
- **Dysarthria:** Muscle weakness affecting lips, tongue, vocal cords, or diaphragm. Results in slurred speech, slow rate, and restricted pitch.
- **Apraxia:** Neurological difficulty coordinating the motor plans for speech. Results in inconsistent errors and groping for sounds.
- **Stammering/Stuttering:** Fluency disorders involving repetitions, prolongations, or blocks.
- **Cleft-related speech:** Hypernasality and consonant distortion due to anatomical differences.

## 2. The Acoustic Mismatch Problem
Modern ASR models (like Whisper or Zipformer) are trained on thousands of hours of neurotypical speech (audiobooks, podcasts, YouTube). When presented with atypical speech, they fail because the phonetic boundaries and timing distributions are completely out of-distribution (OOD) for the model's acoustic encoder.

## 3. The Dataset Void
As established in the Dataset Audit, while major efforts (Project Euphonia) exist for English, they are closely guarded behind corporate and institutional walls. The open-source landscape for atypical speech is severely impoverished, relying mostly on decades-old datasets (Torgo, UASpeech) that lack modern recording fidelity and scale.
