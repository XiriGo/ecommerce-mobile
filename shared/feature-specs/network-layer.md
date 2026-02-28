# M0-03: Network Layer -- Feature Specification

## Overview

The Network Layer provides the HTTP client infrastructure for the XiriGo Ecommerce buyer app
to communicate with the Medusa v2 REST API. It establishes the API client, interceptor/middleware
chains, error handling, JSON serialization, pagination helpers, network monitoring, retry policy,
and token management. All feature modules depend on this layer for their data-fetching needs.

This is a **developer infrastructure** feature. It produces no user-facing screens, but its
error-handling types surface in every feature's UI via `XGErrorView` and localized error
messages.

### User Stories

- As a **developer**, I want a configured API client so that I can call Medusa v2 endpoints from any feature repository.
- As a **developer**, I want automatic auth token injection so that authenticated requests work transparently.
- As a **developer**, I want automatic token refresh on 401 so that expired sessions recover without user intervention.
- As a **developer**, I want a typed error hierarchy so that I can map backend errors to user-friendly messages consistently.
- As a **developer**, I want request/response logging in debug builds so that I can diagnose API issues.
- As a **developer**, I want a network connectivity monitor so that the app can show offline banners proactively.
- As a **developer**, I want pagination helpers so that offset-based list endpoints follow a consistent pattern.
- As a **developer**, I want snake_case to camelCase JSON mapping configured once so that every DTO just works.
- As a **developer**, I want automatic retry with exponential backoff for 5xx errors so that transient server failures are handled gracefully.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| API client (Retrofit / URLSession) | Token storage implementation (M0-06) |
| OkHttp interceptor chain (Android) | Auth state management (M0-06) |
| URLSession configuration (iOS) | Login/register endpoints (M0-06) |
| Auth token interceptor/middleware | Feature-specific API services |
| Token refresh authenticator | Feature-specific DTOs |
| Retry policy with exponential backoff for 5xx | Certificate pinning (release hardening) |
| HTTP error to AppError mapping | WebSocket or real-time connections |
| JSON serialization config | Analytics event tracking |
| Pagination response DTOs | |
| Network connectivity monitor | |
| Debug-only request logging | |
| AppError sealed class/enum | |
| Error to user message mapping | |

### Dependencies on Other Features

| Feature | Dependency Type | Details |
|---------|----------------|---------|
| M0-01: App Scaffold | Hard | Project structure, build config, base URL, DI container shell |

### Features That Depend on This

| Feature | Dependency Type | Details |
|---------|----------------|---------|
| M0-06: Auth Infrastructure | Hard | Uses API client for login/register/refresh; provides token storage that interceptors read |
| M1-01 through M4-05 | Hard | All feature repositories use API client and AppError types |

**Circular dependency note**: The network layer defines the `AuthInterceptor` and `TokenRefreshAuthenticator` interfaces, but their token-reading and token-storing implementations are wired in M0-06 when the token storage module exists. During M0-03, the interceptor is configured to inject tokens read from a `TokenProvider` interface (Android) / protocol (iOS). M0-06 provides the concrete implementation.

---

## 1. API Mapping

This feature does not call specific API endpoints. Instead, it establishes the patterns and
infrastructure that all feature-specific API calls will follow. The patterns below are derived
from analyzing all six API contracts in `shared/api-contracts/`.

### 1.1 Base URL

Read from build configuration, already set up in M0-01:

| Environment | Base URL |
|-------------|----------|
| Debug | `https://api-dev.xirigo.com` |
| Staging | `https://api-staging.xirigo.com` |
| Release | `https://api.xirigo.com` |

- **Android**: `BuildConfig.API_BASE_URL` (String)
- **iOS**: `Config.apiBaseURL` (URL)

### 1.2 JSON Response Wrapping Convention

Medusa v2 uses **named keys** for all response bodies. There is no generic `data` wrapper.
Each endpoint returns its resource under a specific key name:

| Endpoint Pattern | Response Key | Type |
|-----------------|-------------|------|
| `GET /store/products` | `"products"` | Array |
| `GET /store/products/:id` | `"product"` | Object |
| `GET /store/product-categories` | `"product_categories"` | Array |
| `GET /store/carts/:id` | `"cart"` | Object |
| `POST /store/carts` | `"cart"` | Object |
| `GET /store/orders` | `"orders"` | Array |
| `GET /store/orders/:id` | `"order"` | Object |
| `GET /store/customers/me` | `"customer"` | Object |
| `GET /store/customers/me/addresses` | `"addresses"` | Array |
| `POST /auth/customer/emailpass` | `"token"` | String |
| `GET /store/shipping-options` | `"shipping_options"` | Array |

**Implication**: There is no single generic response wrapper. Each feature DTO defines its own
top-level response structure (e.g., `ProductListResponseDto` with a `products` field). The
network layer does not impose a generic wrapper.

### 1.3 Pagination Pattern

All list endpoints follow the Medusa offset-based pagination convention:

**Request query parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `offset` | Int | 0 | Number of items to skip |
| `limit` | Int | 20 | Maximum items to return |

**Response pagination fields** (included alongside the resource array):

| Field | Type | Description |
|-------|------|-------------|
| `count` | Int | Total number of matching items |
| `limit` | Int | Limit that was applied |
| `offset` | Int | Offset that was applied |

**Example** -- `GET /store/products?offset=20&limit=20`:
```json
{
  "products": [ ... ],
  "count": 142,
  "limit": 20,
  "offset": 20
}
```

**Has-more calculation**: `hasMore = offset + items.size < count`

### 1.4 Date Format

All date/time fields use **ISO 8601** format: `"2025-01-15T10:30:00.000Z"`

### 1.5 JSON Key Style

All JSON keys use **snake_case**: `first_name`, `created_at`, `currency_code`, `variant_id`.

The JSON serialization layer must automatically convert between snake_case (API) and
camelCase (Kotlin/Swift properties).

### 1.6 Authentication Header

Authenticated requests include:

```
Authorization: Bearer <token>
```

The `auth` field in API contracts indicates whether an endpoint requires authentication.
Public endpoints (products, categories, cart creation) do not require a token. Private
endpoints (customer profile, orders, session management) require a valid JWT.

### 1.7 Medusa Error Response Format

