# Phase 7D Ghana Language Readiness & Architecture Report

## 1. Executive Summary
Phase 7D executed a strict, reproducible audit of the current dataset assets and established an evidence-based future architectural framework for typical and atypical Ghanaian speech processing. The dataset `UGAkan-ImpairedSpeechData` successfully passed deterministic split validation with strict cross-speaker duplicate exclusion rules. The `UGSpeechData` and Ewe ASR models are not physically present in the workspace, classifying them as `NOT_AVAILABLE` and blocking immediate execution of the general speech track.

## 2. Production Baseline Status
BEFORE = PASS
AFTER = PASS

## 3. UGSpeechData Availability
Status: **NOT_AVAILABLE**
The submodule directory exists locally, but neither raw audio files nor CSV metadata files are present.

## 4. UGSpeechData Language Inventory
Akan: `NOT_AVAILABLE`
Ewe: `NOT_AVAILABLE`
Dagbani: `NOT_AVAILABLE`
Dagaare: `NOT_AVAILABLE`
Ikposo: `NOT_AVAILABLE`

## 5. Language Metadata Quality
The metadata for the `UGAkan-ImpairedSpeechData` accurately records the language as "Akan". Further normalization logic ensures strict capitalization/naming integrity in our derived canonical manifest. For `UGSpeechData`, metadata quality is `NOT_VERIFIED` due to missing raw CSVs.

## 6. Ewe Repository / Split Audit
Status: **NOT_FOUND**
Extensive filesystem search confirms the Ewe ASR models and split directories are missing from the current workspace hierarchy.

## 7. Ewe Speaker Leakage
Status: `NOT_DETERMINED` (Due to missing assets).

## 8. Ewe Duplicate Leakage
Status: `NOT_DETERMINED` (Due to missing assets).

## 9. UGAkan Future Split Architecture
A strictly deterministic, speaker-disjoint split algorithm (`prepare_speaker_disjoint_split.py`) was designed and validated. It uses dynamic filesystem auditing to group identical acoustic representations, fully isolating speakers and excluding structurally conflicted groups (e.g. cross-speaker identical audio) from contaminating the splits.
- Split distribution: Train (~80%), Dev (~10%), Test (~10%)
- Provenance tracking via `split_manifest.json`
- Hard constraint: `TRAIN speakers ∩ DEV speakers = ∅` AND `duplicate_group_id` cannot cross.

## 10. Cross-Speaker Duplicate Handling
All **339 cross-speaker exact duplicates** found in Phase 7C were explicitly labeled as **contaminated** and fully excluded from `train/dev/test` assignment. They are preserved in the raw data but correctly masked out in the experimental split (`split = EXCLUDED`) to prevent catastrophic test-set leakage.

## 11. Typical vs Atypical Population Separation
The architectural tracks are strictly delineated:
- **Track A:** General Ghanaian Languages (UGSpeechData - NOT_AVAILABLE).
- **Track B:** Atypical/Impaired Akan (UGAkan-ImpairedSpeechData - PARTIALLY_READY).
Metrics like WER will never be merged across these populations, maintaining rigorous scientific bounds.

## 12. Multilingual ASR Architecture Options
- **Language-specific ASR**: ARCHITECTURALLY_PLAUSIBLE, highest maintainability.
- **Multilingual ASR**: RESEARCH_REQUIRED, potential interference across 5 distinct languages.
- **Shared encoder + Language-specific heads**: ARCHITECTURALLY_PLAUSIBLE, best balance of disk size vs. specialization.
- **Shared base + lightweight language adapters (PEFT)**: ARCHITECTURALLY_PLAUSIBLE, ideal for offline/mobile memory constraints.

## 13. Personalization Compatibility
Phase 4-6 infrastructure remains intact. Future experiments on atypical speech must structurally decouple calibration samples from held-out evaluation utterances, ensuring the strict `speaker-disjoint` constraint.

## 14. License Status
**LICENSE_REVIEW_REQUIRED**
The availability of datasets does not establish redistribution, sublicensing, or commercialization rights.

## 15. Research Blockers
- **UGSpeechData/Ewe assets** are missing locally.
- **Acoustic/RMS QC** has not been holistically performed; current metrics rely solely on structural file validity and duration boundaries.
- **Session Leakage** remains `NOT_DETERMINED` due to lacking granular timestamping/session-IDs in raw metadata.

## 16. Recommended Next Research Phase
1. Establish licensing/legal clearance (`LICENSE_REVIEW_REQUIRED`).
2. Officially trigger acquisition for `UGSpeechData` audio.
3. Once populated, execute Phase 7E: General baseline training or multilingual encoder development for general Ghanaian speech (Track A), followed by Atypical fine-tuning (Track B).

## 17. Reproducibility / Provenance
All splits, reports, and manifests generated hold explicit tracking fields (e.g., `split_seed=42`, `split_algorithm_version=1.0`) natively inside `split_manifest.json` and the JSONL files.

## 18. Final Status
| Area | Status | Evidence |
|---|---|---|
| Production baseline | PASS | Hash verification |
| UGSpeechData acquisition | NOT_AVAILABLE | Filesystem audit |
| Akan availability | NOT_AVAILABLE | Filesystem audit |
| Ewe availability | NOT_AVAILABLE | Filesystem audit |
| Dagbani availability | NOT_AVAILABLE | Filesystem audit |
| Dagaare availability | NOT_AVAILABLE | Filesystem audit |
| Ikposo availability | NOT_AVAILABLE | Filesystem audit |
| Ewe split integrity | NOT_DETERMINED | Assets missing |
| UGAkan speaker-disjoint readiness | RESEARCH_READY | Strict cross-speaker exclusion + Split validation passed |
| Duplicate handling | RESEARCH_READY | 339 Contaminated groups excluded |
| Session separation | NOT_DETERMINED | Raw metadata lacking session indicators |
| License | LICENSE_REVIEW_REQUIRED | No clearance recorded |
| Multilingual architecture | RESEARCH_REQUIRED | Architectural options documented |
