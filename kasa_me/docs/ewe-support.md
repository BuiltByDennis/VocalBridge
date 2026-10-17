# Ewe support — full feature parity with Twi (v1.3.0)

Ewe (Eʋegbe) is a first-class language in Kasa Me, opened 2026-10-17
with the complete feature set Twi has — not a subset. This document
records what "full" means here, where the data lives, and the honest
limits.

## What Ewe has

| Feature | How |
|---|---|
| Phrase data | `lib/speech/translation/ewe_phrase_data.dart` — ~67 curated phrases, the same English care set and categories as `TwiPhraseData`. Single source for glossary, phrasebook seed, and calibration, exactly like Twi. |
| Dictionary translation | `DictionaryTranslationService` supports `ewe↔en_GH` with the same six layers as Twi (exact, space-insensitive, contained, filler-stripped, strict fuzzy, word gloss + partial gloss). Unknown input returns no gloss — never an invention. Strict thresholds carry over: "asi le ve nam" (my hand hurts) can never fuzzy-match the headache phrase. |
| ASR | Both providers. Khaya: `language=ewe` (ISO 639-3, explicit). UG HCI Lab: the gateway infers language from audio (no language parameter exists), so Ewe flows through the same engine as Twi. |
| TTS | Both providers, via engines built for Ewe. Repeat phrases replay from the TTS cache. |
| Phrasebook | Seeded at DB v4 (`Ewe · …` categories) on fresh installs and as a one-time upgrade for existing installs. No schema change, so no generated-code churn. Phrasebook speak uses an Ewe-built engine. |
| Quick phrases | The home strip follows the active language: Ewe profile → Ewe phrases only. |
| Voice calibration | Record-only, like Twi: 14 Ewe phrases chosen for Ewe's distinctive sounds (ɛ, ɔ, ŋ, ƒ, ɖ, gb, ɣ, nasal vowels). Samples are stored on-device; no cloud ASR quota is spent. The wizard has an Ewe chip next to English and Twi. |
| Bidirectional care flow | Ewe profile → speech is glossed to English and read aloud in English. English profile → a **Twi / Ewe toggle** on the translation card chooses the patient's language; the gloss re-computes in place and is spoken by an engine built for that language (Khaya takes the language per request, so this routing matters). |
| Provider gates | Selecting Ewe without a configured cloud provider gives the same clear, actionable error Twi gives — no on-device Ewe model exists, and the app says so instead of crashing on a placeholder. |

Parity is enforced by tests (`test/speech/ewe_support_test.dart`):
the Ewe phrase set must cover the same English phrases and categories
as Twi's, calibration sizes must match, and both factories must build
both providers for Ewe.

## Honest limits

- **Native review pending.** The Ewe phrase set was authored carefully
  for this build in standard orthography. It should be confirmed by a
  native Ewe speaker before clinical use — the same standard applied
  to every language the app ships. This is stated in the data file
  itself and in `who-kasa-me-helps.md`.
- **Lab-side Ewe is unverified.** The Lab's ASR contract has no
  language parameter; Twi is proven on it (Oct 16), Ewe is inferred.
  The first real Ewe calls will show up in Settings → Speech Provider
  → Last API responses like every other call. Khaya's Ewe is explicit
  in its API (`/asr/v3/languages` lists `ewe`).
- **Phrase-constrained by design.** As with Twi, free-form Ewe speech
  is recognized by the cloud ASR, but the offline dictionary only
  covers the curated care set plus its word gloss — beyond that it
  honestly reports no gloss. (Research brief, Oct 16: no provider
  offers dictation-grade Ghanaian ASR today; phrase-constrained is
  the correct architecture.)
- **Dagbani remains off** — no phrase data, weakest published ASR
  results, zero impaired-speech data. It stays `comingSoon` until it
  can be opened to this same standard.
