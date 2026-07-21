# Tasks / Задачі

## Phase 0 — safety / Безпека
- [x] Keep current auth-role fixes separate from this feature commit.
- [x] Run `flutter analyze --no-pub` before final review.
- [x] Run `flutter test` before final review.

## Phase 1 — existing timeline / Наявний таймлайн
- [x] Import `AnalyticsTimelineSection` in `lib/widgets/analytics_screen_body.dart`.
- [x] Render it after dashboard/weather summary and before charts.
- [x] Verify timeline shows event label and `timestamp` for C1/C2/try/pause.
- [x] Add widget test for event labels + timestamps.

## Phase 2 — weather during match / Погода під час матчу
- [x] Add `lib/widgets/weather_during_match_section.dart`.
- [x] Use `GameSession.weatherSnapshots` when non-empty.
- [x] Fallback to session-level weather fields when snapshots are empty.
- [x] Show fetchedAt, description, temperature, pressure, humidity, wind speed, wind direction.
- [x] Add simple trend text for multi-snapshot sessions: temperature, pressure, max wind.
- [x] Add no-weather fallback text.
- [x] Wire section into analytics/history result UI.

## Phase 3 — fisherman summary / Рибацький висновок
- [x] Add small pure helper/model for match insight summary.
- [x] Derive best activity window from `grid`/`ActivityLog`.
- [x] Derive quietest window.
- [x] Link nearest weather snapshot when available.
- [x] Keep text cautious: correlation, not causation.
- [x] Render summary near timeline/weather.

## Phase 4 — result element / Результатний елемент
- [x] Add nullable `finalWeightKg` to `GameSession`.
- [x] Add nullable `finalCount` to `GameSession`.
- [x] Update constructor/factory/builder/fromJson/toJson.
- [x] Keep old JSON backward-compatible when fields are missing.
- [x] Add edit controls in `SessionEditDialog`.
- [x] Allow weight only, count only, or both.
- [x] Show result values in `HistorySessionDetails`.
- [x] Show result values in analytics/result summary.
- [x] Export result values in plain text report.
- [x] Export result values in CSV report.

## Phase 5 — tests / Тести
- [x] `GameSession` old JSON without result values parses safely.
- [x] `GameSession` weight-only round-trip.
- [x] `GameSession` count-only round-trip.
- [x] `GameSession` weight+count round-trip.
- [x] Timeline widget shows C1/C2/try/pause + time.
- [x] Weather section shows temp/pressure/wind/humidity.
- [x] Weather section handles no snapshots/no weather.
- [x] Session edit saves result element values.
- [x] Report exporter includes result values when present.

## Phase 6 — review gate / Ревʼю
- [x] Run review gate after implementation.
- [x] Fix blockers only; defer polish.
- [x] Stop when analyze/test green and reviewers find no blockers.
