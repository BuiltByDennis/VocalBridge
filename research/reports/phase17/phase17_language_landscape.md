# Phase 17 Language Landscape

## 1. Overview
Ghana is a multilingual nation with over 80 languages. English is the official language, but indigenous languages dominate daily and informal communication.

## 2. Major Languages Evaluated

### Akan (Twi / Fante)
- **Status:** Widely spoken lingua franca across the southern half of Ghana.
- **Dialects:** Asante Twi, Akuapem Twi, Fante, Bono.
- **Population:** ~9-10 million native, ~20+ million L2 (Verified Fact).
- **Orthography:** Latin-based, relies on specific diacritics (`ɛ`, `ɔ`).
- **Research Maturity:** High (relative to others). Several datasets (ALFFA, UGAkan) exist.

### Ewe (Eʋegbe)
- **Status:** Predominantly spoken in the Volta Region and neighboring Togo.
- **Population:** ~3-4 million in Ghana (Verified Fact).
- **Orthography:** Latin-based with tone markers and special characters (`ƒ`, `ɖ`, `ŋ`, `ʋ`, `ɛ`, `ɔ`). Tonal language.
- **Research Maturity:** Medium. Covered in some multilingual efforts (e.g., MMS).

### Ga
- **Status:** Indigenous language of the capital, Accra.
- **Population:** ~1 million (Verified Fact).
- **Orthography:** Latin-based (`ɛ`, `ɔ`, `ŋ`). Tonal.
- **Research Maturity:** Low-to-Medium. Small datasets exist.

### Dagbani
- **Status:** Major language of the Northern Region.
- **Population:** ~1.5 million (Verified Fact).
- **Orthography:** Latin-based (`ɣ`, `ʒ`, `ŋ`, `ɛ`, `ɔ`).
- **Research Maturity:** Medium (benefiting from recent Mozilla Common Voice pushes in the region).

### Dagaare
- **Status:** Spoken in the Upper West Region.
- **Population:** ~1 million (Verified Fact).
- **Research Maturity:** Low.

## 3. Writing System Considerations
Akan, Ewe, Ga, and Dagbani all require proper Unicode support for extended Latin characters. The Kasa Me UI and TTS engines must support these without rendering mojibake (`?` boxes).

## 4. Conclusions
**Akan (Twi)** presents the strongest initial candidate for feasibility testing due to its broad speaker base and relative availability of research datasets, followed by **Dagbani** (strong recent crowdsourcing efforts) and **Ewe**.
