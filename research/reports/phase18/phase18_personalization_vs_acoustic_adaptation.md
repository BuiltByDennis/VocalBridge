# Phase 18: Personalization vs Acoustic Adaptation

It is critical to distinguish between Personalization (what Kasa Me does today) and Acoustic Adaptation (what Kasa Me aspires to do).

## 1. Post-Processing Personalization (Current State)
`Audio -> ASR -> "I want wah tah" -> Personalization -> "I want water"`

Here, the ASR model failed. It emitted "wah tah". The personalization layer (a deterministic dictionary map) caught the error and fixed it. 
**Limitation:** If the user's speech degrades further and the ASR outputs "ah ah ah", the dictionary map will fail to trigger.

## 2. Acoustic Adaptation (Future State)
`Audio -> Adapted ASR -> "I want water"`

Here, the ASR model's internal weights have been adjusted (e.g., via LoRA) to understand that the user's specific acoustic signature for the phonemes in "water" maps to the tokens for "water", even if it sounds like "wah tah" to a neurotypical ear.
**Limitation:** Requires heavy compute to generate the adapter weights, and complex runtime architectures to load them.

## 3. The Evidence Gap
Simulated experiments in `research/phase18/scripts/evaluation_harness.py` highlight this. Personalization is brittle to variations in the misrecognition. Acoustic adaptation is robust, but the engineering pathway to deploy LoRA adapters to an offline Sherpa-ONNX C++ runtime on Android remains unresolved.
