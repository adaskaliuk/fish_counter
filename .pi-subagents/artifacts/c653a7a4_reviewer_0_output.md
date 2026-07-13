## Review
- Correct: `firebase.json:2-3` now declares `"firestore": { "rules": "firestore.rules" }`, so Firebase CLI has a rules file to deploy.
- Correct: `firestore.rules:5-6` allows read/write only when `request.auth.uid == userId`; this covers the app paths:
  - `lib/services/cloud_history_service.dart:121` → `/users/{uid}/sessions/{sessionId}`
  - `lib/services/cloud_settings_service.dart:69-72` → `/users/{uid}/settings/app`
- Correct: startup sync does not leave the app stuck on permission-denied; `lib/auth_gate.dart:202-211` catches startup sync errors and then the `FutureBuilder` can complete to `ClickerScreen`.
- Correct: anonymous/no-user sync is skipped before Firestore writes/reads in `lib/services/cloud_history_service.dart:32-37` and `lib/services/cloud_settings_service.dart:37-38`.
- Correct: `lib/services/cloud_sync_error.dart:3-8` treats Firestore `permission-denied` as non-retryable; covered by `test/cloud_sync_error_test.dart:6-20`.

- Fixed: none applied; review-only task.

- Blocker: `firestore.rules` is currently untracked per `git status --short` evidence (`?? firestore.rules`). If omitted from the commit/PR/deploy artifact, `firebase.json:2-3` references a missing rules file and the production permission-denied fix will not ship.

- Note: I did not find a code-path mismatch between rules and cloud history/settings paths. Remaining risk is deployment/CI validation, not Dart path correctness.