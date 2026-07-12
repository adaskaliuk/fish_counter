## Review
- Correct: `AuthGate` forces role setup when stored role is empty (`lib/auth_gate.dart:66-71`), and `RoleSetupScreen` preserves existing profile fields on save (`lib/auth_gate.dart:96-103`; covered in `test/auth_role_test.dart:128-159`).

- Blocker: `lib/models/app_settings.dart:48` defaults missing remote `role` to `"athlete"`, then `lib/services/prefs_repository.dart:153` writes that into `AthleteProfile`. Legacy/cloud settings with no role will bypass the required role prompt in `lib/auth_gate.dart:66`. Simpler safe fix: keep one source of truth (`AthleteProfile.role`) and default missing role to `''`; if retaining top-level `role`, only use it as legacy input and never synthesize `"athlete"`.

- Fix worth doing now: `lib/auth_screen.dart:163-179` shows role dropdown during sign-in too, though `_submit` only uses it for register (`lib/auth_screen.dart:55-65`). Wrap dropdown/spacer in `if (_isRegister)`.

- Optional/defer: `pubspec.yaml:36` adds `firebase_auth_mocks` for two tests (`test/auth_role_test.dart:169-242`) mostly validating SDK behavior plus a test seam in `AuthScreen`. Existing role prompt/prefs tests cover app logic; remove dependency if minimizing pre-push diff matters.

- Optional/defer: `.speckit/projects/auth-role/*` adds many small spec files, several just “See: …”. If Speckit artifacts are not required in-repo, collapse or omit before push.