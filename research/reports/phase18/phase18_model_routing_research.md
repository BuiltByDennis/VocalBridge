# Phase 18: Model Routing Research

## 1. Concept
Model routing involves a dynamic pipeline:
`Audio -> Language/Model Router -> Appropriate ASR -> Personalization`

## 2. Experimental Mock
A Dart scaffold (`MockAdaptedSpeechEngine`) was created in `research/phase18/` to demonstrate how this could look. A `ResearchModelDescriptor` specifies whether the engine is "atypical adapted", "English baseline", or "Ghanaian language".

## 3. Feasibility
- **Manual Routing:** A UI toggle where the user selects their language or model is trivial to implement and highly robust.
- **Automatic Routing:** Requires an offline Language Identification (LID) model running continuously. This adds 300-500ms of latency to the speech pipeline and consumes additional RAM. Furthermore, LID models perform poorly on dysarthric speech, often misclassifying atypical English as a foreign language.

## 4. Verdict
Automatic Model Routing is **BLOCKED BY ANDROID CONSTRAINTS** and **PROMISING BUT INSUFFICIENT EVIDENCE** (due to poor LID performance on atypical speech). Manual routing remains the baseline.
