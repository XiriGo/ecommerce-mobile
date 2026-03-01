# Handoff: auth-infrastructure -- Android Dev

## Feature
**M0-06: Auth Infrastructure** -- Android implementation of authentication token storage, auth state management, session lifecycle, and DI integration for the XiriGo Ecommerce buyer app.

## Status
COMPLETE -- All 12 new files created, 1 existing file modified, build passes.

---

## Files Created

| # | File | Description |
|---|------|-------------|
| 1 | `core/auth/dto/LoginRequest.kt` | `@Serializable data class` with `email` and `password` fields |
| 2 | `core/auth/dto/RegisterRequest.kt` | `@Serializable data class` with `email` and `password` fields |
| 3 | `core/auth/dto/AuthTokenResponse.kt` | `@Serializable data class` with `token` field |
| 4 | `core/auth/AuthApi.kt` | Retrofit interface with 5 endpoints: `login`, `register`, `createSession`, `destroySession`, `refreshToken` |
| 5 | `core/auth/AuthState.kt` | `@Stable sealed interface` with `Loading`, `Authenticated(token)`, `Guest` variants |
| 6 | `core/auth/TokenStorage.kt` | Interface: `getAccessToken()`, `saveAccessToken(token)`, `clearTokens()`, `getAccessTokenFlow()` |
| 7 | `core/auth/EncryptedTokenStorage.kt` | `@Singleton` implementation using dedicated Preferences DataStore + Tink AEAD (AES256_GCM) encryption |
| 8 | `core/auth/AuthStateManager.kt` | Interface: `authState: StateFlow<AuthState>`, `onLoginSuccess(token)`, `onLogout()`, `checkStoredToken()` |
| 9 | `core/auth/AuthStateManagerImpl.kt` | `@Singleton` implementation with `MutableStateFlow`. Reads from `TokenStorage` on `checkStoredToken()`. |
| 10 | `core/auth/SessionManager.kt` | `@Singleton` class coordinating `AuthApi` + `TokenStorage` + `AuthStateManager`. Has `login()`, `register()`, `logout()`, `refreshToken()` with `Mutex`-protected refresh. |
| 11 | `core/auth/BiometricTokenStorage.kt` | Interface stub only (implementation deferred to M3) |
| 12 | `core/auth/di/AuthModule.kt` | Two Hilt modules: `AuthBindsModule` (binds interfaces) and `AuthProvidesModule` (provides `Aead`, `AuthApi`, `TokenProvider`) |

## Files Modified

| # | File | Modification |
|---|------|-------------|
| 1 | `core/di/NetworkModule.kt` | Removed `InMemoryTokenProvider` class and `provideTokenProvider()` method. `TokenProvider` is now provided by `AuthProvidesModule`. |

---

## Key Design Decisions

### 1. SessionTokenProvider adapter pattern
Created a private `SessionTokenProvider` class inside `AuthModule.kt` that implements `core.network.TokenProvider` by delegating `getAccessToken()` to `TokenStorage` and `refreshToken()` to `SessionManager`. This bridges the network layer's `TokenProvider` contract with the auth layer's `TokenStorage` + `SessionManager` without modifying `AuthInterceptor` or `TokenRefreshAuthenticator`.

### 2. Lazy<SessionManager> for circular dependency
`SessionTokenProvider` takes `dagger.Lazy<SessionManager>` instead of `SessionManager` directly. This breaks the circular dependency: `OkHttpClient` -> `TokenProvider` -> `SessionManager` -> `AuthApi` -> Retrofit -> `OkHttpClient`. The lazy reference defers `SessionManager` resolution until first use.

### 3. @UnauthenticatedClient for AuthApi
`AuthApi` is created from a Retrofit instance using the `@UnauthenticatedClient` OkHttpClient. This avoids the circular dependency entirely for login/register (which are public endpoints). For `refreshToken` and `createSession`/`destroySession`, the token is passed explicitly via `@Header("Authorization")` parameter rather than relying on the `AuthInterceptor`.

### 4. Separate encrypted DataStore
Created a dedicated DataStore instance (`xg_auth_encrypted`) for auth tokens, separate from the general preferences DataStore in `StorageModule`. The token value is encrypted using Tink AEAD (AES256_GCM) with a key stored in the Android Keystore.

### 5. Token passed explicitly in AuthApi methods
`createSession`, `destroySession`, and `refreshToken` accept an explicit `@Header("Authorization") bearerToken: String` parameter. This means the caller must format the header value as `"Bearer $token"`. This approach avoids depending on the auth interceptor for auth-related API calls.

### 6. Fire-and-forget logout
`SessionManager.logout()` catches and logs API errors from `destroySession()` but always proceeds to clear local state via `authStateManager.onLogout()`.

### 7. Mutex-protected refresh
`SessionManager.refreshToken()` uses a `kotlinx.coroutines.sync.Mutex` to prevent concurrent refresh attempts. Note that the `TokenRefreshAuthenticator` (from M0-03) also has its own mutex -- the two work together: the authenticator's mutex serializes OkHttp-level retries, while `SessionManager`'s mutex serializes application-level refresh calls.

---

## Deviations from Spec

### 1. AuthInterceptor not modified
Per the architect's clarification, `AuthInterceptor.kt` was NOT modified. The existing implementation already reads from `TokenProvider.getAccessToken()` and the `TokenRefreshAuthenticator` handles 401 retries. Only the DI binding changed (replaced `InMemoryTokenProvider` with `SessionTokenProvider`).

### 2. String resources not added
Per the architect's clarification, auth UI string resources (`auth_login_title`, etc.) are not added in M0-06. They ship with M1-01/M1-02 screen implementations.

### 3. Tink getPrimitive deprecation
Tink 1.16.0 deprecates `KeysetHandle.getPrimitive(Class)` in favor of a registry-configuration-based API. The deprecated call is suppressed with `@Suppress("DEPRECATION")` since the replacement API has limited documentation and the functionality is identical.

---

## Build Verification

```
./gradlew assembleDebug -> BUILD SUCCESSFUL
```

No Kotlin compilation warnings. No lint errors.

---

## Notes for Tester

- All tests should use `FakeTokenStorage` (in-memory implementation) rather than `EncryptedTokenStorage`
- `SessionManager` is the primary API surface -- test `login()`, `register()`, `logout()`, `refreshToken()` flows
- Verify `AuthState` transitions: `Loading` -> `Guest` (no token), `Loading` -> `Authenticated` (stored token), `Authenticated` -> `Guest` (logout)
- Verify concurrent refresh protection via the `Mutex` in `SessionManager.refreshToken()`
- Verify that `logout()` always clears local state even when the API call fails
