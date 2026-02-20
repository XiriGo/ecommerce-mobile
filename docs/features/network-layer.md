# M0-03: Network Layer

## Overview

The Network Layer provides the HTTP client infrastructure for the Molt Marketplace mobile app to communicate with the Medusa v2 REST API. It is a developer infrastructure feature with no user-facing screens.

**Status**: Complete
**Phase**: M0 (Foundation)
**Issue**: #4
**Platforms**: Android (Kotlin + Retrofit + OkHttp) + iOS (Swift + URLSession + async/await)
**Blocks**: M0-06 (Auth Infrastructure), all M1–M4 feature modules

### What It Provides

- Configured HTTP client (Retrofit + OkHttp on Android, URLSession on iOS)
- Auth token injection on every authenticated request
- Automatic token refresh on 401 with mutex-serialized concurrency protection
- Retry with exponential backoff for 5xx server errors (3 retries, 1s/2s/4s delays, ±20% jitter)
- Medusa error response parsing into a typed `AppError` domain hierarchy
- Snake_case ↔ camelCase JSON conversion configured globally (no per-field annotations needed)
- Network connectivity monitoring (`StateFlow<Boolean>` on Android, `@Observable` on iOS)
- Debug-only request/response logging (zero overhead in release builds)
- Pagination metadata helper for all list endpoints

---

## Architecture

The network layer lives entirely in the **data layer** (`core/network/`) and **domain layer** (`core/domain/error/`). Feature repositories depend on it; feature ViewModels consume only the `AppError` domain type.

```
Feature Repositories (data layer)
         |
         v
core/network/         <- HTTP client, interceptors, authenticator, retry, logging
         |
         v
Medusa v2 REST API    <- api-dev.molt.mt / api-staging.molt.mt / api.molt.mt
```

`AppError` lives in `core/domain/error/` so the domain layer is isolated from transport details. ViewModels receive `AppError` values; they never interact with the network layer directly.

### Dependency Chain

```
M0-01 (App Scaffold)
    -> M0-03 (Network Layer)   <- this feature
        -> M0-06 (Auth Infrastructure)
            -> M1–M4 (all feature modules)
```

`TokenProvider` is defined in this layer as an interface/protocol but its implementation is wired in M0-06 (Auth Infrastructure). A no-op placeholder (`NoOpTokenProvider`) ships with this layer so public endpoints work before M0-06 is implemented.

---

## Components

### AppError

A typed domain error hierarchy that all repositories map network failures to.

**Android** — `sealed class AppError : Exception()` in `core/domain/error/AppError.kt`:

| Case | Trigger |
|------|---------|
| `Network(message)` | `IOException`, `URLError` — no internet, DNS failure, timeout |
| `Server(code, message)` | HTTP 5xx, 422, 429 |
| `NotFound(message)` | HTTP 404 |
| `Unauthorized(message)` | HTTP 401 after token refresh fails, HTTP 403 |
| `Unknown(message)` | JSON parse failure, unexpected response |

**iOS** — `enum AppError: Error, Equatable, Sendable` in `Core/Domain/Error/AppError.swift` — identical five cases in Swift lowercase convention (`network`, `server`, `notFound`, `unauthorized`, `unknown`).

**Error to user message mapping** (localized string keys from M0-01):

| AppError | String Key | English |
|----------|-----------|---------|
| `Network` | `common_error_network` | "Connection error. Please check your internet." |
| `Server` | `common_error_server` | "Something went wrong. Please try again later." |
| `Unauthorized` | `common_error_unauthorized` | "Please log in to continue." |
| `NotFound` | `common_error_not_found` | "The requested item was not found." |
| `Unknown` | `common_error_unknown` | "An unexpected error occurred." |

**Android**: `fun Throwable.toUserMessageResId(): Int` — returns `R.string.common_error_*`
**iOS**: `extension Error { var toUserMessage: String }` — returns `String(localized:)`

### HTTP Status → AppError Mapping

