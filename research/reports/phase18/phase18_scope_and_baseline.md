# Phase 18: Scope and Baseline

## 1. Phase Objective
The objective of Phase 18 is to investigate and experimentally prototype technically valid approaches for improving Kasa Me's recognition of **atypical/impaired speech**, specifically transitioning from Phase 17's feasibility study into empirical evaluation.

## 2. Hard Protected Baseline
Before any research commenced, the following baseline was verified:
- **Test Baseline:** 124/124 tests passing.
- **Compiler Baseline:** 0 `flutter analyze` errors.
- **Production Architecture:** The English Sherpa ASR model, Phase 16 Ghanaian English Enhancement, and Phase 12 High Impact Safety modules remain 100% active and untouched.
- **Constraints:** All production architecture is strictly offline, privacy-first, and Android-compatible.

## 3. Explicit Research Separation
Any prototyping or adaptation modeling takes place strictly within `research/phase18/` and does not compile into the `kasa_me` production binary. Experimental Dart scaffolds (e.g., `MockAdaptedSpeechEngine`) are isolated and not invoked by `SpeechEngine`.
