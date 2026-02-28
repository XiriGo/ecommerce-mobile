# M0-06: Auth Infrastructure

## Overview

Auth Infrastructure is the foundational authentication layer for the XiriGo Ecommerce buyer app. It provides secure token storage, auth state management, session lifecycle (create, refresh, destroy), and the bridge between the network interceptor layer (M0-03) and all M1+ feature screens. This is a purely infrastructure feature — it contains no UI screens.

**Status**: Complete
**Phase**: M0 (Foundation)
**Platforms**: Android (Kotlin + Hilt) + iOS (Swift + Factory)
**Blocked By**: M0-03 (Network Layer), M0-05 (DI Setup)
**Blocks**: M1-01 (Login Screen), M1-02 (Register Screen), M0-04 (Navigation auth gating)

### What This Feature Provides

- `TokenStorage` interface + `EncryptedTokenStorage` (Android, Tink AES256_GCM) / `KeychainTokenStorage` (iOS, KeychainAccess) implementations for encrypted-at-rest JWT storage
- `AuthState` sealed interface (Android) / enum (iOS): `Loading`, `Authenticated(token)`, `Guest`
- `AuthStateManager` interface + implementation: observable `StateFlow<AuthState>` (Android) / `@Observable authState` (iOS) with `checkStoredToken()`, `onLoginSuccess()`, `onLogout()`
- `SessionManager` as the single public API for M1+ feature screens: coordinates `AuthApi` + `TokenStorage` + `AuthStateManager` for full login, register, logout, and token refresh flows
- `AuthApi` (Android Retrofit interface) / `AuthEndpoint` (iOS Endpoint enum) covering 5 auth endpoints
- `BiometricTokenStorage` interface stub (implementation deferred to M3)
- DI wiring: `AuthModule` (Android Hilt) / `Container+Extensions.swift` auth registrations (iOS); replaces `InMemoryTokenProvider` / `NoOpTokenProvider` with a real `SessionManager`-backed `TokenProvider`

### Dependencies

| Depends On | What Is Needed |
|-----------|----------------|
| M0-03: Network Layer | `TokenProvider` interface, `AuthInterceptor` / `AuthMiddleware`, `APIClient`, `AppError` types |
| M0-05: DI Setup | Hilt `SingletonComponent` + `@UnauthenticatedClient`, Factory Container + `apiClient` singleton |
| M0-01: App Scaffold | Tink (Android) + KeychainAccess (iOS) already in dependency catalog |

### Features That Depend on This

| Feature | What It Needs |
|---------|--------------|
| M1-01: Login Screen | `SessionManager.login(email, password)`, observe `AuthStateManager.authState` |
| M1-02: Register Screen | `SessionManager.register(email, password)`, observe `AuthStateManager.authState` |
| M0-04: Navigation | `AuthStateManager.authState` for route guards and auth-gated redirects |
| M2-01: Cart | `AuthState` to require login before checkout |
| M2-02: Wishlist | `AuthState` to sync wishlist when authenticated |
| M3-03: User Profile | `AuthState.Authenticated` token for authorized API calls |
| All auth-required features | `TokenStorage` provides token to `AuthInterceptor` / `AuthMiddleware` via `TokenProvider` |

---

## Architecture

### Three-Layer Abstraction

```
Network Layer (M0-03)           Auth Layer (M0-06)
─────────────────────           ──────────────────────────────────────
TokenProvider  <────────────── SessionTokenProvider (Android adapter)
                                SessionManager (iOS — conforms directly)
                                    │
                                    ├── AuthApi / AuthEndpoint
                                    ├── TokenStorage (EncryptedTokenStorage / KeychainTokenStorage)
                                    └── AuthStateManager (AuthStateManagerImpl)
```

**TokenStorage vs TokenProvider**

| Abstraction | Location | Purpose |
|-------------|----------|---------|
| `TokenStorage` | `core/auth/` | Low-level encrypted storage: save, get, clear, observe |
| `TokenProvider` | `core/network/` | Network contract used by `AuthInterceptor` / `APIClient`: get, refresh, clear |

