## Review
- Blocker: none.
- Fix worth doing now: none.
- Note: role gate is narrow enough: shared dashboard metrics remain visible, coach-only readiness/forecast block is gated in `lib/widgets/analytics_dashboard_section.dart:113`, and coach summary/weather sections are gated in `lib/widgets/analytics_screen_body.dart:46`.
- Note: athlete coverage exists in `test/auth_role_test.dart:81`; coach dashboard test coverage exists in `test/auth_role_test.dart:75`.