When the API returns an error, the response body follows this structure:

```json
{
  "type": "not_found",
  "message": "Product with id prod_xxx was not found",
  "code": "RESOURCE_NOT_FOUND"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `type` | String | Error category (e.g., `not_found`, `unauthorized`, `invalid_data`) |
| `message` | String | Human-readable error description (English) |
| `code` | String (optional) | Machine-readable error code |

The network layer must attempt to parse this body on non-2xx responses and include the
`message` in the mapped `AppError`.

### 1.8 Common Request Headers

All requests must include:

| Header | Value | Notes |
|--------|-------|-------|
| `Content-Type` | `application/json` | For POST/PUT/PATCH/DELETE with body |
| `Accept` | `application/json` | Always |
| `Authorization` | `Bearer <token>` | Only for authenticated endpoints |
| `x-publishable-api-key` | `<key>` | Medusa publishable API key (from config) |

### 1.9 HTTP Methods Used

Across all six API contracts:

| Method | Usage |
|--------|-------|
| `GET` | Fetch resources (products, categories, orders, cart, customer, addresses, shipping options) |
| `POST` | Create resources, update resources, authenticate, add items, apply promotions |
| `DELETE` | Remove resources (line items, addresses, sessions) |

Note: Medusa v2 uses `POST` for updates (not `PUT` or `PATCH`).

---

## 2. Data Models

### 2.1 AppError

A domain-level error hierarchy that all repositories map to. Feature ViewModels use
these types to determine which error message to show.

**Android** (sealed class extending Exception):

```
sealed class AppError : Exception()

  case Network(message: String = "Network error")
    -- No internet connection, DNS failure, connection timeout, socket timeout

  case Server(code: Int, message: String)
    -- HTTP 5xx responses, HTTP 422 validation errors

  case NotFound(message: String = "Not found")
    -- HTTP 404 responses

  case Unauthorized(message: String = "Unauthorized")
    -- HTTP 401 after token refresh has already been attempted

  case Unknown(message: String = "Unknown error")
    -- Catch-all for unexpected errors (JSON parse failures, unknown HTTP codes)
```

**iOS** (enum conforming to Error, Equatable):

```
enum AppError: Error, Equatable

  case network(message: String = "Network error")
  case server(code: Int, message: String)
  case notFound(message: String = "Not found")
  case unauthorized(message: String = "Unauthorized")
  case unknown(message: String = "Unknown error")
```

### 2.2 HTTP Status to AppError Mapping

| HTTP Status | Condition | Maps To |
|------------|-----------|---------|
| 200-299 | Success | No error (parse response body) |
| 401 | Unauthorized | First: attempt token refresh. If refresh fails: `AppError.Unauthorized` |
| 403 | Forbidden | `AppError.Unauthorized(message: "Access denied")` |
| 404 | Not found | `AppError.NotFound(message: parsed from body or default)` |
| 422 | Validation error | `AppError.Server(code: 422, message: parsed from body)` |
| 429 | Rate limited | `AppError.Server(code: 429, message: "Too many requests")` |
| 500-599 | Server error | Retry up to 3 times with exponential backoff. If all retries fail: `AppError.Server(code: statusCode, message: parsed from body or default)` |
| IOException (Android) | Network failure | `AppError.Network` |
| URLError (iOS) | Network failure | `AppError.Network` |
| SerializationException / DecodingError | JSON parse failure | `AppError.Unknown(message: "Failed to parse response")` |
| Any other | Unexpected | `AppError.Unknown` |

### 2.3 AppError to User Message Mapping

Each `AppError` case maps to a localized string resource key. These keys were already
created in M0-01 (app-scaffold) for all three languages.

| AppError Case | String Key | English Value |
|--------------|------------|---------------|
| `Network` | `common_error_network` | "Connection error. Please check your internet." |
| `Server` | `common_error_server` | "Something went wrong. Please try again later." |
| `Unauthorized` | `common_error_unauthorized` | "Please log in to continue." |
| `NotFound` | `common_error_not_found` | "The requested item was not found." |
| `Unknown` | `common_error_unknown` | "An unexpected error occurred." |

**Android**: `fun Throwable.toUserMessageResId(): Int` returns `R.string.common_error_*`.
**iOS**: `extension Error { var toUserMessage: String }` returns `String(localized:)`.

### 2.4 Medusa Error Response DTO

Used to parse error bodies from non-2xx responses.

```
MedusaErrorDto
  type: String          -- e.g., "not_found", "unauthorized", "invalid_data"
  message: String       -- e.g., "Product with id prod_xxx was not found"
  code: String?         -- e.g., "RESOURCE_NOT_FOUND" (optional)
```

**Android**: `@Serializable data class MedusaErrorDto`
**iOS**: `struct MedusaErrorDTO: Decodable`

### 2.5 Pagination Metadata

A reusable structure to carry pagination info alongside any list response.

```
PaginationMeta
  count: Int            -- total matching items
  limit: Int            -- page size used
  offset: Int           -- offset used
```

This is not a generic wrapper. Each feature response DTO embeds its own resource array
(e.g., `products: [ProductDto]`) and includes `count`, `limit`, `offset` fields alongside it.
The `PaginationMeta` type exists as a convenience for repositories to extract and pass
pagination state to ViewModels.

### 2.6 TokenProvider Interface/Protocol

An abstraction that the network layer depends on for reading the current auth token.
The concrete implementation is provided by M0-06 (Auth Infrastructure).

**Android**:
```
interface TokenProvider {
    suspend fun getAccessToken(): String?
    suspend fun refreshToken(): String?
    suspend fun clearTokens()
}
```

**iOS**:
```
protocol TokenProvider: Sendable {
    func getAccessToken() async -> String?
    func refreshToken() async throws -> String?
    func clearTokens() async
}
```

### 2.7 PublishableApiKeyProvider

An abstraction for providing the Medusa publishable API key. Read from build config.

**Android**: `interface PublishableApiKeyProvider { fun getApiKey(): String }`
**iOS**: `protocol PublishableApiKeyProvider: Sendable { func getApiKey() -> String }`

---

## 3. UI Wireframe

Not applicable. This is an infrastructure feature with no user-facing screens.

All errors surfaced by this layer are displayed through the existing `XGErrorView` and
`XGLoadingView` design system components (created in M0-02). Feature screens handle the
presentation of these states via their UiState sealed types.

---

## 4. Navigation Flow

Not applicable. This feature has no screens or navigation destinations.

---

## 5. State Management

Although the network layer itself has no UI state, it exposes two reactive state sources
that feature modules consume.

### 5.1 Network Connectivity State

A system-level observable that reports whether the device has an active internet connection.

**Android**:
```
class NetworkMonitor(context: Context)
  val isConnected: StateFlow<Boolean>
    -- Uses ConnectivityManager + NetworkCallback
    -- Emits true when any network (WiFi, cellular) is available
    -- Emits false when all networks are lost
    -- Initial value: current connectivity state at construction time
