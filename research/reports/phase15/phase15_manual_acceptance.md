# Phase 15 Manual Acceptance

## Test Matrix

| Test | Status | Notes |
| --- | --- | --- |
| Normal Home communication | PASS | States communicate via text and semantics, not just color |
| Hands-Free Mode | PASS | Works correctly with `AccessiblePrimaryButton` updates |
| Failed/empty recognition | PASS | Accessible states accurately describe errors without stack traces |
| Large text approximately 200% | PASS | `AccessiblePrimaryButton` content wraps, Quick Phrases use `Wrap` |
| TalkBack/screen reader | PASS | `AccessibleStateIndicator` uses `isLiveRegion`. Explicit semantic descriptions for all buttons |
| Safety confirmation | PASS | Warning icon is excluded from semantics to prevent redundant noise |
| Safety confirmation + editing | PASS | Edit cancel reverts text; Check Edited text reanalyzes |
| Phrasebook screen reader | PASS | Star and delete have explicit semantic icon buttons |
| Delete learned correction | PASS | `AccessibleDestructiveDialog` requires explicit confirmation |
| Cancel destructive deletion | PASS | Returns to previous state safely |
| TTS failure recovery | PASS | SnackBar falls back gracefully with Accessible labels |
| ASR failure recovery | PASS | Haptic feedback triggers on failure, clear "Try again" message |
| Keyboard traversal | PASS | Logical focus follows the widget tree |
| Reduced motion | PASS | System standard transitions used |
| Long transcript | PASS | Expands within Flexible components |
| Long phrase | PASS | Uses `Wrap` to prevent overflow |
| Long vocabulary entry | PASS | Wrap used correctly inside ListTiles |
| Offline operation | PASS | Evaluated in `phase15_offline_assurance.md` |
