---
name: rest-api
description: REST API + OpenAPI/Swagger standards - methods (PUT/PATCH/QUERY), status codes, RFC 9457 errors, pagination, idempotency, versioning, breaking changes. Use when adding, changing, or reviewing endpoints or an OpenAPI spec, new or existing.
---

# REST API & OpenAPI Skill

**Spec References:** [RFC 9110 HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110) |
[RFC 10008 QUERY](https://www.rfc-editor.org/rfc/rfc10008) |
[RFC 9457 Problem Details](https://www.rfc-editor.org/rfc/rfc9457) |
[OpenAPI 3.2.1](https://spec.openapis.org/oas/v3.2.1.html) |
[OWASP API Security Top 10 (2023)](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)

This skill defines the contract on the wire and in the OpenAPI document. Framework skills (`fastapi`,
`spring-boot`, `ruby-on-rails`, `nodejs`) define how to implement that contract.

## 1. Pick the Mode First

The rules stay the same in each mode. The priority changes.

| Mode | Priority | First step |
| --- | --- | --- |
| **Maintain** an existing API | Existing contract wins over this skill | Run the convention audit |
| **Extend** with a new feature | Match existing conventions; new endpoints spec-first | Update OpenAPI before code |
| **Greenfield** new system | This skill's defaults | Record conventions and write the spec before code |

### Invariants vs Conventions

**Invariants** apply in every mode to new and touched code:

- The security rules in [section 12](#12-api-specific-security): object-level authorization, no tokens in URLs,
  bounded input.
- GET, HEAD, OPTIONS, and QUERY never change state.
- Error bodies never leak internals (stack traces, SQL, hostnames).
- No new `200` response that carries an error.
- Every new endpoint is in the spec.

**Conventions** follow the existing API in brownfield:

- JSON and path casing, ID format, path-parameter naming, `operationId` style, enum casing.
- Envelope, error format, pagination style, versioning scheme.
- PATCH media type, the `400` vs `422` choice.

Fix an invariant violation now. If the fix breaks clients (for example, moving a token out of the query string),
accept both forms, deprecate the old one on a short timeline, and notify consumers.

### Maintain (Brownfield)

- **Consistency beats correctness for conventions.** A `snake_case` API does not get one `camelCase` endpoint
  because this skill prefers it. Clients and generated SDKs already depend on the current shape.
- **Audit conventions before any change.** Use the checklist in
  [reference.md → Convention Audit](./reference.md#convention-audit).
- **Make additive changes only** in the current version. See [section 9](#9-versioning-evolution--deprecation).
- **New headers on existing endpoints start optional** (`Idempotency-Key`, `If-Match`). Making them required is a
  breaking change.
- **No spec yet?** Generate one from the code first, commit it as a snapshot of reality, then change the code.
  A spec that describes the wished-for API instead of the real one is worse than no spec.
- **Record convention deviations** in a tech-debt ticket. Do not fix them in the current PR.

### Extend (New Feature on an Existing API)

1. No spec yet? Do the Maintain snapshot first, in its own PR.
1. Read the existing spec and 2–3 neighboring endpoints. Copy their conventions.
1. Change the contract before the logic:
   - **Design-first repo:** edit the spec (paths, schemas, examples, error responses).
   - **Code-first repo:** write DTOs, route signatures, and annotations with stub handlers. Regenerate the spec
     and review its diff. Never hand-edit a generated spec.
1. Lint the spec and run a breaking-change diff against the main branch ([section 11](#11-tooling--ci-gates)).
1. Implement the logic. Contract tests validate real responses against the spec.
1. Where existing conventions are silent (for example, the first async endpoint), use this skill's defaults.

### Greenfield (New System)

1. Decide the conventions in [section 2](#2-conventions-to-decide-up-front) and write them down before the first
   endpoint.
1. Design first: write the OpenAPI document and review it like code. Mock it (`prism mock openapi.yaml`) so
   client teams can start in parallel.
1. Encode the conventions as lint rules ([Spectral ruleset](./reference.md#spectral-ruleset)) so CI enforces them,
   not reviewers.
1. Pick one source of truth: generate code from the spec, or generate the spec from code. Never hand-edit both.

## 2. Conventions to Decide Up Front

These are greenfield defaults. In brownfield, the existing answer wins.

| Decision | Default | Why |
| --- | --- | --- |
| Path segments | Plural nouns, lowercase `kebab-case` | Paths are case-sensitive; lowercase removes a class of 404s |
| JSON field casing | `snake_case` or `camelCase`, one per API | Mixed casing breaks generated clients |
| Resource IDs | Opaque strings (UUIDv7, ULID, prefixed `ord_…`) | Slows enumeration, hides row counts; not a BOLA control |
| Timestamps | RFC 3339 in UTC: `2026-09-30T01:41:00Z` | Unambiguous and sortable |
| Money | Integer minor units or decimal string, plus ISO 4217 `currency` | Floats round (`0.1 + 0.2`) |
| Errors | RFC 9457 `application/problem+json` | Standard format with tooling support |
| Pagination | Cursor-based | Stable under inserts; uses an index seek |
| Versioning | Major version in path: `/v1` | Visible, cache-friendly, simple routing |
| Spec | OpenAPI 3.1.x, committed in the repo | Widest tooling support ([section 10](#10-openapi-document-standards)) |

Examples in this skill use `snake_case`.

## 3. Resource & URI Design

- Use nouns, not verbs: `GET /orders`, not `GET /getOrders`.
- Use collection and item paths: `/orders` and `/orders/{order_id}`.
- Nest only for true ownership, max 2 levels: `/customers/{customer_id}/orders`. For deeper paths, promote the
  resource to top level with a filter: `/order-items?order_id=…`.
- No trailing slash. No file extensions (`.json`). Content type comes from `Accept`.
- Name path parameters after the resource (`{order_id}`), not `{id}`. Two `{id}` parameters in one path cannot be
  told apart.
- For actions that do not map to CRUD, pick **one** style per API:
  - Sub-resource noun: `POST /orders/{order_id}/cancellation`
  - Custom method ([Google AIP-136](https://google.aip.dev/136)): `POST /orders/{order_id}:cancel`
- Use the query string for filtering, sorting, paging, and sparse fields. Never put secrets or tokens in it,
  because proxies and access logs record full URLs.

## 4. HTTP Methods

Semantics come from RFC 9110 and RFC 10008. **PUT is not deprecated.** RFC 9110 still defines it. PATCH is the
usual choice for partial updates. PUT stays for full replacement.

| Method | Use for | Safe | Idempotent | Request body | Typical success |
| --- | --- | --- | --- | --- | --- |
| `GET` | Read a resource or collection | Yes | Yes | No | `200`, `304` |
| `HEAD` | Headers only (existence, `ETag`, size) | Yes | Yes | No | `200` |
| `OPTIONS` | Capabilities, CORS preflight | Yes | Yes | No | `204` |
| `QUERY` | Read with a complex query in the body | Yes | Yes | Yes | `200` |
| `POST` | Create in a collection; non-idempotent action | No | No | Yes | `201`, `202`, `200` |
| `PUT` | Full replace; create at a client-chosen URI | No | Yes | Yes | `200`, `204`, `201` |
| `PATCH` | Partial update | No | Depends on the patch format | Yes | `200`, `204` |
| `DELETE` | Remove a resource | No | Yes | No | `204`, `202` |

- **GET never changes state.** Crawlers, link prefetchers, and retry middleware call it freely. Do not send a
  body on GET: RFC 9110 gives it no defined meaning, and intermediaries can drop it.
- **PUT replaces the whole resource.** Omitted fields are cleared or reset to defaults. If clients send only the
  changed fields, the operation is a PATCH. Name it that way.
- **PATCH declares its format.** Use `application/merge-patch+json` (RFC 7396) for field updates, where `null`
  means "remove this field". Use `application/json-patch+json` (RFC 6902) for array operations or `test`
  preconditions. New PATCH endpoints reject other media types with `415`. An existing endpoint that accepts plain
  `application/json` keeps accepting it; add the explicit type alongside. Merge Patch is idempotent. JSON Patch
  `add` to an array is not.
- **DELETE is idempotent in state, not in response.** A repeated DELETE returns `204` (treat as done) or
  `404` / `410` (already gone). Pick one per API and document it. With soft delete, DELETE sets the deletion
  marker, and later reads return `404` (hidden) or `410 Gone` (disclosed).
- **QUERY** (RFC 10008, June 2026) replaces `POST /orders/search` for large or structured queries. It is safe and
  idempotent, and responses are cacheable (the cache key includes the body). Advertise it with the
  `Accept-Query` response header. Check support at every hop first: framework router, reverse proxy, CDN, WAF,
  and client libraries. Until every hop supports it, keep `POST /orders/search` and document it as read-only and
  retry-safe.
- **POST retries can duplicate side effects.** Pair create and charge endpoints with `Idempotency-Key`
  ([section 7](#7-idempotency-retries--async-work)).
- **Wrong method on a known path:** return `405` with an `Allow` header.

## 5. Status Codes

Use the most specific code. Never return `200` with an error body. The full table is in
[reference.md → Status Codes](./reference.md#status-codes).

- **201 Created** — include a `Location` header with the new resource URI. The body is the created resource.
- **202 Accepted** — async work accepted. Include `Location` pointing to a status resource.
- **204 No Content** — no body at all, not even `{}`.
- **400 vs 422** — `400` for malformed syntax and for parameter errors (path, query, or header: wrong type,
  unknown enum value, out of range). `422` for a body that parses but fails schema or business rules. RFC 9110
  defines `422` in terms of request content, so parameter errors fit `400`. Brownfield: keep what the API
  already uses. Do not mix both for the same failure.
- **401 vs 403** — `401` means missing or invalid credentials (send `WWW-Authenticate`). `403` means
  authenticated but not allowed.
- **404 to hide existence** — return `404` instead of `403` when a `403` would confirm that another tenant's
  resource exists.
- **409 Conflict** — the request conflicts with current state (duplicate unique key, invalid state transition).
- **412 / 428** — `If-Match` precondition failed / precondition required but missing
  ([section 8](#8-collections-caching--concurrency)).
- **413 / 414 / 415** — body too large / URI too long / unsupported media type.
- **429 Too Many Requests** — always include `Retry-After`.
- **5xx** — server faults only. A validation error that returns `500` is a bug in the global error handler.

## 6. Error Responses — RFC 9457 Problem Details

RFC 9457 obsoletes RFC 7807. The JSON wire format did not change. Media type: `application/problem+json`.

```json
{
  "type": "https://api.example.com/problems/validation-error",
  "title": "Request validation failed",
  "status": 422,
  "detail": "2 fields failed validation.",
  "instance": "/v1/orders",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "errors": [
    { "pointer": "#/items/0/quantity", "detail": "must be greater than 0" },
    { "pointer": "#/currency", "detail": "must be an ISO 4217 code" }
  ]
}
```

- **`type`** — a stable URI for the problem kind; its documentation lives there. Use `about:blank` when the
  HTTP status says everything.
- **`title`** — the same text for every occurrence of a `type`. **`detail`** — specific to this occurrence.
- **`status`** — must match the HTTP status code.
- **Extensions** (`errors`, `trace_id`) are allowed. Clients must ignore members they do not know.
- **Never leak internals.** No stack traces, SQL, file paths, or internal hostnames. The client gets a generic
  message plus a `trace_id`. The detailed error goes to logs and the error tracker, with passwords and tokens
  stripped.
- **Brownfield with a custom envelope:** keep it in the current version. Adopt RFC 9457 in the next major
  version, or serve it only when the client sends `Accept: application/problem+json`.

## 7. Idempotency, Retries & Async Work

### Idempotency-Key

Use it on POST (and PATCH when needed) for endpoints with side effects: payments, orders, emails.

1. The client generates a unique key (UUID) per logical operation and reuses it on every retry.
1. The server stores key + request fingerprint + response, scoped per client, for a set window (for example, 24 h).
1. Same key, same payload: replay the stored response. Do not run the operation again.
1. Same key, different payload: `422`. Same key while the first request is still in flight: `409`.

**Status:** the IETF draft (`draft-ietf-httpapi-idempotency-key-header-07`) expired in April 2026 without
becoming an RFC. The header is still the de facto convention (Stripe and many payment APIs). Use it, but do not
cite it as a standard.

### Long-Running Operations

- Return `202 Accepted` with `Location: /v1/operations/{operation_id}`.
- The status resource returns `status` (`pending`, `running`, `succeeded`, `failed`). On success it links to the
  result, or answers `303 See Other` with the result URI.
- Offer webhooks for high-volume clients. Sign webhook payloads (HMAC with a timestamp) so receivers can verify
  them and reject replays.

### Retries

- Document which endpoints are **retry-safe**. GET, PUT, DELETE, and QUERY are, by HTTP semantics. POST is
  retry-safe only with `Idempotency-Key`, or when it is a documented read-only search.
- A retried PUT or DELETE sent with `If-Match` can get `412` or `404` when the first attempt succeeded but its
  response was lost. Clients treat that as a possible success and re-read the resource.
- Clients honor `Retry-After` on `429` and `503` and use exponential backoff with jitter.

## 8. Collections, Caching & Concurrency

### Pagination

- **Cursor-based by default.** Request: `?limit=50&cursor=eyJpZCI6…`. Response: `next_cursor` (`null` on the last
  page), or a `Link: <…>; rel="next"` header (RFC 8288).
- The cursor encodes the sort key plus the ID (for `sort=-created_at`: last `created_at` + last `id`).
- **Sign (HMAC) or encrypt the cursor.** Base64 alone is encoding, not opacity: clients can decode and forge it.
  Treat decoded values as untrusted input. Return `400` when a cursor is reused with a different filter or sort.
- `limit` has a documented default and max (for example, default 20, max 100). Reject values over the max with
  `400`. Do not clamp: a clamped value means the server accepted input its own spec forbids. Unbounded lists are
  OWASP API4 (unrestricted resource consumption).
- **Offset pagination** (`?page=3&per_page=20`) only for small datasets or UIs that need page jumps.
  `OFFSET 100000` still scans 100,000 rows.
- Make total counts opt-in (`?include_total=true`). `COUNT(*)` on a large table is expensive.

```json
{
  "data": [{ "id": "ord_01J9ZK3M7Q", "status": "shipped" }],
  "next_cursor": "eyJrIjpbIjIwMjYtMDktMzBUMDE6NDE6MDBaIiwib3JkXzAxSjlaSzNNN1EiXX0.Zk3p9Qx2"
}
```

The keyset query behind that cursor (PostgreSQL row-value syntax). It needs an index on
`(customer_id, created_at DESC, id DESC)`:

```sql
SELECT id, status, created_at
FROM orders
WHERE customer_id = $1
  AND (created_at, id) < ($2, $3) -- values from the verified cursor
ORDER BY created_at DESC, id DESC
LIMIT 21; -- limit + 1: the extra row tells whether a next page exists
```

### Filtering, Sorting, Sparse Fields

- Filter by field name: `?status=shipped&created_after=2026-01-01T00:00:00Z`.
- Sort with a leading `-` for descending: `?sort=-created_at,name`. Allow-list sortable fields and index them.
- Sparse fields: `?fields=id,status,total`.
- Filters too complex for a query string: use QUERY ([section 4](#4-http-methods)).

### Caching and Optimistic Locking

- Send an `ETag` on GET. The client sends `If-None-Match`; answer `304 Not Modified` when nothing changed.
- For optimistic locking, the client sends `If-Match: "<etag>"` on PUT, PATCH, and DELETE. Answer `412` on a
  mismatch. For contended resources, require the header and answer `428` when it is missing.
- **Use strong ETags on resources that accept `If-Match`.** `If-Match` uses strong comparison (RFC 9110), so a
  weak `W/"…"` ETag always fails with `412`. Rails emits weak ETags by default, and nginx gzip turns strong
  ETags into weak ones.
- `Cache-Control: private, no-cache` for per-user data: the client stores it and revalidates with the ETag.
  `no-store` for secrets, PII, and payment data. `public, max-age=…` only for data that is truly public.

## 9. Versioning, Evolution & Deprecation

### Non-Breaking (Ship in the Current Version)

- Add an endpoint, an optional request field, an optional query parameter, or a response field.
- Add an enum value — **only** when the spec tells clients to tolerate unknown values. Otherwise strict generated
  clients fail to deserialize it.

### Breaking (New Major Version or Negotiated Migration)

- Remove or rename a field, endpoint, or parameter.
- Change a field type or format. Make an optional request field required. Add a required parameter or header.
- Tighten validation (lower `maxLength`), change a default, change a status code, change the auth scheme, change
  the pagination style, or change the error format.
- Rename an `operationId`. SDK method names come from it.

Principle: in requests, the server can safely **accept more**. In responses, it can safely **add**. Anything that
narrows accepted input or changes existing output breaks some client. Full matrix:
[reference.md → Breaking-Change Matrix](./reference.md#breaking-change-matrix).

### Rules

- Greenfield: put the major version in the path (`/v1`). Brownfield: keep the existing scheme. Never put minor
  or patch versions in the URL.
- Run old and new major versions side by side during the migration window.
- Document the tolerant-reader rule: clients ignore unknown response fields.

### Deprecation Lifecycle

1. Mark the operation `deprecated: true` in OpenAPI and add a changelog entry.

1. Send these headers on every response from the deprecated endpoint:

   ```http
   Deprecation: @1790812800
   Sunset: Thu, 01 Apr 2027 00:00:00 GMT
   Link: <https://api.example.com/docs/migrations/v2>; rel="deprecation"
   ```

   `Deprecation` (RFC 9745) is a structured-field date: Unix seconds with an `@` prefix. `Sunset` (RFC 8594) is
   an HTTP-date. The Sunset date must not be earlier than the Deprecation date.

1. Monitor traffic to the deprecated endpoint. Contact the consumers that still call it.

1. After the Sunset date, return `410 Gone` with a problem+json body that links to the migration guide.

## 10. OpenAPI Document Standards

### Version Choice

- **Greenfield: OpenAPI 3.1.x.** It uses JSON Schema 2020-12 and has the widest support across linters,
  generators, and doc renderers.
- **Move to 3.2.x** (latest 3.2.1) once every tool in the chain supports it. 3.2 adds native `query` operations,
  `additionalOperations`, the `querystring` parameter location, streaming via `itemSchema` (SSE, JSON Lines),
  and nested tags. Examples: [reference.md → OpenAPI 3.2](./reference.md#openapi-32-additions).
- **Brownfield on 3.0.x:** do not bump the version inside a feature PR. Migrate in a separate change
  ([reference.md → Migration](./reference.md#migration-30--31--32)).

### Structure

- The spec lives in the repo next to the code (`openapi.yaml`, or an `openapi/` folder split with `$ref`).
  It changes in the same PR as the code.
- One source of truth. **Design-first:** the spec drives the code, and tests validate the code against it.
  **Code-first:** annotations generate the spec, and CI commits and diffs the generated file.
- Put reusable parts in `components` (`schemas`, `parameters`, `responses`, `headers`, `securitySchemes`).
  Paths only `$ref` them.
- `servers` lists real base URLs. No `localhost` in a published spec.

### Every Operation Has

- **`operationId`** — unique, stable, `camelCase` verb + noun (`listOrders`, `createOrder`). Brownfield: keep
  the existing style.
- **`summary`** and **`tags`**.
- **Every realistic response** — success plus `400`/`401`/`403`/`404`/`422`/`429` as they apply, each a `$ref`
  to a shared response with the problem schema. A lone `default` response documents nothing.
- **`security`** — or an explicit `security: []` on public endpoints, so "public" is a decision, not an accident.
- **Request and response `examples`.**

### Schemas

- `required` lists on every object. `format` on strings (`uuid`, `date-time`, `email`, `uri`).
- Bounds on every input: `maxLength`, `maximum`, `maxItems`, `pattern`. Validators and fuzzers use them (API4).
- `readOnly` for server-owned fields (`id`, `created_at`), `writeOnly` for secrets (`password`). `readOnly` only
  documents intent: most frameworks do not reject or strip it on input. Enforce it with a separate input schema
  (`OrderCreate`) or a validator set to reject readOnly fields in requests (mass assignment, API3).
- Close request schemas, keep response schemas open. A schema reused in both directions with
  `additionalProperties: false` makes every new response field a breaking change for validating clients.
  Split it (`OrderItemInput` vs `OrderItem`).
- Decide `additionalProperties` on request schemas. `false` rejects typos and unexpected fields.
- Enums are strings with one casing style.
- Nullability is explicit (`type: [string, "null"]` in 3.1). Absent and `null` mean different things, especially
  in Merge Patch.

Full annotated example: [reference.md → Annotated OpenAPI 3.1 Example](./reference.md#annotated-openapi-31-example).

## 11. Tooling & CI Gates

| Gate | Tool | Command |
| --- | --- | --- |
| Style lint | [Spectral](https://github.com/stoplightio/spectral) | `spectral lint openapi.yaml` |
| Structural lint | [Redocly CLI](https://redocly.com/docs/cli) | `redocly lint openapi.yaml` |
| Breaking change | [oasdiff](https://github.com/oasdiff/oasdiff) | `oasdiff breaking base.yaml openapi.yaml --fail-on ERR` |
| Contract / fuzz | [Schemathesis](https://schemathesis.readthedocs.io) | `schemathesis run openapi.yaml --url http://localhost:8000/v1` |
| Mock server | [Prism](https://github.com/stoplightio/prism) | `prism mock openapi.yaml` |

- Contract tests run the committed spec against the running app. Pointing Schemathesis at the app's own
  generated `/openapi.json` only checks the app against itself. Schemathesis 3.x names the flag `--base-url`.
- Base spec for the diff: `git show origin/main:openapi.yaml > base.yaml` for a single file. For a split
  `openapi/` folder, check out main in a `git worktree` and `redocly bundle` both sides first. Copied relative
  `$ref`s would resolve against the wrong tree.
- Keep one spec file per live major version (`openapi.v1.yaml`, `openapi.v2.yaml`). The diff for an existing
  major must be clean. Bumping `info.version` does not excuse a break in `/v1`. Record an accepted exception in
  a reviewed `--err-ignore` file, with the reason.
- CI order: lint, then the breaking-change diff, then contract tests against the running app.
- Before adopting OpenAPI 3.2, confirm each tool in this table supports it.
- Spec generators per framework: [reference.md → Framework Spec Generators](./reference.md#framework-spec-generators).

## 12. API-Specific Security

Generic secure coding lives in the `owasp` skill. This section covers the
[OWASP API Security Top 10 (2023)](https://owasp.org/API-Security/editions/2023/en/0x11-t10/), still the latest
edition.

- **API1 BOLA** — check ownership on every object access (`order.customer_id == current_user.id`), not only a
  role check on the route. Test with two users from different tenants. Opaque IDs are defense in depth, not
  this control.
- **API2 Broken Authentication** — send tokens in `Authorization: Bearer <token>`, never in the query string.
  Use short-lived tokens. Verify the signature against a pinned algorithm allow-list (never trust the token's
  `alg` header, never accept `none`). Validate `iss`, `aud`, and `exp`.
- **API3 BOPLA** — allow-list writable fields (mass assignment) and returned fields (excessive data exposure).
- **API4 Resource Consumption** — max page size, max body size (`413`), rate limits (`429` + `Retry-After`),
  timeouts, and schema bounds.
- **API5 BFLA** — admin endpoints enforce roles on the server. A hidden URL is not access control.
- **API6 Sensitive Business Flows** — limit automated abuse of flows like checkout, sign-up, and referral
  rewards (per-account limits, bot detection), not only raw request rates.
- **API7 SSRF** — validate client-supplied URLs (webhook targets, import URLs) against an allow-list. Block
  private and link-local ranges.
- **API8 Security Misconfiguration** — see `owasp` A02 (verbose errors, default credentials, missing TLS).
- **API9 Inventory** — the spec is the inventory. Every deployed endpoint is in it, and retired versions are
  actually switched off.
- **API10 Unsafe Consumption of APIs** — validate third-party API responses like user input. Set timeouts, and
  do not follow redirects blindly.
- **Rate-limit headers:** `RateLimit` and `RateLimit-Policy` are still an IETF draft (draft-11, May 2026). They
  are optional. `Retry-After` is the standard header to rely on.
- **CORS:** explicit origin allow-list. Never reflect the request `Origin` back together with
  `Access-Control-Allow-Credentials: true`: that trusts every site. (Browsers already reject `*` with credentials.)

## 13. Review Checklist

- [ ] Mode identified (maintain / extend / greenfield); invariants enforced; existing conventions matched.
- [ ] Paths use plural nouns in the API's casing (greenfield: lowercase kebab-case), max 2 nesting levels.
- [ ] Method semantics are correct: GET is safe, PUT replaces fully, PATCH declares its media type.
- [ ] Most specific status code; `201` has `Location`; no `200` with an error body.
- [ ] Errors use `application/problem+json` (or the existing envelope in brownfield) and leak no internals.
- [ ] Collections are paginated with a max `limit`; sort and filter fields are allow-listed and indexed.
- [ ] New endpoints with side effects accept `Idempotency-Key` (optional on existing endpoints).
- [ ] Every handler checks object-level authorization (BOLA).
- [ ] No breaking change without a new major version; `oasdiff breaking` is clean.
- [ ] The spec changed in the same PR: `operationId`, all responses, `security`, examples, input bounds.
- [ ] Spectral / Redocly lint passes; contract tests pass.
- [ ] Deprecated endpoints send `Deprecation`, `Sunset`, and `Link` headers.

## See Also

- `backend` — service layering, database, caching, background jobs.
- `owasp` — generic secure coding checklist (this skill covers API-specific risks only).
- `fastapi`, `spring-boot`, `ruby-on-rails`, `nodejs`, `php` — framework implementation.
- `postgresql`, `mysql`, `oracle-sql` — indexes and query tuning for the keyset query in section 8.
- `peer-review`, `conventional-comment` — writing API review comments.

> Status code table, breaking-change matrix, annotated OpenAPI 3.1 example, Spectral ruleset, 3.0 → 3.1 → 3.2
> migration, framework spec generators, and standards status: [reference.md](./reference.md)
