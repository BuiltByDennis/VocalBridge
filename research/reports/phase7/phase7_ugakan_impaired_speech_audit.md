# Phase 7B: UGAkan-ImpairedSpeechData Audit

## 1. Overview
- **Dataset**: UGAkan-ImpairedSpeechData
- **Population**: impaired_speech
- **Status**: VERIFIED
- **Total Audio Files**: 14312
- **Total Duration (hours)**: 50.36
- **Missing Audios**: 0
- **Corrupt Audios**: 0
- **Exact Duplicates**: 432

## 2. Published vs Local Verified Statistics

| Metric | Published | Local Verified | Difference | Status |
|---|---|---|---|---|
| Audio Files | 14,312 | 14312 | 0 | PASS |
| Duration (hours) | 50.01 | 50.36 | 0.35 | WARNING |
| Mean Duration (sec) | 12.46 | 12.67 | 0.21 | WARNING |
| Std Duration (sec) | 7.71 | 7.75 | 0.04 | PASS |
| Max Duration (sec) | 60.08 | 60.08 | 0.00 | PASS |

## 3. Demographics & Environment
**Aetiologies:**
```json
{
  "Cerebral palsy": 2627,
  "Cerebral Palsy": 5089,
  "Cleft": 1826,
  "Stammering": 4475,
  "Stroke": 295
}
```

**Genders:**
```json
{
  "Female": 7558,
  "Male": 6754
}
```

**Environments:**
```json
{
  "Other": 3075,
  "Indoor": 2254,
  "Outdoor": 7706,
  "Studio": 982,
  "In a car": 295
}
```

**Speakers:** 56

## 4. Integrity
- source_files_unchanged: PASS
- audio_files_readable: PASS
- metadata_readable: PASS
- transcripts_available: PASS
- duplicate_check_completed: PASS
- speaker_metadata_available: PASS
- license_metadata_available: PASS
- manifest_generated: PASS

## 5. License Status
The source dataset has unclear permissions for model redistribution and commercial use.
**license_status**: LICENSE_REVIEW_REQUIRED
