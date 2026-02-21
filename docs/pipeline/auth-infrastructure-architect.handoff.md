# Handoff: auth-infrastructure -- Architect (Verified)

## Feature
**M0-06: Auth Infrastructure** -- Authentication token storage, auth state management, session lifecycle, and token refresh for the Molt Marketplace buyer app.

## Status
VERIFIED -- Gap analysis complete. Spec is accurate, API contracts match, and existing code is accounted for.

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/auth-infrastructure.md` |
| This Handoff | `docs/pipeline/auth-infrastructure-architect.handoff.md` |

---

## 1. Gap Analysis: What Already Exists vs What Needs to Be Created

### 1.1 Android -- Already Exists (from M0-03 Network Layer and M0-05 DI Setup)

| # | File | What It Does | Relevant to M0-06 |
|---|------|--------------|--------------------|
| 1 | `core/network/TokenProvider.kt` | Interface with `getAccessToken()`, `refreshToken()`, `clearTokens()` | This is the network layer's abstraction. M0-06 creates `TokenStorage` (a superset with `saveAccessToken` and `getAccessTokenFlow`) and a `SessionManager` that bridges both. |
| 2 | `core/network/AuthInterceptor.kt` | Reads token from `TokenProvider.getAccessToken()`, adds `Authorization: Bearer` header, skips public endpoints | Already functional. M0-06 modifies this to use the real `TokenStorage`-backed `TokenProvider` instead of `InMemoryTokenProvider`. |
| 3 | `core/network/TokenRefreshAuthenticator.kt` | OkHttp `Authenticator` with mutex-protected refresh via `TokenProvider.refreshToken()`, retry limit of 2 | Already functional. M0-06 provides a real `TokenProvider` implementation where `refreshToken()` calls `POST /auth/token/refresh` and stores the result. |
| 4 | `core/di/NetworkModule.kt` | Provides `InMemoryTokenProvider` as the `TokenProvider` singleton; provides `AuthInterceptor`, `TokenRefreshAuthenticator`, authenticated/unauthenticated OkHttp clients | M0-06 must replace the `InMemoryTokenProvider` binding. The new `AuthModule` should provide a `TokenProvider` that delegates to `TokenStorage` + `SessionManager`. |
| 5 | `core/di/Qualifiers.kt` | `@AuthenticatedClient`, `@UnauthenticatedClient`, dispatcher qualifiers | No changes needed. |
| 6 | `core/di/StorageModule.kt` | Provides `DataStore<Preferences>` and Room `MoltDatabase` | No changes needed. M0-06 may use its own encrypted DataStore instance (separate from the general preferences DataStore). |
| 7 | `core/di/CoroutineModule.kt` | Provides dispatchers | No changes needed. |
| 8 | `core/domain/error/AppError.kt` | Sealed class with Network, Server, NotFound, Unauthorized, Unknown | No changes needed. Auth flows map errors to these types. |
| 9 | `core/network/ApiErrorMapper.kt` | Maps `Throwable` to `AppError` (HttpException, IOException, etc.) | No changes needed. SessionManager can use this for error mapping. |
| 10 | `build.gradle.kts` | Already has `implementation(libs.tink)` dependency | No changes needed. |
| 11 | `libs.versions.toml` | Already has `tink = "1.16.0"` | No changes needed. |

### 1.2 Android -- Needs to Be Created (New Files)

All new files go in `android/app/src/main/java/com/molt/marketplace/core/auth/`:

| # | File | Description |
|---|------|-------------|
| 1 | `TokenStorage.kt` | Interface: `getAccessToken()`, `saveAccessToken(token)`, `clearTokens()`, `getAccessTokenFlow()` |
| 2 | `EncryptedTokenStorage.kt` | Implementation using DataStore + Tink AEAD. `@Singleton`. |
| 3 | `AuthState.kt` | Sealed interface: `Loading`, `Authenticated(token)`, `Guest`. `@Stable`. |
| 4 | `AuthStateManager.kt` | Interface: `authState: StateFlow<AuthState>`, `onLoginSuccess(token)`, `onLogout()`, `checkStoredToken()` |
| 5 | `AuthStateManagerImpl.kt` | Implementation with `MutableStateFlow`. Coordinates with `TokenStorage`. `@Singleton`. |
| 6 | `SessionManager.kt` | Coordinates `AuthApi` + `TokenStorage` + `AuthStateManager`. Has `login()`, `register()`, `logout()`, `refreshToken()`. `@Singleton`. |
| 7 | `AuthApi.kt` | Retrofit interface: 5 endpoints. |
| 8 | `dto/LoginRequest.kt` | `@Serializable data class` |
| 9 | `dto/RegisterRequest.kt` | `@Serializable data class` |
| 10 | `dto/AuthTokenResponse.kt` | `@Serializable data class` |
| 11 | `BiometricTokenStorage.kt` | Interface stub only. No implementation. |
| 12 | `di/AuthModule.kt` | Hilt module: binds interfaces, provides `AuthApi`, `SessionManager`. |

### 1.3 Android -- Needs to Be Modified (Existing Files)

| # | File | Modification |
|---|------|-------------|
| 1 | `core/di/NetworkModule.kt` | **Remove** the `InMemoryTokenProvider` class and the `provideTokenProvider()` method. The `TokenProvider` binding moves to `AuthModule`, which provides a real implementation backed by `TokenStorage` + `SessionManager`. |

**Critical Integration Point**: The existing `TokenProvider` interface in `core/network/TokenProvider.kt` has three methods: `getAccessToken()`, `refreshToken()`, `clearTokens()`. The new `SessionManager` must implement `TokenProvider` (or an adapter must be created) so that `AuthInterceptor` and `TokenRefreshAuthenticator` continue to work without modification. The spec's `TokenStorage` is a lower-level storage abstraction; the `TokenProvider` contract bridges `TokenStorage` + `SessionManager` for the network layer.

**Recommended approach**: Create a `SessionTokenProvider` adapter class that implements `core.network.TokenProvider` by delegating `getAccessToken()` to `TokenStorage` and `refreshToken()` to `SessionManager.refreshToken()`. Register this as the `TokenProvider` singleton in `AuthModule`.

### 1.4 iOS -- Already Exists (from M0-03 Network Layer and M0-05 DI Setup)

| # | File | What It Does | Relevant to M0-06 |
|---|------|--------------|--------------------|
| 1 | `Core/Network/TokenProvider.swift` | Protocol with `getAccessToken()`, `refreshToken()`, `clearTokens()`. Also `NoOpTokenProvider`. | Same role as Android. M0-06 provides a real implementation. |
| 2 | `Core/Network/AuthMiddleware.swift` | `TokenRefreshActor` with actor-based mutex for concurrent refresh serialization | Already functional. M0-06 provides a real `TokenProvider` so it actually does work. |
| 3 | `Core/Network/APIClient.swift` | Full API client with auth token injection, 401 handling via `TokenRefreshActor`, retry with backoff | Already functional. Uses `TokenProvider` for auth. No changes needed. |
| 4 | `Core/DI/Container+Extensions.swift` | Registers `NoOpTokenProvider()` as singleton `tokenProvider`, provides `apiClient` | M0-06 must replace `NoOpTokenProvider` with `KeychainTokenStorage`-backed implementation. |
| 5 | `Core/Network/Endpoint.swift` | Protocol: `path`, `method`, `headers`, `queryItems`, `body`, `requiresAuth` | No changes needed. `AuthEndpoint` will conform to this. |
| 6 | `Core/Domain/Error/AppError.swift` | Enum with `network`, `server`, `notFound`, `unauthorized`, `unknown` | No changes needed. |
| 7 | `Package.resolved` | Already has `KeychainAccess` SPM dependency | No changes needed. |

### 1.5 iOS -- Needs to Be Created (New Files)

All new files go in `ios/MoltMarketplace/Core/Auth/`:

| # | File | Description |
|---|------|-------------|
| 1 | `TokenStorage.swift` | Protocol: `getAccessToken()`, `saveAccessToken(_:)`, `clearTokens()` |
| 2 | `KeychainTokenStorage.swift` | Implementation using `KeychainAccess`. Service: `"com.molt.marketplace.auth"`. Accessibility: `.whenUnlockedThisDeviceOnly`. |
| 3 | `AuthState.swift` | Enum: `loading`, `authenticated(token:)`, `guest`. Conforms to `Equatable, Sendable`. |
| 4 | `AuthStateManager.swift` | Protocol: `authState`, `onLoginSuccess(token:)`, `onLogout()`, `checkStoredToken()` |
| 5 | `AuthStateManagerImpl.swift` | `@MainActor @Observable final class`. |
| 6 | `SessionManager.swift` | `final class, Sendable`. Coordinates `APIClient` + `TokenStorage` + `AuthStateManager`. |
| 7 | `AuthEndpoint.swift` | Enum conforming to `Endpoint`. 5 cases. |
| 8 | `DTO/LoginRequest.swift` | `struct: Encodable` |
| 9 | `DTO/RegisterRequest.swift` | `struct: Encodable` |
| 10 | `DTO/AuthTokenResponse.swift` | `struct: Decodable` |
| 11 | `BiometricTokenStorage.swift` | Protocol stub only. |

### 1.6 iOS -- Needs to Be Modified (Existing Files)

| # | File | Modification |
|---|------|-------------|
| 1 | `Core/DI/Container+Extensions.swift` | Replace `NoOpTokenProvider` registration with real `KeychainTokenStorage`-backed `TokenProvider`. Add `tokenStorage`, `authStateManager`, `sessionManager` factory registrations. |

**Critical Integration Point**: Same as Android. The `TokenProvider` protocol in `Core/Network/TokenProvider.swift` is what `APIClient` and `TokenRefreshActor` use. M0-06 must provide a class that conforms to `TokenProvider` and delegates to `TokenStorage` + `SessionManager`. The `SessionManager` itself can conform to `TokenProvider`, or a `SessionTokenProvider` adapter can bridge the two.

**Recommended approach**: Make `SessionManager` conform to `TokenProvider`. Its `getAccessToken()` delegates to `TokenStorage`, `refreshToken()` calls `POST /auth/token/refresh` and stores the result, `clearTokens()` delegates to `TokenStorage`. Register `SessionManager` as the `TokenProvider` singleton.

---

## 2. API Contract Verification

All 5 endpoints in the spec match `shared/api-contracts/auth.json` exactly:

| Spec Section | API Contract | Match |
|--------------|-------------|-------|
| 1.1 Login: `POST /auth/customer/emailpass` | auth.json endpoint 1 | YES -- path, method, auth=false, request body (email, password), response (token), error 401 |
| 1.2 Register: `POST /auth/customer/emailpass/register` | auth.json endpoint 2 | YES -- path, method, auth=false, request body (email, password), response (token), error 422 |
| 1.3 Create Session: `POST /auth/session` | auth.json endpoint 3 | YES -- path, method, auth=true, empty request/response |
| 1.4 Destroy Session: `DELETE /auth/session` | auth.json endpoint 4 | YES -- path, method, auth=true, empty request/response |
| 1.5 Refresh Token: `POST /auth/token/refresh` | auth.json endpoint 5 | YES -- path, method, auth=true, empty request, response (token) |

No discrepancies found between the spec and the API contracts.

---

## 3. Spec Verification Summary

### 3.1 Items Verified as Correct

1. **Data models** (Section 2): AuthState, TokenStorage, AuthStateManager, SessionManager, DTOs -- all well-defined with platform-specific signatures.
2. **State flows** (Section 5): App launch, login, register, logout, token refresh -- all correctly specified with edge case handling.
3. **Error scenarios** (Section 6): Complete error mapping table covering all HTTP statuses and network errors.
4. **Security requirements** (Section 8): Tink (Android), KeychainAccess (iOS), no token in logs, HTTPS only, backup exclusion.
5. **File manifest** (Section 9): Clear file listing for both platforms with descriptions.
6. **Build verification criteria** (Section 11): Comprehensive checklist for both platforms.
7. **Implementation notes** (Section 10): Step-by-step guidance for both Android and iOS developers.

### 3.2 Important Clarifications for Developers

**Clarification 1: TokenProvider vs TokenStorage relationship**

The spec defines `TokenStorage` (Section 2.2) as a new interface/protocol in `core/auth/`. The existing `TokenProvider` (in `core/network/`) was created by M0-03 and is used by `AuthInterceptor`, `TokenRefreshAuthenticator` (Android) and `APIClient`, `TokenRefreshActor` (iOS). These are **two separate abstractions**:

- `TokenStorage` = low-level encrypted storage (save, get, clear, flow)
- `TokenProvider` = network layer contract (get, refresh, clear)

**Action for Android Dev**: Create a `SessionTokenProvider` (or have `SessionManager` implement `TokenProvider`) that bridges `TokenStorage.getAccessToken()` and `SessionManager.refreshToken()`. In `AuthModule`, bind this as the `TokenProvider` singleton. Remove the `provideTokenProvider()` method from `NetworkModule.kt`.

**Action for iOS Dev**: Either make `SessionManager` conform to `TokenProvider`, or create a bridging class. In `Container+Extensions.swift`, replace the `NoOpTokenProvider()` registration with the real implementation.

**Clarification 2: AuthInterceptor does NOT need modification**

The spec (Section 9.1, row 13) says "Modify `AuthInterceptor.kt`". However, the existing `AuthInterceptor` already reads from `TokenProvider.getAccessToken()` and handles 401 via `TokenRefreshAuthenticator`. **No code changes to `AuthInterceptor.kt` are needed** -- only the DI binding changes (swapping `InMemoryTokenProvider` for a real one). The same applies to iOS: `APIClient.swift` and `AuthMiddleware.swift` need no code changes.

**Clarification 3: DataStore for token storage (Android)**

The spec mentions "Proto DataStore + Tink". The existing `StorageModule` already provides a `DataStore<Preferences>` (Preferences DataStore, not Proto DataStore). For M0-06, the developer should create a **separate** encrypted DataStore instance specifically for auth tokens (do not reuse the general preferences DataStore). Use Tink AEAD to encrypt the token value before storing it, or use `EncryptedSharedPreferences` as an alternative if Proto DataStore setup is too complex. The key point is: the token must be encrypted at rest.

**Clarification 4: String resources are for M1-01/M1-02**

The string resources listed in spec Section 9.3 (`auth_login_title`, `auth_register_title`, etc.) are **not needed for M0-06**. They should be added when M1-01 (Login Screen) and M1-02 (Register Screen) are implemented. The only error string keys that M0-06 uses are already defined: `common_error_network`, `common_error_server`, `common_error_unauthorized` (from M0-01 scaffold).

---

## 4. Summary of Work for Downstream Agents

### 4.1 Android Dev

| Category | Count | Details |
|----------|-------|---------|
| New files to create | 12 | All in `core/auth/` (see Section 1.2 above) |
| Files to modify | 1 | `core/di/NetworkModule.kt` -- remove `InMemoryTokenProvider` and `provideTokenProvider()` |
| Test files to create | 6 | 5 test classes + 1 `FakeTokenStorage` (see spec Section 9.4) |
| Key dependency | Tink 1.16.0 | Already in `libs.versions.toml` and `build.gradle.kts` |
| Implementation order | DTOs -> AuthApi -> AuthState -> TokenStorage -> EncryptedTokenStorage -> AuthStateManager -> SessionManager -> AuthModule -> Tests |

### 4.2 iOS Dev

| Category | Count | Details |
|----------|-------|---------|
| New files to create | 11 | All in `Core/Auth/` (see Section 1.5 above) |
| Files to modify | 1 | `Core/DI/Container+Extensions.swift` -- replace NoOp, add auth registrations |
| Test files to create | 6 | 5 test classes + 1 `FakeTokenStorage` (see spec Section 9.4) |
| Key dependency | KeychainAccess | Already in `Package.resolved` |
| Implementation order | DTOs -> AuthEndpoint -> AuthState -> TokenStorage -> KeychainTokenStorage -> AuthStateManager -> SessionManager -> Container registration -> Tests |

---

## 5. Key Decisions (Unchanged from Original)

1. **SessionManager as single public API**: Feature screens inject `SessionManager` and `AuthStateManager`. They do NOT interact with `TokenStorage` or `AuthApi` directly.
2. **Fire-and-forget logout**: Always clears local state regardless of API call result.
3. **Mutex-protected refresh**: Only one token refresh in-flight at a time.
4. **Optimistic session on network failure**: Stored token -> stay Authenticated even if session validation fails due to network.
5. **Customer profile creation not in this layer**: POST /store/customers is M1-02's responsibility.
6. **Biometric stub only**: Interface defined, not implemented until M3.
7. **String keys defined in spec, added with M1 screens**: Auth UI string resources ship with M1-01/M1-02, not M0-06.

---

## 6. Risks and Considerations

1. **Circular dependency risk**: `SessionManager` needs `AuthApi` (Retrofit), but Retrofit needs `OkHttpClient`, which needs `TokenProvider`, which needs `SessionManager` for `refreshToken()`. Break the cycle by using `Lazy<SessionManager>` or `Provider<SessionManager>` in the `TokenProvider` adapter, or by having `TokenRefreshAuthenticator` call `SessionManager.refreshToken()` through a `Lazy` reference.
2. **Thread safety**: `EncryptedTokenStorage` must be thread-safe. DataStore is inherently thread-safe. `KeychainTokenStorage` must use `Sendable`-safe patterns.
3. **Testing without Keychain/Tink**: All tests should use `FakeTokenStorage` (in-memory). No real encryption in unit tests.
4. **Startup performance**: `checkStoredToken()` does network I/O (session validation). This must run off the main thread and not block app launch. The UI shows normally while auth state is `Loading`.

---

## 7. Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | File manifest (Section 1.2 + 1.3), data models (spec Section 2), state flows (spec Section 5), implementation notes (spec Section 10.1), clarifications (Section 3.2) |
| iOS Dev | File manifest (Section 1.5 + 1.6), data models (spec Section 2), state flows (spec Section 5), implementation notes (spec Section 10.2), clarifications (Section 3.2) |

## Notes for Next Features

- **M1-01 (Login Screen)**: Inject `SessionManager` and `AuthStateManager`. Call `sessionManager.login(email, password)`. Observe `authStateManager.authState` for navigation.
- **M1-02 (Register Screen)**: Inject `SessionManager`. Call `sessionManager.register(email, password)`. Then call customer creation API (POST /store/customers) separately.
- **M1-03 (Forgot Password)**: Uses customer endpoints, not auth endpoints. Auth infrastructure not directly involved.
- **M0-04 (Navigation)**: Observe `AuthStateManager.authState` for route guards.
- **M3 (Biometric)**: Implement `BiometricTokenStorage`, register in DI, integrate with `SessionManager`.
