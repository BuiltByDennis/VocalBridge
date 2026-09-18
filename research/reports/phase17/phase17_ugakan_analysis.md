# Phase 17 UGAkan Analysis

## 1. Dataset Overview
- **Name**: UGAkan (University of Ghana Akan Dataset)
- **Language**: Akan (primarily Asante Twi and Akuapem Twi).
- **Contents**: Crowdsourced and locally recorded speech data aimed at establishing a baseline for Akan ASR.

## 2. Technical Characteristics
- **Total Audio**: Unknown exactly from public metadata, but frequently cited in local NLP papers as encompassing several hours of read and conversational speech.
- **Conditions**: Variable. Includes smartphone recordings in everyday environments.
- **Atypical Speech**: **NONE**. UGAkan is composed of neurotypical/healthy speakers. It is *not* an atypical speech dataset.

## 3. Licensing & Provenance
- **LICENSE_STATUS**: UNKNOWN / REQUIRES_REVIEW.
- While commonly used in academic papers by Ghanaian researchers, explicit commercial licensing files (e.g., MIT, CC-BY) are often missing or vaguely defined in institutional repositories. 
- **COMMERCIAL_USE_RESTRICTED**: Assumed until verified.
- **REDISTRIBUTION_RESTRICTED**: Assumed until verified.

## 4. Suitability for Kasa Me
- **General Ghanaian ASR**: Yes, it is highly suitable for research and benchmarking generic Akan ASR models.
- **Atypical-Speech Adaptation**: No. The dataset contains no dysarthric or impaired speech. 
- **Production Use**: Unsafe to bundle models trained heavily on this without explicit written commercial release from the dataset owners.

## 5. Summary
UGAkan is a vital research asset but must be strictly classified as a `RESEARCH_ONLY` artifact until licensing is clarified. It does not solve the atypical speech gap.
