# Phase 18: Privacy

## 1. The Acoustic Data Problem
Acoustic adaptation requires raw audio. 
Currently, Kasa Me processes audio in real-time and instantly destroys the buffer (Phase 1).
If Phase 19 pursues acoustic adaptation, it will require collecting, storing, and processing raw audio from the user.

## 2. Privacy Violations
Uploading dysarthric speech to a cloud server for training violates Kasa Me's core offline privacy mandate. Atypical speech is highly identifiable medical biometric data.

## 3. Mitigation Strategies
If Kasa Me implements data collection for a future benchmark or adaptation:
- It must be explicitly opt-in.
- It must be clearly labeled as **Research Data**.
- It must remain in scoped storage, inaccessible to other apps.
- It must have an auto-delete retention policy.
