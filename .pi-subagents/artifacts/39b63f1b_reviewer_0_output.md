## Blockers only
- Blocker: validation fails. `flutter analyze --no-pub` exits 1:
  - `lib/auth_gate.dart:124`, `lib/auth_screen.dart:165` use deprecated `DropdownButtonFormField.value`.
  - `lib/history_screen.dart:223` uses `BuildContext` after async gap.
- Blocker: athlete visibility leaks coach-only fields. Spec field matrix marks `defaultTrainingType` / `defaultFishingMethod` coach-only, but:
  - `lib/widgets/session_edit_dialog.dart:128-129` shows Training type / Fishing method unconditionally.
  - `lib/services/report_exporter.dart:35-36` and `:176-178` export them even when `isCoach == false`.
- Blocker: coach summaries not wired into analytics. Spec requires coach dashboard/summary, and `AnalyticsCoachDashboardSection` exists, but `lib/widgets/analytics_screen_body.dart:37-49` only toggles weather; no coach summary section is rendered.

## Fixes worth doing now
- `lib/auth_screen.dart:64-65`: signup saves `AthleteProfile(role: _role!)`, clobbering existing local profile fields. Use existing profile `copyWith(role: ...)`.
- `lib/models/app_settings.dart:48`: missing role defaults to `'athlete'`; migration-safe behavior should preserve missing/empty role or derive from nested profile so setup can prompt.
- Add tests for athlete export/session-edit hiding `trainingType` / `fishingMethod`, and integrated coach analytics summary visibility.

## Optional/defer
- Role dropdown is visible on login too (`lib/auth_screen.dart:163-179`); harmless but noisy.
- New role strings are localized for en/uk; other supported locales fall back to English.