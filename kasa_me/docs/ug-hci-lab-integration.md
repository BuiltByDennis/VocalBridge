# UG HCI Lab API Integration Guide

This doc covers everything needed to switch Kasa Me from the offline engines
to the University of Ghana HCI Lab ASR/TTS APIs — which the hackathon
**requires** for any team using speech recognition or synthesis.

## 1. What is already built (no API key needed)

The app ships with the full integration scaffold behind the existing engine
interfaces, so no architecture changes are needed once credentials arrive:

| Piece | File |
|---|---|
| Settings model + secure storage (base URL, API key, endpoint paths) | `lib/speech/ug_hci_lab/ug_hci_lab_config.dart` |
| Error parsing for the Lab's documented error envelope | `lib/speech/ug_hci_lab/lab_api_error.dart` |
| ASR engine (buffers mic audio → WAV → `POST /api/v1/asr`, field `file`) | `lib/speech/engine/ug_hci_lab_speech_engine.dart` |
| TTS engine (text → `POST /api/v1/tts` → plays returned WAV) | `lib/speech/tts/ug_hci_lab_tts_engine.dart` |
| Provider routing for ASR + TTS | `lib/speech/engine/speech_engine_factory.dart`, `lib/speech/tts/tts_engine_factory.dart` |
| Settings UI: provider switch, API key entry, test connection | `lib/ui/settings/speech_provider_screen.dart` (route `/settings/speech-provider`) |
| Twi gating with an actionable error when no key is set | `lib/ui/home/home_communication_notifier.dart` |
| Provider shown in the engine banner ("Ready · UG HCI Lab API") | `lib/ui/components/engine_status_banner.dart` |

## 2. The Lab contract (confirmed from the HCI Lab API docs, Oct 2026)

| | ASR | TTS |
|---|---|---|
| Endpoint | `POST https://lab-subscription-platform.vercel.app/api/v1/asr` | `POST https://lab-subscription-platform.vercel.app/api/v1/tts` |
| Auth | `Authorization: Bearer <token>` | same |
| Request | multipart/form-data, field **`file`** = audio file (wav/mp3/…; filename or `audio/*` content type drives format detection). **No language parameter** — the API infers it from the audio | JSON `{"text": "…", "model_type": "ss", "speaker": "PT"}` — model/speaker are always `ss`/`PT` |
| Response | transcript JSON (parser accepts `transcript`/`text`/`transcription`, or a plain-text body) | the body **is** the WAV audio (`audio/wav`); metadata in headers |
| Errors | JSON `{"request_id", "error": {"code", "message"}}` — the app branches on this, incl. quota codes | same |
| Per-request limits | 120 s audio, 10 MB | **250 characters** (the app auto-splits longer text into sentence chunks, one request each) |

### Quotas (per API key — plan testing and the demo around these!)

| | Per day | Per week |
|---|---|---|
| ASR | **10 requests** | 50 requests / 30 min of audio |
| TTS | **15 requests** | 70 requests / 5,000 characters |

Every mic utterance in a Ghanaian language = 1 ASR request. Every Twi
read-aloud (incl. each auto-speak and each chunk of a long message) = 1 TTS
request. English ASR/TTS is offline and free. **Budget for demo day:** one
full run of the §3 script costs ≈ 3 ASR + 2 TTS — rehearse at most twice,
and don't burn the day's quota on casual testing before the screening.
The Settings **Test connection** button makes one real TTS request
("Akwaaba") — that's the only way to truly verify the key, but it counts.

### Setup (2 minutes — defaults are already the real values)

1. **Settings → Speech Provider** → select **UG HCI Lab API**.
2. Base URL is pre-filled (`https://lab-subscription-platform.vercel.app`) —
   just paste the **API key**. Tap **Save**, then **Test connection**.
3. Go to Language → **Twi**. The banner should read `Ready · UG HCI Lab API`.
4. Hold to speak in Twi → transcript appears → translation card → read-aloud.

If the Lab ever moves the gateway, base URL and endpoint paths can be
changed under **Settings → Speech Provider → Advanced** — no rebuild.

## 3. Demo script (screening)

Narrate one end-to-end communication task — a non-verbal Twi-speaking patient
in a hospital ward communicating a need to an English-speaking nurse:

1. Open the app, point at the banner: "Ready · UG HCI Lab API".
2. Press the mic button, speak a Twi care phrase (e.g. "Me pɛ nsuo").
3. The transcript appears, and right below it the **translation card**: Twi on
   the left, English ("I would like some water") on the right — the completed
   task, visible and undeniable.
4. Tap the speaker on the English side: the nurse hears it read aloud in
   English (offline TTS — no quota cost). **Task complete.**
