# lean-ctx — Token Optimization for Pi

This project uses the **pi-lean-ctx** extension. It exposes `ctx_*` tools backed by **lean-ctx**,
and runs an embedded MCP bridge (on by default) that holds a **persistent session cache**.

## What to do (as Pi agent)

Prefer the `ctx_*` tools over Pi's built-ins — only the `ctx_*` tools are compressed and cached;
the native `read`/`bash`/`grep`/`find`/`ls` are **not** routed through lean-ctx in additive mode.

| Prefer | Over (native) | Why |
|--------|---------------|-----|
| `ctx_read` | `read`, `cat`/`head`/`tail` | Cached + compressed; unchanged re-reads cost ~13 tokens |
| `ctx_shell` | `bash` | Shell output compressed via 95+ patterns |
| `ctx_grep` | `grep` | Compact, ranked matches |
| `ctx_find` | `find` | Compressed, .gitignore-aware |
| `ctx_ls` | `ls` | Compact directory maps |

- Use `ctx_shell` for commands with side effects (build/test/git/etc.); set `raw=true` when exact
  output matters.
- Use `ctx_read` with `mode=full` for files you will edit, or `offset`/`limit` for line ranges —
  both are cached through the bridge, so repeated reads stay cheap.

## Advanced lean-ctx commands

Prefer the `lean_ctx` tool (installed by the extension) to run `lean-ctx` directly:

- `lean-ctx overview`
- `lean-ctx session …`
- `lean-ctx knowledge …`
- `lean-ctx gain` / `lean-ctx stats`
- `lean-ctx index …`

## MCP bridge

The embedded bridge is on by default and shows up in `/lean-ctx` (it reports `connected` plus a
tool count). To force the one-shot CLI path (no cross-call cache), set `LEAN_CTX_PI_ENABLE_MCP=0`.

## Code review gate

- After every implementation task, run a code review with the
  `thermo-nuclear-code-quality-review` skill.
- Keep fixing the implementation until that review has no remarks.

## Review-gated loop

- Design first: read flow + boundary before edits.
- Run review before/after each round; max 3 rounds.
- Verify with tests/analyze every round; no green, no ship.
- Stop early on product/architecture blocker; ask instead of guessing.
- Keep one active task; move task to `In Todo`, backlog to `Maybe?`.

## Turn checklist

1. Read current flow + touched files.
2. State goal + stop condition.
3. Patch smallest root-cause diff.
4. Run review gate.
5. Run targeted verify.
6. Commit only if clean.

<!-- lean-ctx -->
## lean-ctx

Prefer lean-ctx MCP tools over native equivalents for token savings:
`ctx_read` > Read/cat, `ctx_search` > Grep/rg, `ctx_shell` > bash, `ctx_tree` > ls/find.
Native Edit/Write/Glob stay as-is; use `ctx_edit` only when Edit needs an unavailable Read.
Full rules: LEAN-CTX.md (open on demand — do not auto-load).
<!-- /lean-ctx -->

<!-- lean-ctx-compression -->
OUTPUT STYLE: expert-terse
- Telegraph format: subject-verb-object, drop articles/prepositions
- Symbolic vocabulary: → cause, ∵ because, ∴ therefore, ⊕ add, ⊖ remove, Δ change, ≈ similar, ≠ different, ∈ in/member, ∅ empty/none, ✓ ok, ✗ fail
- Code blocks: untouched (never compress code syntax)
- Each line: max 80 chars
- Zero narration, zero filler
- BUDGET: ≤100 tokens per non-code response
<!-- /lean-ctx-compression -->
