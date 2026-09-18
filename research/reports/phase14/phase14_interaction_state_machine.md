# Phase 14 Interaction State Machine

## Overview
The Phase 14 state machine uses `CommunicationState` to strictly control the application's lifecycle, ensuring audio, safety, and TTS never race or leak state.

## States
1. `loading`: Initializing ASR, pipelines, TTS.
2. `idle`: Waiting for user action.
3. `listening`: Microphone active, streaming audio to VAD and ASR.
4. `processing`: VAD finished or user requested Stop. ASR processing final transcript.
5. `ready`: Transcript completed, displayed, and ready for Edit, Speak, Replay, or Cancel.
6. `confirmationRequired`: High-impact text requires explicit confirmation before TTS.
7. `speaking`: TTS is actively playing audio.
8. `error`: A fatal error occurred in the pipeline, requires retry.

## Valid Transitions
- `idle` -> `listening`, `error`
- `listening` -> `processing` (Stop), `idle` (Cancel), `error`
- `processing` -> `ready` (FinalTranscript), `idle` (Empty Transcript), `error`
- `ready` -> `speaking` (Safe Speak / Replay), `confirmationRequired` (High-Impact Speak), `idle` (Clear/Cancel)
- `confirmationRequired` -> `speaking` (Confirmed), `ready` (Cancelled)
- `speaking` -> `idle` (Finished/Stopped), `error`