```

**iOS**:
```
@Observable final class NetworkMonitor
  private(set) var isConnected: Bool = true
    -- Uses NWPathMonitor on a background queue
    -- Updates on @MainActor when path status changes
    -- .satisfied = true, .unsatisfied/.requiresConnection = false
```

**Consumption pattern**:
- Feature ViewModels observe `NetworkMonitor.isConnected` to proactively disable actions
  (e.g., disable "Add to Cart" button when offline).
- App-level UI shows a non-blocking "No Internet" banner when `isConnected` is `false`.
- This does NOT replace error handling; API call failures still produce `AppError.Network`.

### 5.2 Auth Token State (Transparent)

The `AuthInterceptor` (Android) / `AuthMiddleware` (iOS) transparently reads the token from
`TokenProvider` and injects it into request headers. Feature code never handles tokens directly.

The `TokenRefreshAuthenticator` (Android) / `AuthMiddleware` (iOS) handles 401 responses by:
1. Locking a mutex (to prevent concurrent refresh attempts)
2. Calling `TokenProvider.refreshToken()`
3. If successful: retrying the original request with the new token
4. If failed: emitting `AppError.Unauthorized`

This is entirely transparent to callers. Repositories receive either a successful response
or an `AppError` -- never a raw 401.

---

## 6. Error Scenarios

### 6.1 No Network Connection

| Trigger | Detection | Mapped Error | User Experience |
|---------|-----------|-------------|-----------------|
| Device has no internet | `IOException` (Android) / `URLError.notConnectedToInternet` (iOS) | `AppError.Network` | `XGErrorView` with "Connection error. Please check your internet." and Retry button |

### 6.2 Request Timeout

| Trigger | Detection | Mapped Error | User Experience |
|---------|-----------|-------------|-----------------|
| Server does not respond within timeout | `SocketTimeoutException` (Android) / `URLError.timedOut` (iOS) | `AppError.Network` | Same as no network -- `XGErrorView` with retry |

**Timeout configuration:**

| Parameter | Android (OkHttp) | iOS (URLSession) |
|-----------|-------------------|-------------------|
| Connect timeout | 30 seconds | N/A (combined) |
| Read timeout | 60 seconds | N/A (combined) |
| Write timeout | 60 seconds | N/A (combined) |
| Request timeout | N/A | 60 seconds (`timeoutIntervalForRequest`) |
| Resource timeout | N/A | 300 seconds (`timeoutIntervalForResource`) |

### 6.3 Unauthorized (401)

| Trigger | Detection | Recovery | Fallback |
|---------|-----------|----------|----------|
| Expired access token | HTTP 401 response | Attempt `POST /auth/token/refresh` | If refresh fails: `AppError.Unauthorized` -> app redirects to login screen |

**Token refresh sequence:**
```
1. Original request returns 401
2. Acquire refresh mutex lock (prevent concurrent refreshes)
3. Check if token was already refreshed by another request (compare token)
   a. If yes: retry original request with current (new) token
   b. If no: proceed to step 4
4. Call POST /auth/token/refresh with current token
5. If refresh succeeds (200):
   a. Store new token via TokenProvider
   b. Retry original request with new token
   c. Release mutex
   d. Return response from retry
6. If refresh fails (401 or error):
   a. Clear all tokens via TokenProvider.clearTokens()
   b. Release mutex
   c. Return AppError.Unauthorized
   d. Auth state observer (M0-06) handles redirect to login
