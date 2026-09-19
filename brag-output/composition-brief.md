# Hyperframes Composition Brief: VocalBridge

## Objective
Create a short launch-style brag video for VocalBridge.

## Output
- Composition directory: `brag-output/composition/`
- Rendered video: `brag-output/brag.mp4`
- Format: landscape — 1920x1080
- Duration: 18 seconds

## Source Material
- Project root: `/home/tjay/VocalBridge`
- Primary files read: `PROJECT_CONTEXT.md`, `kasa_me/README.md`
- Product name: VocalBridge
- Tagline / strongest claim: "The system adapts to the speaker rather than forcing the speaker to adapt to the system."
- Key UI or visual moment to recreate: The large Push-to-Talk button being pressed, and the high-contrast Twi transcription text appearing.
- Copy that must appear verbatim:
  - "Speech tech wasn't built for Twi."
  - "So we built an offline AI that adapts to you."
  - "Mehia me nnuru"
  - "100% Offline. Akan/Twi Support."

## Creative Direction
- Tone preset: polished
- Creative direction: Quiet, premium assistive technology film, focusing on empowerment and privacy, centered on Akan/Twi.
- Interpretation: Pacing should be steady and deliberate, allowing the text to be read clearly. Visual energy should be clean, focused, and free of clutter. Restraint is key—no chaotic cuts or flashy colors.
- Angle: Emphasize that the app runs entirely offline, adapting locally to the user instead of relying on the cloud, to ensure privacy and reliability—especially for under-resourced languages like Akan/Twi.
- Hook: Fade in elegant, high-contrast text on a black background ("Speech tech wasn't built for Twi."), lingering long enough to set a serious, empowering tone.
- Outro / punchline: "VocalBridge" logo centering and fading into black.
- Avoid:
  - Generic SaaS language
  - Abstract filler visuals
  - Unrelated visual redesign

## Visual Identity
- Background: #000000 (Black)
- Text: #FFFFFF (White)
- Accent: #FFCC00 (High-contrast yellow, if needed)
- Display font: Chicago (or a similarly bold, highly legible sans-serif/retro-premium font)
- Body font: Inconsolata or a clean sans-serif
- Visual references from the project: High contrast, motor-accessible large elements.

## Storyboard
Use the storyboard in `brag-output/brag-plan.md` as the creative contract.

Scene summary:
1. Scene 1: The Hook — 3s — High contrast text "Speech tech wasn't built for everyone."
2. Scene 2: The Reveal — 3s — Text "So we built one that adapts to you."
3. Scene 3: UI - The Button — 3s — Large Push-to-Talk button is pressed.
4. Scene 4: UI - Transcription — 4s — Text "I need my medication." types out.
5. Scene 5: The Flex — 2s — "100% Offline. Zero Cloud." badge appears.
6. Scene 6: Outro — 3s — "VocalBridge" logo/name.

## Audio
- Audio role: warm bed with subtle UI clicks
- Audio arc: Begins calm, builds slightly as the app is "used," then resolves warmly at the end.
- Music: (Placeholder premium track, or intentional silence if music missing)
- Music treatment: Fade in smoothly at start, fade under final logo.
- Music cue guidance: detect at composition via hyperframes beats
- Audio-reactive treatment: subtle glow on the text/button corresponding to RMS energy.
- Audio-coupled moments:
  - Scene 3 - Button press — satisfying deep click
  - Scene 4 - Transcription — subtle popping/typing SFX
  - Scene 5 - Badge reveal — premium chime
- SFX selection guidance: use clean, UI-appropriate sounds. No harsh, high-frequency noises.
- SFX analysis guidance: unavailable
- Exact SFX choice: Hyperframes should choose filenames, timestamps, density, and volume based on the implemented animation.
- Audio files: copy the chosen music and any Hyperframes-selected SFX into `brag-output/composition/assets/`

## Hyperframes Instructions
Load the composition-building Hyperframes domain skills — `hyperframes-core`, `hyperframes-animation`, `hyperframes-creative`, `hyperframes-keyframes`, and `hyperframes-cli`. /brag is its own workflow: do not enter the `hyperframes` entry-point intent interview and do not route into its generic promo / launch-video workflow. Prefer native Hyperframes conventions over anything in `/brag`.

Requirements:
- Show at least one real UI, copy, or visual element from the source project.
- Keep all text readable in the final render.
- Keep the video within 15-25 seconds.
- Include the planned music/SFX layer unless audio was explicitly disabled.
- Treat `/brag` audio notes as guidance, not a fixed cue sheet. Choose SFX after the visual animation exists.
- Treat music cue metadata as optional timing hints.
- Major reveals may move toward nearby strong cues within about 0.15s. Smaller entrances may align to nearby beat points within about 0.10s.
- Use SFX to support motion and interaction.
- Honor planned music treatment such as fade-outs.
- Consider Hyperframes audio-reactive workflow for subtle brand-specific motion.
- Use local assets for audio and any required runtime/media dependencies when possible.
- Run `hyperframes check` before render.
