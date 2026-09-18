# Phase 17 Safety Research

## 1. Compatibility with Phase 12 (High-Impact Safety)
Phase 12 enforces a hard confirmation gate on transcripts containing emergency, financial, and personal contact information before allowing TTS. 

### Current English Rules
- `_emergencyRegex`: matches "help", "emergency", "police", "hospital", "ambulance", "doctor", "fire".
- `_financialCurrencyRegex`: matches "gh₵", "\$", "cedis", "dollars".
- `_medicalRegex`: matches "dosage", "pill", "mg", "painkiller".

## 2. Impact of Ghanaian Languages
If Kasa Me loads an Akan ASR model, the raw transcript will be in Twi.
- **Problem 1:** The English `_emergencyRegex` will completely fail to catch a Twi emergency phrase (e.g., "Mepawokyew boa me" - Please help me).
- **Problem 2:** Financial amounts (e.g., "Sika", "cedis") might be transcribed phonetically or using local terms, bypassing the currency regex.

## 3. Required Mitigation
To maintain the safety guarantees of Kasa Me:
1. **Language-Aware Safety Dictionaries:** `HighImpactSafetyAnalyzer` must accept a `languageCode`. 
2. **Translated Thresholds:** We must compile equivalent exact-match lists for critical categories in every supported language (e.g., `AkanSafetyRules`, `GaSafetyRules`).
3. **Numeric Preservation:** Number formatting (e.g., phone numbers) remains universal, so numeric regexes will likely survive cross-lingual translation, provided the ASR model correctly outputs Arabic numerals rather than spelled-out words (e.g., "5" instead of "enum").

## 4. Conclusion
Ghanaian-language ASR breaks Phase 12 safety by default. Any introduction of a non-English ASR model *must* be accompanied by a translated safety rule package.
