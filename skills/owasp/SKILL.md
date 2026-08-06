---
name: owasp
description: OWASP Top 10:2025 security risks (A01-A10), input handling, auth, output encoding, and a secure coding checklist. Use when reviewing code for security or running a security audit.
---

# OWASP Security Skill

Apply OWASP thinking for **all features**, especially input handling, authentication, and data
access. Guidance below is organized by the current **OWASP Top 10:2025** category each practice
belongs to.

## OWASP Top 10:2025 — Quick Map

| # | Category | One-line risk |
| --- | -------- | -------------- |
| A01 | Broken Access Control | Users act outside intended permissions (SSRF included here). |
| A02 | Security Misconfiguration | Insecure defaults, verbose errors, missing hardening. |
| A03 | Software Supply Chain Failures | Compromised/unverified dependencies, build, or CI/CD. |
| A04 | Cryptographic Failures | Weak/missing encryption exposes sensitive data. |
| A05 | Injection | Untrusted data reaches an interpreter (SQL, shell, etc.). |
| A06 | Insecure Design | Missing threat modeling; flaw baked in before code exists. |
| A07 | Authentication Failures | Weak credential, session, or identity handling. |
| A08 | Software or Data Integrity Failures | Unsigned/unverified code or data, unsafe deserialization. |
| A09 | Security Logging and Alerting Failures | Attacks go undetected — no logs, no alerts. |
| A10 | Mishandling of Exceptional Conditions | Errors fail open, leak detail, or exhaust resources. |

This is the 8th edition (released January 2026, first major update since 2021). See
[reference.md](reference.md) for the full 2021→2025 rank changes and methodology.

## 10 Core Security Principles

1. **Secure the weakest link** — identify and harden the most vulnerable component first.
2. **Defence in depth** — layer multiple security controls; never rely on a single barrier.
3. **Fail securely** — on error, default to denying access, not granting it.
4. **Least privilege** — grant only the minimum permissions necessary; deny by default.
5. **Compartmentalise** — isolate components so a breach in one doesn't compromise all.
6. **Keep it simple** — complex security is hard to audit and easy to break.
7. **Promote privacy** — collect only necessary data; protect it at every layer.
8. **Hiding secrets is hard** — assume secrets in code will leak; use env vars and secret managers.
9. **Be reluctant to trust** — verify inputs, identities, and systems; trust nothing by default.
10. **Use community resources** — prefer well-tested libraries over custom implementations.

## Access Control & SSRF (A01)

- **Deny by default** — every request requiring auth must be explicitly authorized.
- Apply least necessary privilege per user/role.
- Validate authorization on every request (not just at login).
- Use RBAC (Role-Based Access Control) — cancancan (Rails), Pundit, etc.
- SSRF now falls under this category: allowlist outbound request destinations, never let
  user input control a server-side request's host/URL unvalidated.

## Security Misconfiguration (A02)

- Ship secure defaults; remove default credentials and sample/debug accounts before release.
- Disable verbose errors, stack traces, and directory listings in production.
- Disable unused features, ports, services, and pages — smaller surface, fewer bugs to exploit.
- Apply security headers (`Content-Security-Policy`, `X-Content-Type-Options`,
  `Strict-Transport-Security`) and keep framework/server configs reviewed, not copy-pasted.

## Software Supply Chain (A03)

- Keep dependencies updated; audit regularly (`pip-audit`, `npm audit`, `bundle audit`).
- Prefer well-maintained, widely-used libraries; review new dependencies before adding them.
- Pin dependency versions in production; use a lockfile.
- Generate an SBOM (Software Bill of Materials) for what ships to production.
- Sign build artifacts/commits where feasible; audit CI/CD pipeline permissions — a compromised
  build step is often an easier attack path than the application itself.

## Cryptographic Failures (A04)

- Use TLS/HTTPS everywhere; enforce HSTS (`Strict-Transport-Security`).
- Encrypt sensitive fields at rest (e.g., using `attr_encrypted` in Rails).
- Use a secrets manager (Vault, AWS Secrets Manager, env vars) — never hardcode secrets in source.
- Use `SecureRandom` / `crypto.randomBytes()` for cryptographic randomness — never `Math.random()`.
- Hash passwords with bcrypt (minimum cost factor 12) + unique salts.

