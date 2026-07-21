# Fish Counter Implementation Plan

Updated: 2026-07-20

## Product Focus

Fish Counter is a training and competition support app for sport anglers,
athletes, and coaches. It helps users count actions, control pace, review
rhythm stability, and analyze training sessions.

## Current Status

### Delivered

- Flutter project builds for Web and iOS.
- `flutter analyze --no-pub` and the full Flutter test suite pass.
- English, German, French, Polish, Italian, Dutch, Romanian, and Ukrainian
  localization is available.
- Session start, pause, save, history, analytics, UI undo, and shake undo are
  implemented.
- Shake undo On/Off and sensitivity settings are persisted.
- Athlete/coach roles and Google Sign-In are implemented.
- Local persistence uses `hive_ce`; settings and history sync at startup and
  retry at safe opportunities.
- Session metadata, goals, athlete notes, coach comments, final weight, and
  final count are persisted and editable.
- Analytics includes status metrics, stability, charts, activity heatmap,
  timeline windows, weather correlation, and per-session coach summaries.
- Weather snapshots, astronomy context, readiness score, fishing-window
  forecast, species/body presets, and historical tuning are implemented.
- Plain-text, CSV, and PDF reports are implemented and shareable.
- Speckit projects `auth-role` and `match-results-timeline` are complete.
- Privacy audit, data minimization, safe export disclosure, bounded sync errors,
  UID-scoped Firestore rules, and account deletion are complete.

### Data Lifecycle

- Local and Firestore session/settings data has no automatic expiry and remains
  until the user deletes a session, clears app storage, or deletes the account.
- Account deletion requires a signed-in, non-anonymous user and removes owned
  Firestore sessions, Firestore settings, all local app data, then the Firebase
  Auth identity. A failed step is reported and can be retried.
- Shared or copied reports leave app control and cannot be recalled; the export
  UI warns users to review names, notes, venues, and weather before sharing.
- App data in Hive has no app-level encryption. Current release accepts the
  platform app sandbox as the protection boundary for minimized, non-credential
  training data; authentication credentials stay in platform Firebase storage.

### Planning State

- Fizzy `In Todo` is empty.
- Backlog remains in `Maybe?`; cleanup and privacy cards are closed through
  2026-07-20.
- Before implementation, move exactly one selected card into `In Todo`.

## Next Priorities

### 1. Field Test on iPhone

Goal: validate the current MVP in real fishing and training conditions.

Checklist:

- Test button size and placement with one hand.
- Test visibility outdoors and in sunlight.
- Test vibration feedback strength.
- Test action delay behavior.
- Test session start, pause, save, history, and analytics.
- Test accidental taps.
- Test shake undo reliability and false triggers.
- Test Google Sign-In and foreground sync on a physical iPhone.
- Record device, iOS version, environment, and reproducible failures.

Exit criteria:

- Device findings are recorded as focused Fizzy cards.
- Button layout and shake sensitivity defaults have explicit decisions.
- No release-blocking auth, storage, sync, or session-flow defect remains.

### 2. Store Release Preparation — Fizzy #42

Goal: prepare a complete App Store and Google Play release package.

Scope:

- Validate App Store and Google Play icons.
- Produce the Play Store feature graphic and current screenshots.
- Finalize app name, description, keywords, and support metadata.
- Prepare privacy notes for location, weather, authentication, and sync.
- Verify release signing, entitlements, bundle identifiers, and versioning.

Exit criteria:

- Store assets satisfy platform dimensions and content rules.
- Release metadata matches current behavior.
- A signed release build passes a physical-device smoke test.

## Product Backlog

Keep these cards in `Maybe?` until a priority slot is available:

1. Fizzy #28 — Apple Sign-In for iOS.
2. Fizzy #36 — cross-athlete coach dashboard with athlete/session drill-down.
3. Fizzy #37 — reusable coach training templates.
4. Fizzy #40 — richer automatic coach insights for drops, pauses, tries, and
   strong/weak intervals.

The existing coach summary is session-scoped; it does not complete #36. The
current match insight covers activity windows and nearby weather; it only
partially covers #40.

## Completed Fizzy Cleanup

Closed as implemented:

- #39 activity heatmap.
- #46 readiness score.
- #47 best fishing-window forecast.
- #50 species/body-type presets.
- #51 moon, sun, and twilight context.
- #52 historical catch tuning.
- #53 forecast/readiness dashboard.
- #55 private-data audit and remediation.

Closed as duplicate, superseded, or completed roadmap tracking:

- #48 and #49 duplicate #50 and #51.
- #54 roadmap tracking for completed forecast/readiness work.
- #56 and #57 duplicate the completed `hive_ce` migration and startup sync.

## Product Positioning

> A training and pace-control tool for sport anglers and coaches.

## UX Principles

The app should work well:

- with wet hands;
- with one hand;
- under sunlight;
- under competition stress;
- with minimal screen attention;
- with strong but configurable haptic feedback;
- with simple recovery from mistakes through Undo.
