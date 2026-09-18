# Phase 18: Model Adaptation Research

## 1. Theoretical Framework
To adapt an existing ASR model to a specific user's dysarthric speech, one typically isolates the acoustic encoder. For the Zipformer architecture used by Sherpa, this involves freezing the base model and training small Low-Rank Adaptation (LoRA) matrices on the attention layers.

## 2. Technical Blockers for Kasa Me
1. **PyTorch vs ONNX:** Adaptation is performed in PyTorch. Kasa Me runs ONNX models via Sherpa. We cannot run PyTorch backpropagation on an Android phone.
2. **Cloud Dependency:** To train the LoRA weights, Kasa Me would need to upload the user's calibration audio to a secure server, train the adapter, and download the new weights. This violates the 100% offline privacy mandate.
3. **Federated Learning:** Technically possible, but the compute requirements for on-device Federated Learning for a Zipformer model exceed the thermal and RAM limits of target low-end Android devices.

## 3. Verdict
True acoustic model adaptation is **BLOCKED BY ANDROID CONSTRAINTS** and **BLOCKED BY PRIVACY/ETHICS**. Until highly optimized on-device LoRA training for ONNX becomes available, Kasa Me must rely on Strategy A (Post-ASR Personalization) as its primary mechanism for handling atypical speech.
