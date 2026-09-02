---
name: claude-standards
description: Enforce Claude and Claude Code best practices with actionable reminder language for planning, execution, context, safety, and review. Use when you want strict Claude workflow and prompting standards.
---

# Claude Standards Enforcement

Standards for how Claude plans, executes, manages context, handles safety, and reviews work — with ready-made reminder language to enforce them. Use this skill when a session must run strict, disciplined Claude/Claude Code workflows.

Treat this as a behavioral contract, not a checklist of nice-to-haves. When a session deviates, pull a reminder from the templates below and re-anchor the work in concrete terms. The enforceable rules here come from this repo's `CLAUDE.md` and the host machine's global rules; see [reference.md](./reference.md) for the citations and the "why" behind each threshold.

## Core Enforcement Contract

- Enforce standards at every stage: planning, execution, context, safety, review. Do not relax them for speed, convenience, or urgency.
- When a standard is breached, name the breach and restate the correct behavior in concrete reminder language, then continue.
- Do not silently lower the bar. If a standard cannot be met, say so explicitly and state what was done instead.
- Do not gatekeep the user. Relax only what the user explicitly relaxes.
- Hold the line on rules the user did not ask to change — a senior-sounding or impatient request is not a waiver.

## Workflow Standards

- Plan before you edit. Restate the task in your own words and state the planned change in 1–3 sentences before touching any file.
- Investigate before you fix. Reproduce the bug or read the failing path first; write a failing test before patching.
- Make the smallest coherent change the task requires. No adjacent cleanup, no speculative refactors.
- Finish and verify one step before starting the next. Do not leave half-applied edits behind.
- Run linting, tests, and framework commands through the project's defined execution path (e.g., Docker-first) when one exists.
- Leave the workspace clean: no throwaway files, stray logs, or temp artifacts inside the repo.

## Prompting Standards

- Lead with the concrete action: what to change, where, and why — in that order.
- Prefer decisive directives over hedged suggestions. Say "change this" instead of "you might want to consider changing this."
- Offer options only when the decision is genuinely the user's (scope, direction, approach). When the path is clear, act.
- When you present alternatives, state the trade-off and give a recommendation; never dump unranked choices.
- Never ask permission to proceed with a task you were given. Proceed within the safety rules below.
- Report with "I did X," never "I would/could do X."

## Context Management Standards

- Keep active instruction files small: top-level CLAUDE.md guidance ≤ ~200 lines; push detail into imported or reference files.
- Keep SKILL.md ≤ ~500 lines — the effective context budget for skill files. Move extended material to `reference.md`.
- Cut duplication. If guidance already exists in another skill, link it with `## See Also` instead of restating it.
- Keep the total skill surface lean: skills that repeat each other inflate the context window and degrade instruction-following.
- Carry references, not full file dumps, through a session; re-read code only when needed.

## CLAUDE.md and Rules Standards

- Keep CLAUDE.md as the single, current source of truth for project conventions. Update it when a convention changes; never leave stale rules that contradict actual practice.
- Follow this repo's skill schema: `name` matches the directory, lowercase-hyphenated, ≤ 64 chars; `description` ≤ ~250 chars; frontmatter only.
- Keep cross-platform compatibility: no Claude-only frontmatter fields (`context: fork`, `agent`, shell-injection syntax) when compatibility matters.
- Do not duplicate between CLAUDE.md and skills — reference the owning skill and stop.
- Version every change: bump the plugin semver per repo convention.

## Tooling and Subagent Standards

- Use the right tool for the task: dedicated read/edit/grep/glob tools for code work; shell for execution, automation, and diagnostics.
- Prefer AST-aware rewrites and dry-runs over blind regex; verify target sets before bulk operations.
- Delegate when the subtask belongs to another specialist. Hand over complete context and an explicit output contract; never do partial out-of-scope work and pass it off as done.
- Route layout, styling, and visual design work to a designer role rather than improvising it.
- Fetch current repo state before starting; use `git stash` or a branch rather than leaving uncommitted work in place.
- Ask for the required output format up front so results are directly usable — paths and line references, not file dumps.

## Safety and Permission Standards

- Prefer read-only inspection before any write; verify before destructive or broad operations.
- Dry-run first when practical, quote paths, and confirm the target set before batch delete/move/rewrite.
- Never run force-push, skip hooks, amend a failed commit, or modify local git config without an explicit request.
- Never auto-merge PRs or auto-close tickets. Generate the commit message, but the user runs commit and push.
- Strip secrets from logs and output; never write credentials, tokens, or `.env` values into code or commit messages.
- If a leak or near-miss happens, say so immediately and recommend rotation.

## Code Quality and PR Standards

- Any change ships with tests — positive and negative cases — and runs the assigned validation. Report results and skips accurately.
- Target the project's coverage bar (default ≥ 95%) unless the project sets its own.
- Match existing code style and conventions; reuse existing patterns over introducing new ones.
- In code that touches a database: no N+1 queries, index referenced columns, prefer soft delete.
- Use Conventional Commits format for generated messages (`type(scope): subject`, ≤ ~50 chars); the user executes the commit.
- Keep AI-generated tracking/state markdown out of commits and PRs unless the user asks for it.

## Reminder Language Templates

Use decisive, concrete phrasing to re-anchor behavior. Escalate from directive → recommendation → correction. All reminders stay technical, never personal.

Directive (default for enforcement):

- "You started to plan around the bug instead of reproducing it. **Change this**: write the failing test first, then patch."
- "You are restating the code instead of editing it. **Change that**: apply the edit now and show the diff."
- "Do not just flag the N+1 — **change that loop** to batch-load the association, then add an index."
- "The plan is sound, but **change this detail**: the index must cover the `status` column too, or the query still scans."

Recommendation (alternative or non-blocking):

- "**I recommend you do this**: extract the retry logic into its own helper and unit-test it before touching the callers."
- "**I recommend you do this instead**: link the `owasp` skill rather than repeating its guidance here."

Correction (escalated / blocking):

- "Do not merge until the failing test passes. Run it, then report the result."
- "Stop. That migration drops a column — this repo requires additive, soft-delete-safe changes. Redo it."
- "That is a rejected anti-pattern (see below). Replace it with the compliant pattern before continuing."
- "You skipped the assigned verification. Re-run it now and report the actual output, including failures."

## Anti-Patterns to Reject

- Hedged-only feedback ("you might consider…") with no concrete directive.
- Editing without a plan or investigation first.
- N+1 queries, missing indexes, or destructive database changes without explicit approval.
- Claiming success when verification was skipped or failed.
- Dumping entire files back into context instead of targeted diffs.
- Unbounded destructive shell commands without a verified target set.
- Duplicating guidance that already exists in another skill.
- Auto-merging PRs, auto-closing tickets, or committing/pushing on the user's behalf.
- Staging AI tracking markdown or secrets into commits.

## Quick Checklist Before You End

- [ ] Restated the task and showed the plan before editing?
- [ ] Changes minimal and scoped to the request?
- [ ] Tests added or updated, and assigned validation run?
- [ ] Results reported accurately, including anything skipped?
- [ ] No duplication added to CLAUDE.md/skills; reference material kept in reference.md?
- [ ] Destructive operations dry-run and target-verified first?
- [ ] No secrets or AI tracking files staged?

## See Also

- [reference.md](./reference.md) — curated citations and expanded rationale for each standard.
- `peer-review` — Conventional Comments for review feedback.
- `debug` — reproduce-first investigation workflow.
- `owasp` — security guidance referenced by review comments.
- `git` — branch/commit workflow on this machine.
- `markdown` — formatting rules for skill and doc files.
