# Claude Standards Reference

Optional expanded reference for the `claude-standards` skill: curated citations and the rationale behind each standard. Keep `SKILL.md` actionable; this file carries the "why."

---

## Official Docs vs Repo-Curated Guidance

Every standard in this skill traces to one of two sources:

1. **Official Anthropic guidance** — Claude Code / Claude best practices published by Anthropic.
2. **Repo-curated conventions** — rules this repository (and its host machine) have tightened or operationalized for daily use, mostly from this repo's `CLAUDE.md`.

Where the two conflict, repo rules win locally. The official links below clarify upstream intent; the repo links define the enforceable contract on this machine.

## Curated Citations (Official)

| Topic | Source | What to take |
| --- | --- | --- |
| Claude Code — best practices | <https://code.claude.com/docs/en/best-practices> | Small, verifiable diffs; run tests; let Claude do the work; don't duplicate effort. |
| Claude Code best practices (Anthropic engineering) | <https://www.anthropic.com/engineering/claude-code-best-practices> | CLAUDE.md guidance, checklists, delegation, and memory hygiene. |
| Claude Code — memory (CLAUDE.md) | <https://code.claude.com/docs/en/memory> | Keep CLAUDE.md small and current; structure it so rules actually get followed; `@imports`. |
| Building effective agents | <https://www.anthropic.com/research/building-effective-agents> | Workflow vs. delegation design; when to hand a subtask to a specialist. |
| Prompt engineering overview | <https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview> | Clarity and specificity; direct instructions outperform hedged ones. |
| Conventional Commits | <https://www.conventionalcommits.org/> | Commit message format the repo enforces. |
| Conventional Comments | <https://conventionalcomments.org/> | Labeled, parseable review feedback (see `peer-review`). |

## Repo-Curated Citations (This Repository)

| Rule | Source | Threshold / Contract |
| --- | --- | --- |
| Skill schema (name, description) | Repo `CLAUDE.md` | `name` lowercase-hyphenated, ≤ 64 chars; `description` ≤ ~250 chars; no extra frontmatter for cross-platform use. |
| SKILL.md size budget | Repo `CLAUDE.md` | ≤ ~500 lines; longer material moves to `reference.md`; no duplication across skills — use `## See Also`. |
| Plugin versioning | Repo `CLAUDE.md` + git history | Bump `.claude-plugin/plugin.json` semver on every change. |
| Commit discipline | Host machine CLAUDE.md (global) | AI generates the Conventional Commit message; the user runs commit/push. No AI tracking markdown in PRs. |
| Test / coverage policy | Host machine CLAUDE.md (global) | Every change includes tests; target ≥ 95% coverage; validate UI via browser tooling. |
| Docker-first execution | Host machine CLAUDE.md (global) | Run lint/test/framework commands in Docker when a compose file exists. |
| Database practices | Host machine CLAUDE.md (global) | Avoid N+1, index query-referenced columns, soft delete, never drop/reset local DB without approval. |
| Git safety | Host machine CLAUDE.md (global) | Load the `git` skill; stash/branch before edits; never change local git config unasked; fetch first. |

## Rationale by Standard

### Reminder language

Hedged phrasing ("you might consider…") leaves the receiver free to ignore it and reads as optional even when it is not. Directive language ("change this," "change that," "I recommend you do this") states the required action unambiguously, which is exactly what prompt-engineering guidance calls for: clear, specific instructions. Escalation matters too — a correction ("do not merge until the test passes") must be distinguishable from a preference, otherwise everything lands at the same weight and nothing lands at all.

### Context thresholds

Every loaded skill file consumes context budget, and inflated context measurably degrades instruction-following. The repo's ~500-line SKILL.md ceiling exists precisely because that is the effective budget for a skill file to stay useful; the ≤ ~200-line CLAUDE.md guidance is tighter because CLAUDE.md is loaded in every session while skills load on demand. This is why detailed rationale lives in `reference.md`: it is reachable when needed but does not tax the active window.

### Safety and permissions

The ownership split (AI proposes, user commits/pushes/merges) keeps a human review gate on every state change. Read-only-by-default plus dry-runs convert irreversible operations into reviewable ones. These rules come from the host machine's global CLAUDE.md and are enforced as policy, not etiquette.

### Delegation and subagents

Delegation works when the delegate receives full context and an explicit output contract; partial handoffs force the delegate to re-derive context and produce unverifiable results. The "path and line references, not file dumps" convention keeps results compressed and directly actionable, which is what makes the orchestrator/specialist pattern viable.

## Related Skills Map

| Concern | Owning skill | Relationship to `claude-standards` |
| --- | --- | --- |
| Review feedback format | `peer-review` | Supplies the labeled-comment vocabulary enforcement uses. |
| Bug investigation | `debug` | Reproduce-first workflow this skill mandates. |
| Security rationale | `owasp` | The "why" behind security-flavored review comments. |
| Commit/branch workflow | `git` | The mechanics behind the commit discipline rules. |
| File/formatting rules | `markdown` | Applies to skill and doc files maintained under these standards. |
| Cross-platform config | `claudecode-migrate`, `llm-config-export` | Why this skill avoids Claude-only frontmatter and shell-injection syntax. |
