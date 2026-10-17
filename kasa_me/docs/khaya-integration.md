# Khaya AI Integration (second Ghanaian provider)

Added Oct 2026, from the production-sprint research recommendation:
the UG HCI Lab stays the hackathon path and the default cloud
provider; **Khaya AI (Ghana NLP)** is an optional second provider the
user can select in Settings → Speech Provider. It exists for two
reasons: real-world use is not capped by the Lab's per-key quotas
(ASR 10/day, TTS 15/day), and Khaya takes an **explicit language
parameter**, which is the credible route to Ewe.

## The contract (Khaya's published integration docs, verified Oct 2026)

| | ASR v3 | TTS v2 |
|---|---|---|
| Endpoint | `POST https://translation-api.ghananlp.org/asr/v3/transcribe?language=<code>` | `POST https://translation-api.ghananlp.org/tts/v2/synthesize` |
| Auth | `Ocp-Apim-Subscription-Key: <key>` (both services, one key) | same |
| Request | Raw audio bytes as the body, `Content-Type: audio/wav` (MP3/FLAC/OGG also accepted) | JSON `{"text", "language", "speaker_id"?, "format"?}` |
| Success | `{"text": "...", "timings": {...}}` | The body IS the audio |
| Voices | — | `male_low` / `male_high` / `female`, same three for every language |
| Errors | `{"error": {"code", "message", "details": [...]}}` — 400 `VALIDATION_FAILED`, 500 `SYSTEM_ERROR` | same |

Language codes are **ISO 639-3** (`twi`, `ewe`, `dag`) — two-letter
codes are rejected with a 400 naming the correct code.
`KhayaSettings.khayaLanguageCode` owns the mapping.

Pricing and plan limits are **not** in the API docs — they are set by
the user's subscription at translation.ghananlp.org. The app assumes
no quota in either direction; the subscription's terms are the user's
to check before relying on Khaya for a demo.

## How it's wired

- `SpeechProvider.khaya` (stored by name in the existing settings —
  older settings blobs are unaffected). Settings → Speech Provider
  shows three cards: Offline / UG HCI Lab API / Khaya AI.
- `lib/speech/khaya/khaya_config.dart` — `KhayaSettings` (key, speaker,
  timeout) in secure storage under `khaya_settings_v1`, mirroring
  `UgHciLabSettings`. The key never leaves secure storage.
- `KhayaSpeechEngine` / `KhayaTtsEngine` sit behind the existing
  factories (`SpeechEngineFactory` / `TtsEngineFactory`); the home
  screen's config signature includes the Khaya key + speaker, so
  saving them rebuilds the engines in place — no restart.
- The hardened plumbing is shared: byte-sniffed audio extraction,
  timeout floors (ASR 120 s, TTS 90 s), next-chunk prefetch during
  playback, 3× retry on server errors only, and diagnostics —
  Khaya exchanges are recorded in the same store and shown, tagged
  "Khaya AI", under Settings → Speech Provider → **Last API
  responses**.
- Settings' Khaya **Test connection** calls `GET /asr/v3/languages`
  with the key: it validates the key and lists the languages
  **without spending a single speech request** (the Lab's test, by
  contrast, must synthesize one word).
- The phrasebook rebuilds its TTS engine per phrase language
  (Twi phrases carry a `Twi · …` category) — Khaya needs the right
  language per request; the Lab never did.

## Ewe status — engine-ready, NOT yet enabled

Khaya accepts `language=ewe` today, and both engines map it. That is
not a shippable Ewe feature: the language registry still lists Ewe
as disabled/experimental. Enablement waits on (1) a native-reviewed
`EwePhraseData` set mirroring `TwiPhraseData`, and (2) the phrase-
accuracy probe from the Oct 16 research brief (≥70% on a 15-phrase
Ewe care set with typical speakers before it flips on). Dagbani
stays disabled on the same evidence — weakest measured accuracy,
no impaired-speech data.

## Tests

`test/speech/khaya_integration_test.dart` (24 tests): contract
mapping and URIs, error-envelope parsing (including the Azure APIM
auth shape), transcript parsing, request-body shape, chunking,
audio extraction, and factory routing with its fallbacks.

## Latency notes (Oct 17 field report)

- Dennis's first Khaya **Test connection** timed out at the original
  20 s cap on a `GET /languages` call — the gateway can be slow on
  a first (cold) call, especially on mobile data. The test now saves
  the key first, waits up to 45 s, and says plainly when a timeout
  (rather than a rejection) is what happened. The Lab's test got the
  same treatment (60 s; it spends a real synthesis).
- A test trap found the same day: Test connection used to test the
  *typed* key while the app ran on the *saved* one — a key could
  "pass" here and never exist for the app. Both providers' tests now
  persist before probing.
- TTS through Khaya gets the same latency kit as the Lab path:
  `TtsAudioCache` (repeat phrases replay instantly), next-chunk
  prefetch, visible failures, and per-call elapsed times under
  Last API responses — which is also how to compare Khaya vs Lab
  speed honestly, on the same phrases, before choosing a demo path.