| HTTP Status | Maps To |
|------------|---------|
| 200–299 | Success (parse body) |
| 401 | Attempt token refresh → retry. If refresh fails: `Unauthorized` |
| 403 | `Unauthorized(message: "Access denied")` |
| 404 | `NotFound(message: from body or default)` |
| 422 | `Server(code: 422, message: from body)` |
| 429 | `Server(code: 429, message: "Too many requests")` |
| 500–504 | Retry up to 3 times → if exhausted: `Server(code, message)` |
| IOException / URLError | `Network` |
| DecodingError / SerializationException | `Unknown` |

### API Client

**Android** — `Retrofit` instance in `core/network/ApiClient.kt`:
- Base URL from `BuildConfig.API_BASE_URL`
- Kotlin Serialization converter factory (`Json.asConverterFactory`)
- Backed by `OkHttpClient` with interceptor chain

**iOS** — `final class APIClient: Sendable` in `Core/Network/APIClient.swift`:
- Generic `func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T`
- Uses `URLSession` with custom configuration
- Handles auth injection, 401 refresh + retry, 5xx retry, and error mapping inline

### Auth Interceptor / Auth Middleware

Injects `Authorization: Bearer <token>` on every non-public request by reading from `TokenProvider`.

- **Android**: `AuthInterceptor` (OkHttp application interceptor). Uses `runBlocking` to bridge the suspend `TokenProvider.getAccessToken()` call.
- **iOS**: Inline logic in `APIClient.request()`. Auth token injected at step 3 of the request flow.

Public endpoints (login, register) are skipped — no token header added.

### Token Refresh

Handles 401 responses by attempting a token refresh before propagating `AppError.Unauthorized`.

- **Android**: `TokenRefreshAuthenticator` (OkHttp `Authenticator`). Uses `kotlinx.coroutines.sync.Mutex` to serialize concurrent refresh attempts. Max 1 retry.
- **iOS**: `actor TokenRefreshActor` in `Core/Network/AuthMiddleware.swift`. Uses Swift actor isolation to serialize concurrent refresh. Max 1 retry.

Token refresh sequence:
1. Receive 401 response
2. Acquire mutex/actor lock
3. If token already changed by another concurrent request — retry with current token (short-circuit)
4. Call `TokenProvider.refreshToken()`
5. Success: store new token, retry original request, release lock
6. Failure: call `TokenProvider.clearTokens()`, release lock, throw/return `AppError.Unauthorized`

### Retry Policy

Transparent exponential backoff for transient 5xx server errors. Feature code never implements retry.

| Parameter | Value |
|-----------|-------|
| Max retries | 3 |
| Retryable status codes | 500, 502, 503, 504 |
| Base delay | 1 second |
| Backoff multiplier | 2x |
| Max delay | 8 seconds |
| Jitter | ±20% (prevents thundering herd) |

**Delay schedule** (with jitter disabled for clarity):

| Attempt | Delay |
|---------|-------|
| 1st retry | ~1s |
| 2nd retry | ~2s |
| 3rd retry | ~4s |

- **Android**: `RetryInterceptor` (OkHttp application interceptor). Uses `Thread.sleep()` (OkHttp thread pool, synchronous).
- **iOS**: Retry loop inside `APIClient.request()`. Uses `Task.sleep(nanoseconds:)` (async-safe, supports cancellation).

Not retried: 4xx responses, network errors (`IOException`/`URLError`).

### JSON Serialization

Configured once; all feature DTOs inherit it automatically.

**Android** (`Json` instance):
```
ignoreUnknownKeys = true
coerceInputValues = true
isLenient = true
explicitNulls = false
namingStrategy = JsonNamingStrategy.SnakeCase   // auto snake_case <-> camelCase
```

**iOS** (`JSONDecoder.api` / `JSONEncoder.api`):
```
keyDecodingStrategy = .convertFromSnakeCase
keyEncodingStrategy = .convertToSnakeCase
dateDecodingStrategy = .iso8601
dateEncodingStrategy = .iso8601
```

### Network Connectivity Monitor

Single source of truth for device connectivity state. Feature ViewModels observe it to proactively disable actions (e.g., "Add to Cart") when offline.

**Android**: `NetworkMonitor` using `ConnectivityManager.registerDefaultNetworkCallback()`. Exposes `val isConnected: StateFlow<Boolean>`.

