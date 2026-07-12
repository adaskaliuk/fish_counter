# Task for reviewer

[Read from: /Users/drongous/workspace/experemental/FishCounter/fish_counter/plan.md, /Users/drongous/workspace/experemental/FishCounter/fish_counter/progress.md]

Final review loop round 1 — ponytail simplicity/maintainability review for auth-role work in latest commit.

Inspect repo directly. Do NOT edit. Do NOT run subagents.

Target: commit `5b18bee Add auth role flow` versus parent (`git diff 5b18bee^ 5b18bee`). Apply ponytail lens: delete complexity, avoid speculative abstractions, use existing patterns, shortest safe diff. Ignore style-only complaints.

Focus:
- unnecessary code/dependencies/tests/spec docs
- over-engineered role flow or mocks
- obvious simpler fixes with same behavior
- any complexity worth fixing before push

Return: blockers only, fixes worth doing now, optional/defer. Short.

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