```

### 6.4 Not Found (404)

| Trigger | Detection | Mapped Error | User Experience |
|---------|-----------|-------------|-----------------|
| Resource does not exist | HTTP 404 | `AppError.NotFound(message: parsed body or default)` | Feature-specific handling: "Product not found", "Order not found", etc. |

### 6.5 Validation Error (422)

| Trigger | Detection | Mapped Error | User Experience |
|---------|-----------|-------------|-----------------|
| Invalid request data | HTTP 422 | `AppError.Server(code: 422, message: parsed body)` | Feature shows specific validation message from server |

### 6.6 Server Error (5xx) with Retry

| Trigger | Detection | Mapped Error | User Experience |
|---------|-----------|-------------|-----------------|
| Backend error | HTTP 500-599 | Retried up to 3 times with exponential backoff. Final failure: `AppError.Server(code: statusCode, message: parsed body or default)` | `XGErrorView` with "Something went wrong. Please try again later." and Retry button |

### 6.7 JSON Parse Error

| Trigger | Detection | Mapped Error | User Experience |
|---------|-----------|-------------|-----------------|
| Unexpected response format | `SerializationException` (Android) / `DecodingError` (iOS) | `AppError.Unknown(message: "Failed to parse response")` | `XGErrorView` with "An unexpected error occurred." |

### 6.8 Rate Limiting (429)

| Trigger | Detection | Mapped Error | User Experience |
|---------|-----------|-------------|-----------------|
| Too many requests | HTTP 429 | `AppError.Server(code: 429, message: "Too many requests. Please try again later.")` | Error message shown, feature may implement retry-after logic |

### 6.9 DNS Resolution Failure

| Trigger | Detection | Mapped Error | User Experience |
|---------|-----------|-------------|-----------------|
| Cannot resolve hostname | `UnknownHostException` (Android) / `URLError.cannotFindHost` (iOS) | `AppError.Network` | Same as no network |

---

## 7. Retry Policy

### 7.1 Overview

The network layer implements automatic retry with exponential backoff for transient server
errors (HTTP 5xx). This is transparent to callers -- repositories and ViewModels do not need
to implement retry logic themselves.

### 7.2 Configuration

| Parameter | Value |
|-----------|-------|
| Max retries | 3 |
| Retryable status codes | 500, 502, 503, 504 (server errors) |
| Base delay | 1 second |
| Backoff multiplier | 2x |
| Max delay | 8 seconds |
| Jitter | +/- 20% random jitter to prevent thundering herd |

**Delay schedule:**

| Attempt | Base Delay | With Jitter Range |
|---------|-----------|-------------------|
| 1st retry | 1s | 0.8s -- 1.2s |
| 2nd retry | 2s | 1.6s -- 2.4s |
| 3rd retry | 4s | 3.2s -- 4.8s |

### 7.3 Non-Retryable Requests

Retries are NOT applied to:
- **Client errors** (4xx): 400, 401, 403, 404, 422, 429 -- these are not transient
- **Network errors** (IOException / URLError): connectivity issues are handled by the offline
  banner and manual user retry; automatic retry would just delay the error
- **POST requests that are not idempotent**: To avoid duplicate side effects, POST requests
  are only retried if the failure was a 5xx **and** the request body was never sent (i.e.,
  the error occurred at the connection level, not after the server received the body). In
  practice, OkHttp's `RetryAndFollowUpInterceptor` handles this distinction. For iOS,
  `APIClient` checks `URLError.networkUnavailableReason` to determine if the request
  reached the server.

**Safe to retry:**
- All GET requests (idempotent reads)
- All DELETE requests (idempotent deletes)
- POST requests where the server returned a 5xx status code (the server received and
  processed the request but failed internally -- the retry is a new attempt)

### 7.4 Interaction with Token Refresh

Retry and token refresh are independent mechanisms:
- **401 handling**: Done by the `TokenRefreshAuthenticator` (Android) / `APIClient` inline
  logic (iOS). This is NOT part of the retry interceptor.
- **5xx retry**: Done by the `RetryInterceptor` (Android) / `APIClient` retry loop (iOS).
- If a retried request returns 401, the token refresh mechanism handles it normally.
- If a token-refreshed request returns 5xx, it enters the retry loop.

### 7.5 Sequence Diagram -- Retry with Backoff

```
Client          RetryInterceptor       OkHttp/URLSession       Server
  |                    |                       |                   |
  |--- request() ---->|                       |                   |
  |                    |--- execute() -------->|--- HTTP --------->|
  |                    |                       |<-- 503 -----------|
  |                    |  (attempt 1 failed)   |                   |
  |                    |  wait ~1s             |                   |
  |                    |--- execute() -------->|--- HTTP --------->|
  |                    |                       |<-- 502 -----------|
  |                    |  (attempt 2 failed)   |                   |
  |                    |  wait ~2s             |                   |
  |                    |--- execute() -------->|--- HTTP --------->|
  |                    |                       |<-- 200 -----------|
  |<-- response -------|                       |                   |
