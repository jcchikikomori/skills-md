---
name: peer-review
description: Write structured, actionable code review comments using the Conventional Comments format (label, decorations, subject, discussion). Use when reviewing PRs/diffs or leaving review feedback.
---

# Peer Review Skill (Conventional Comments)

**Spec Reference:** [conventionalcomments.org](https://conventionalcomments.org/)

Use this format for every review comment so intent (blocking vs. non-blocking,
praise vs. issue) is unambiguous to the author and machine-parseable by tooling.

## Core Format

```
<label> [decorations]: <subject>

[discussion]
```

- **label** — required. Sets the intent of the comment.
- **decorations** — optional, parenthesized, comma-separated (e.g. `(non-blocking)`).
- **subject** — one-line summary of the point.
- **discussion** — optional paragraph with rationale, code, or links.

Example:

```
suggestion (security, non-blocking): Use the framework's DOM sanitizer here.

Raw string concatenation into innerHTML is an XSS vector even if the current
input is trusted — a future caller may not guarantee that.
```

## Labels

| Label | Meaning |
| ------- | --------- |
| `praise` | Highlights something done well. Sincere, specific. |
| `nitpick` | Trivial, preference-based point. Always non-blocking. |
| `suggestion` | Proposes a concrete improvement with rationale. |
| `issue` | A specific problem that needs resolving. |
| `todo` | Small, necessary change — smaller than an `issue`. |
| `question` | Genuine request for clarification, not a disguised complaint. |
| `thought` | An idea sparked by the diff, not a request to act. Non-blocking. |
| `chore` | Required task unrelated to code correctness (e.g. rebase, changelog). |
| `note` | Informational, no action needed. |

Optional extras when more precision helps: `typo`, `polish`, `quibble`.

## Decorations

| Decoration | Meaning |
| ------------ | --------- |
| `(blocking)` | Must be resolved before approval. |
| `(non-blocking)` | Should not prevent merge/approval. |
| `(if-minor)` | Only blocking if the fix turns out to be small. |

Custom decorations (e.g. `(security)`, `(perf)`) are allowed to add context —
they don't change blocking semantics unless combined with `(blocking)`.

## Guidelines

- Label every comment — an unlabeled comment forces the author to guess intent.
- Default to non-blocking. Reserve `(blocking)` for things that must change.
- Aim for at least one `praise` per review — reviews that are 100% criticism read as hostile even when accurate.
- Ask, don't demand: phrase `issue`/`suggestion` comments with the *why*, not just the *what*.
- Keep `nitpick`/`typo`/`polish` visually distinct from `issue` so authors can triage quickly.

## Example Review Comments

```
praise: Clean extraction of the retry logic into its own helper — much easier to test in isolation.

issue (blocking): This query runs inside the loop, causing N+1.
Move the `includes(:author)` up to the initial `Post.where(...)` call.

suggestion (non-blocking): Consider extracting this validation into a shared
concern since `Order` and `Invoice` duplicate it almost verbatim.

question: Is the 30s timeout here intentional, or copied from the other client?
If intentional, a comment explaining the choice would help future readers.
```

## See Also

- `owasp` — for the security rationale behind security-flavored review comments.
- `git` — for review as part of the branch/PR workflow on this machine.
