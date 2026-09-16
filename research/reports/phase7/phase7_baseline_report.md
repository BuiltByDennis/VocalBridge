# Kasa Me — Phase 7A Baseline Model Report

## 1. Production Model Metadata

* **Model ID:** `english_edge_v1`
* **Display Name:** English (Ghana) Edge Zipformer v1
* **Language Target:** `en_GH`
* **Base Architecture:** Streaming Zipformer Transducer
* **Upstream Baseline Source:** `sherpa-onnx-streaming-zipformer-en-20M-2023-02-17`
* **Quantization:** INT8
* **Sample Rate:** 16,000 Hz
* **Total Asset Size:** ~43.6 MB

---

## 2. Immutable Cryptographic Baseline Verification

The production ASR model files located at `kasa_me/assets/models/asr/english/` have been cryptographically hashed and verified using SHA-256:

| File Name | Relative Path | Size (Bytes) | SHA-256 Hash | Status |
| :--- | :--- | :--- | :--- | :--- |
| **`encoder.onnx`** | `kasa_me/assets/models/asr/english/encoder.onnx` | 42,845,182 | `3810755ce7c3ab26b42a8bcf39d191308fa27fb0f53358823ba46141d03b7eb3` | **PASS** |
| **`decoder.onnx`** | `kasa_me/assets/models/asr/english/decoder.onnx` | 539,499 | `21e2a2acd961b3ac72f55be2f10f1a285e1b0b0ba010d7c0b6eab141411b163c` | **PASS** |
| **`joiner.onnx`** | `kasa_me/assets/models/asr/english/joiner.onnx` | 259,572 | `e085d73b593cf9b0707f370dbd656d58327d3fe36d80d849202ef81df02cb01e` | **PASS** |
| **`tokens.txt`** | `kasa_me/assets/models/asr/english/tokens.txt` | 5,048 | `49e3c2646595fd907228b3c6787069658f67b17377c60aeb8619c4551b2316fb` | **PASS** |

---

## 3. Automated Verification Tooling

* **Script Path:** `research/models/baseline/verify_baseline_model.py`
* **Manifest Path:** `research/models/baseline/baseline_manifest.json`
* **Execution Command:**
  ```bash
  python3 research/models/baseline/verify_baseline_model.py
  ```
* **Verification Output:**
  ```text
  ================================================================================
  KASA ME BASELINE ASR MODEL VERIFICATION — [english_edge_v1]
  ================================================================================
  Overall Status: PASS
  Manifest Path : research/models/baseline/baseline_manifest.json
  --------------------------------------------------------------------------------
  File Name       Status   Size (Bytes)   SHA-256 Hash
  --------------------------------------------------------------------------------
  encoder.onnx    PASS     42845182       3810755ce7c3ab26b42a8bcf39d191308fa27fb0f53358823ba46141d03b7eb3
  decoder.onnx    PASS     539499         21e2a2acd961b3ac72f55be2f10f1a285e1b0b0ba010d7c0b6eab141411b163c
  joiner.onnx     PASS     259572         e085d73b593cf9b0707f370dbd656d58327d3fe36d80d849202ef81df02cb01e
  tokens.txt      PASS     5048           49e3c2646595fd907228b3c6787069658f67b17377c60aeb8619c4551b2316fb
  ================================================================================
  ```

---

## 4. Hard Production Boundary Rules

1. **Model Immutability:** `english_edge_v1` is frozen. No weights, ONNX operators, or token lists may be altered.
2. **Experimental Isolation:** All future research checkpoints or Ghanaian-language models must reside in `research/models/experimental/`.
3. **No Automatic Promotion:** No experimental model will be promoted to production without explicit verification and approval.