```

---

## 8. Accessibility

Not applicable for the network layer itself. All error messages produced by this layer
are surfaced through localized string resources (`common_error_network`, `common_error_server`,
etc.) which support:

- **Dynamic Type** (iOS) / **Font Scale** (Android) -- handled by `XGErrorView` component
- **Screen Reader** -- error messages are plain text, fully readable by TalkBack/VoiceOver
- **Localization** -- error messages exist in all three languages (English, Maltese, Turkish)

No interactive elements are created by this layer.

---

## 9. Android Implementation Details

### 9.1 Retrofit + OkHttp Configuration

**Retrofit instance:**
- Base URL: `BuildConfig.API_BASE_URL`
- Converter: `Json.asConverterFactory("application/json".toMediaType())` (Kotlin Serialization)
- No call adapters needed (suspend functions return directly)

**Kotlin Serialization `Json` instance:**
```
Json {
    ignoreUnknownKeys = true       -- API may add new fields; do not crash
    coerceInputValues = true       -- null for non-null fields -> use default value
    isLenient = true               -- tolerate minor JSON format issues
    explicitNulls = false          -- do not serialize null fields in request bodies
    encodeDefaults = false         -- do not send default values in request bodies
    namingStrategy = JsonNamingStrategy.SnakeCase  -- auto snake_case <-> camelCase
}
```

**OkHttp client:**
- Connect timeout: 30 seconds
- Read timeout: 60 seconds
- Write timeout: 60 seconds
- Cache: 10 MB disk cache in app cache directory
- Interceptors (applied in this order):
  1. `AuthInterceptor` (application interceptor) -- injects Bearer token
  2. `RetryInterceptor` (application interceptor) -- retries 5xx with exponential backoff
  3. `HttpLoggingInterceptor` (network interceptor, debug only) -- logs request/response via Timber
  4. `ChuckerInterceptor` (application interceptor, debug only) -- in-app HTTP inspector
- Authenticator: `TokenRefreshAuthenticator` -- handles 401 retry with refreshed token

### 9.2 AuthInterceptor

**Type**: OkHttp `Interceptor` (application-level)

**Behavior:**
1. Read the current access token from `TokenProvider.getAccessToken()` (suspend, called
   via `runBlocking` since OkHttp interceptors are synchronous)
2. If token is not null and the request URL does not match a public-only endpoint pattern,
   add `Authorization: Bearer <token>` header
3. Always add `Accept: application/json` header
4. If a publishable API key is configured, add `x-publishable-api-key` header
5. Proceed with the chain

**Public endpoints** (do not require token injection):
- `POST /auth/customer/emailpass` (login)
- `POST /auth/customer/emailpass/register` (register)
- Requests that already have an `Authorization` header (do not overwrite)

### 9.3 TokenRefreshAuthenticator

**Type**: OkHttp `Authenticator`

**Behavior:**
- Called by OkHttp when a response has status 401
- Uses a `Mutex` to serialize concurrent refresh attempts
- Checks if the token in the failed request matches the current stored token
  (if different, another request already refreshed it -- just retry with current token)
- Calls `TokenProvider.refreshToken()` to obtain a new token
- On success: returns a new `Request` with the updated `Authorization` header
- On failure: calls `TokenProvider.clearTokens()` and returns `null` (lets the 401 propagate)
- Max retry count: 1 (do not loop indefinitely)

### 9.4 RetryInterceptor

**Type**: OkHttp `Interceptor` (application-level)

**Behavior:**
1. Proceed with the chain to get the response
2. If response status is in `[500, 502, 503, 504]`:
   a. Close the response body
   b. For each retry attempt (up to 3):
      - Calculate delay: `baseDelay * 2^(attempt-1)` with jitter
      - Sleep for the calculated delay (`Thread.sleep` -- interceptors run on OkHttp threads)
      - Re-execute the request via `chain.proceed(request)`
      - If the new response is successful (not 5xx): return it
   c. If all retries fail: return the last failed response (caller maps to `AppError.Server`)
3. If response is not 5xx: return immediately (no retry)

**Configuration constants** (defined in `RetryInterceptor`):
```
MAX_RETRIES = 3
BASE_DELAY_MS = 1000L
BACKOFF_MULTIPLIER = 2.0
MAX_DELAY_MS = 8000L
JITTER_FACTOR = 0.2
RETRYABLE_CODES = setOf(500, 502, 503, 504)
```

### 9.5 ApiErrorMapper

**Responsibilities:**
- Takes a Retrofit `HttpException` or a raw `Throwable` and maps it to `AppError`
- For `HttpException`: reads the error response body, attempts to parse as `MedusaErrorDto`,
  maps HTTP status code to the appropriate `AppError` subtype
- For `IOException` subtypes: maps to `AppError.Network`
- For `SerializationException`: maps to `AppError.Unknown`
- For everything else: maps to `AppError.Unknown`

### 9.6 NetworkMonitor

**Implementation:**
- Requires `Context` (injected via Hilt as `@ApplicationContext`)
- Uses `ConnectivityManager.registerDefaultNetworkCallback()`
- Exposes `val isConnected: StateFlow<Boolean>`
- Callback implementation:
  - `onAvailable()`: emit `true`
  - `onLost()`: emit `true` only if other networks still available; `false` if none
  - `onCapabilitiesChanged()`: check `NET_CAPABILITY_INTERNET` and `NET_CAPABILITY_VALIDATED`
- Initial value: query `activeNetwork` capabilities at construction time
- Requires `ACCESS_NETWORK_STATE` permission (already in manifest from scaffold)

### 9.7 LoggingInterceptor

**Type**: Thin wrapper around OkHttp's `HttpLoggingInterceptor`

**Configuration:**
- Logger: `Timber`-based logger implementation
- Level: `BODY` for debug builds, `NONE` for release builds
- Added as a **network interceptor** to capture wire-level details

### 9.8 Hilt DI Module

A `@Module @InstallIn(SingletonComponent::class)` that provides:

| Binding | Scope | Implementation |
|---------|-------|----------------|
| `Json` | `@Singleton` | Configured Kotlin Serialization Json instance |
| `OkHttpClient` | `@Singleton` | Configured with interceptors, authenticator, cache, timeouts |
| `Retrofit` | `@Singleton` | Configured with base URL, JSON converter, OkHttp client |
| `NetworkMonitor` | `@Singleton` | ConnectivityManager-based |
| `TokenProvider` | `@Singleton` | Placeholder no-op implementation (replaced in M0-06) |

Note: The `NetworkModule` is created here. Feature-specific `@Provides fun provideXxxApi(retrofit: Retrofit): XxxApi` bindings are added by each feature's own DI module.

---

## 10. iOS Implementation Details

### 10.1 URLSession Configuration

**URLSessionConfiguration.default** with customizations:
- `timeoutIntervalForRequest`: 60 seconds
- `timeoutIntervalForResource`: 300 seconds
- `urlCache`: `URLCache(memoryCapacity: 10_485_760, diskCapacity: 52_428_800)` (10 MB memory, 50 MB disk)
- `httpAdditionalHeaders`:
  - `Accept`: `application/json`
- `waitsForConnectivity`: `false` (fail fast when offline; app shows offline banner separately)

### 10.2 APIClient

**Type**: `final class APIClient: Sendable`

**Properties:**
- `baseURL: URL` -- from `Config.apiBaseURL`
- `session: URLSession` -- configured as above
- `tokenProvider: TokenProvider` -- for auth header injection
- `decoder: JSONDecoder` -- configured for Medusa responses
- `encoder: JSONEncoder` -- configured for Medusa requests
- `retryPolicy: RetryPolicy` -- configuration for retry behavior

**Primary method:**
```
func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
```

**Request flow:**
1. Build `URLRequest` from `Endpoint` (path, method, headers, query items, body)
2. Set base URL + path
3. If `endpoint.requiresAuth` is `true`: inject Bearer token from `TokenProvider`
4. Add `Accept: application/json` and `Content-Type: application/json` headers
5. If publishable API key configured: add `x-publishable-api-key` header
6. Encode body (if present) with `JSONEncoder.api`
7. Call `session.data(for: request)`
8. Check HTTP status code:
   - 200-299: decode response body as `T` using `JSONDecoder.api`
   - 401: attempt token refresh and retry (see section 10.4)
   - 500-504: enter retry loop with exponential backoff (see section 10.5)
   - Other: parse error body as `MedusaErrorDTO`, map to `AppError`
9. Return decoded `T`

### 10.3 Endpoint Protocol

```
protocol Endpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
    var requiresAuth: Bool { get }
}
```

Each feature defines an `enum` conforming to `Endpoint` for its API calls.

**Default implementations** (via protocol extension):
- `headers`: empty dictionary
- `queryItems`: nil
- `body`: nil
- `requiresAuth`: false

### 10.4 AuthMiddleware (Token Injection + Refresh)

Token injection and refresh are handled within `APIClient.request()` rather than as
a separate middleware class, since URLSession does not have OkHttp's interceptor pattern.

**Token refresh sequence** (same logic as Android, section 6.3):
- Uses an `actor`-based mutex (`TokenRefreshActor`) to serialize concurrent refresh attempts
- Checks if token was already refreshed by comparing the failed token with current token
- Calls `TokenProvider.refreshToken()`
- On success: retries the original request with the new token
- On failure: clears tokens, throws `AppError.unauthorized`
- Max retry: 1 attempt

### 10.5 RetryPolicy

**Type**: `struct RetryPolicy: Sendable`

**Properties:**
```
struct RetryPolicy: Sendable {
    let maxRetries: Int             // default: 3
    let baseDelay: TimeInterval     // default: 1.0
    let backoffMultiplier: Double   // default: 2.0
    let maxDelay: TimeInterval      // default: 8.0
    let jitterFactor: Double        // default: 0.2
    let retryableStatusCodes: Set<Int>  // default: [500, 502, 503, 504]
}
```

**Implementation in APIClient:**
- After receiving a 5xx response, `APIClient` enters a retry loop
- Uses `Task.sleep(nanoseconds:)` for async-friendly delays (no thread blocking)
- Applies jitter: `delay * (1.0 + Double.random(in: -jitterFactor...jitterFactor))`
- If the retried request returns 401, the token refresh mechanism handles it
- If all retries exhausted, throws `AppError.server(code:message:)` from the last response

### 10.6 JSONCoders

**`JSONDecoder.api`** (static computed property or factory):
- `keyDecodingStrategy = .convertFromSnakeCase`
- `dateDecodingStrategy = .iso8601`

**`JSONEncoder.api`** (static computed property or factory):
- `keyEncodingStrategy = .convertToSnakeCase`
- `dateEncodingStrategy = .iso8601`

### 10.7 HTTPMethod Enum

```
enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
```

### 10.8 NetworkMonitor

**Type**: `@MainActor @Observable final class NetworkMonitor`

**Implementation:**
- Uses `NWPathMonitor` from Network framework
- Runs on a dedicated `DispatchQueue` (background)
- Publishes `private(set) var isConnected: Bool`
- Path handler checks `path.status == .satisfied`
- Starts monitoring on `init`, cancels on `deinit`
- Must dispatch UI updates to `@MainActor`

### 10.9 RequestLogger

**Type**: Protocol or utility function, debug-only

**Implementation:**
- Uses `os.Logger(subsystem: "com.xirigo.ecommerce", category: "Network")`
- Logs request: method, URL, headers (redacting Authorization token), body size
- Logs response: status code, URL, body size, duration
- Wrapped in `#if DEBUG` -- zero overhead in release builds
- Uses `os.Logger.Level.debug` for requests, `.info` for responses, `.error` for failures

