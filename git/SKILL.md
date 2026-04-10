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
