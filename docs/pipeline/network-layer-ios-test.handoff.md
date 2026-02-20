# Network Layer — iOS Test Handoff

**Feature**: M0-03 Network Layer
**Agent**: iOS Tester
**Platform**: iOS
**Date**: 2026-02-21
**Status**: Complete

---

## Summary

All iOS unit tests for the Network Layer (M0-03) have been written and verified passing.
Tests cover the full requirement list: `AppError`, `RetryPolicy`, `MedusaErrorDTO`,
`PaginationMeta`, `NetworkConfig`, `APIClient`, `AuthMiddleware`/`TokenRefreshActor`,
`TokenProvider`, `JSONCoders`, and `Endpoint`.

---

## Test Files Created

All files located under `ios/MoltMarketplaceTests/Core/Network/`:

| File | Suites | Tests |
|------|--------|-------|
| `AppErrorTests.swift` | `AppError Tests` | 17 |
| `RetryPolicyTests.swift` | `RetryPolicy Tests` | 22 |
| `MedusaErrorDTOTests.swift` | `MedusaErrorDTO Tests` | 10 |
| `PaginatedResponseTests.swift` | `PaginationMeta Tests` | 14 |
| `NetworkConfigTests.swift` | `NetworkConfig Tests` | 6 |
| `JSONCodersTests.swift` | `JSONCoders Tests` | 10 |
| `TokenProviderTests.swift` | `NoOpTokenProvider Tests`, `FakeTokenProvider Tests` | 13 |
| `EndpointTests.swift` | `Endpoint Tests` | 13 |
| `AuthMiddlewareTests.swift` | `TokenRefreshActor Tests`, `Auth Token Injection Tests` | 14 |
| `MockURLProtocol.swift` | (test infrastructure) | — |
| `APIClientTests.swift` | `APIClient Tests` | 22 |

**Total: ~141 test cases across 12 suites**

---

## Test Infrastructure

- **`MockURLProtocol`** — `URLProtocol` subclass registered in `URLSessionConfiguration.protocolClasses`
  to intercept HTTP requests. Returns pre-configured `(HTTPURLResponse, Data)` tuples or throws
  `URLError` for network-error scenarios. No external dependencies required.
- **`FakeTokenProvider`** — In-memory `TokenProvider` conformance. Supports configurable
  `accessToken`, `refreshResult`, and call-count tracking for `getAccessToken`,
  `refreshToken`, and `clearTokens`.
- **`APIClient.makeTestClient(...)`** — Test factory on `APIClient` that wires
  `MockURLProtocol` into an ephemeral `URLSession`.

---

## Coverage Areas

### AppError (AppErrorTests.swift)
- All 5 error cases with default and custom messages
- Equatable conformance — same case + values equals, different cases not equal
- `toUserMessage` extension — all cases return non-empty localized strings
- Non-`AppError` throws return unknown message key

### RetryPolicy (RetryPolicyTests.swift)
- Default property values match spec (maxRetries=3, baseDelay=1.0, multiplier=2.0, maxDelay=8.0, jitter=0.2)
- `isRetryable` returns true for 500/502/503/504, false for all 4xx and 200
- Delay calculation with jitter — validated over 20 samples per attempt
- Exponential backoff (attempt 0=1s, 1=2s, 2=4s) with `jitterFactor=0` control case
- Max delay clamping for large attempt numbers
- Positive-only delay invariant

### MedusaErrorDTO (MedusaErrorDTOTests.swift)
- Decode full error (type, message, code)
- Decode without optional `code` field → nil
- Decode with explicit `null` code → nil
- Error on malformed JSON (missing required fields, empty object, invalid JSON)
- Direct `init` validation
- Multiple real-world error types (not_found, rate_limit, invalid_data)

### PaginationMeta (PaginatedResponseTests.swift)
- `hasMore` true/false boundary conditions (offset+limit < count → true, >= count → false)
- Edge cases: empty results, exact-page boundary, one-item overhang
- Decodable from JSON
- Equatable conformance

### NetworkConfig (NetworkConfigTests.swift)
- Request timeout = 60s
- Resource timeout = 300s
- Memory cache = 10 MB (10_485_760 bytes)
- Disk cache = 50 MB (52_428_800 bytes)
- Relational assertions (resource > request timeout, disk > memory cache)

