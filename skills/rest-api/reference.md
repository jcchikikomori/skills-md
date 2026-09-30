# REST API & OpenAPI Reference

Detailed tables, examples, and standards status. See [SKILL.md](./SKILL.md) for the actionable rules.

---

## Convention Audit

Run this audit on a brownfield API before any change. For each row, record the answer plus one example endpoint.

| Convention | Where to look | Possible answers |
| --- | --- | --- |
| JSON field casing | 3 response bodies from different controllers | `camelCase` / `snake_case` / mixed |
| Path casing | Route table, spec `paths` | `kebab-case` / `camelCase` / `snake_case` |
| Path-parameter naming | Route table | `{id}` / `{order_id}` / `{orderId}` |
| ID format | Path parameters, `id` fields | Integer / UUID / prefixed string |
| Enum casing | Status and type fields | `lower_snake` / `SCREAMING_SNAKE` / `camelCase` |
| Null vs absent | Responses with empty optional fields | Field omitted / `null` / empty string |
| `operationId` style | Spec, generated SDK method names | `camelCase` / `snake_case` / generated |
| Error format | One `404` and one validation error | problem+json / custom envelope / plain text |
| Validation status | An invalid POST | `400` / `422` |
| Envelope | One single-item GET and one collection GET | Bare object / `{ "data": … }` |
| Pagination | Any list endpoint | Cursor / offset / page number / none |
| Versioning | Base URL, request headers | `/v1` / header / media type / none |
| Auth | Security middleware, spec `securitySchemes` | Bearer JWT / session cookie / API key |
| Dates | Timestamp fields | RFC 3339 / epoch seconds / local time |
| Update verb | Edit endpoints | PUT / PATCH / both |
| PATCH media type | PATCH request `Content-Type` | `application/json` / merge-patch / JSON Patch |
| Concurrency | `ETag` on GET, `If-Match` on writes | Strong / weak / none; required / optional |
| Idempotency | `Idempotency-Key` on POST | Required / optional / none |
| Spec | Repo, `/openapi.json`, `/docs` | Hand-written / generated / stale / missing |

A "mixed" answer means the API has no convention for that row. Match the closest neighboring endpoint and log
the inconsistency as tech debt.

## Status Codes

| Code | Name | Use when | Required / expected headers |
| --- | --- | --- | --- |
| `200` | OK | Successful read, or update that returns a body | — |
| `201` | Created | Resource created | `Location` |
| `202` | Accepted | Async work accepted, not finished | `Location` (status resource) |
| `204` | No Content | Success, no body | — |
| `206` | Partial Content | Range request served | `Content-Range` |
| `303` | See Other | Async result ready at another URI | `Location` |
| `304` | Not Modified | `If-None-Match` / `If-Modified-Since` matched | `ETag` |
| `308` | Permanent Redirect | Resource moved; method and body must be kept | `Location` |
| `400` | Bad Request | Unparsable request, or invalid path / query / header parameter | — |
| `401` | Unauthorized | Missing or invalid credentials | `WWW-Authenticate` |
| `403` | Forbidden | Authenticated, not allowed | — |
| `404` | Not Found | No resource, or existence must stay hidden | — |
| `405` | Method Not Allowed | Path exists, method does not | `Allow` |
| `406` | Not Acceptable | Cannot produce any type in `Accept` | — |
| `409` | Conflict | State conflict: duplicate key, bad transition, in-flight idempotency key | — |
| `410` | Gone | Removed on purpose (after Sunset, or soft-deleted and disclosed) | — |
| `412` | Precondition Failed | `If-Match` did not match | — |
| `413` | Content Too Large | Body over the limit | — |
| `414` | URI Too Long | Query string over the limit (move the query to QUERY) | — |
| `415` | Unsupported Media Type | `Content-Type` not accepted | `Accept-Patch` (PATCH), `Accept-Query` (QUERY) |
| `422` | Unprocessable Content | Body parses, but fails schema or business rules | — |
| `428` | Precondition Required | Conditional header required but missing | — |
| `429` | Too Many Requests | Rate limit hit | `Retry-After` |
| `500` | Internal Server Error | Unhandled server fault | — |
| `501` | Not Implemented | Method not supported by the server at all | — |
| `502` | Bad Gateway | Upstream returned an invalid response | — |
| `503` | Service Unavailable | Overloaded or in maintenance | `Retry-After` |
| `504` | Gateway Timeout | Upstream did not answer in time | — |

