## Review

### Blockers
- **Blocker:** `lib/widgets/analytics_screen_body.dart:37-43` renders `AnalyticsDashboardSection` for athletes too. Spec marks `coachSummary` + coach dashboard sections as coach-only (`.speckit/projects/auth-role/fields.md:20-21`, `.speckit/projects/auth-role/ui/analytics-coach-dashboard-section.md:3-4`), and acceptance requires athletes never see coach-only summaries (`acceptance.md:6`). Current athlete path still shows readiness dashboard / forecast content from `lib/widgets/analytics_dashboard_section.dart:44-170`.
- **Blocker:** `lib/services/report_exporter.dart:52-70,99-124,197-224,257-279` still exports weather, forecast/readiness, and historical tuning when `isCoach == false`. Since UI hides weather behind `isCoach` (`lib/widgets/analytics_screen_body.dart:44-47`) and exporter spec says coach sections only for coach mode (`.speckit/projects/auth-role/ui/report-exporter.md:3-5`), athlete exports can still leak coach-only summaries/context.

### Fixes worth doing now
- `lib/auth_screen.dart:163-179`: role picker is visible in sign-in mode, though requirement is signup role selection (`.speckit/projects/auth-role/ui/auth-screen.md:3-5`). Hide it unless `_isRegister`.
- `lib/widgets/session_edit_dialog.dart:124`: coach name input is hidden for coaches when the saved session has empty `coachName`; coach should be able to add it.

### Optional / defer
- Add tests for athlete-not-seeing dashboard/forecast/export sections; current tests only cover weather and coach/comment export hiding.
- Root `plan.md` was missing; reviewed `.speckit/projects/auth-role/plan.md` plus `progress.md`.