**iOS**: `@MainActor @Observable final class NetworkMonitor` using `NWPathMonitor` on a background queue. Publishes `private(set) var isConnected: Bool`.

This does not replace error handling. API call failures still produce `AppError.Network`.

### Request Logging

**Android**: `LoggingInterceptor` wrapping OkHttp's `HttpLoggingInterceptor` with `Timber`. Level `BODY` in debug, `NONE` in release (network interceptor, sees wire-level requests).

**iOS**: `RequestLogger` using `os.Logger(subsystem: "com.molt.marketplace", category: "Network")`. Authorization token is redacted. Entire implementation is wrapped in `#if DEBUG`.

---

## Token Refresh Flow

```
Feature Repository
    |
    | throws APIClient (iOS) / OkHttp (Android)
    |
    v
[401 Response]
    |
    +-- Acquire mutex/actor lock
    |
    +-- Token already refreshed by concurrent request?
    |     YES --> retry with current token, release lock
    |
    +-- NO --> call TokenProvider.refreshToken()
                |
                +-- Success --> store new token
                |               retry original request
                |               release lock
                |               return response
                |
                +-- Failure --> clear all tokens (TokenProvider.clearTokens())
                               release lock
                               throw AppError.Unauthorized
                               (M0-06 auth state observer navigates to login)
```

---

## Configuration Reference

### Base URLs

| Environment | URL |
|-------------|-----|
| Debug | `https://api-dev.molt.mt` |
| Staging | `https://api-staging.molt.mt` |
| Release | `https://api.molt.mt` |

**Android**: `BuildConfig.API_BASE_URL`
**iOS**: `Config.apiBaseURL`

### Timeouts

| Parameter | Android | iOS |
|-----------|---------|-----|
| Connect | 30s | — |
| Read | 60s | — |
| Write | 60s | — |
| Request | — | 60s (`timeoutIntervalForRequest`) |
| Resource | — | 300s (`timeoutIntervalForResource`) |

### Cache

| Platform | Size |
|----------|------|
| Android (OkHttp disk cache) | 10 MB |
| iOS (URLCache memory) | 10 MB |
| iOS (URLCache disk) | 50 MB |

### Request Headers (All Requests)

| Header | Value |
|--------|-------|
| `Accept` | `application/json` |
| `Content-Type` | `application/json` (POST/PUT/PATCH with body) |
| `Authorization` | `Bearer <token>` (authenticated endpoints only) |
| `x-publishable-api-key` | Medusa publishable API key (from config) |

---

## Medusa API Conventions

- **JSON keys**: snake_case (auto-converted to camelCase by the serialization layer)
- **Dates**: ISO 8601 (`"2025-01-15T10:30:00.000Z"`)
- **Updates**: Medusa v2 uses `POST` for updates (not `PUT`/`PATCH`)
- **Response wrapping**: No generic `data` wrapper. Each endpoint uses a named key (e.g., `"products"`, `"cart"`, `"order"`)

### Pagination

All list endpoints use offset-based pagination:

**Request**: `?offset=0&limit=20`

**Response** (alongside the resource array):
```json
{
  "products": [ ... ],
  "count": 142,
  "limit": 20,
  "offset": 20
}
```

Has-more: `offset + items.size < count`

`PaginationMeta` is a reusable struct/data class that repositories use to extract pagination state for ViewModels.

---

## Usage Examples

### Android — Feature Repository

```kotlin
@Singleton
class ProductRepositoryImpl @Inject constructor(
    private val api: ProductApi,      // Retrofit interface, provided by feature DI module
    private val errorMapper: ApiErrorMapper
) : ProductRepository {

    override suspend fun getProducts(offset: Int, limit: Int): Result<ProductListResult> =
        runCatching {
            api.getProducts(offset = offset, limit = limit)
        }.map { response ->
            ProductListResult(
                products = response.products.map { it.toDomain() },
                pagination = PaginationMeta(
                    count = response.count,
                    limit = response.limit,
                    offset = response.offset
                )
            )
        }.mapError { it.toAppError() }   // ApiErrorMapper extension
}
```

