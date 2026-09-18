# Phase 18: Production Promotion Gates

## 1. The Rule
No experimental adaptation may become production merely because it improves WER.

## 2. The 14 Gates
Before any adapted model or new ASR pipeline enters `kasa_me/lib/speech/`, it must mathematically and legally pass:
1. **Measurable Improvement:** Statistically significant WER drop on the target etiology.
2. **Speaker-Disjoint Validation:** Proven via `dataset_validator.py`.
3. **No Unacceptable Regression on Typical Speech.**
4. **No Unacceptable Regression on Existing English.**
5. **No Unacceptable Regression in Ghanaian English.**
6. **Safety Validation:** High-impact terms trigger correctly.
7. **Accessibility Validation:** UI constraints hold.
8. **Offline Validation:** Inference requires 0 network requests.
9. **Android Performance Validation:** Model fits in RAM; Real-Time Factor < 1.0.
10. **Privacy Validation:** No raw audio persistence.
11. **Licensing Clearance:** CC0, MIT, Apache 2.0, or CC-BY (No Non-Commercial clauses).
12. **Provenance Documentation:** Manifest recorded.
13. **Reproducibility:** Evaluation scripts yield identical metrics on subsequent runs.
14. **Model Integrity Verification:** Checksums match.

## 3. Status
As of the conclusion of Phase 18, **NO** experimental acoustic adaptation model has passed all 14 gates. Kasa Me remains securely anchored to its Phase 17 baseline.
