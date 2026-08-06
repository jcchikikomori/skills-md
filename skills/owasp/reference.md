# OWASP Top 10 Reference

Edition-specific detail that changes with each OWASP release, kept separate from `SKILL.md` so
the actionable guidance doesn't need a rewrite every time OWASP ships a new edition — only this
file does.

## 2021 → 2025 Rank Changes

Source: [owasp.org/Top10/2025](https://owasp.org/Top10/2025/), cross-checked against
[Parasoft](https://www.parasoft.com/blog/owasp-top-10/),
[Fastly](https://www.fastly.com/blog/new-2025-owasp-top-10-list-what-changed-what-you-need-to-know),
and [GitLab](https://about.gitlab.com/blog/2025-owasp-top-10-whats-changed-and-why-it-matters/)
summaries.

| 2025 | Category | 2021 rank | Change |
| --- | -------- | --- | ------ |
| A01 | Broken Access Control | A01 | Unchanged — SSRF (2021 A10) absorbed into this category |
| A02 | Security Misconfiguration | A05 | Up 3 — cloud infrastructure sprawl driving this |
| A03 | Software Supply Chain Failures | A06 (partial) | **New** — expands "Vulnerable and Outdated Components" |
| A04 | Cryptographic Failures | A02 | Down 2 |
| A05 | Injection | A03 | Down 2 — industry progress on input sanitization |
| A06 | Insecure Design | A04 | Down 2 |
| A07 | Authentication Failures | A07 | Unchanged — renamed from "Identification and Authentication Failures" |
| A08 | Software or Data Integrity Failures | A08 | Unchanged — minor rename |
| A09 | Security Logging and Alerting Failures | A09 | Unchanged — renamed from "...and Monitoring Failures" |
| A10 | Mishandling of Exceptional Conditions | — | **New** — replaces SSRF's old slot; #1 emerging concern in community survey |

## Methodology

- ~2.8 million applications analyzed — the largest dataset OWASP has used for this list.
- 589 CWEs mapped from ~175,000 CVE records (up from ~400 CWEs in the 2021 edition), distributed
  across the 10 categories (248 CWEs total mapped in).
- 8 of 10 categories are purely data-driven (frequency/incidence in the tested corpus).
- 2 of 10 categories (A03 and A10) were chosen from a community practitioner survey specifically
  to surface emerging risks not yet measurable at scale from CVE/CWE data alone.

## Deeper Remediation: A03 Software Supply Chain Failures

The two 2025 additions have no prior art in this repo's older checklist, so they get more detail
here than the older, already-familiar categories:

- **SBOM (Software Bill of Materials)**: generate one per release (CycloneDX or SPDX format) so
  a newly-disclosed CVE in a transitive dependency can be checked against what's actually shipped,
  not just what's in the direct manifest.
- **Artifact/commit signing**: sign release artifacts (e.g. Sigstore/cosign for containers, GPG
  for commits/tags) so a compromised build server can't silently inject unsigned changes.
- **CI/CD pipeline permissions**: audit what secrets/scopes each pipeline step actually needs —
  a build step with broad write access to the registry or repo is a bigger blast radius than
  most application-layer vulnerabilities.
- **Dependency pinning**: lockfiles are necessary but not sufficient — pair them with automated
  update PRs (Dependabot/Renovate) reviewed by a human, not silently auto-merged.

## Deeper Remediation: A10 Mishandling of Exceptional Conditions

- **Fail closed by design**: an exception thrown mid-authorization-check must result in "deny,"
  never "the check didn't run, so allow." This usually means wrapping the *default* case in the
  deny branch, not the allow branch.
- **Centralized exception handling**: a single boundary (e.g. framework-level error middleware)
  that decides what's safe to expose, rather than each controller/handler improvising its own
  try/catch with inconsistent leakage.
- **Resource exhaustion**: unbounded loops, unbounded file uploads, unbounded retry/backoff, and
  unbounded queue growth are all "exceptional condition" failures under this category — cap them
  explicitly rather than assuming normal load.
- **Test failure paths deliberately**: chaos-style tests (kill a dependency mid-request, inject a
  timeout) catch fail-open bugs that happy-path tests never will.

## Keeping This Current

OWASP Top 10 editions ship infrequently (2017 → 2021 → 2025 — roughly a 4-year cadence). Before
assuming this file is stale, check <https://owasp.org/Top10/> directly for a newer edition rather
than guessing from secondary sources. If a newer edition exists, update the rank table above and
`SKILL.md`'s Quick Map together — they must stay in sync.