`TokenStorage` is the storage layer. `TokenProvider` is the network contract. M0-06 bridges them:
- **Android**: A private `SessionTokenProvider` class inside `AuthModule.kt` implements `TokenProvider` by delegating `getAccessToken()` to `TokenStorage` and `refreshToken()` to `SessionManager`. `Lazy<SessionManager>` breaks the circular dependency `OkHttpClient -> TokenProvider -> SessionManager -> AuthApi -> Retrofit -> OkHttpClient`.
- **iOS**: `SessionManager` directly conforms to `TokenProvider`. A `LazyTokenProvider` wrapper in `Container+Extensions.swift` defers resolution to first call, breaking the same circular dependency.

### SessionManager as Single Public API

Feature screens (M1+) inject `SessionManager` and `AuthStateManager` only. They do NOT interact with `TokenStorage` or `AuthApi` directly.

```
Feature Screen / ViewModel
    │
    ├── SessionManager.login / register / logout / refreshToken
    │       │
    │       ├── AuthApi (Retrofit / AuthEndpoint)       ← API calls
    │       ├── TokenStorage.saveAccessToken / clear    ← Encrypted storage
    │       └── AuthStateManager.onLoginSuccess / onLogout
    │
    └── AuthStateManager.authState (StateFlow / @Observable)
            │
            └── AuthState: Loading | Authenticated(token) | Guest
```

### AuthState Lifecycle

```
                    +----------+
     App Launch --> | Loading  |
                    +----+-----+
                         │
              ┌──────────┴──────────┐
              │                     │
        token found            no token
              │                     │
              ▼                     ▼
     +-----------------+      +---------+
     | Authenticated   |<---->|  Guest  |
     | (token: String) |      |         |
     +-----------------+      +---------+
          │        ▲             ▲  │
          │        │             │  │
     logout/    login/        logout │
     token     register              │
     expired                    login/register
```

### Circular Dependency Resolution

Both platforms resolve `APIClient -> TokenProvider -> SessionManager -> APIClient`:
- **Android**: `Lazy<SessionManager>` in `SessionTokenProvider` — Hilt defers `SessionManager` resolution to first use.
- **iOS**: `LazyTokenProvider` in `Container+Extensions.swift` — Factory defers `SessionManager` resolution to first method call.

---

## API Endpoints

All endpoints are defined in `shared/api-contracts/auth.json`. Base path: `/auth`.

| # | Method | Path | Auth Required | Description |
|---|--------|------|---------------|-------------|
| 1 | `POST` | `/auth/customer/emailpass` | No | Login — returns JWT |
| 2 | `POST` | `/auth/customer/emailpass/register` | No | Register — returns JWT |
| 3 | `POST` | `/auth/session` | Yes (Bearer) | Create session |
| 4 | `DELETE` | `/auth/session` | Yes (Bearer) | Destroy session (logout) |
| 5 | `POST` | `/auth/token/refresh` | Yes (Bearer) | Refresh expired JWT |

### Request / Response DTOs

```
LoginRequest    { email: String, password: String }
RegisterRequest { email: String, password: String }
AuthTokenResponse { token: String }
```

`POST /auth/session` and `DELETE /auth/session` use empty request and response bodies. `createSession` / `destroySession` on Android accept an explicit `@Header("Authorization") bearerToken: String` parameter; the caller formats it as `"Bearer $token"`. iOS uses an `EmptyResponse: Decodable` struct to route through the standard `APIClient.request<T>()` path.

### Error Responses

| Endpoint | Status | Error Type | Mapped AppError |
|----------|--------|------------|-----------------|
| Login | 401 | `unauthorized` | `Unauthorized` |
| Register | 422 | `duplicate` | `Server(422, msg)` |
| Token Refresh | 401 | `unauthorized` | `Unauthorized` (clears tokens) |
| Any auth endpoint | 5xx | — | `Server(code, msg)` |
| Any auth endpoint | network | — | `Network` |

---

## State Management

### App Launch Flow

