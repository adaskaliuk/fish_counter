## Review

- Blockers: none found.
- Fixes worth doing now: none.
- Optional/defer:
  - `lib/analytics_screen.dart:35-45` defaults `isCoach` to `false` while role loads; very fast coach tap on export could get athlete-scoped export. Low-risk UX race.
  - `lib/widgets/analytics_dashboard_section.dart:29-38,117-157` still shows readiness/forecast/weather context in the base dashboard for all users. OK if only `AnalyticsCoachDashboardSection`/weather section/export forecast are coach-only; revisit if product means all forecast/weather UI must be coach-only.

Evidence checked:
- `lib/models/app_settings.dart:48` missing role → `''`.
- `lib/services/prefs_repository.dart:153-155` falls back to nested profile role.
- `lib/auth_screen.dart:63-65` preserves profile fields on signup; `163-180` picker only in register mode.
- `lib/history_screen.dart:216-225` loads role before edit dialog.
- `lib/widgets/session_edit_dialog.dart:124-128` hides coach/training/method fields for athlete; hidden values remain controller-backed.
- `lib/services/report_exporter.dart:35-36,52-72,101-111,276-289` gates coach-only export fields/sections.
- `lib/widgets/analytics_screen_body.dart:45-55` wires coach dashboard/weather only under `isCoach`.
- Tests cover these paths in `test/app_settings_test.dart:31-61`, `test/auth_role_test.dart:74-130,216-280`, `test/report_exporter_test.dart:87-146`.