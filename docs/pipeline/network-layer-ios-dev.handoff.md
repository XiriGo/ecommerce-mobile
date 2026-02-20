# Network Layer - iOS Dev Handoff

## Agent: ios-dev
## Feature: M0-03 Network Layer
## Platform: iOS
## Status: Complete

## Files Created

Base path: `ios/MoltMarketplace/Core/`

| # | File | Description |
|---|------|-------------|
| 1 | `Domain/Error/AppError.swift` | `enum AppError: Error, Equatable, Sendable` with 5 cases (network, server, notFound, unauthorized, unknown). Includes `Error.toUserMessage` extension using `String(localized:)` for localized messages. |
| 2 | `Network/HTTPMethod.swift` | `enum HTTPMethod: String, Sendable` -- GET, POST, PUT, DELETE, PATCH. |
| 3 | `Network/Endpoint.swift` | `protocol Endpoint: Sendable` with path, method, headers, queryItems, body, requiresAuth. Default implementations for optional properties. |
| 4 | `Network/JSONCoders.swift` | `JSONDecoder.api` and `JSONEncoder.api` static properties with snake_case conversion and ISO 8601 date handling. |
| 5 | `Network/MedusaErrorDTO.swift` | `struct MedusaErrorDTO: Decodable, Sendable` for parsing Medusa error responses (type, message, code). |
| 6 | `Network/TokenProvider.swift` | `protocol TokenProvider: Sendable` with getAccessToken/refreshToken/clearTokens. Includes `NoOpTokenProvider` placeholder for pre-M0-06 usage. |
| 7 | `Network/RetryPolicy.swift` | `struct RetryPolicy: Sendable` with configurable maxRetries, baseDelay, backoffMultiplier, maxDelay, jitterFactor, retryableStatusCodes. Static `.default` factory (3 retries, 1s base, 2x multiplier, [500,502,503,504]). |
| 8 | `Network/AuthMiddleware.swift` | `actor TokenRefreshActor` serializing concurrent token refresh attempts. Checks if token already refreshed by another request, manages active refresh task lifecycle. |
| 9 | `Network/APIClient.swift` | `final class APIClient: Sendable` -- main network client. Generic `request<T: Decodable>(_ endpoint:)`. Handles URLSession configuration, auth token injection, 401 refresh + retry, 5xx retry with exponential backoff, error mapping from HTTP status + Medusa error body to AppError. Uses `AnyEncodable` type-eraser for body encoding. |
| 10 | `Network/PaginatedResponse.swift` | `struct PaginationMeta: Decodable, Equatable, Sendable` with count, limit, offset, and computed `hasMore`. |
| 11 | `Network/NetworkConfig.swift` | `enum NetworkConfig` with timeout and cache capacity constants (60s request, 300s resource, 10MB memory / 50MB disk cache). |
| 12 | `Network/NetworkMonitor.swift` | `@Observable final class NetworkMonitor: @unchecked Sendable` using NWPathMonitor. `@MainActor` isolated `isConnected` property for SwiftUI observation. |
| 13 | `Network/RequestLogger.swift` | Debug-only (`#if DEBUG`) utility using `os.Logger`. Logs request method/URL/headers (redacted auth), response status/duration/size. |
| 14 | `DI/Container+Extensions.swift` | Factory registrations: `tokenProvider` (NoOpTokenProvider singleton), `apiClient` (APIClient singleton), `networkMonitor` (NetworkMonitor singleton). |

## Files Modified

| File | Change |
|------|--------|
| `Core/DI/Container+Extensions.swift` | Added network layer registrations (was empty) |

## Files Removed

| File | Reason |
|------|--------|
| `Core/Network/.gitkeep` | Replaced by actual network layer files |
| `Core/Domain/Error/.gitkeep` | Replaced by AppError.swift |

## Architecture Decisions

1. **APIClient as final class (not actor)**: URLSession manages its own thread safety. Only token refresh serialization uses an actor (`TokenRefreshActor`).
2. **@unchecked Sendable on NetworkMonitor**: NWPathMonitor callbacks are dispatched to MainActor for property updates. The monitor itself runs on a background queue. The class is safe to share across concurrency boundaries.
3. **AnyEncodable type-eraser**: Required because `Endpoint.body` is `(any Encodable & Sendable)?`. The wrapper enables `JSONEncoder.encode()` to work with the existential type.
4. **NoOpTokenProvider**: Returns nil for all token operations. Ensures network layer compiles and works for public endpoints before M0-06 (Auth Infrastructure) provides the real implementation.
5. **Retry only on 5xx**: Client errors (4xx) and network errors (URLError) are never automatically retried per spec.

## Build Verification

- `xcodebuild build` succeeded with zero errors
- No strict concurrency warnings (Swift 6.0, SWIFT_STRICT_CONCURRENCY=complete)
- XcodeGen project regenerated successfully

## Key Behaviors

- Base URL from `Config.apiBaseURL`
- URLSession with 60s request timeout, 300s resource timeout
- Retry: 3 retries for 500/502/503/504, exponential backoff (1s, 2s, 4s) with +/-20% jitter
- Token refresh: On 401, uses actor-serialized refresh via TokenRefreshActor, retries once
- Error mapping: URLError -> AppError.network, HTTP status -> AppError variant, DecodingError -> AppError.unknown
- Logging: os.Logger with privacy-sensitive token redaction, debug builds only
- JSON: snake_case <-> camelCase auto-conversion, ISO 8601 dates, unknown keys ignored

## Dependencies

- Factory (DI) -- already in project
- Network framework (NWPathMonitor) -- system framework
- os framework (Logger) -- system framework

## Next Steps

- iOS Tester: Write unit tests for APIClient, TokenRefreshActor, RetryPolicy, JSONCoders, AppError
- M0-06 (Auth Infrastructure): Replace NoOpTokenProvider with Keychain-backed implementation
