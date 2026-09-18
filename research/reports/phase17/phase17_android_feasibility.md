# Phase 17 Android & Offline Feasibility

## 1. Physical Constraints (Edge Devices)
Kasa Me is targeted at offline Android users, requiring broad compatibility with mid-to-low-tier devices in Ghana (e.g., Tecno, Infinix, Samsung A-series).

### Acceptance Targets:
- **APK Size Impact:** < 50MB per language.
- **RAM Usage:** < 200MB during active streaming.
- **Inference Latency:** Real-Time Factor (RTF) < 0.2 (transcribes 1s of audio in < 200ms).
- **Thermal:** Must not throttle device during 5-minute continuous speech loops.

## 2. Model Assessment
- **Sherpa-ONNX (Zipformer):**
  - **Size:** ~30MB (int8 quantized).
  - **RAM:** ~100MB.
  - **Feasibility:** **EXCELLENT**. (Already validated in Phase 8-16).
- **Whisper.cpp (Tiny/Base):**
  - **Size:** 39MB (Tiny) / 74MB (Base).
  - **RAM:** ~150MB.
  - **Feasibility:** **HIGH**. 
- **Meta MMS / Seamless M4T:**
  - **Size:** 1.2GB+.
  - **RAM:** 2GB+.
  - **Feasibility:** **ZERO**. Cannot run in real-time on target devices.

## 3. Storage Strategy
If Kasa Me supports 5 Ghanaian languages via Strategy D (Separate models), bundling all of them in the APK would bloat it to 200MB+.
**Requirement:** Language models must be implemented as *On-Demand Offline Downloads* rather than bundled assets. 

## 4. Conclusion
True offline Ghanaian ASR is highly feasible *computationally*, but only if the model architecture remains Zipformer/Transducer (Sherpa) or highly quantized Whisper. Large foundation models are disqualified immediately based on thermal and RAM constraints.
