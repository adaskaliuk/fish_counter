## Review

**Blockers**

- **`lib/auth_gate.dart:74-83` — RoleSetupScreen never leaves after save.** `_saveRole()` writes prefs then toggles `_saving`, but nothing triggers `AuthGate` (StatelessWidget wrapping `FutureBuilder<AthleteProfile>`) to rebuild. User taps Save → button re-enables → they sit on the picker forever until the app is restarted or the auth stream fires. Violates acceptance "prompt them to choose … before entering the app" — they never enter. Fix: after `saveAthleteProfile`, either `Navigator.of(context).pushReplacement(...)` into the synced clicker screen, or hoist role into a `ValueNotifier`/`ChangeNotifier` the `AuthGate` listens to. Easiest ponytail fix: replace the `FutureBuilder` with a `StatefulBuilder`/`setState` after save, or have `RoleSetupScreen` accept an `onSaved` callback and pass one from `AuthGate` that flips a local flag.

- **`lib/auth_gate.dart:78` — data wipe for legacy users.** `AthleteProfile(role: _role!)` constructs a fresh profile with every other field defaulted to `''`. Pre-existing users (role was just added in this diff — see `git show HEAD:lib/models/athlete_profile.dart`) already have `athleteName`, `defaultVenue`, etc. persisted; hitting Save on `RoleSetupScreen` overwrites all of them. Fix: `final existing = repo.loadAthleteProfile();` then save `AthleteProfile(role: _role!, athleteName: existing.athleteName, coachName: existing.coachName, …)`. Adding an `AthleteProfile.copyWith` would be the lazy version.

**Non-blocking nits**

- **`lib/models/app_settings.dart:44`** — `role: json['role']?.toString() ?? 'athlete'` defaults to `'athlete'` while `AthleteProfile.fromJson` defaults to `''`. Both eventually resolve via `isCoach == 'coach'`, but the two sources of truth disagree on the literal. Harmonize to `''` since that's what `PrefsRepository.loadAppSettings` propagates from the profile anyway.

- **`lib/history_screen.dart:218-226`** — `final isCoach = PrefsRepository.create().then((repo) async => repo.loadAthleteProfile().isCoach); … isCoach: await isCoach` reads like a two-step future dance for no reason. Lazy version: `final isCoach = (await PrefsRepository.create()).loadAthleteProfile().isCoach;`.

- **`lib/widgets/session_edit_dialog.dart:120`** — `if (widget.isCoach && widget.session.coachName.isNotEmpty)` gates the *coach name field* on the name already being present, so a coach editing a session that has no coachName yet cannot fill it in. Probably not what you want; drop the `.isNotEmpty` guard.

- **`lib/widgets/analytics_notes_section.dart:18`** — guard is `athleteNote.isEmpty && coachComment.isEmpty` but the body only ever renders `athleteNote`. If `athleteNote` is empty and `coachComment` is not, you draw a "Session notes" header with nothing under it. Widget is dead code in `lib/` (spec's `analytics-notes-section.md` says N/A), so nit-only.

- **`lib/auth_gate.dart:33-42`** — `PrefsRepository.create().then(...)` inside `future:` is fine, but the future is recreated on every rebuild of the outer StreamBuilder. Not a leak (Flutter's FutureBuilder caches by identity via `didUpdateWidget`) but if the outer stream fires you re-hit storage. Cache the future in a `StatefulWidget`.

- **Tests** — `test/auth_role_test.dart` covers persistence, coach/athlete visibility on `AnalyticsScreenBody`, RoleSetupScreen save-to-prefs, and MockFirebaseAuth signup/login. No test covers "after RoleSetupScreen save, user reaches the clicker screen" — which is exactly why blocker #1 slipped through. Add a widget test that pumps `AuthGate` with a signed-in mock user + empty prefs, saves a role, `pumpAndSettle`, and expects `AuthGateKeys.startupSyncScreenKey`/`clickerScreenKey`.

**Good**
- Role round-trips via `PrefsRepository.saveAthleteProfile`/`loadAthleteProfile` (`test/auth_role_test.dart:19-40`); default empty → `isAthlete` per `AthleteProfile:31-32`.
- `AuthScreen._submit` requires `_role != null` on register path and persists it (`lib/auth_screen.dart:55-67`); login path leaves prefs alone (verified by `login with existing user does not clobber role`).
- `AnalyticsScreenBody`, `SessionEditDialog`, `ReportExporter.buildCsv/buildPlainText`, and `_SettingsDialogBody` all gate coach-only inputs, sections, and exports on `isCoach`.
- Hidden coach controllers in `session_edit_dialog.dart` still round-trip original values via `getUpdatedSession()`, so an athlete editing a coach-authored session doesn't clear coachName/coachComment.
- Localization strings for role labels added to both EN and UA locales in `app_localizations.dart`.