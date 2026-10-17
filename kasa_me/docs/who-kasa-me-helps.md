# Who Kasa Me Helps — and How

Kasa Me exists for people whose speech the world — and ordinary speech
recognizers — does not understand. This document maps the app's real,
shipped mechanisms to its four primary audiences, and explains how each
person trains the app to understand *them*. It is deliberately honest
about the boundary of what adapts: the recognition models themselves
(UG HCI Lab ASR for Ghanaian languages, Sherpa-ONNX/Whisper offline for
English) are fixed; **everything around them learns** — and that
learning layer is where atypical speech is won or lost.

## The shared problem

Mainstream ASR is trained on typical speech and systematically fails
people with speech impairments: it cuts them off mid-pause, trusts its
own low confidence in the wrong places, and has no memory of how *this*
person says *this* word. Kasa Me's answer is a personal layer:

- **Calibration** — guided phrase practice (English checked by the
  recognizer; Twi and Ewe recorded as on-device voice samples) that seeds the
  learning system and feeds the Accuracy Score.
- **Correction memory with evidence tiers** — when the app mishears and
  the user fixes a word, the fix is remembered (tentative → probable →
  learned). Learned mappings apply automatically; the safety guard
  blocks loops and cascading rewrites so learning can never corrupt
  itself.
- **A speech profile per condition** (Settings → Personalization) that
  changes how recognition behaves — not just settings cosmetics.
- **An Accuracy Score that depends on training** — 50% recognizer
  confidence on everyday speech, 30% calibration performance, 20% how
  rarely the user still has to correct the app. Training visibly pays.
- **Communication without speaking at all** — phrasebook (English + curated
  Twi and Ewe phrasebooks), quick phrases, tap-to-speak, dwell control,
  and a Ghanaian ↔ English translation card so a message is understood even
  when speech is not possible in the moment.

All training data — calibration audio, corrections, profiles — is
stored **only on the phone** (local database + secure storage) and can
be deleted in Settings → Privacy & Data. Audio is sent to the UG HCI
Lab API only when the user speaks with the Lab provider selected,
exactly as with any cloud recognizer; English recognition never leaves
the device.

## 1. A person who stammers

**Their reality:** repetitions ("m-m-me"), prolongations and silent
blocks. Typical recognizers either transcribe the disfluency literally
— making the person look inarticulate in their own message — or time
out during a block and lose the utterance entirely.

**How Kasa Me helps:**
- The **Stammer speech profile** switches on disfluency tidying: the
  personalization pipeline collapses immediate repetitions and
  part-word repetitions ("I I I want wa-wa-water" → "I want water")
  *before* the message is shown, translated, or read aloud. The person
  is quoted as they mean to be heard.
- Listening patience is raised (voice-activity sensitivity lowered), so
  the app waits through blocks and pauses instead of deciding the
  person has finished.
- Learned corrections apply a little more readily (confidence gate
  0.85), because a stammerer's recognizer confidence is noisy.
- When speaking is hardest, the phrasebook and quick phrases let them
  communicate a full need with one tap — and the phrase is spoken
  aloud in a clear, fluent voice.

## 2. A person with cerebral palsy

**Their reality:** dysarthria — speech that may be slower, quieter,
slurred or effortful, and highly individual. A general recognizer's
confidence scores are meaningless for dysarthric speech; its errors are
not random but *systematic for that person* — which makes them
learnable.

**How Kasa Me helps:**
- The **Cerebral palsy speech profile** leans on the person's own
  patterns over the recognizer: their learned corrections override the
  raw transcript far more readily (confidence gate 0.95), and start
  working after just 2 examples instead of 3.
- Microphone gain is raised (×1.5 preset) for a weaker voice, and
  listening patience is at its highest (slow, effortful speech is
  never rushed).
- Calibration plus everyday corrections build a personal mapping of
  "the sound I make → the word I mean," which is precisely the
  systematic part of dysarthria. The Accuracy Score rises as those
  mappings accumulate — the user can watch the app learn them.
- Dwell control, large targets and simplified UI address the motor
  side of CP, not just the speech side.

## 3. A person recovering from stroke

**Their reality:** often two problems at once — dysarthria (weak or
uncoordinated speech muscles) and aphasia (word-finding difficulty).
They may know what they want to say and be unable to get the words
out, and fatigue makes long interactions costly.

**How Kasa Me helps:**
- The **Stroke recovery speech profile** combines fast learning
  (corrections active after 2 examples, high override gate) with
  patient listening while the person searches for a word, and raised
  mic gain for a weakened voice.
- The **phrasebook is a word-finding aid**: saved personal and care
  phrases (including the full Twi and Ewe sets) are visible, tappable, and
  spoken aloud — communication does not depend on retrieving the word
  under pressure.
- Phrase biasing favours the person's frequent phrases in recognition,
  shrinking the gap between attempted and understood speech.
- Auto-speak and the translation card let a caregiver hear the message
  in English even when the patient speaks Twi or Ewe, and vice versa —
  critical in Ghanaian hospital and home-care settings.
- Progress is visible: calibration and the Accuracy Score give the
  person (and their therapist/family) a concrete sense of the app
  adapting as recovery and training proceed.

## 4. A person with a cleft lip / palate

**Their reality:** hypernasal resonance and consonants that are
produced differently (pressure consonants especially). Their speech is
consistent — intelligible to people who know them, foreign to a
general recognizer. Familiar listeners succeed because they have
*learned the person's sound system*; the app must do the same.

**How Kasa Me helps:**
- The **Cleft speech profile** builds the person's sound-to-word
  corrections fastest (active after 2 examples) and applies them
  readily (gate 0.90), mimicking how a familiar listener adapts.
- Calibration gives structured coverage of everyday phrases so the
  most important mappings are learned deliberately, not by accident.
- Mic gain is raised slightly and correction memory is always on, so
  every corrected word permanently improves the next conversation.
- Because their mappings are personal and stored on-device, the
  adaptation belongs to them — it is not uploaded, shared, or reset by
  an app update.

## How personal training works (the loop)

1. **Choose a speech profile** — one tap in Settings → Personalization;
   behaviour and listening presets change immediately, app-wide, with
   no restart.
2. **Calibrate** — read the guided phrases (English is checked live;
   Twi and Ewe build a voice-sample library on the phone without spending
   cloud recognition quota). Mismatches automatically become corrections.
3. **Correct in the moment** — tap a misheard word in conversation and
   fix it. Corrections climb the evidence tiers and start applying
   automatically.
4. **Watch the score** — the home Accuracy Score is computed from
   calibration and from how rarely corrections are still needed. More
   training → a measurably better-understood person.

## Honest limits

- The Lab and offline ASR models are not fine-tuned per user inside
  the app today; adaptation happens in the personalization layer
  around them. Calibration audio is saved on-device so per-user model
  adaptation (the `research/` fine-tuning track) can use it later.
- Ghanaian calibration (Twi, Ewe) is recorded, not recognizer-checked,
  to protect the Lab API's strict per-key quotas (10 ASR requests/day).
- Ewe opened fully in v1.3.0 with the same feature set as Twi; its
  curated phrase set was authored for this build and awaits review by
  a native Ewe speaker before clinical use. Khaya lists Ewe
  explicitly; the Lab gateway infers language from audio, so Lab-side
  Ewe recognition is unverified until field tests confirm it.
- Translation is a curated dictionary with a word-for-word gloss
  fallback for fully-known vocabulary — it never guesses, and says so
  when a phrase is beyond it.
