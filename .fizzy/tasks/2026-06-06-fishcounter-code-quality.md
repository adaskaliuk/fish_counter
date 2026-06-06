# FishCounter: code-quality fixes after review

Status: done
Created: 2026-06-06
Updated: 2026-06-06

## Scope

Start with low-risk fixes from the Flutter code review:

- persist session visibility/activity flags consistently;
- make activity/status JSON parsing backward-compatible;
- reduce excessive battery polling;
- keep analyzer/tests green.

## Progress

- Added backward-compatible status parsing for legacy `green/orange/red/grey` values.
- Hardened JSON map parsing for sessions and repository activity loading.
- Persisted `isSessionActive` and `isDataHidden` through the shared app state.
- Reduced battery polling from every second to about every 30 seconds.
- Moved `ClickerScreen` load/save/history persistence calls onto `PrefsRepository`.
- Moved click increment and timing-status business rules into `ClickerController`.
- Moved increment guard, activity entry creation, pause toggling, and pause marker creation into `ClickerController`.
- Moved power on/off and saved-session reset state into `ClickerController`.
- Moved saved `GameSession` creation and match-duration formatting into `ClickerController`.
- Improved saved match-duration formatting from `H:M` to `H:MM`.
- Added regression tests for status parsing and clicker controller rules.
- `flutter analyze` passes.
- `flutter test` passes. Latest run: 25 tests passed.

## Notes

The `fizzy` CLI is not available in this environment, so this task is recorded locally under `.fizzy/tasks/`.
