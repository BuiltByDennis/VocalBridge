# Phase 16 Manual Acceptance Tests

| Test | Status | Notes |
| --- | --- | --- |
| TEST 1: Ghanaian institution ("I study at UMaT") | PASS | UMaT correctly preserved due to InstitutionMatcher. |
| TEST 2: Boundary protection ("UMaTting") | PASS | Remains unchanged. `\b` boundary works correctly. |
| TEST 3: Ghanaian place ("Accra") | PASS | Accra properly capitalized if lowercased by ASR. |
| TEST 4: Ghanaian currency ("five hundred cedis") | PASS | Correctly normalized to GH₵500. TTS reads normally. |
| TEST 5: Phone number ("0241234567") | PASS | Preserved correctly without stripping leading zeros. |
| TEST 6: Financial safety | PASS | "Send five hundred cedis" triggers HIGH safety and stops TTS. |
| TEST 7: Personal vocabulary precedence | PASS | Explicit `umat` definition accurately overwrites generic rules. |
| TEST 8: Passive personalization | PASS | Trusted corrections continue functioning. |
| TEST 9: False positive protection | PASS | Non-matching substrings safely ignored. |
| TEST 10: Offline functionality | PASS | Validated in airplane mode. |
| TEST 11: Accessibility | PASS | Phase 15 accessible buttons and live regions unaffected. |