### 10.10 Factory DI Registration

In `Container+Extensions.swift`:

| Registration | Scope | Implementation |
|-------------|-------|----------------|
| `apiClient` | `.singleton` | `APIClient(baseURL: Config.apiBaseURL, tokenProvider: ...)` |
| `networkMonitor` | `.singleton` | `NetworkMonitor()` |
| `tokenProvider` | `.singleton` | No-op placeholder (replaced in M0-06) |

---

## 11. File Manifest

### 11.1 Android Files

Base path: `android/app/src/main/java/com/xirigo/ecommerce/core/`

| # | File Path (relative to base) | Description |
|---|------------------------------|-------------|
| 1 | `network/ApiClient.kt` | Provides Retrofit instance: base URL from `BuildConfig`, JSON converter factory, OkHttp client. Singleton object or class provided via Hilt. |
| 2 | `network/OkHttpClientFactory.kt` | Builds `OkHttpClient` with interceptor chain, authenticator, cache, and timeouts. Separates OkHttp construction from Retrofit for testability. |
| 3 | `network/AuthInterceptor.kt` | OkHttp `Interceptor` that reads token from `TokenProvider` and injects `Authorization: Bearer` header. Skips public-only endpoints. |
| 4 | `network/TokenRefreshAuthenticator.kt` | OkHttp `Authenticator` that handles 401 by calling `TokenProvider.refreshToken()`, retries with new token, or clears tokens on failure. Uses `Mutex` for concurrency. |
| 5 | `network/RetryInterceptor.kt` | OkHttp `Interceptor` that retries 5xx responses up to 3 times with exponential backoff and jitter. Configurable via constants. |
| 6 | `network/LoggingInterceptor.kt` | Thin wrapper around OkHttp's `HttpLoggingInterceptor` configured with `Timber` logger. Sets `BODY` level for debug, `NONE` for release. |
| 7 | `network/ApiErrorMapper.kt` | Object with `fun Throwable.toAppError(): AppError` extension function. Maps `HttpException`, `IOException`, `SerializationException` to `AppError` subtypes. Parses `MedusaErrorDto` from error response body. |
| 8 | `network/MedusaErrorDto.kt` | `@Serializable data class MedusaErrorDto(val type: String, val message: String, val code: String? = null)` |
| 9 | `network/PaginationMeta.kt` | `data class PaginationMeta(val count: Int, val limit: Int, val offset: Int)` -- convenience for extracting pagination info from responses. |
| 10 | `network/NetworkMonitor.kt` | `ConnectivityManager`-based class exposing `val isConnected: StateFlow<Boolean>`. Uses `registerDefaultNetworkCallback`. Injected as `@Singleton`. |
| 11 | `network/TokenProvider.kt` | `interface TokenProvider` with `getAccessToken()`, `refreshToken()`, `clearTokens()` suspend functions. |
| 12 | `network/HttpMethod.kt` | Not needed (Retrofit uses annotations). Omit. |
| 13 | `domain/error/AppError.kt` | Sealed class with 5 subtypes (`Network`, `Server`, `NotFound`, `Unauthorized`, `Unknown`) + `toUserMessageResId()` extension function. |
| 14 | `di/NetworkModule.kt` | Hilt `@Module @InstallIn(SingletonComponent::class)` providing `Json`, `OkHttpClient`, `Retrofit`, `NetworkMonitor`, placeholder `TokenProvider`. |

**Test files** (base: `android/app/src/test/java/com/xirigo/ecommerce/core/`):

| # | Test File | Tests |
|---|-----------|-------|
| 1 | `network/AuthInterceptorTest.kt` | Token injection, skipping public endpoints, missing token behavior |
| 2 | `network/TokenRefreshAuthenticatorTest.kt` | Successful refresh + retry, failed refresh + clear, concurrent refresh serialization |
| 3 | `network/RetryInterceptorTest.kt` | Retry on 500/502/503/504, no retry on 4xx, max retry limit, exponential backoff delays |
| 4 | `network/ApiErrorMapperTest.kt` | All HTTP status mappings, IOException mapping, SerializationException mapping, MedusaErrorDto parsing |
| 5 | `domain/error/AppErrorTest.kt` | `toUserMessageResId()` returns correct string resource for each case |