### Android — Feature DI Module

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object ProductNetworkModule {

    @Provides
    @Singleton
    fun provideProductApi(retrofit: Retrofit): ProductApi =
        retrofit.create(ProductApi::class.java)
}
```

### iOS — Feature Repository

```swift
final class ProductRepositoryImpl: ProductRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getProducts(offset: Int, limit: Int) async throws -> ProductListResult {
        let response: ProductListResponse = try await apiClient.request(
            ProductEndpoint.list(offset: offset, limit: limit)
        )
        return ProductListResult(
            products: response.products.map { $0.toDomain() },
            pagination: PaginationMeta(
                count: response.count,
                limit: response.limit,
                offset: response.offset
            )
        )
    }
}
```

### iOS — Feature Endpoint

```swift
enum ProductEndpoint: Endpoint {
    case list(offset: Int, limit: Int)
    case detail(id: String)

    var path: String {
        switch self {
        case .list: return "/store/products"
        case .detail(let id): return "/store/products/\(id)"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .list(let offset, let limit):
            return [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        case .detail: return nil
        }
    }
}
```

### Observing Network Connectivity (Both Platforms)

**Android** (in ViewModel):
```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val networkMonitor: NetworkMonitor
) : ViewModel() {
    val isOnline = networkMonitor.isConnected.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = true
    )
}
```

**iOS** (in View):
```swift
struct HomeView: View {
    @Environment(NetworkMonitor.self) private var networkMonitor

    var body: some View {
        if !networkMonitor.isConnected {
            MoltErrorView(message: String(localized: "common_error_network"))
        }
        // ... rest of view
    }
}
```

---

## File Structure

### Android

**Root**: `android/app/src/main/java/com/molt/marketplace/core/`

```
core/
  domain/
    error/
      AppError.kt                   # Sealed class: Network, Server, NotFound, Unauthorized, Unknown
  network/
    ApiClient.kt                    # Retrofit instance (base URL, JSON converter, OkHttp client)
    OkHttpClientFactory.kt          # Builds OkHttpClient (interceptors, authenticator, cache, timeouts)
    AuthInterceptor.kt              # Injects Bearer token; skips public endpoints
    TokenRefreshAuthenticator.kt    # Handles 401: mutex-protected refresh + retry (OkHttp Authenticator)
    RetryInterceptor.kt             # Retries 500/502/503/504 up to 3x with exponential backoff
    LoggingInterceptor.kt           # Timber-backed OkHttp logging (debug only)
    NetworkConfig.kt                # Timeout and cache size constants
    ApiErrorMapper.kt               # Throwable.toAppError() extension; parses MedusaErrorDto
    MedusaErrorDto.kt               # @Serializable data class for Medusa error response body
    PaginationMeta.kt               # data class with count/limit/offset + hasMore computed property
    NetworkMonitor.kt               # ConnectivityManager wrapper; StateFlow<Boolean>
    TokenProvider.kt                # Interface: getAccessToken / refreshToken / clearTokens
  di/
    NetworkModule.kt                # Hilt @Module: Json, OkHttpClient, Retrofit, NetworkMonitor, TokenProvider