1. App starts, `AuthState = Loading`
2. `AuthStateManager.checkStoredToken()` reads from `TokenStorage`
3. **Token found**: Set `Authenticated(token)`, call `POST /auth/session` to validate
   - 200 OK: stay `Authenticated`
   - 401: attempt `POST /auth/token/refresh`
     - 200 OK: store new token, set `Authenticated(newToken)`, retry `POST /auth/session`
     - 401/Error: `clearTokens()`, set `Guest`
   - Network error: stay `Authenticated` (offline-capable; stored token may work when network returns)
4. **No token found**: set `Guest`

### Login Flow

1. UI calls `SessionManager.login(email, password)`
2. `POST /auth/customer/emailpass` → `AuthTokenResponse`
3. `TokenStorage.saveAccessToken(token)`
4. `POST /auth/session` (fire-and-forget; session failure does NOT abort login)
5. `AuthStateManager.onLoginSuccess(token)` → `AuthState = Authenticated(token)`
6. Returns `Result.success` / no throw

On failure at step 2: 401 → `AppError.Unauthorized`; network error → `AppError.Network`.

### Register Flow

Same as login flow but calls `POST /auth/customer/emailpass/register`. On 422, maps to `AppError.Server(422, "Email already registered")`. Customer profile creation (`POST /store/customers`) is M1-02's responsibility, not this layer.

### Logout Flow

1. UI calls `SessionManager.logout()`
2. `DELETE /auth/session` — fire-and-forget; API failure is logged, not surfaced
3. `TokenStorage.clearTokens()`
4. `AuthStateManager.onLogout()` → `AuthState = Guest`
5. Navigation layer observes `Guest` and handles redirect

Logout always succeeds locally. The local state is authoritative.

### Token Refresh Flow (Auth Interceptor Integration)

Handled by the existing `TokenRefreshAuthenticator` (Android) / `TokenRefreshActor` (iOS) from M0-03. M0-06 provides the real `TokenProvider` implementation so these components now actually perform network refresh:

1. Interceptor/middleware detects 401 on any API call
2. Acquires refresh mutex (one refresh at a time)
3. Checks if token already changed → if so, retry with new token directly
4. Calls `POST /auth/token/refresh` via `SessionManager.refreshToken()`
5. 200 OK: store new token, update `AuthState`, retry original request
6. 401/Error: `clearTokens()`, set `AuthState = Guest`, propagate `AppError.Unauthorized`

---

## Security

| Concern | Android | iOS |
|---------|---------|-----|
| Token storage | Encrypted DataStore (`molt_auth_encrypted`) with Tink AEAD AES256_GCM; key in Android Keystore | Keychain via KeychainAccess; service `com.xirigo.ecommerce.auth`; accessibility `.whenUnlockedThisDeviceOnly` |
| Token in logs | Never — `Authorization` header value redacted in all HTTP logging | Never — same policy |
| Token transmission | `Authorization: Bearer {token}` header only; never in URL query params | Same policy |
| Backup exclusion | DataStore file excluded from Android auto-backup via `android:fullBackupContent` | Keychain `.whenUnlockedThisDeviceOnly` excludes from iCloud backup |
| Network | HTTPS enforced via `network_security_config.xml`; cleartext blocked in production | HTTPS enforced via App Transport Security |
| Biometric stub | `BiometricTokenStorage` interface defined; not registered in DI until M3 | Same — protocol stub only |
| Multi-device | Users may be logged in on multiple devices; each device has its own independent JWT | Same policy |

---

## File Structure

### Android

Base path: `android/app/src/main/java/com/xirigo/ecommerce/`