## Injection (A05)

- **No input can be trusted**: form data, files, params, cookies, headers, query strings.
- Use Strong Parameters / allowlists to whitelist attributes (Rails, Laravel, etc.).
- Use parameterized queries / prepared statements — never interpolate user input into SQL, shell,
  or XML/XPath strings.
- Use your framework's default HTML escaping to prevent **XSS**; encode output for the correct
  context (HTML, JavaScript, URL, CSS).
- File uploads: whitelist content types, enforce size limits, store outside the web root.

## Insecure Design (A06)

- Threat-model new features before writing code — identify abuse cases, not just happy paths.
- Choose secure-by-default architecture (e.g., deny-by-default authorization, encrypted storage
  as the norm) rather than bolting security on after the fact.
- Complex, security-critical logic gets a design review before implementation starts.

## Authentication Failures (A07)

- Use established auth libraries (Devise for Rails, Passport for Node, etc.) — never roll your own.
- Require or offer MFA for privileged and sensitive accounts.
- Sessions: timeout after a short idle period; regenerate session ID on login.
- Cookies: `Secure`, `HttpOnly`, `SameSite=Lax` (or `Strict`), encrypted/signed.
- CSRF: use your framework's built-in CSRF protection — never disable it.
- Implement account lockout / rate limiting on login endpoints.

## Software / Data Integrity Failures (A08)

- Avoid `pickle` (Python), `eval()`, `exec()`, or `YAML.load` with untrusted data — unsafe
  deserialization lets attacker-controlled data become attacker-controlled code.
- Verify signatures on artifacts and auto-update mechanisms before applying them.
- Ensure CI/CD and deployment pipelines reject unsigned or unverified changes.

## Security Logging & Alerting Failures (A09)

- Log detailed errors to a server-side error tracking service (Sentry, Rollbar, etc.).
- Strip sensitive fields (passwords, tokens, PII, credit card numbers) from logs before sending.
- Use structured logging; do not log request bodies unless you have scrubbed them.
- Logging without alerting is a false sense of safety — wire security-relevant events (failed
  logins, permission denials, rate-limit trips) to active alerts, not just a searchable archive.

## Mishandling of Exceptional Conditions (A10)

- **Fail closed, not open** — an unhandled exception must not default to granting access or
  skipping a check.
- Centralize exception handling; don't let each call site decide its own ad hoc fallback.
- Return **generic error messages** to users — never expose stack traces, internal paths, or
  DB errors.
- Guard against resource exhaustion (unbounded loops, unbounded uploads, unbounded retries).
- Deliberately test failure paths (timeouts, dependency outages) — don't just test the happy path.

## SAST / Code Review Security Checklist

Before merging, verify:

- [ ] No SQL injection vectors (parameterized queries used everywhere). (A05)
- [ ] No XSS vectors (output encoded; no raw `html_safe` / `innerHTML` with user data). (A05)
- [ ] No hardcoded secrets, API keys, or passwords. (A04)
- [ ] No insecure deserialization (`pickle`, `eval`, unsafe YAML). (A08)
- [ ] Authorization checks present on all sensitive endpoints; SSRF-prone requests allowlisted. (A01)
- [ ] No default credentials, debug endpoints, or verbose errors reachable in production. (A02)
- [ ] Error/exception paths fail closed and don't leak stack traces. (A10)
- [ ] Sensitive fields stripped from logs; security events wired to alerts. (A09)
- [ ] File uploads validated for type and size. (A05)
- [ ] CSRF protection enabled; rate limiting applied to auth endpoints. (A07)

**Any code that introduces security flaws will not be approved for merge.**

## See Also

- `debug` — root-cause analysis when a security incident needs investigating, not just prevented.
- `web-audit` — broader site auditing that overlaps with A02/A09 hardening checks.
- `ruby`, `python`, `nodejs` — stack-specific security notes (e.g. framework-provided escaping,
  deserialization gotchas) that build on this skill's generic guidance.
