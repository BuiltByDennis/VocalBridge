# UG HCI Lab API Integration Guide

This doc covers everything needed to switch Kasa Me from the offline engines
to the University of Ghana HCI Lab ASR/TTS APIs — which the hackathon
**requires** for any team using speech recognition or synthesis.

## 1. What is already built (no API key needed)

The app ships with the full integration scaffold behind the existing engine
interfaces, so no architecture changes are needed once credentials arrive:

| Piece | File |
|---|---|
| Settings model + secure storage (base URL, API key, endpoint paths, language codes) | `lib/speech/ug_hci_lab/ug_hci_lab_config.dart` |
| ASR engine (buffers mic audio → WAV → `POST {base}/asr`) | `lib/speech/engine/ug_hci_lab_speech_engine.dart` |
| TTS engine (text → `POST {base}/tts` → plays returned audio) | `lib/speech/tts/ug_hci_lab_tts_engine.dart` |
| Provider routing for ASR + TTS | `lib/speech/engine/speech_engine_factory.dart`, `lib/speech/tts/tts_engine_factory.dart` |
| Settings UI: provider switch, API key entry, test connection | `lib/ui/settings/speech_provider_screen.dart` (route `/settings/speech-provider`) |
| Twi gating with an actionable error when no key is set | `lib/ui/home/home_communication_notifier.dart` |
| Provider shown in the engine banner ("Ready · UG HCI Lab API") | `lib/ui/components/engine_status_banner.dart` |

## 2. When API access is granted — 15-minute checklist

1. Open the Lab's API docs and confirm the **exact** values for:
   - base URL
   - ASR endpoint path (default `/asr`) and request format
     (default: multipart `audio` = 16 kHz mono PCM16 WAV, fields `language`,
     `sample_rate`; response JSON `{"transcript": "…", "confidence": 0.9}`)
   - TTS endpoint path (default `/tts`) and request/response format
     (default: JSON `{"text","language"}` → raw audio bytes or
     `{"audio_base64": "…"}`)
   - auth scheme/header (default `Authorization: Bearer <key>`)
   - language codes for Twi/Ewe/Dagbani (defaults: `tw`, `ee`, `dag` — **verify**)
2. If anything differs, update it in **Settings → Speech Provider → Advanced**
   — no code changes needed. Only if the contract is fundamentally different
   (e.g. WebSocket streaming) do the two engine files need edits; the
   upload/parse assumptions are marked `VERIFY` in code comments.
3. Paste the base URL + API key, tap **Test connection**, then switch the
   provider to **UG HCI Lab API**.
4. Go to Language → **Twi**. The banner should read `Ready · UG HCI Lab API`.
5. Hold to speak in Twi → transcript appears → auto-speak reads it back in Twi.

## 3. Demo script (screening)

Narrate one end-to-end communication task — a non-verbal Twi-speaking patient
in a hospital ward communicating a need to an English-speaking nurse:

1. Open the app, point at the banner: "Ready · UG HCI Lab API".
2. Press the mic button, speak a Twi care phrase (e.g. "Me pɛ nsuo").
3. The transcript appears, and right below it the **translation card**: Twi on
   the left, English ("I would like some water") on the right — the completed
   task, visible and undeniable.
4. Tap the speaker on the English side: the nurse hears it read aloud in
   English. **Task complete.**
5. Flip it: switch the app language to English, speak "The doctor is coming"
   → the card shows the Twi gloss ("Dokota no reba") → tap its speaker to
   read it aloud in Twi to the patient.
6. Show one accessibility feature live (dwell control or high-contrast toggle).
7. Show the high-impact guard: say a money phrase → confirm dialog appears.

## 4. Deliberate product decisions (for judges' questions)

- **Why not 100% offline anymore?** The hackathon mandates the Lab APIs for
  ASR/TTS. Offline engines stay as a *fallback* (resilience story), and all
  personalization data stays on-device (privacy story).
- **Why is Twi gated on the API key?** There is no bundled Twi model in the
  app and none that fits the size budget; the honest path is the Lab's
  models. The app says so instead of failing silently.
- **What about the fine-tuned wav2vec2 model in `research/`?** It is the R&D
  track (personalized atypical-speech models), not the demo path. The demo
  uses the Lab API; the research continues in parallel for sustainability.
- **Scalability:** adding Ewe = one `languageCodes` entry + Lab language
  support. No new model bundling, no app-size growth.
- **Sustainability:** zero server costs (Lab hosts models; personalization is
  on-device), offline fallback keeps the app useful without connectivity,
  modular language packs keep maintenance to config, not releases.
