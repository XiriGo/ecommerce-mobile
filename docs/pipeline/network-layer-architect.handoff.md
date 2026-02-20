# Handoff: network-layer -- Architect

## Feature
**M0-03: Network Layer** -- HTTP client infrastructure for Medusa v2 REST API communication.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/network-layer.md` |
| This Handoff | `docs/pipeline/network-layer-architect.handoff.md` |

## Summary of Spec

The network layer spec defines the complete HTTP client infrastructure for both Android and iOS platforms.

### Android
- Retrofit 3.0 + OkHttp 5.0 + Kotlin Serialization 1.8.0
- `AuthInterceptor` injects Bearer token from `TokenProvider` interface
- `TokenRefreshAuthenticator` handles 401 with mutex-serialized refresh + retry
- `RetryInterceptor` retries 5xx responses up to 3 times with exponential backoff (1s, 2s, 4s) + jitter
- `ApiErrorMapper` maps HTTP status codes, IOException, SerializationException to `AppError`
- `NetworkMonitor` uses ConnectivityManager with `StateFlow<Boolean>`
- `LoggingInterceptor` wraps OkHttp logging with Timber (debug only)
- Hilt `NetworkModule` provides Retrofit, OkHttpClient, Json, NetworkMonitor as singletons
- OkHttp timeouts: 30s connect, 60s read, 60s write; 10 MB disk cache
- 14 production files + 5 test files

### iOS
- URLSession with async/await, custom configuration
- `APIClient` with generic `request<T: Decodable>(_ endpoint: Endpoint)` method
- `Endpoint` protocol for type-safe API endpoint definitions
- `TokenRefreshActor` (Swift actor) serializes concurrent token refresh attempts
- `RetryPolicy` struct configures retry behavior (3 retries, exponential backoff, jitter)
- `JSONDecoder.api` / `JSONEncoder.api` with snake_case + ISO 8601
- `NetworkMonitor` uses NWPathMonitor, `@Observable` for SwiftUI integration
- `RequestLogger` uses os.Logger (debug only, `#if DEBUG`)
- Request timeout: 60s; URLCache: 10 MB memory, 50 MB disk
- 12 production files + 5 test files

### Shared Concepts
- `AppError` sealed class/enum with 5 cases: Network, Server, NotFound, Unauthorized, Unknown
- HTTP status to AppError mapping table (401, 404, 422, 429, 5xx, IOException/URLError)
- Error to localized user message mapping (uses string keys from M0-01)
- `TokenProvider` interface/protocol defined here, implemented in M0-06
- `MedusaErrorDto/DTO` for parsing Medusa error response bodies
- `PaginationMeta` for offset-based pagination metadata
- Medusa API conventions: snake_case JSON, named response keys, ISO 8601 dates
- Retry policy: 3 retries with exponential backoff for 5xx errors (1s base, 2x multiplier, 20% jitter)

## Key Decisions

1. **TokenProvider as interface/protocol**: Defines the contract here, but implementation lives in M0-06 (Auth Infrastructure). A no-op placeholder is provided so the network layer compiles independently.
2. **No generic response wrapper**: Medusa uses named keys per resource type (not a shared `data` wrapper), so each feature DTO defines its own response structure.
3. **Token refresh in OkHttp Authenticator (Android)**: Uses OkHttp's built-in `Authenticator` interface for 401 handling, which is the idiomatic approach. Uses `runBlocking` for the coroutine bridge.
4. **Token refresh in APIClient (iOS)**: Handled inline within the `request()` method since URLSession has no interceptor pattern. Mutex via Swift `actor`.
5. **Kotlin Serialization with SnakeCase naming strategy**: Uses `JsonNamingStrategy.SnakeCase` for automatic conversion rather than per-field `@SerialName` annotations.
6. **ignoreUnknownKeys = true**: Prevents crashes when the backend adds new fields.
7. **Separate `AuthInterceptor` and `TokenRefreshAuthenticator`**: Auth header injection (every request) is decoupled from 401 retry logic, following OkHttp best practices.
8. **NetworkMonitor as singleton**: Single source of truth for connectivity state, observable by any feature.
9. **Debug-only logging**: Both platforms ensure zero logging overhead in release builds.
10. **Retry with exponential backoff for 5xx**: `RetryInterceptor` (Android) / `APIClient` inline retry (iOS) handles transient server errors with 3 retries, exponential backoff (1s, 2s, 4s), and +/-20% jitter to prevent thundering herd.
11. **Retry is transparent**: Callers (repositories, ViewModels) do not implement retry logic. The network layer handles it automatically.
12. **No retry for client errors or network errors**: Only 500, 502, 503, 504 are retried. 4xx errors and connectivity failures are reported immediately.
13. **Timeout values**: 30s connect, 60s read/write (Android); 60s request timeout (iOS). These match the project requirements specification.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | File manifest (section 11.1), implementation order (section 13), OkHttp notes (section 9), retry interceptor design (section 9.4), DI module structure |
| iOS Dev | File manifest (section 11.2), implementation order (section 13), URLSession config (section 10), retry policy design (section 10.5), Factory registration |

## Verification

Downstream developers should verify their implementation against the criteria in spec section 12.

## Changes from Previous Version

- **Added retry policy (section 7)**: Full specification for retry with exponential backoff for 5xx errors -- 3 retries, 1s base delay, 2x multiplier, 20% jitter
- **Updated timeout values**: Connect timeout changed from 15s to 30s. Read/write timeout changed from 30s to 60s. iOS request timeout changed from 30s to 60s. These now match the issue requirements.
- **Added `RetryInterceptor.kt` (Android)**: New OkHttp interceptor for 5xx retry, inserted after `AuthInterceptor` in the chain
- **Added `RetryPolicy.swift` (iOS)**: New configuration struct for retry behavior, used by `APIClient`
- **Added retry test files**: `RetryInterceptorTest.kt` (Android), `RetryPolicyTests.swift` (iOS)
- **Updated scope table**: Retry policy moved from "Out of Scope" to "In Scope"
- **Updated file counts**: Android: 13->14 production files, 4->5 test files. iOS: 11->12 production files, 4->5 test files.

## Notes for Next Features

- **M0-06 (Auth Infrastructure)**: Must implement `TokenProvider` interface/protocol with actual Keychain/DataStore-backed token storage. Replace the no-op placeholder in DI.
- **M1+ features**: Each feature creates its own Retrofit API interface (Android) / Endpoint enum (iOS) and repository. All use `AppError` for error handling and `ApiErrorMapper`/`APIClient` for HTTP communication.
- **Error messages**: All 5 error string keys (`common_error_network`, `common_error_server`, `common_error_unauthorized`, `common_error_not_found`, `common_error_unknown`) are already defined in M0-01 scaffold resources for all three languages.
- **Retry is automatic**: Feature developers do not need to implement retry logic for 5xx errors. The network layer handles it transparently.