Prefer `308` over `301` for API redirects. Many clients change a `301` POST into a GET.

## HTTP Method Details

### PUT vs PATCH

Current resource:

```json
{ "id": "ord_01J9ZK3M7Q", "status": "pending", "note": "Leave at door", "currency": "AUD" }
```

`PUT` sends the full replacement. An omitted `note` is cleared:

```http
PUT /v1/orders/ord_01J9ZK3M7Q HTTP/1.1
Content-Type: application/json
If-Match: "a1b2c3"

{ "status": "pending", "currency": "AUD" }
```

`PATCH` with JSON Merge Patch (RFC 7396) changes only the named fields. `null` removes a field:

```http
PATCH /v1/orders/ord_01J9ZK3M7Q HTTP/1.1
Content-Type: application/merge-patch+json
If-Match: "a1b2c3"

{ "note": null }
```

`PATCH` with JSON Patch (RFC 6902) runs ordered operations. A failed `test` aborts the whole patch:

```http
PATCH /v1/orders/ord_01J9ZK3M7Q HTTP/1.1
Content-Type: application/json-patch+json

[
  { "op": "test", "path": "/status", "value": "pending" },
  { "op": "replace", "path": "/status", "value": "cancelled" }
]
```

Advertise the accepted patch formats with `Accept-Patch: application/merge-patch+json` on `OPTIONS` and `415`
responses.

### QUERY (RFC 10008)

```http
QUERY /v1/orders HTTP/1.1
Content-Type: application/json
Accept: application/json

{
  "status": ["shipped", "delivered"],
  "total_gte": 10000,
  "sort": ["-created_at"],
  "limit": 50
}
```

- **Safe and idempotent.** Clients, proxies, and retry middleware can repeat it.
- **Cacheable.** The cache key must include the request body and related metadata.
- **`Accept-Query`** response header lists the query media types the resource accepts.
- **`Location`** in the response can point to a URI that repeats this query with a plain `GET`.
  **`Content-Location`** can point to the stored result of this specific run.
- **`415`** when the query media type is not supported.

Fallback while any hop in the chain lacks QUERY support: `POST /v1/orders/search` with the same body, documented
as safe and idempotent.

### DELETE and Soft Delete

- `DELETE /v1/orders/{order_id}` sets `deleted_at`. The row stays for audit and recovery.
- Later `GET`, `PUT`, and `PATCH` on that ID return `404` (hidden) or `410` (disclosed). Pick one per API.
- A repeated `DELETE` follows the API's documented choice: `204`, `404`, or `410`.
- Collections exclude soft-deleted rows by default. Admin tooling can opt in with `?include_deleted=true`.
- A restore operation is a state change: `POST /v1/orders/{order_id}/restoration` or `POST …:restore`.

## Breaking-Change Matrix

Rule of thumb: in **requests**, the server can safely accept more. In **responses**, the server can safely add.
Anything that narrows accepted input or changes existing output breaks some client.

| Change | In request | In response |
| --- | --- | --- |
| Add optional field / param | Safe | Safe (tolerant readers ignore it) |
| Add required field / param / header | **Breaking** | Safe |
| Remove field | **Breaking** if `additionalProperties: false` | **Breaking** |
| Rename field | **Breaking** | **Breaking** |
| Widen type (`integer` → `number`) | Safe | **Breaking** |
| Narrow type (`number` → `integer`) | **Breaking** | Safe |
| Add enum value | Safe | **Breaking** unless clients tolerate unknown values |
| Remove enum value | **Breaking** | Safe |
| Tighten validation (`maxLength` 255 → 100) | **Breaking** | — |
| Loosen validation | Safe | — |
| Optional → required | **Breaking** | Safe |
| Required → optional | Safe | **Breaking** (clients expect the field) |
| Change default value | **Breaking** (behavior changes silently) | — |
| Change success or error status code | — | **Breaking** |
| Change error body format | — | **Breaking** |
| Change pagination style | **Breaking** | **Breaking** |
| Change auth scheme or required scopes | **Breaking** | — |
| Rename `operationId` | **Breaking** for generated SDKs | — |
| Remove endpoint or method | **Breaking** | — |

