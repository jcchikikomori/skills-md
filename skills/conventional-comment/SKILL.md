---
name: conventional-comment
description: Write low-noise conventional comments and concise author/reviewer replies. Includes templates for accept+fix, disagree+explain, defer, offline sync, anti-patterns, and escalation. Use when reviewing PRs or responding to review threads.
---

# Conventional Comment Skill (Low-Noise Reviews)

**Spec Reference:** [conventionalcomments.org](https://conventionalcomments.org/)

How to write review comments and replies that keep threads short, scannable, and
actionable — on both sides of the review. The full label/decoration reference
lives in `peer-review`; this skill focuses on low-noise writing, replies, and
keeping the thread from degrading into ping-pong.

## The Core Format (short version)

```
<label> [decorations]: <subject>

[discussion]
```

- **label** — required, sets intent: `praise`, `nitpick`, `suggestion`, `issue`, `todo`, `question`, `thought`, `chore`, `note`.
- **decorations** — optional, parenthesized, comma-separated: `(blocking)`, `(non-blocking)`, `(if-minor)`.
- **subject** — one-line summary of the point.
- **discussion** — short rationale, code, or link. Only when the subject is not enough.

See `peer-review` for the full tables — don't duplicate them here.

## Low-Noise Comment Writing

- One point per comment. A multi-issue comment buries the blocking item.
- Anchor every comment to a specific line/range — "this function" is noise without a location.
- State the *why*, not just the *what*; one sentence of rationale is enough.
- Be explicit about blocking: if you wouldn't block on it, mark `(non-blocking)`.
- Skip nitpicks that aren't worth the author's time. Noise budget is finite.
- Aim for at least one `praise` per review — 100% criticism reads as hostile.

## Reply Templates (author/reviewer)

Keep replies under ~3 lines. The thread is the record; the fix is the proof.
Reply with the same label you were given, and resolve the thread once addressed.

### Accept + fix

```
Fixed in <sha> — thanks for the catch.
```

```
Agreed. Extracted the validation in <sha>; resolves this thread.
```

### Disagree + explain

```
Disagree — <one-line reason> because <evidence>. Kept as-is; happy to
revisit if the constraint changes.
```

### Defer / follow-up

```
Deferring to <ticket/issue> so this doesn't get lost.
```

### Offline sync summary

After a call/chat, close the thread with the outcome:

```
note: Discussed in sync — <decision>. No code change needed; closing.
```

## Anti-Patterns

- **Unlabeled comments** — forces the author to guess intent.
- **Vague wording** — "please improve this" / "maybe refactor" with no concrete ask or rationale.
- **Thread ping-pong** — re-explaining the same point across 6 comments. Move to sync after ~2 rounds.
- **Blocking everything** — dilutes the signal of `(blocking)`.
- **Empty resolutions** — resolving a thread with "ok" or a 👍 leaves no record of what changed.
- **Quote-dumping** — pasting whole functions into a reply instead of a commit link.

## Escalation: When to Move to Sync

Move to a call/chat when:

- The thread reaches ~2 rounds of back-and-forth without convergence.
- The disagreement is about product direction, not code correctness.
- The explanation needs whiteboarding or a long design discussion.

Rules for sync:

- Announce it in the thread: `question: Worth a quick sync — trade-offs summarized above.`
- Keep the thread open until the sync happens.
- After sync, post one summary comment (offline sync template above) and resolve.
- Never leave a thread dangling with "let's sync" as the last word.

## See Also

- `peer-review` — full label/decoration reference and comment-writing format.
- `git` — branch/PR workflow on this machine.
- `claude-standards` — repo conventions review comments should reference.
