## Review

- Correct:
  - `AnalyticsScreenBody` wires existing `AnalyticsTimelineSection` and new `WeatherDuringMatchSection` before charts: `lib/widgets/analytics_screen_body.dart:60-62`.
  - Weather widget has empty-data fallback and avoids `first/last` on empty lists: `lib/widgets/weather_during_match_section.dart:29-37`, `91-107`.
  - Result values display in analytics/history/export when non-null: `lib/widgets/analytics_dashboard_section.dart:91-100`, `lib/widgets/history_session_details.dart:40-43`, `lib/services/report_exporter.dart:30-33`, `179-183`.
  - `SessionEditDialog` initializes, saves, and clears result inputs through controllers/copyWith flags: `lib/widgets/session_edit_dialog.dart:74-79`, `121-124`.

- Blocker:
  - `lib/game_session.dart:302-329` — `finalCount` does not preserve optional/null values through JSON. `toJson()` always writes `"finalCount": null`; `fromJson()` checks only `containsKey` and then calls `TypeUtils.safeInt(null)`, which returns `0` (`lib/utils/type_utils.dart:12-16`). Result: weight-only or unknown-count sessions reload as `finalCount == 0`, causing UI/export to show a fake count. Tests miss this because weight-only round-trip asserts only weight: `test/game_session_test.dart:150`.

- Fix worth doing now:
  - Add assertions for `finalCount` remaining null on weight-only/no-result JSON round-trip, and for CSV result rows. Current CSV exporter code includes rows, but `test/report_exporter_test.dart:83-90` does not assert them.
  - Add the missing `SessionEditDialog` widget test noted in project tasks; current tests cover model/export/timeline/weather, not edit save/clear.

- Optional/defer:
  - Weather tests do not cover session-level weather fallback; current code path exists at `lib/widgets/weather_during_match_section.dart:44-66`.
  - Weather snapshots are not filtered to a match window; likely acceptable v1 because existing capture appears session-scoped, but requirement wording asks “fall inside match time window.”