```

**Interceptor chain order**: `AuthInterceptor` (application) → `RetryInterceptor` (application) → `LoggingInterceptor` (network)

**Test files** (`android/app/src/test/java/com/molt/marketplace/core/`):

| File | Tests |
|------|-------|
| `network/AuthInterceptorTest.kt` | 6 |
| `network/TokenRefreshAuthenticatorTest.kt` | 3 |
| `network/RetryInterceptorTest.kt` | 12 |
| `network/ApiErrorMapperTest.kt` | 16 |
| `domain/error/AppErrorTest.kt` | 12 |
| `network/NetworkConfigTest.kt` | 6 |
| `network/PaginationMetaTest.kt` | 11 |
| `network/ApiClientTest.kt` | 4 |
| `network/AuthInterceptorEdgeCasesTest.kt` | 9 |
| `network/RetryInterceptorEdgeCasesTest.kt` | 16 |
| `network/TokenRefreshAuthenticatorEdgeCasesTest.kt` | 7 |
| `network/ApiErrorMapperEdgeCasesTest.kt` | 17 |
| `domain/error/AppErrorEdgeCasesTest.kt` | 14 |

Total: **133 tests, 0 failures**

### iOS

**Root**: `ios/MoltMarketplace/Core/`

```
Core/
  Domain/
    Error/
      AppError.swift                # enum AppError: Error, Equatable, Sendable (5 cases + toUserMessage)
  Network/
    APIClient.swift                 # final class APIClient: Sendable; generic request<T: Decodable>
    Endpoint.swift                  # protocol Endpoint: Sendable (path, method, headers, queryItems, body, requiresAuth)
    HTTPMethod.swift                # enum HTTPMethod: String, Sendable (GET, POST, PUT, DELETE, PATCH)
    AuthMiddleware.swift            # actor TokenRefreshActor (concurrent refresh serialization)
    RetryPolicy.swift               # struct RetryPolicy: Sendable; static .default (3 retries, 1s base, 2x)
    JSONCoders.swift                # JSONDecoder.api + JSONEncoder.api (snake_case + ISO 8601)
    MedusaErrorDTO.swift            # struct MedusaErrorDTO: Decodable, Sendable
    PaginatedResponse.swift         # struct PaginationMeta: Decodable, Equatable, Sendable + hasMore
    NetworkConfig.swift             # enum NetworkConfig (timeout + cache capacity constants)
    NetworkMonitor.swift            # @Observable final class NetworkMonitor (NWPathMonitor, @MainActor)
    RequestLogger.swift             # #if DEBUG os.Logger utility (request/response logging)
    TokenProvider.swift             # protocol TokenProvider: Sendable + NoOpTokenProvider placeholder
  DI/
    Container+Extensions.swift      # Factory registrations: tokenProvider, apiClient, networkMonitor
```

**Test files** (`ios/MoltMarketplaceTests/Core/Network/`):

| File | Tests |
|------|-------|
| `AppErrorTests.swift` | 17 |
| `RetryPolicyTests.swift` | 22 |
| `MedusaErrorDTOTests.swift` | 10 |
| `PaginatedResponseTests.swift` | 14 |
| `NetworkConfigTests.swift` | 6 |
| `JSONCodersTests.swift` | 10 |
| `TokenProviderTests.swift` | 13 |
| `EndpointTests.swift` | 13 |
| `AuthMiddlewareTests.swift` | 14 |
| `APIClientTests.swift` | 22 |

Total: **~141 tests** (+ `MockURLProtocol.swift` test infrastructure)

---

## Testing Summary

| Platform | Test Framework | Test Files | Test Cases | Result |
|----------|---------------|-----------|-----------|--------|
| Android | JUnit 4 + Truth + OkHttp MockWebServer | 13 | 133 | PASS |
| iOS | Swift Testing + MockURLProtocol | 10 + 1 infra | ~141 | PASS |

**Key patterns**:
- Android: `FakeTokenProvider` (in-memory, reused across interceptor tests), `MockWebServer` (HTTP-level interceptor testing)
- iOS: `FakeTokenProvider` with call-count tracking, `MockURLProtocol` (`URLProtocol` subclass, no external dependencies), `APIClient.makeTestClient(...)` factory
- Both: Fakes over mocks — no mock library used

**Not tested via unit tests** (require device/integration):
- Android: `NetworkMonitor` (requires `ConnectivityManager`), `OkHttpClientFactory` (requires `Context`)
- iOS: `NetworkMonitor` (NWPathMonitor is not mocked at unit test level)

---

## Pre-existing Test Failures (Unrelated to This Feature)

Two pre-existing failures in the iOS test suite are **not introduced by the network layer**:
- `LocalizableTests.swift` — Maltese string exact-match assertions fail due to Unicode character differences
- `MoltEmptyViewTests.swift` — Test runner crash (ViewInspector API incompatibility)

---

## Documentation References

- **Architect Spec**: `shared/feature-specs/network-layer.md`
- **API Contracts**: `shared/api-contracts/`
- **Android Standards**: `docs/standards/android.md`
- **iOS Standards**: `docs/standards/ios.md`
- **CLAUDE.md**: Project-wide conventions

---

**Last Updated**: 2026-02-21
**Agent**: doc-writer
**Status**: Complete
