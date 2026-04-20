---
name: git
description: Git workflow rules for this machine. GPG-signed commits required, opencode sessions cannot commit. Focus on staging (git add), reading, and branch management.
---

# Git Rules

- **Never run `git commit` or `git push`** — as the commits are going to be signed by GPG.
- Your job is to **prepare and stage changes only** (`git add`). The user will commit and push manually in their own terminal where GPG + TTY work.
- `git stash`, `git diff`, `git status`, `git log`, `git add`, and read-only git commands are all fine.
- For revert/undo, use `git blame` to identify changes and reduce mistakes.
- Fetch the current repository first before doing any changes. If there is an ongoing change from upstream, ask if a merge/rebase is needed.

## Merging / Rebasing onto Target Branch

Run these steps in order before integrating upstream changes:

1. **Fetch upstream**
   ```bash
   git fetch origin
   ```

2. **Check divergence** — commits on target not yet on current branch
   ```bash
   git log HEAD..origin/<target> --oneline
   ```

3. **Check overlapping file changes**
   ```bash
   git diff --name-only HEAD...origin/<target>
   ```

4. **Run spec/test impact check** (see below) — do this BEFORE merging or rebasing.

5. **Assess conflict risk** — if divergence or file overlap is significant, ask user whether to merge or rebase.

6. **Stage only** — user commits and pushes manually (GPG constraint).

## Spec & Test Impact Check

Before any merge or rebase, scan for upstream spec/test changes that overlap with current branch work:

```bash
git diff HEAD...origin/<target> -- \
  '*_spec.rb' '*.spec.*' '*.test.*' \
  'spec/' 'test/' '__tests__/' 'tests/'
```

If spec/test files changed upstream:

- **Surface the diff** — show which test files changed and what changed.
- **Flag domain overlap** — identify if changed tests cover the same features or files the current branch modifies.
- **Ask before proceeding** — if current branch implementation might be tested by outdated or newly changed specs, ask user whether to update the branch first or proceed.

Rationale: merging upstream test changes into a branch with new implementation creates false-negative CI — tests pass because they test old behavior. Catching spec drift before merge avoids confusing downstream failures.

## Resolving Conflicts

- If there are merge conflicts, **assess the problem** and ask the user to decide if we should resolve it or not.
- Resolve each conflict by file. **do not resolve everything in one go**.

## Tags

- Follow existing version prefixes (if available).
- Follow versioning format from SemVer (e.g. v1.0.0-beta).

## Pull Request Standards

- **PR size ≤ 200 lines** (unless no reasonable simplification possible).
- **Limited scope:** Only changes for the ticket/story (no unrelated refactoring).
- **Short description** or dot points explaining the changes.