```
core/
  auth/
    TokenStorage.kt               # Interface: getAccessToken, saveAccessToken, clearTokens, getAccessTokenFlow
    EncryptedTokenStorage.kt      # @Singleton; DataStore<Preferences> + Tink AEAD (AES256_GCM); separate from general prefs DataStore
    AuthState.kt                  # @Stable sealed interface: Loading, Authenticated(token), Guest
    AuthStateManager.kt           # Interface: authState: StateFlow<AuthState>, onLoginSuccess, onLogout, checkStoredToken
    AuthStateManagerImpl.kt       # @Singleton; MutableStateFlow<AuthState>(Loading); reads TokenStorage on checkStoredToken
    SessionManager.kt             # @Singleton; login, register, logout, refreshToken; Mutex-protected refresh
    AuthApi.kt                    # Retrofit interface: login, register, createSession, destroySession, refreshToken
    BiometricTokenStorage.kt      # Interface stub only (M3)
    dto/
      LoginRequest.kt             # @Serializable data class
      RegisterRequest.kt          # @Serializable data class
      AuthTokenResponse.kt        # @Serializable data class
    di/
      AuthModule.kt               # AuthBindsModule (binds TokenStorage, AuthStateManager) + AuthProvidesModule
                                  # (provides Aead, AuthApi via @UnauthenticatedClient Retrofit, SessionTokenProvider)
  di/
    NetworkModule.kt              # MODIFIED: removed InMemoryTokenProvider + provideTokenProvider()
                                  # TokenProvider binding moved to AuthModule (SessionTokenProvider)
```

### iOS

Base path: `ios/XiriGoEcommerce/`

```
Core/
  Auth/
    TokenStorage.swift            # Protocol: getAccessToken, saveAccessToken, clearTokens; Sendable
    KeychainTokenStorage.swift    # final class; KeychainAccess; service "com.xirigo.ecommerce.auth"; .whenUnlockedThisDeviceOnly
    AuthState.swift               # enum: loading, authenticated(token:), guest; Equatable, Sendable
    AuthStateManager.swift        # @MainActor protocol: authState, onLoginSuccess, onLogout, checkStoredToken
    AuthStateManagerImpl.swift    # @MainActor @Observable final class; nonisolated init for Factory DI
    SessionManager.swift          # final class; conforms to TokenProvider; private RefreshActor for mutex-protected refresh
    AuthEndpoint.swift            # enum: Endpoint; 5 cases; maps to path, method, body, requiresAuth
    BiometricTokenStorage.swift   # Protocol stub only (M3)
    DTO/
      LoginRequest.swift          # struct: Encodable
      RegisterRequest.swift       # struct: Encodable
      AuthTokenResponse.swift     # struct: Decodable
  DI/
    Container+Extensions.swift    # MODIFIED: replaced NoOpTokenProvider with LazyTokenProvider;
                                  # added tokenStorage, authStateManager, sessionManager singletons
```

### Test Files

**Android** base: `android/app/src/test/java/com/xirigo/ecommerce/core/auth/`

| File | Tests | Description |
|------|-------|-------------|
| `FakeTokenStorage.kt` | — | In-memory `TokenStorage` using `MutableStateFlow<String?>`; reused by all test classes |
| `TokenStorageTest.kt` | 11 | `FakeTokenStorage` contract: save/get/clear, flow emissions, overwrite semantics |
| `AuthStateManagerTest.kt` | 20 | State transitions, `checkStoredToken`, `onLoginSuccess`, `onLogout`, `AuthState` equality |
| `SessionManagerTest.kt` | 20 | login/register/logout/refreshToken flows; includes `FakeAuthApi` with call count tracking |
| `AuthModuleTest.kt` | 14 | DI wiring contracts: `TokenStorage` round-trips, `SessionTokenProvider` delegation |

**iOS** base: `ios/XiriGoEcommerceTests/Core/Auth/`

| File | Tests | Description |
|------|-------|-------------|
| `FakeTokenStorage.swift` | — | In-memory `TokenStorage` with call count tracking |
| `TokenStorageTests.swift` | 9 | save/get/clear, nil initial state, overwrite, call counts |
| `AuthStateManagerTests.swift` | 11 | Loading->guest/authenticated transitions, onLoginSuccess, onLogout, full lifecycle |
| `SessionManagerTests.swift` | 14 | login/register/logout/refreshToken; `TokenProvider` conformance (`getAccessToken`, `clearTokens`) |
| `AuthEndpointTests.swift` | 22 | All 5 endpoints: path, method, body, requiresAuth; default headers and queryItems |

---

## Testing Summary

