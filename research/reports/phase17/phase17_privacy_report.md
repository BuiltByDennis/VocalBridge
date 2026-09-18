# Phase 17 Privacy Report

## 1. Research Phase
Phase 17 involved zero code changes to the production application. No new telemetry, analytics, or background data collection systems were evaluated or introduced.

## 2. Future Ghanaian Language ASR Privacy
Any future implementation of Ghanaian Language ASR (Phase 18+) must adhere to Kasa Me's existing privacy constraints:
- **No Cloud APIs:** Speech must not be transmitted to OpenAI, Meta, Google, or any third-party translation/ASR endpoint.
- **No Raw Audio Persistence:** Audio buffers used for inference must be destroyed immediately upon final transcript generation.
- **On-Device Dictionaries:** Any translated safety rules or dictionaries must be statically compiled or stored in the local SQLite database.

## 3. Dataset Privacy
Public datasets evaluated in this phase (Common Voice, FLEURS) rely on opt-in consent from their participants. However, if Kasa Me introduces a mechanism to collect Atypical Ghanaian Speech for training (as identified in the gap analysis), it will require a rigorous HIPAA-compliant medical data privacy framework, which is currently out of scope for the mobile application itself.
