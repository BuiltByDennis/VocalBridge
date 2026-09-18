# Phase 7C: Data Quality & Leakage Audit Report

## 1. Summary
- **Dataset**: UGAkan-ImpairedSpeechData
- **Status**: PARTIALLY_READY (Speaker leakage detected, requires rigorous future split logic).
- **Production Baseline Verification**: BEFORE = PASS | AFTER = PASS.
- **Modifications**: NO TRAINING PERFORMED. NO ADAPTATION PERFORMED. NO PRODUCTION MODEL MODIFIED. 
- **Raw Files**: Intact and unmodified.

## 2. Audio Findings
- **Total Files**: 14,312
- **Total Duration**: 50.36 hours
- **Mean Duration**: 12.67 seconds
- **Median Duration**: 11.48 seconds
- **Std Duration**: 7.75 seconds
- **Min Duration**: 1.48 seconds
- **Max Duration**: 60.08 seconds
- **Technical Anomalies**: 0 missing/corrupt.
- **Low-Energy / Clipping**: Evaluated structurally via duration & integrity; full ML-less RMS flagged for future acoustic pipeline implementation, but no files removed.

## 3. Transcript Findings
- **Total**: 14,312
- **Missing/Malformed**: 0 (All 14,312 evaluated as 'OK').
- **Unique**: 14,053
- **Repeated**: 259 files share a normalized transcript with another file.

## 4. Duplicate Findings
- **Exact Duplicate Groups (SHA-256)**: 432
- **Exact Duplicate Files**: 864 total files in duplicate groups.
- **Cross-Speaker Exact Duplicates**: 339 (CRITICAL LEAKAGE CANDIDATE)
- **Cross-Aetiology Duplicates**: 0
- **Cross-Environment Duplicates**: 0
- **Near-Duplicate Candidates**: 13 (Identified by matching transcript & duration).

## 5. Speaker Findings
- **Unique Speakers**: 56
- **Smallest Speaker**: 16 files
- **Largest Speaker**: 1,378 files
- **Imbalance**: High imbalance across speakers.

## 6. Demographics
- **Aetiology (Normalized)**: cerebral_palsy (7,716), stammering (4,475), cleft (1,826), stroke (295).
- **Environment**: Outdoor (7,706), Other (3,075), Indoor (2,254), Studio (982), In a car (295).
- **Gender**: Female (7,558), Male (6,754).

## 7. Leakage Findings
- **speaker leakage**: FOUND (339 exact hash duplicates cross speaker boundaries).
- **duplicate leakage**: FOUND (864 duplicate files present in raw dataset).
- **transcript leakage**: FOUND (259 repeated transcripts).
- **metadata leakage**: NOT_FOUND
- **session leakage**: NOT_DETERMINED (Raw CSV lacks reliable deterministic sequence/session markers).

## 8. Split Readiness
**NOT READY for naive splits**. 
The dataset is ready for a *speaker-disjoint* train/dev/test experiment ONLY IF the 339 cross-speaker exact duplicates are formally resolved or excluded. The hard constraint must be `TRAIN speakers ∩ DEV speakers = ∅` AND duplicate group IDs must not cross partitions.

## 9. License Status
**LICENSE_REVIEW_REQUIRED**