### 11.2 iOS Files

Base path: `ios/XiriGoEcommerce/Core/`

| # | File Path (relative to base) | Description |
|---|------------------------------|-------------|
| 1 | `Network/APIClient.swift` | `final class APIClient: Sendable`. Generic `request<T: Decodable>(_ endpoint: Endpoint) async throws -> T`. Handles auth injection, 401 refresh + retry, 5xx retry with backoff, error mapping. |
| 2 | `Network/Endpoint.swift` | `protocol Endpoint: Sendable` with `path`, `method`, `headers`, `queryItems`, `body`, `requiresAuth` properties. Default implementations via extension. |
| 3 | `Network/HTTPMethod.swift` | `enum HTTPMethod: String, Sendable` -- `.get`, `.post`, `.put`, `.delete`, `.patch`. |
| 4 | `Network/AuthMiddleware.swift` | `actor TokenRefreshActor` managing the refresh mutex. Used by `APIClient` to serialize concurrent token refresh attempts. |
| 5 | `Network/RetryPolicy.swift` | `struct RetryPolicy: Sendable` with `maxRetries`, `baseDelay`, `backoffMultiplier`, `maxDelay`, `jitterFactor`, `retryableStatusCodes`. Static `.default` factory. |
| 6 | `Network/JSONCoders.swift` | `extension JSONDecoder { static let api: JSONDecoder }` and `extension JSONEncoder { static let api: JSONEncoder }` with snake_case + ISO 8601 config. |
| 7 | `Network/PaginatedResponse.swift` | `struct PaginationMeta: Decodable, Equatable, Sendable` with `count`, `limit`, `offset` fields. |
| 8 | `Network/MedusaErrorDTO.swift` | `struct MedusaErrorDTO: Decodable` with `type`, `message`, `code` (optional) fields. |
| 9 | `Network/NetworkMonitor.swift` | `@MainActor @Observable final class NetworkMonitor`. Uses `NWPathMonitor`. Exposes `private(set) var isConnected: Bool`. |
| 10 | `Network/RequestLogger.swift` | Debug-only utility using `os.Logger`. Logs request method/URL/headers and response status/duration. Wrapped in `#if DEBUG`. |
| 11 | `Network/TokenProvider.swift` | `protocol TokenProvider: Sendable` with `getAccessToken()`, `refreshToken()`, `clearTokens()` async functions. |
| 12 | `Domain/Error/AppError.swift` | `enum AppError: Error, Equatable` with 5 cases + `extension Error { var toUserMessage: String }` using `String(localized:)`. |

**Test files** (base: `ios/XiriGoEcommerceTests/Core/`):

| # | Test File | Tests |
|---|-----------|-------|
| 1 | `Network/APIClientTests.swift` | Successful request, error status mapping, auth header injection, token refresh on 401, retry on 5xx with backoff |
| 2 | `Network/TokenRefreshActorTests.swift` | Successful refresh + retry, failed refresh + clear, concurrent refresh serialization |
| 3 | `Network/RetryPolicyTests.swift` | Delay calculation, jitter bounds, retryable status code filtering |
| 4 | `Network/JSONCodersTests.swift` | Snake_case decoding, ISO 8601 date decoding, encoding round-trip |
| 5 | `Domain/Error/AppErrorTests.swift` | `toUserMessage` returns correct localized string for each case |

### 11.3 Shared Files (No changes)

No new shared files. The existing `shared/api-contracts/*.json` files are reference-only
and are not modified by this feature.

---

## 12. Build Verification Criteria

The network layer is complete when:

### Android

- [ ] `./gradlew assembleDebug` succeeds with all network layer files compiled
- [ ] `AuthInterceptor` injects token header when `TokenProvider` returns a token
- [ ] `AuthInterceptor` skips injection when `TokenProvider` returns null
- [ ] `TokenRefreshAuthenticator` calls `refreshToken()` on 401 and retries
- [ ] `RetryInterceptor` retries on 500, 502, 503, 504 up to 3 times
- [ ] `RetryInterceptor` does NOT retry on 4xx responses
- [ ] `RetryInterceptor` applies exponential backoff with jitter between retries
- [ ] `ApiErrorMapper` correctly maps all HTTP status codes to `AppError` subtypes
- [ ] `ApiErrorMapper` correctly maps `IOException` to `AppError.Network`
- [ ] `ApiErrorMapper` parses `MedusaErrorDto` from error response bodies
- [ ] `NetworkMonitor.isConnected` emits `true` when network is available
- [ ] `AppError.toUserMessageResId()` returns correct string resource IDs
- [ ] Hilt module provides `Retrofit`, `OkHttpClient`, `Json`, `NetworkMonitor`
- [ ] All unit tests pass: `./gradlew testDebugUnitTest --tests "*.core.*"`
- [ ] OkHttp logging interceptor is active only in debug builds
- [ ] JSON serialization correctly handles snake_case keys
- [ ] OkHttp connect timeout is 30s, read timeout is 60s, write timeout is 60s

### iOS

- [ ] `xcodebuild -scheme XiriGoEcommerce-Debug build` succeeds with all network layer files
- [ ] `APIClient.request()` correctly builds `URLRequest` from `Endpoint`
- [ ] `APIClient.request()` injects Bearer token for authenticated endpoints
- [ ] `APIClient.request()` attempts token refresh on 401 and retries
- [ ] `APIClient.request()` retries on 5xx up to 3 times with exponential backoff
- [ ] `APIClient.request()` maps error responses to `AppError`
- [ ] `RetryPolicy` calculates correct delays with backoff and jitter
- [ ] `JSONDecoder.api` correctly decodes snake_case keys
- [ ] `JSONDecoder.api` correctly decodes ISO 8601 dates
- [ ] `NetworkMonitor.isConnected` reflects actual connectivity state
- [ ] `AppError.toUserMessage` returns correct localized strings
- [ ] Factory container provides `APIClient` and `NetworkMonitor` singletons
- [ ] All unit tests pass: `xcodebuild test -scheme XiriGoEcommerce-Debug`
- [ ] `RequestLogger` is compiled only in DEBUG builds
- [ ] No strict concurrency warnings
- [ ] URLSession request timeout is 60s

