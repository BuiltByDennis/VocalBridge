# UGSpeechData Research Dataset Workspace (Phase 7 Scaffold)

## 1. Overview & Dataset Source
* **Source Repository:** [HCI-LAB-UGSPEECHDATA/speech_data_ghana_ug](https://github.com/HCI-LAB-UGSPEECHDATA/speech_data_ghana_ug)
* **Dataset Identifier:** `ugspeechdata_v1`
* **Status:** Phase 7A Infrastructure Scaffold (Data acquisition and auditing reserved for Phase 7B)

## 2. Technical Scope & Hard Research Boundaries
1. **Generic Ghanaian Language Resource — NOT Atypical Speech Data:**
   UGSpeechData consists of speech recorded from general Ghanaian speakers across several indigenous languages (such as Twi, Ewe, Dagbani, Ga) and Ghanaian English. It is **NOT** an atypical, impaired, or disordered speech dataset.
2. **Separation from Private User Data:**
   Kasa Me user recordings for speech personalization remain strictly private, on-device, and separate from public or external research speech datasets.
3. **100% Offline Production Requirement:**
   The Kasa Me Flutter mobile client operates entirely offline without external cloud dependencies. UGSpeechData is used solely within the offline research environment (`research/`) for evaluating multilingual capabilities and language modeling.
4. **Frozen Production Model Protection:**
   UGSpeechData assets will never be automatically injected into the frozen production model (`english_edge_v1`).

## 3. Directory Layout
```text
research/datasets/ugspeechdata/
├── raw/         # Unmodified downloaded source archives/audio (Phase 7B)
├── metadata/    # Source transcripts and metadata CSVs (Phase 7B)
├── manifests/   # Standardized Kasa Me CSV manifests (Phase 7B)
├── processed/   # Normalized 16 kHz mono PCM16 WAV files (Phase 7B)
├── splits/      # Speaker-aware and language-stratified splits (Phase 7B)
├── reports/     # Dataset validation and coverage reports (Phase 7B)
├── scripts/     # Dataset acquisition, parsing, and pipeline scripts (Phase 7B)
└── README.md    # Workspace specification
```

## 4. Reproducibility & Phase 7B Notice
All preprocessing and split generation scripts developed in Phase 7B must be deterministic, version-controlled, and produce cryptographic hashes for manifest validation.
