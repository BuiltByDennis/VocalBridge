# Phase 20, Track 1: Phase 14 State Machine Audit

## Findings
- `HomeCommunicationNotifier` states: `notLoaded, loading, ready, listening, processing, error`.
- Missing states: `CONFIRMATION_REQUIRED`, `SPEAKING`.
- Double speak protection, replay, and stale interaction logic: Missing.
- **Status**: MISSING/REGRESSED to Phase 4 state.