| Platform | Test Files | Test Cases | Estimated Coverage |
|----------|-----------|------------|--------------------|
| Android | 5 (+ 1 stale fix) | 65 | >= 85% lines, >= 75% branches |
| iOS | 5 | 56 | ~95% (AuthStateManagerImpl), ~85% (SessionManager), 100% (AuthEndpoint, TokenStorage protocol) |
| **Total** | **10** | **121** | |

Test patterns:
- **Fakes over mocks**: `FakeTokenStorage` (both platforms), `FakeAuthApi` (Android)
- **Android**: `runTest` + Turbine `StateFlow` / `Flow` assertions; `Truth.assertThat`; backtick natural language test names
- **iOS**: Swift Testing (`@Test`, `@Suite`, `#expect`); `MockURLProtocol` for HTTP-level tests; `@MainActor` for `@Observable` types; `@Suite(.serialized)` for shared `MockURLProtocol` state

Also fixed: `android/app/src/test/java/com/xirigo/ecommerce/core/di/NetworkModuleTest.kt` (stale reference to removed `provideTokenProvider()`).

---

## Integration Points for Downstream Features

| Feature | What to Inject | How to Use |
|---------|---------------|------------|
| M1-01: Login Screen | `SessionManager`, `AuthStateManager` | Call `sessionManager.login(email, password)`; observe `authStateManager.authState` for navigation |
| M1-02: Register Screen | `SessionManager`, `AuthStateManager` | Call `sessionManager.register(email, password)`; call `POST /store/customers` separately after success |
| M0-04: Navigation | `AuthStateManager` | Observe `authState` for route guards; `Guest` → show Login modal with `returnTo` redirect |
| M2-01: Cart | `AuthStateManager` | Check `authState == .authenticated` before allowing checkout |
| All auth-required features | `AuthStateManager` | `authState == .authenticated` is the gate; no need to read `TokenStorage` directly |
| M3: Biometric | DI container | Implement `BiometricTokenStorage`, register in `AuthModule` / `Container`, wire into `SessionManager` |

### M1-01 / M1-02 ViewModel Pattern

**Android:**
```kotlin
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val sessionManager: SessionManager,
    private val authStateManager: AuthStateManager,
) : ViewModel() {
    val authState: StateFlow<AuthState> = authStateManager.authState
        .stateIn(viewModelScope, SharingStarted.Eagerly, AuthState.Loading)

    fun login(email: String, password: String) {
        viewModelScope.launch {
            sessionManager.login(email, password)
                .onSuccess { /* navigation handled by authState observer */ }
                .onFailure { /* map AppError to UI state */ }
        }
    }
}
```

**iOS:**
```swift
@MainActor @Observable
final class LoginViewModel {
    private let sessionManager: SessionManager
    private let authStateManager: AuthStateManagerImpl

    init(
        sessionManager: SessionManager = Container.shared.sessionManager(),
        authStateManager: AuthStateManagerImpl = Container.shared.authStateManager()
    ) {
        self.sessionManager = sessionManager
        self.authStateManager = authStateManager
    }

    var authState: AuthState { authStateManager.authState }

    func login(email: String, password: String) async {
        do {
            try await sessionManager.login(email: email, password: password)
            // navigation driven by authState observation
        } catch {
            // map AppError to UI state
        }
    }
}
```

---

## Documentation References

- **Feature Spec**: `shared/feature-specs/auth-infrastructure.md`
- **API Contracts**: `shared/api-contracts/auth.json`
- **Architect Handoff**: `docs/pipeline/auth-infrastructure-architect.handoff.md`
- **Android Dev Handoff**: `docs/pipeline/auth-infrastructure-android-dev.handoff.md`
- **iOS Dev Handoff**: `docs/pipeline/auth-infrastructure-ios-dev.handoff.md`
- **Android Test Handoff**: `docs/pipeline/auth-infrastructure-android-test.handoff.md`
- **iOS Test Handoff**: `docs/pipeline/auth-infrastructure-ios-test.handoff.md`
- **CLAUDE.md Standards**: `CLAUDE.md`

---

**Last Updated**: 2026-02-21
**Agent**: doc-writer
**Status**: Complete
