# Phase 17 Model Strategy Comparison

## Strategies

### A. Separate Language-Specific Models
- **Concept:** One 30MB ONNX model for English, another 30MB model for Twi, another for Ewe.
- **Pros:** Lowest RAM usage at runtime (only load what is active). High accuracy for the specific language. No code-switching confusion.
- **Cons:** Users must manually toggle languages. If a user speaks English while in Twi mode, it produces garbage.

### B. One Multilingual Ghanaian Model
- **Concept:** Train a single model covering Twi, Ga, Ewe, etc.
- **Pros:** Only one model to load.
- **Cons:** Huge data requirement. High risk of phonetic collisions. Likely much larger model size (100MB+).

### C. Existing Multilingual Foundation Model (e.g. MMS)
- **Concept:** Load Meta MMS.
- **Pros:** Instant coverage.
- **Cons:** CC-BY-NC license blocks commercial use. Too slow for real-time edge.

### D. Hybrid Language-Specific Selection (Recommended)
- **Concept:** Maintain Sherpa English as the core. Provide a UI toggle (e.g., "Language: English | Twi"). Only load the Twi ONNX model when requested.
- **Pros:** Preserves the 100% offline, highly performant Phase 8-16 architecture. 
- **Cons:** Demands high-quality monolingual datasets to train the Twi model.

### E. Atypical-Speech Adaptation First
- **Concept:** Ignore Ghanaian languages entirely for now. Fine-tune the English model on Ghanaian *atypical* English speech.
- **Pros:** Maximizes the immediate assistive utility of Kasa Me. Solves the primary accessibility goal.
- **Cons:** Excludes non-English speaking Ghanaians.

## Trade-offs Summary
| Strategy | Offline Feasibility | Licensing Risk | Development Cost | Code-Switching |
| --- | --- | --- | --- | --- |
| Separate | High | Low | High | Poor |
| Multilingual | Low | Low | Very High | Better |
| Foundation (MMS) | Low | High (Blocked)| Low | Good |

**Conclusion:** Strategy D (Hybrid Language-Specific) paired with Strategy E (Atypical English Adaptation) presents the only technically viable path forward.
