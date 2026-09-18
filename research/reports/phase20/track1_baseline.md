# Phase 20, Track 1: Current Repository Baseline

## Git State
- **Current Branch**: `main`
- **Current HEAD**: `c930550 phase20: recover and harden privacy deletion`
- **Track 0 Checkpoint**: Confirmed present at `c930550`.
- **Working-Tree Cleanliness**: Mostly clean, with uncommitted modifications to `pubspec.lock` and `lib/storage/database/app_database.g.dart` (generated file), and several untracked research scripts/reports.

## Environment
- **Flutter Version**: 3.24.3 (channel stable)
- **Dart Version**: 3.5.3
- **Dependency State**: Packages resolved and cached (recently rebuilt via `flutter clean` + `pub get`).

## Generated Code State
- Drift database bindings are tracked and synchronized, though `lib/storage/database/app_database.g.dart` shows local modifications from the recent generator run.

## Test Baseline Reconciliation
- **Historical Baseline**: 124 tests (Phase 16)
- **Current Total (Actual)**: 7 tests passed.
- **Tests Lost**: The Phase 19 deletion incident completely wiped out the vast majority of test files in `test/`, specifically within the `profile`, `speech`, and `state` subdirectories. They were uncommitted and unrecoverable via `git checkout .`.

**Conclusion**: The historical test baseline was destroyed. The true current test baseline is 7 tests.
