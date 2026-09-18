# Phase 15 — Accessibility Hardening & Inclusive Interaction Audit

## Objective
The purpose of this audit is to identify accessibility issues within Kasa Me to ensure the application is genuinely usable by people with atypical/impaired speech and users with different accessibility needs, without compromising on Phase 14's safety and offline functionality.

## 1. Touch Target Problems & Gestures
* **Finding**: Many primary actions (Start, Stop, Speak, Edit) are implemented using default widget sizes (e.g., standard `ElevatedButton` or `IconButton` which default to 48x48 padding).
* **Finding**: Only one custom component (`LargePushToTalkButton`) actively implements an oversized touch target and semantic wrapping. 
* **Strategy**: Standardize interactive controls (especially on the Home Communication screen and Safety Confirmation Sheet) to have larger touch targets (minimum 64x64 for critical actions like Start/Stop, 48x48 for secondary actions) using standard Flutter accessibility guidelines. Use `InkWell` or explicitly sized `IconButton`s with large hit-test areas.

## 2. Screen Reader & Semantics
* **Finding**: There is an almost complete absence of explicit `Semantics` wrappers in the application, meaning screen readers are relying on Flutter's default widget tree inference. 
* **Finding**: Critical state changes (e.g. `IDLE` to `LISTENING`, `READY` to `SPEAKING`) are largely conveyed visually. `HomeCommunicationState` does not announce its transitions explicitly to screen readers.
* **Finding**: `IconButton`s without tooltips or explicit semantic labels will read poorly.
* **Strategy**: 
  - Introduce `MergeSemantics` and `ExcludeSemantics` where nested text/icons are confusing. 
  - Add explicit `Semantics(label: ..., button: true)` for all major controls.
  - Announce major state transitions (e.g. via `SemanticsService.announce` or by rendering an off-screen `Semantics(liveRegion: true)` container).

## 3. Keyboard & Focus Order
* **Finding**: The UI has not been audited for logical `FocusNode` ordering. Modals like `SafetyConfirmationSheet` may trap focus poorly or fail to focus on the primary action immediately.
* **Strategy**: Utilize `FocusTraversalGroup` for predictable tab ordering. Ensure `autofocus: true` or explicit focus requests are made when the safety sheet opens (focusing the "Review Message" container or the primary action).

## 4. Text Readability & Scaling
* **Finding**: Several UI elements (like the Quick Phrase horizontal list and Settings sliders) may clip or overflow when system accessibility text scaling is maxed out.
* **Strategy**: Ensure `Flexible`, `Expanded`, and `Wrap` are used for row-based controls. Wrap text elements and remove constrained heights (e.g., replace fixed `height: 44` in Quick Phrases with intrinsic or flexible layouts).

## 5. Color, Contrast, & Empty States
* **Finding**: `CommunicationState` relies heavily on color (border colors for listening vs idle). Errors and warnings rely primarily on red/error colors (e.g. `SafetyConfirmationSheet` uses `theme.colorScheme.error`).
* **Strategy**: Integrate iconography, explicit text statuses, and semantic meaning alongside color to convey state. Standardize error messaging to provide actionable recovery steps ("I didn't catch that. Try again.") rather than technical terms.

## 6. Safety & Destructive Actions
* **Finding**: `SafetyConfirmationSheet` contains some potentially ambiguous buttons or lacks sufficient explicit semantic descriptions for the consequences.
* **Finding**: Destructive actions (like "Delete" in Learned Corrections) happen upon `onLongPress` without explicit dialog confirmations, which is a major accessibility anti-pattern (relies on precise gesture and lacks confirmation).
* **Strategy**: Replace `onLongPress` deletions with explicit actions (e.g., trailing "Delete" icon that opens a confirmation dialog). Ensure `SafetyConfirmationSheet` buttons use explicit verbs ("SPEAK THIS", "EDIT", "CANCEL").

## 7. Speech Impairment Specific UX
* **Finding**: Errors from the engine might feel blaming if recognition fails.
* **Strategy**: Add accessible, non-blaming error state UI ("I couldn't recognize that speech. You can try again or edit the transcript."). 

## 8. Haptic & Audio Feedback
* **Finding**: Missing structured haptic feedback for critical lifecycle events (started listening, stopped listening, safety required).
* **Strategy**: Implement `HapticFeedback.lightImpact()` and `HapticFeedback.heavyImpact()` at key state transitions in `HomeCommunicationNotifier`.

## Conclusion
Phase 15 will implement these strategies systemically by establishing generic semantic widget components (`AccessiblePrimaryButton`, etc.), fixing focus/scaling regressions, and ensuring the interaction loop is predictable and forgiving.
