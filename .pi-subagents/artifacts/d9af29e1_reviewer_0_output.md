## Review
- Blocker: `lib/widgets/analytics_dashboard_section.dart:46-47` still renders `l10n.dashboardTitle` for athletes. In English this is `Readiness dashboard` (`lib/l10n/app_localizations.dart:131`), so readiness context is not fully hidden.
  - Fix now: gate/rename that heading for `!isCoach`, and add an athlete assertion for `find.text('Readiness dashboard') == findsNothing`.
- Note: current athlete test only checks exact `Readiness` at `test/auth_role_test.dart:84`, so it misses the visible `Readiness dashboard` heading.