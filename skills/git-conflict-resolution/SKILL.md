---
name: git-conflict-resolution
description: Resolve git merge and rebase conflicts. Use when you have WIP changes to stash before pulling, are mid-conflict with <<<< markers, or need fetch+rebase workflow. Covers stash-pull-pop, fetch+rebase, conflict markers, per-file resolution, checkout --ours/--theirs, abort/recovery, and rerere.
---

# Git Conflict Resolution

## Use Case

Use this skill when you have uncommitted work on your branch and need to pull in upstream changes — or when a merge/rebase has already produced conflict markers. This covers both the stash-then-integrate pattern and the cleaner fetch+rebase approach.

For the upstream-integration decision (merge vs. rebase), spec/test impact, and GPG commit rules — see the `git` skill.

---

## Choosing Your Path

| Situation | Approach |
|---|---|
| Clean working tree, no WIP | Fetch + rebase (recommended) |
| WIP changes on branch | Stash workflow below |
| Already mid-merge conflict | Jump to [Resolving Conflicts](#resolving-conflicts) |
| Already mid-rebase conflict | Jump to [Resolving Conflicts](#resolving-conflicts) |

**Rule:** Never rebase commits that have been pushed to a shared/public branch. Rebase is safe only on your own un-pushed local commits.

---

## Stash Workflow (WIP on Branch)

Use when you have uncommitted changes and need to pull in upstream work.

```bash
# 1. Save WIP with a meaningful label
git stash push -m "wip: <short description>"

# 2. Fetch and integrate upstream
git fetch origin
git rebase origin/<target-branch>   # or: git merge origin/<target-branch>

# 3a. No conflicts — restore your work
git stash pop

# 3b. Conflicts from step 2 — resolve first, then restore
#     (see Resolving Conflicts below)
#     After resolving: git add <files> → git rebase --continue
#     Then: git stash pop
```

**If `git stash pop` itself produces conflicts:** the stash entry is NOT dropped — it survives for retry. Resolve the pop conflict, stage the file, then drop the stash manually:

```bash
git add <conflicted-file>
git stash drop
```

---

## Recommended Path (Clean Working Tree)

No WIP? Skip the stash entirely:

```bash
git fetch origin
git rebase origin/<target-branch>
# If conflicts arise → resolve inline → git add → git rebase --continue
```

One-liner shorthand (fetch + rebase combined):

```bash
git pull --rebase origin <target-branch>
```

Use `git merge` instead of `git rebase` when the branch is shared or you want an explicit merge commit in history.

---

## Resolving Conflicts

### 1. Identify conflicted files

```bash
git status
git diff --name-only --diff-filter=U
```

### 2. Understand conflict markers

```
<<<<<<< HEAD
your current changes
=======
incoming changes
>>>>>>> origin/main
```

**Rebase label warning:** During a rebase, `HEAD` is the upstream commit being replayed onto — NOT your branch. "Theirs" (`>>>>>>>`) is actually your own commit. Labels flip from what you might expect.

### 3. Resolve one file at a time

For each conflicted file, pick one of:

| Option | Command |
|---|---|
| Keep your version entirely | `git checkout --ours <file>` |
| Keep incoming version entirely | `git checkout --theirs <file>` |
| Manual edit | Open file, delete all markers, craft correct result |
| Visual tool | `git mergetool` (launches configured tool) |

After resolving each file:

```bash
git add <file>
```

Never run `git commit` mid-rebase. Stage only — rebase manages the commit.

### 4. Continue

```bash
# After rebase conflict
git rebase --continue

# After merge conflict — user commits manually (GPG constraint from git skill)
git status   # confirm no remaining conflicts first
```

### 5. Verify

```bash
git status
git log --oneline -5
```

---

## Abort & Recovery

Something went wrong? Back out cleanly:

```bash
# Abort mid-rebase — returns to pre-rebase state
git rebase --abort

# Abort mid-merge — returns to pre-merge state
git merge --abort
```

**Stash pop conflict recovery:** if pop failed mid-way, stash entry still exists. Clean the file and retry:

```bash
git restore <conflicted-file>   # or: git checkout -- <file>
git stash pop
```

**Ultimate safety net:** `git reflog` shows every HEAD position. Recover any prior state with:

```bash
git reflog
git reset --hard <sha>
```

---

## Tool Setup (Optional)

Configure VS Code as your merge tool (one-time):

```bash
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
```

Alternatives: `vimdiff` (built-in), `meld` (GUI, cross-platform), `kdiff3` (robust 3-way).

Enable rerere — Git remembers your conflict resolutions and reapplies them automatically for repeated patterns:

```bash
git config --global rerere.enabled true
```

---

## See Also

- `git` — fetch workflow, divergence check, spec/test impact, merge vs. rebase decision, GPG commit rules, PR standards
