# Handoff: auth-infrastructure -- iOS Dev

## Feature
**M0-06: Auth Infrastructure** -- iOS implementation of authentication token storage, auth state management, session lifecycle, and token provider integration.

## Status
COMPLETE -- All 11 new files created, 1 existing file modified. Build verified.

## Files Created

| # | File | Description |
|---|------|-------------|
| 1 | `Core/Auth/DTO/LoginRequest.swift` | `Encodable` struct with `email` and `password` fields |
| 2 | `Core/Auth/DTO/RegisterRequest.swift` | `Encodable` struct with `email` and `password` fields |
| 3 | `Core/Auth/DTO/AuthTokenResponse.swift` | `Decodable` struct with `token` field |
| 4 | `Core/Auth/AuthEndpoint.swift` | Enum conforming to `Endpoint` with 5 cases: login, register, createSession, destroySession, refreshToken |
| 5 | `Core/Auth/AuthState.swift` | Enum with `loading`, `authenticated(token:)`, `guest` cases. Conforms to `Equatable, Sendable`. |
| 6 | `Core/Auth/TokenStorage.swift` | Protocol: `getAccessToken()`, `saveAccessToken(_:)`, `clearTokens()`. Conforms to `Sendable`. |
| 7 | `Core/Auth/KeychainTokenStorage.swift` | `final class` implementation using KeychainAccess. Service: `com.xirigo.ecommerce.auth`. Accessibility: `.whenUnlockedThisDeviceOnly`. |
| 8 | `Core/Auth/AuthStateManager.swift` | `@MainActor` protocol: `authState`, `onLoginSuccess(token:)`, `onLogout()`, `checkStoredToken()` |
| 9 | `Core/Auth/AuthStateManagerImpl.swift` | `@MainActor @Observable final class`. Holds `authState` property, coordinates with `TokenStorage`. Uses `nonisolated init` for DI compatibility. |
| 10 | `Core/Auth/SessionManager.swift` | `final class` conforming to `TokenProvider`. Coordinates `APIClient` + `TokenStorage` + `AuthStateManager`. Contains private `RefreshActor` for mutex-protected token refresh and `EmptyResponse` for void endpoints. |
| 11 | `Core/Auth/BiometricTokenStorage.swift` | Protocol stub only -- no implementation until M3. |

## Files Modified

| # | File | Modification |
|---|------|-------------|
| 1 | `Core/DI/Container+Extensions.swift` | Replaced `NoOpTokenProvider` with real auth registrations: `tokenStorage` (singleton), `authStateManager` (singleton), `sessionManager` (singleton). Added `LazyTokenProvider` to break circular dependency between APIClient and SessionManager. |

## Key Design Decisions

### 1. Circular Dependency Resolution
`APIClient -> TokenProvider -> SessionManager -> APIClient` creates a circular resolution in Factory. Solved with `LazyTokenProvider` -- a lightweight wrapper that defers `SessionManager` resolution to first method call rather than construction time.

### 2. SessionManager Conforms to TokenProvider
Rather than creating a separate adapter class, `SessionManager` directly conforms to the `TokenProvider` protocol from the network layer. This bridges `TokenStorage` (low-level keychain access) with `TokenProvider` (network layer contract) in a single type.

### 3. AuthStateManager Protocol is @MainActor
The `AuthStateManager` protocol is annotated `@MainActor` (not `Sendable`) because its implementation is `@Observable` and drives UI state. Callers from non-isolated contexts use `await` to hop to the main actor, which is correct for auth state transitions.

### 4. Void Endpoints Use EmptyResponse
`createSession` and `destroySession` return empty HTTP bodies. A private `EmptyResponse: Decodable` struct handles these through the standard `APIClient.request<T>()` path. Both calls are fire-and-forget with error logging.

### 5. Token Refresh Uses Private Actor
A private `RefreshActor` serializes concurrent refresh attempts. Only one refresh is in-flight at a time; subsequent requests wait for the active task's result.

### 6. No AuthMiddleware Modification
Per the architect's clarification, `APIClient.swift` and `AuthMiddleware.swift` need no code changes. The existing `TokenRefreshActor` in `AuthMiddleware.swift` already uses `TokenProvider`. Swapping `NoOpTokenProvider` with `SessionManager` (via `LazyTokenProvider`) in the DI container is sufficient.

### 7. String Resources Not Added
Per the architect's clarification, auth UI string resources ship with M1-01/M1-02 screens, not M0-06.

## Deviations from Spec

| Spec Says | Actual | Reason |
|-----------|--------|--------|
| `AuthStateManager` protocol is `Sendable` | Protocol is `@MainActor` instead | Swift 6 strict concurrency: `@Observable @MainActor` class cannot conform to `Sendable` protocol without data race issues. `@MainActor` protocol correctly enforces main actor isolation for UI state. |
| `AuthStateManagerImpl` uses standard `init` | Uses `nonisolated init` | Factory DI closures are nonisolated; `@MainActor` init cannot be called from nonisolated context in Swift 6. `nonisolated init` only assigns stored properties (safe). |
| Direct `SessionManager` as `TokenProvider` in Container | `LazyTokenProvider` wrapper | Circular dependency: `apiClient -> tokenProvider -> sessionManager -> apiClient`. Lazy wrapper defers resolution. |

## Build Verification

- Xcode project regenerated via `xcodegen generate`
- `xcodebuild build` with iPhone 16 (iOS 18.6) simulator: **BUILD SUCCEEDED**
- Zero errors, zero project-related warnings
- Swift 6 strict concurrency: complete (no data race warnings)

## Testing Notes

For the iOS Tester:
- `FakeTokenStorage` (in-memory) should be created for unit tests
- Test `AuthStateManagerImpl` state transitions: loading -> guest (no token), loading -> authenticated (stored token), onLoginSuccess, onLogout
- Test `SessionManager` flows: login success, login failure, register success, register 422, logout always clears, refreshToken success/failure
- Test `AuthEndpoint` produces correct path, method, body, requiresAuth for all 5 cases
- Test `KeychainTokenStorage` save/get/clear (integration test with Keychain)
- All tests should use init-based injection (not DI container)