---

## 13. Implementation Notes for Developers

### For Android Developer

1. Start with `domain/error/AppError.kt` -- this has no dependencies and everything else references it
2. Create `network/TokenProvider.kt` interface -- the interceptor and authenticator depend on it
3. Create `network/MedusaErrorDto.kt` -- needed by the error mapper
4. Create `network/ApiErrorMapper.kt` -- maps Throwable to AppError, used by all repositories
5. Create `network/AuthInterceptor.kt` -- reads token from `TokenProvider`, injects header
6. Create `network/TokenRefreshAuthenticator.kt` -- handles 401 retry via `TokenProvider.refreshToken()`
7. Create `network/RetryInterceptor.kt` -- retries 5xx responses with exponential backoff
8. Create `network/LoggingInterceptor.kt` -- wraps OkHttp logging interceptor with Timber
9. Create `network/OkHttpClientFactory.kt` -- assembles interceptor chain, sets timeouts and cache
10. Create `network/ApiClient.kt` -- creates Retrofit with OkHttp client and JSON converter
11. Create `network/PaginationMeta.kt` -- simple data class
12. Create `network/NetworkMonitor.kt` -- ConnectivityManager wrapper
13. Create `di/NetworkModule.kt` -- Hilt module providing all network singletons
14. Provide a no-op `TokenProvider` implementation in the Hilt module as a placeholder for M0-06
15. Write unit tests for `AuthInterceptor`, `TokenRefreshAuthenticator`, `RetryInterceptor`, `ApiErrorMapper`, `AppError`

**Key OkHttp notes:**
- Use `runBlocking` in `AuthInterceptor.intercept()` to call `suspend fun getAccessToken()`,
  since OkHttp interceptors run on OkHttp's thread pool (not a coroutine context). This is
  the standard pattern for OkHttp + coroutines.
- `TokenRefreshAuthenticator` also uses `runBlocking`. Keep the refresh operation short.
- For the `Mutex`, use `kotlinx.coroutines.sync.Mutex` -- not `java.util.concurrent` locks.
- Ensure the logging interceptor is a **network interceptor** (added via `.addNetworkInterceptor()`)
  so it logs the actual wire-level request/response including redirects.
- Chucker should be an **application interceptor** (added via `.addInterceptor()`).
- `RetryInterceptor` must be an **application interceptor** added AFTER `AuthInterceptor`
  but BEFORE the logging interceptor. Order: Auth -> Retry -> Logging (network) -> Chucker.
- In `RetryInterceptor`, use `Thread.sleep()` for the delay (not coroutine `delay()`),
  since OkHttp interceptors run on synchronous threads. This is acceptable because OkHttp
  manages its own thread pool.

**DI module structure:**
- `NetworkModule` is `@InstallIn(SingletonComponent::class)` with `object` type using `@Provides`
- All network singletons are `@Singleton` scoped
- Feature API interfaces are NOT provided here -- each feature has its own `@Module`

### For iOS Developer

1. Start with `Domain/Error/AppError.swift` -- no dependencies, referenced everywhere
2. Create `Network/HTTPMethod.swift` -- simple enum
3. Create `Network/Endpoint.swift` -- protocol with defaults
4. Create `Network/JSONCoders.swift` -- static decoder/encoder
5. Create `Network/MedusaErrorDTO.swift` -- error response parsing
6. Create `Network/TokenProvider.swift` -- protocol for auth
7. Create `Network/RetryPolicy.swift` -- retry configuration struct
8. Create `Network/AuthMiddleware.swift` -- `actor TokenRefreshActor` for refresh mutex
9. Create `Network/APIClient.swift` -- main client with request method, retry loop, error mapping
10. Create `Network/PaginatedResponse.swift` -- pagination metadata struct
11. Create `Network/NetworkMonitor.swift` -- NWPathMonitor wrapper
12. Create `Network/RequestLogger.swift` -- os.Logger debug logging
13. Register in `Container+Extensions.swift` (Factory): `apiClient`, `networkMonitor`
14. Provide a no-op `TokenProvider` conformance as placeholder for M0-06
15. Write unit tests for `APIClient`, `TokenRefreshActor`, `RetryPolicy`, `JSONCoders`, `AppError`

**Key Swift notes:**
- `APIClient` should be a `final class` (not an actor) since it uses `URLSession` which
  manages its own thread safety. The only actor-protected state is in `TokenRefreshActor`.
- `TokenRefreshActor` is a Swift `actor` to naturally serialize concurrent refresh calls.
- All types crossing concurrency boundaries must be `Sendable`.
- `NetworkMonitor` must be `@MainActor` since its `isConnected` property is observed by
  SwiftUI views. The `NWPathMonitor` callback dispatches to `@MainActor` for updates.
- `Endpoint.body` is typed as `(any Encodable)?`. The `APIClient` erases this to `Data`
  using `JSONEncoder.api.encode()` with a type-erasing wrapper.
- The retry loop in `APIClient` uses `Task.sleep(nanoseconds:)` which is async-friendly
  and supports structured concurrency cancellation. Do NOT use `Thread.sleep`.
- For testing, create a `MockURLProtocol` that intercepts `URLSession` requests and returns
  pre-configured responses. Register it via `URLSessionConfiguration.protocolClasses`.
- `RetryPolicy` is a simple value type with a `static let `default`` factory for standard config.

### Common Rules (Both Platforms)

- Follow `CLAUDE.md` exactly for naming conventions, file locations, architecture layers
- The `TokenProvider` interface/protocol is defined here but its implementation belongs to M0-06
- Provide a no-op placeholder `TokenProvider` that always returns `null`/`nil` so the network
  layer compiles and works for public endpoints before M0-06 is implemented
- All error messages use the string keys created in M0-01 (`common_error_network`, etc.)
- JSON serialization must handle unknown keys gracefully (ignore them, do not crash)
- The network layer must be fully testable with dependency injection (no static singletons
  that cannot be swapped in tests)
- Debug logging must have zero overhead in release builds
- Currency amounts from the API are in the **smallest unit** (e.g., cents). Conversion to
  display format (e.g., EUR 12.99) is handled by feature-level formatters, not the network layer
- Retry policy applies only to 5xx server errors. Client errors (4xx) and network errors are
  never automatically retried