5. Flip it: switch the app language to English, speak "The doctor is coming"
   → the card shows the Twi gloss ("Dokota no reba") → tap its speaker to
   read it aloud in Twi to the patient (1 Lab TTS request).
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
- **Scalability:** the Lab API takes no language parameter — it infers the
  language from the audio — so new Ghanaian languages arrive when the Lab
  gateway supports them, with no app changes or model bundling. (Ewe and
  Dagbani support on the gateway is the Lab's roadmap, not ours — today
  the demonstrated path is Twi.)
- **Sustainability:** zero server costs (Lab hosts models; personalization is
  on-device), offline fallback keeps the app useful without connectivity,
  modular language packs keep maintenance to config, not releases.

## 5. Troubleshooting: "Success" on the Lab dashboard, empty/silent in the app

Field report, Oct 16 2026: the dashboard showed ASR and TTS requests as
**Success (HTTP 200)** while the app displayed an empty transcript and
played no (or late, partial) audio. The Lab had done its part — the
failures were all in how the app read the responses. Fixed the same day:

- **ASR success-body shape.** The published docs never showed it, and the
  original parser only read top-level `transcript`/`text`/`transcription`
  keys. The parser now deep-searches the decoded JSON (envelope wrappers
  like `data`/`result` are unwrapped; transcript-shaped keys win at every
  level) and treats a non-JSON body as the transcript. If a 200 response
  still yields nothing, the app now says so instead of showing a silent
  blank — and the raw body is saved (see below).
- **Client timeouts.** The stored default was 30 s, but Lab ASR/TTS
  inference can run longer; the client was abandoning requests the Lab
  went on to complete successfully. The engines now enforce floors —
  ASR waits at least 120 s, TTS at least 90 s (stored setting respected
  above the floor, capped at 300 s).
- **TTS audio detection.** Playback no longer trusts the Content-Type
  header: the response bytes are sniffed (WAV/MP3/OGG/M4A magic), a JSON
  envelope carrying base64 audio or an audio URL is also accepted, and
  the temp file gets the detected format's extension. The Test
  connection probe accepts WAV bytes as well as an audio header.
- **TTS pacing.** Chunks (≤250 chars each) are now synthesized one ahead
  while the current chunk plays, so per-request latency no longer lands
  between chunks.
- **Diagnostics.** Every Lab exchange is recorded in
  `LabDiagnosticsStore` (secure storage): ASR keeps status, elapsed time
  and the raw body (first 1,200 chars); TTS keeps status, elapsed,
  content-type, byte count and detected format. **Settings → Speech
  Provider → "Last Lab responses"** shows them — that card is the first
  thing support needs when a request "succeeds" but the app stays blank
  or silent. Behaviour is pinned by
  `test/speech/ug_hci_lab_response_test.dart` (21 tests).

**Second provider:** Khaya AI (Ghana NLP) is available as an optional provider — see `docs/khaya-integration.md`. The Lab remains the hackathon path above.

## 6. Latency — what is and isn't fixable from the app

Field report, Oct 17 2026: round trips took very long on BOTH cloud
providers, and the Lab dashboard showed requests sitting **In
Progress for minutes** (ASR 10:37, TTS 10:43) — the Lab's own
processing queue, on a day when its service was slow. No client
change can make a provider's models faster; what the app controls
is everything around that wait:

- **Payloads are already minimal** — ASR uploads are 16 kHz mono
  WAV, the smallest faithful representation of the utterance.
- **English never waits** — it is on-device (Whisper + system TTS)
  and effectively instant. Only Ghanaian-language calls pay network
  + provider time.
- **Repeated phrases are now instant** — synthesized speech is
  cached in memory per provider/language/voice/text
  (`TtsAudioCache`, 40 entries, LRU). Care communication repeats
  the same phrases all day; the second "me pɛ aduane" does not call
  the provider at all (and spends no quota).
- **The wait is visible and escapable** — the home screen shows a
  live "Waiting for the speech service… Ns" counter during
  processing, with a **Cancel** that hands the UI back immediately
  (the late result is swallowed; the provider may still finish —
  and bill — the request in the background).
- **TTS failures are no longer silent** — the cloud engines record
  them (Last API responses) and surface them on the home screen
  instead of swallowing them into a debug log.
- **Choosing between providers is an empirical question** — the
  Last API responses card records elapsed ms per call; compare Lab
  vs Khaya on the same phrases and pick the faster one for the demo.

Practical guidance: keep utterances short, demo on the best network
available, and rehearse the exact demo phrases once — the TTS cache
then makes every repetition after the first effectively instant.
