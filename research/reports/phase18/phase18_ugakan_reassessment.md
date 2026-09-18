# Phase 18: UGAkan Reassessment

## 1. What UGAkan Is
UGAkan is a crowdsourced dataset of spoken Akan (Twi) collected by researchers at the University of Ghana and academic partners. It is one of the largest structured acoustic resources for the language.

## 2. What UGAkan Is Not
UGAkan is **not** an atypical speech dataset. The dataset consists of typical speakers reading text. 

## 3. Critical Limitation for Kasa Me
We must explicitly document: **UGAkan = valuable Akan research resource, but not automatically a general-purpose atypical speech foundation dataset.**
Training a model on UGAkan would yield a competent general Twi recognizer, but it would fail on dysarthric Twi speech just as badly as the current Sherpa model fails on dysarthric English speech, because the acoustic variations (slurring, pacing, breath control) are entirely absent from the training distribution.

## 4. Phase 18 Ruling
UGAkan is classified as **RESEARCH ONLY**. It provides a baseline for Track B (Ghanaian Language Speech) but offers zero direct evidence or utility for Track A (Atypical Speech) or Track C (Intersection).