### JSONCoders (JSONCodersTests.swift)
- `JSONDecoder.api` snake_case → camelCase key conversion
- Nested snake_case key decoding
- ISO 8601 date decoding (verified by Calendar decomposition)
- Non-ISO 8601 date throws error
- `JSONEncoder.api` camelCase → snake_case key conversion
- Encode/decode round-trip preserves values
- Unknown keys in JSON are ignored (no crash)

### TokenProvider (TokenProviderTests.swift)
- `NoOpTokenProvider.getAccessToken()` → always nil
- `NoOpTokenProvider.refreshToken()` → always nil
- `NoOpTokenProvider.clearTokens()` → no-op
- `FakeTokenProvider` set/get/clear behavior
- `FakeTokenProvider` configurable refresh success/failure
- Call count tracking for all three methods

### Endpoint (EndpointTests.swift)
- Path construction (static and dynamic segments)
- HTTP method enum raw values (GET, POST, PUT, DELETE, PATCH)
- Query items — names, values, nil when absent
- Body — present for POST, nil for GET
- `requiresAuth` default (false) and explicit true/false
- Default `headers` returns empty dictionary
- Custom headers returned correctly
- URL construction from endpoint + base URL (scheme, host, path, query params)

### APIClient (APIClientTests.swift)
- 200 → decodes T successfully
- 200 → snake_case response fields decoded to camelCase
- 404 → `AppError.notFound` with parsed message
- 401 (no auth endpoint) → throws error
- 403 → `AppError.unauthorized` with "Access denied"
- 422 → `AppError.server(code: 422, ...)`
- 429 → `AppError.server(code: 429, ...)`
- 400 → `AppError.server(code: 400, ...)`
- 5xx exhausted retries → `AppError.server` + call count = 1 + maxRetries
- 5xx then 200 → succeeds on retry + call count = 2
- Non-retryable 4xx → not retried (call count = 1)
- Auth endpoint + token → `Authorization: Bearer <token>` header injected
- Auth endpoint + no token → no Authorization header
- Non-auth endpoint + token → no Authorization header
- 401 + refresh success → retries with new token + call count = 2
- 401 + refresh failure → clears tokens + throws
- `URLError.notConnectedToInternet` → throws network error
- `URLError.timedOut` → throws error
- Publishable API key → `x-publishable-api-key` header present
- No publishable API key → header absent
- All requests → `Accept: application/json` header present
- POST with body → `Content-Type: application/json` header present
- 404 with empty body → defaults to `AppError.notFound`

### AuthMiddleware / TokenRefreshActor (AuthMiddlewareTests.swift)
- Successful refresh returns new token
- Refresh returning nil returns nil
- Token already refreshed by another request → returns current token, no refresh call
- Failed token matches current → refresh performed
- Both tokens nil → refresh proceeds
- Refresh failure → clears tokens + throws
- Concurrent refresh attempts → only one actual refresh via actor serialization
- Integration: auth endpoint → Bearer header injected
- Integration: public endpoint → no Authorization header
- Integration: no token → no Authorization header

---

## Test Framework

- **Swift Testing** (`@Suite`, `@Test`, `#expect`) — all new tests
- **XCTest**: not used in new files (Swift Testing only)
- **URLProtocol subclassing**: `MockURLProtocol` for network stubbing
- **Fakes**: `FakeTokenProvider` — no mocks or third-party mock libraries
- **No SnapshotTesting / ViewInspector** — Network layer has no UI

---

## Pre-existing Test Failures (Not Introduced by This Work)

These failures existed before this feature branch and are unrelated to network tests:

1. **`Localization Tests`** — Two assertions checking exact Maltese string values fail because
   the actual localization string (with Unicode special characters) differs from test hardcoded
   values. Pre-existing in `LocalizableTests.swift`.

2. **`MoltEmptyView Tests`** — Test runner crashes when running the `"EmptyView body is a valid View"`
   test. Pre-existing issue in `MoltEmptyViewTests.swift` (likely a ViewInspector API incompatibility).

---

## Files Modified

- `ios/MoltMarketplace.xcodeproj/project.pbxproj` — Added 11 new test file references and
  build file entries for the `MoltMarketplaceTests` target. Added `Network` group under
  `Core` in the test target group tree.

---

## Next Steps

- **Doc Writer**: Document the Network Layer API surface and error handling contract
- **Reviewer**: Review test coverage, ensure all spec requirements are covered
- No source code changes required — tests pass against current implementation

---

*Generated by iOS Tester agent on 2026-02-21*