`oasdiff breaking` detects most rows automatically. It cannot detect behavior changes behind an unchanged
schema, such as a new default applied in code. Reviewers still check those.

## Annotated OpenAPI 3.1 Example

A compact Orders API that applies the SKILL.md rules: cursor pagination, idempotent create, merge-patch update
with optimistic locking, RFC 9457 errors, input bounds, and read/write schema split. It passes `spectral lint`
with the [ruleset below](#spectral-ruleset) and `redocly lint`. Redocly only warns `no-server-example.com`,
because the `servers` are placeholders.

```yaml
openapi: 3.1.1
info:
  title: Orders API
  version: 1.4.0 # contract version; bump on every contract change
  description: >-
    Order management. Clients must ignore unknown response fields and
    tolerate unknown enum values.
  contact:
    name: Orders team
    url: https://developer.example.com/support
  license:
    name: Proprietary
    url: https://developer.example.com/terms
servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api.staging.example.com/v1
    description: Staging
security:
  - bearerAuth: [] # default for every operation
tags:
  - name: orders
    description: Order lifecycle.
paths:
  /orders:
    get:
      operationId: listOrders
      summary: List orders
      description: Returns orders for the current customer, newest first by default.
      tags: [orders]
      parameters:
        - $ref: '#/components/parameters/Limit'
        - $ref: '#/components/parameters/Cursor'
        - name: status
          in: query
          description: Filter by order status.
          schema:
            $ref: '#/components/schemas/OrderStatus'
        - name: sort
          in: query
          description: Sort field. Prefix `-` for descending.
          schema:
            type: string
            enum: [created_at, -created_at, total, -total] # allow-listed and indexed
            default: -created_at
      responses:
        '200':
          description: One page of orders.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderList'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '429':
          $ref: '#/components/responses/TooManyRequests'
    post:
      operationId: createOrder
      summary: Create an order
      description: Retry with the same Idempotency-Key to avoid duplicate orders.
      tags: [orders]
      parameters:
        - $ref: '#/components/parameters/IdempotencyKey'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/OrderCreate'
            examples:
              two_items:
                summary: Order with two line items
                value:
                  currency: AUD
                  items:
                    - sku: SKU-1001
                      quantity: 2
                    - sku: SKU-2002
                      quantity: 1
      responses:
        '201':
          description: Order created.
          headers:
            Location:
              $ref: '#/components/headers/Location'
            ETag:
              $ref: '#/components/headers/ETag'
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Order'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '409':
          $ref: '#/components/responses/Conflict'
        '422':
          $ref: '#/components/responses/ValidationError'
        '429':
          $ref: '#/components/responses/TooManyRequests'
  /orders/{order_id}:
    parameters:
      - $ref: '#/components/parameters/OrderId'
    get:
      operationId: getOrder
      summary: Get an order
      description: Send If-None-Match with a stored ETag to get 304 when unchanged.
      tags: [orders]
      responses:
        '200':
          description: The order.
          headers:
            ETag:
              $ref: '#/components/headers/ETag'
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Order'
        '304':
          description: Not modified since the ETag in If-None-Match.
        '401':
          $ref: '#/components/responses/Unauthorized'
        '404':
          $ref: '#/components/responses/NotFound'
    patch:
      operationId: updateOrder
      summary: Update an order
      description: JSON Merge Patch. Send `null` to clear a field. If-Match is required.
      tags: [orders]
      parameters:
        - $ref: '#/components/parameters/IfMatch'
      requestBody:
        required: true
        content:
          application/merge-patch+json:
            schema:
              $ref: '#/components/schemas/OrderPatch'
            examples:
              clear_note:
                summary: Remove the delivery note
                value:
                  note: null
      responses:
        '200':
          description: The updated order.
          headers:
            ETag:
              $ref: '#/components/headers/ETag'
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Order'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '404':
          $ref: '#/components/responses/NotFound'
        '412':
          $ref: '#/components/responses/PreconditionFailed'
        '422':
          $ref: '#/components/responses/ValidationError'
        '428':
          $ref: '#/components/responses/PreconditionRequired'
    delete:
      operationId: deleteOrder
      summary: Delete an order
      description: Soft delete. Later reads of this ID return 404.
      tags: [orders]
      parameters:
        - $ref: '#/components/parameters/IfMatch'
      responses:
        '204':
          description: Order deleted.
        '401':
          $ref: '#/components/responses/Unauthorized'
        '404':
          $ref: '#/components/responses/NotFound'
        '412':
          $ref: '#/components/responses/PreconditionFailed'
        '428':
          $ref: '#/components/responses/PreconditionRequired'
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  parameters:
    OrderId:
      name: order_id
      in: path
      required: true
      description: Opaque order ID.
      schema:
        type: string
        pattern: '^ord_[0-9A-Za-z]{10,32}$'
      example: ord_01J9ZK3M7Q
    Limit:
      name: limit
      in: query
      description: Page size.
      schema:
        type: integer
        minimum: 1
        maximum: 100 # hard cap (OWASP API4)
        default: 20
    Cursor:
      name: cursor
      in: query
      description: Opaque cursor from `next_cursor`. Do not build or parse it.
      schema:
        type: string
        maxLength: 512
    IdempotencyKey:
      name: Idempotency-Key
      in: header
      required: true # greenfield; start optional on existing endpoints
      description: Unique per logical operation. Reuse the same key on retry.
      schema:
        type: string
        format: uuid
    IfMatch:
      name: If-Match
      in: header
      required: true # greenfield; start optional on existing endpoints
      description: ETag from the last read of this order.
      schema:
        type: string
        maxLength: 128
  headers:
    ETag:
      description: Version tag of the representation.
      schema:
        type: string
    Location:
      description: URI of the created resource.
      schema:
        type: string
        format: uri
    RetryAfter:
      description: Seconds to wait before retrying.
      schema:
        type: integer
        minimum: 0
    WWWAuthenticate:
      description: Authentication challenge.
      schema:
        type: string
  schemas:
    OrderStatus:
      type: string
      enum: [pending, paid, shipped, cancelled]
    Money:
      type: object
      required: [amount, currency]
      properties:
        amount:
          type: integer
          description: Amount in minor units (cents).
          minimum: 0
          maximum: 100000000
        currency:
          type: string
          description: ISO 4217 code.
          pattern: '^[A-Z]{3}$'
    OrderItemInput:
      type: object
      required: [sku, quantity]
      additionalProperties: false # closed: request schema
      properties:
        sku:
          type: string
          maxLength: 64
        quantity:
          type: integer
          minimum: 1
          maximum: 1000
    OrderItem:
      type: object # open: response schema can gain fields
      required: [sku, quantity]
      properties:
        sku:
          type: string
        quantity:
          type: integer
        unit_price:
          $ref: '#/components/schemas/Money'
    OrderCreate:
      type: object
      required: [currency, items]
      additionalProperties: false # rejects unknown fields (mass assignment)
      properties:
        currency:
          type: string
          pattern: '^[A-Z]{3}$'
        note:
          type: string
          maxLength: 500
        items:
          type: array
          minItems: 1
          maxItems: 100
          items:
            $ref: '#/components/schemas/OrderItemInput'
    OrderPatch:
      type: object
      additionalProperties: false
      minProperties: 1
      properties:
        note:
          type: [string, 'null'] # null clears the field (Merge Patch)
          maxLength: 500
        status:
          type: string
          enum: [cancelled] # only transition a client may request
    Order:
      type: object
      required: [id, status, currency, items, total, created_at, updated_at]
      properties:
        id:
          type: string
          readOnly: true
          example: ord_01J9ZK3M7Q
        status:
          $ref: '#/components/schemas/OrderStatus'
        currency:
          type: string
          pattern: '^[A-Z]{3}$'
        note:
          type: [string, 'null']
          maxLength: 500
        items:
          type: array
          maxItems: 100
          items:
            $ref: '#/components/schemas/OrderItem'
        total:
          allOf:
            - $ref: '#/components/schemas/Money'
          readOnly: true
        created_at:
          type: string
          format: date-time
          readOnly: true
        updated_at:
          type: string
          format: date-time
          readOnly: true
    OrderList:
      type: object
      required: [data, next_cursor]
      properties:
        data:
          type: array
          maxItems: 100
          items:
            $ref: '#/components/schemas/Order'
        next_cursor:
          type: [string, 'null']
          description: Cursor for the next page. `null` on the last page.
    Problem:
      type: object
      description: RFC 9457 Problem Details.
      required: [type, title, status]
      properties:
        type:
          type: string
          format: uri-reference
          default: about:blank
        title:
          type: string
        status:
          type: integer
          minimum: 400
          maximum: 599
        detail:
          type: string
        instance:
          type: string
          format: uri-reference
        trace_id:
          type: string
          description: Correlates this error with server logs.
    ValidationProblem:
      allOf:
        - $ref: '#/components/schemas/Problem'
        - type: object
          required: [errors]
          properties:
            errors:
              type: array
              items:
                type: object
                required: [pointer, detail]
                properties:
                  pointer:
                    type: string
                    description: JSON Pointer to the invalid member.
                  detail:
                    type: string
  responses:
    BadRequest:
      description: The request could not be parsed.
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Problem'
    Unauthorized:
      description: Missing or invalid credentials.
      headers:
        WWW-Authenticate:
          $ref: '#/components/headers/WWWAuthenticate'
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Problem'
    NotFound:
      description: No such resource, or not visible to this caller.
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Problem'
    Conflict:
      description: Conflicts with current state, or the idempotency key is in use.
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Problem'
    ValidationError:
      description: The request failed validation.
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ValidationProblem'
          examples:
            bad_quantity:
              summary: Invalid line item
              value:
                type: https://api.example.com/problems/validation-error
                title: Request validation failed
                status: 422
                detail: 1 field failed validation.
                instance: /v1/orders
                trace_id: 4bf92f3577b34da6a3ce929d0e0e4736
                errors:
                  - pointer: '#/items/0/quantity'
                    detail: must be greater than 0
    PreconditionFailed:
      description: If-Match does not match the current ETag.
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Problem'
    PreconditionRequired:
      description: If-Match is required for this operation.
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Problem'
    TooManyRequests:
      description: Rate limit exceeded.
      headers:
        Retry-After:
          $ref: '#/components/headers/RetryAfter'
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Problem'
```

## OpenAPI 3.2 Additions

OpenAPI 3.2.0 shipped in September 2025. 3.2.1 is the current patch release. It keeps JSON Schema 2020-12 from
3.1, so most 3.1 documents only need the version string changed.

| Feature | Keyword | Use for |
| --- | --- | --- |
| QUERY method | `query` on the Path Item | RFC 10008 operations |
| Other methods | `additionalOperations` (map keyed by method name) | Non-standard verbs |
| Whole query string as one schema | Parameter `in: querystring` | Complex filter objects |
| Streaming responses | `itemSchema` on the Media Type | SSE (`text/event-stream`), JSON Lines, `json-seq` |
| Nested tags | Tag `summary`, `parent`, `kind` (`nav`, `badge`, `audience`) | Doc navigation |
| OAuth device flow | `deviceAuthorization` flow, `oauth2MetadataUrl` | TVs, CLIs, limited-input devices |
| Document identity | `$self` | Base URI for resolving `$ref` |

```yaml
openapi: 3.2.0 # spec format version; the API contract version below is unchanged
info:
  title: Orders API
  version: 1.4.0
  license:
    name: Proprietary
    url: https://developer.example.com/terms
servers:
  - url: https://api.example.com/v1
security:
  - bearerAuth: []
tags:
  - name: orders
    summary: Orders
    description: Order lifecycle.
    kind: nav
  - name: order-events
    summary: Order events
    description: Real-time order status changes.
    parent: orders # nested under "orders" in docs navigation
    kind: nav
paths:
  /orders:
    query: # RFC 10008 QUERY operation
      operationId: queryOrders
      summary: Search orders with a structured query
      tags: [orders]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/OrderQuery'
      responses:
        '200':
          description: Matching orders.
          content:
            application/json:
              schema:
                type: object
                required: [data, next_cursor]
                properties:
                  data:
                    type: array
                    maxItems: 100
                    items:
                      type: object
                  next_cursor:
                    type: [string, 'null']
        '415':
          $ref: '#/components/responses/Problem'
        '422':
          $ref: '#/components/responses/Problem'
  /orders/events:
    get:
      operationId: streamOrderEvents
      summary: Stream order status changes
      tags: [order-events]
      responses:
        '200':
          description: Server-Sent Events stream.
          content:
            text/event-stream:
              itemSchema: # describes one event, not the whole stream
                type: object
                required: [data]
                properties:
                  event:
                    type: string
                  data:
                    type: string
                    contentMediaType: application/json
                  id:
                    type: string
        '401':
          $ref: '#/components/responses/Problem'
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
  schemas:
    OrderQuery:
      type: object
      additionalProperties: false
      properties:
        status:
          type: array
          maxItems: 10
          items:
            type: string
            enum: [pending, paid, shipped, cancelled]
        total_gte:
          type: integer
          minimum: 0
        limit:
          type: integer
          minimum: 1
          maximum: 100
  responses:
    Problem:
      description: RFC 9457 problem details.
      content:
        application/problem+json:
          schema:
            type: object
            required: [type, title, status]
            properties:
              type:
                type: string
              title:
                type: string
              status:
                type: integer
```

## Migration: 3.0 → 3.1 → 3.2

Do each migration as its own PR, then run the breaking-change diff. A correct migration shows no breaking changes.

### 3.0 → 3.1

| 3.0 | 3.1 |
| --- | --- |
| `openapi: 3.0.3` | `openapi: 3.1.1` |
| `nullable: true` | `type: [string, 'null']` |
| `exclusiveMinimum: true` with `minimum: 0` | `exclusiveMinimum: 0` |
| `example:` inside a Schema | `examples: [ … ]` (array) inside a Schema |
| `type: string`, `format: binary` (file body) | Omit the schema, or `contentMediaType: application/octet-stream` |
| `type: string`, `format: byte` | `type: string`, `contentEncoding: base64` |
| Siblings next to `$ref` ignored | `$ref` may carry `summary` and `description` |
| No webhooks | Top-level `webhooks` |
| `paths` required | `paths` optional (webhook-only or component-only documents) |

### 3.1 → 3.2

- Change `openapi: 3.1.x` to `openapi: 3.2.0` (or `3.2.1`).
- Where the stack supports QUERY, add `query` operations **alongside** `POST /search`. Then deprecate the POST
  with the SKILL.md section 9 lifecycle. Removing it in the same change is breaking.
- Replace vendor streaming extensions (`x-…`) with `itemSchema`.
- Bumping the `openapi` format version is not an API major version. Keep `info.version` and `servers` as they are.
- Everything else is additive. Adopt features one at a time.

### Swagger 2.0 → 3.x

Convert with [swagger2openapi](https://github.com/Mermade/oas-kit) (outputs 3.0.x), then apply the 3.0 → 3.1 table.

## Spectral Ruleset

Save as `.spectral.yaml` next to the spec. It extends the built-in OpenAPI rules and encodes the SKILL.md
conventions, so CI rejects violations instead of reviewers.

```yaml
extends: ["spectral:oas"]
rules:
  operation-operationId: error
  operation-tags: error
  operation-tag-defined: error

  paths-kebab-case:
    description: Path segments lowercase kebab-case, parameters snake_case, optional AIP-136 :customMethod.
    severity: error
    given: $.paths[*]~
    then:
      function: pattern
      functionOptions:
        match: "^(/([a-z0-9]+(-[a-z0-9]+)*|\\{[a-z0-9_]+\\})(:[a-z][a-zA-Z0-9]*)?)+$"

  operation-id-camel-case:
    description: operationId must be camelCase.
    severity: error
    given: $.paths[*][get,put,post,patch,delete,query].operationId
    then:
      function: casing
      functionOptions:
        type: camel

  error-responses-problem-json:
    description: 4xx and 5xx responses must use application/problem+json.
    severity: error
    given: $.components.responses[*].content
    then:
      field: application/problem+json
      function: truthy

  collection-limit-has-maximum:
    description: The limit parameter must declare a maximum (OWASP API4).
    severity: error
    given: $.components.parameters[?(@.name == 'limit')].schema
    then:
      field: maximum
      function: truthy

  string-bounds:
    description: Request string properties need maxLength, pattern, enum, or format (OWASP API4).
    severity: warn
    given: $.components.schemas[?(@property.match(/(Create|Patch|Update|Input|Query|Request)$/))].properties[?(@.type == 'string' || @.type[0] == 'string')]
    then:
      function: schema
      functionOptions:
        schema:
          anyOf:
            - required: [maxLength]
            - required: [pattern]
            - required: [enum]
            - required: [format]
```

- The error-response rule checks shared `components.responses`. Pair it with the SKILL.md rule that operations
  only `$ref` shared error responses, so every error goes through one checked place.
- `string-bounds` matches request schemas by name suffix and catches nullable strings (`type: [string, 'null']`)
  when `string` comes first. Rename the suffix list to fit the API's schema naming.
- **Brownfield:** set the casing and problem-json rules from the convention audit results, or turn them off.
  Enforcing greenfield defaults on an existing API forces breaking renames.

## Framework Spec Generators

| Stack | Tool | Where the spec comes from | Notes |
| --- | --- | --- | --- |
| FastAPI | Built in | `GET /openapi.json` | Emits OpenAPI 3.1 since FastAPI 0.99 |
| Spring Boot | [springdoc-openapi](https://springdoc.org) | `GET /v3/api-docs` | Set `springdoc.api-docs.version=openapi_3_1` explicitly |
| Ruby on Rails | [rswag](https://github.com/rswag/rswag) | `rake rswag:specs:swaggerize` | Spec generated from RSpec request specs |
| NestJS | [@nestjs/swagger](https://docs.nestjs.com/openapi/introduction) | `SwaggerModule.createDocument` | Decorators on DTOs and controllers |
| Express / Node.js | [zod-to-openapi](https://github.com/asteasolutions/zod-to-openapi) | Registry from Zod schemas | Same Zod schemas validate requests |
| Laravel | [Scramble](https://scramble.dedoc.co) | `GET /docs/api.json` | Infers from FormRequests and resources |

Code-first rule: commit the generated spec and fail CI when the committed file differs from a fresh generation.
Without that check, the published spec drifts from the running code.

## Standards Status

Status checked September 2026.

| Standard | Status | Covers |
| --- | --- | --- |
| [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110) HTTP Semantics | Internet Standard (June 2022) | Methods incl. PUT and PATCH semantics, status codes, conditional requests |
| [RFC 10008](https://www.rfc-editor.org/rfc/rfc10008) QUERY Method | Proposed Standard (June 2026) | Safe, idempotent method with a body |
| [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457) Problem Details | Proposed Standard (July 2023); obsoletes RFC 7807 | `application/problem+json` |
| [RFC 9745](https://www.rfc-editor.org/rfc/rfc9745) Deprecation header | Proposed Standard (March 2025) | `Deprecation` field, `deprecation` link relation |
| [RFC 8594](https://www.rfc-editor.org/rfc/rfc8594) Sunset header | Informational (May 2019) | `Sunset` field |
| [RFC 8288](https://www.rfc-editor.org/rfc/rfc8288) Web Linking | Proposed Standard | `Link` header, `rel="next"` |
| [RFC 7396](https://www.rfc-editor.org/rfc/rfc7396) JSON Merge Patch | Proposed Standard | `application/merge-patch+json` |
| [RFC 6902](https://www.rfc-editor.org/rfc/rfc6902) JSON Patch | Proposed Standard | `application/json-patch+json` |
| [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339) Date and Time | Proposed Standard | Timestamp format |
| Idempotency-Key header | Expired draft-07 (April 2026) | De facto convention only |
| RateLimit / RateLimit-Policy headers | Internet-Draft 11 (May 2026) | Optional; use `Retry-After` |
| [OpenAPI 3.2.1](https://spec.openapis.org/oas/v3.2.1.html) | Current (3.2.0 released September 2025) | API description format |
| [OWASP API Security Top 10](https://owasp.org/API-Security/editions/2023/en/0x11-t10/) | 2023 edition (latest) | API-specific risks |

Re-check the draft rows before citing them. Drafts can change syntax or expire.
