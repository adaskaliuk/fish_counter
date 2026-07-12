# Task for reviewer

Second review round for auth-role speckit project. First retry failed due rate limit; try now.

Scope: uncommitted changes (`git diff HEAD`). Spec: `.speckit/projects/auth-role/`.

Verify blockers fixed:
1. `lib/auth_gate.dart` — RoleSetupScreen exits after save. AuthGate Stateful, cached future, `onSaved` setState reload.
2. `RoleSetupScreen._saveRole` preserves existing profile fields with `existing.copyWith(role: _role!)`.

Also verify:
- `AthleteProfile.copyWith` covers every field.
- `test/auth_role_test.dart` has regression for preserving fields.
- Full suite already passed locally: `flutter test` → 80/80.

Deliverable: SHORT bullet list, blockers only. No essay.

## Acceptance Contract
Acceptance level: attested
Completion is not accepted from prose alone. End with a structured acceptance report.

Criteria:
- criterion-1: Return concrete findings with file paths and severity when applicable

Required evidence: review-findings, residual-risks

Finish with a fenced JSON block tagged `acceptance-report` in this shape:
Use empty arrays when no items apply; array fields contain strings unless object entries are shown.
```acceptance-report
{
  "criteriaSatisfied": [
    {
      "id": "criterion-1",
      "status": "satisfied",
      "evidence": "specific proof"
    }
  ],
  "changedFiles": [
    "src/file.ts"
  ],
  "testsAddedOrUpdated": [
    "test/file.test.ts"
  ],
  "commandsRun": [
    {
      "command": "command",
      "result": "passed",
      "summary": "short result"
    }
  ],
  "validationOutput": [
    "validation output or concise summary"
  ],
  "residualRisks": [
    "none"
  ],
  "noStagedFiles": true,
  "diffSummary": "short description of the diff",
  "reviewFindings": [
    "blocker: file.ts:12 - issue found, or no blockers"
  ],
  "manualNotes": "anything else the parent should know"
}
```