# M0-06: Auth Infrastructure -- Feature Specification

## Overview

Auth Infrastructure is the foundational authentication layer for the Molt Marketplace buyer
app. It provides secure token storage, auth state management, session lifecycle (create, refresh,
destroy), and the auth interceptor/middleware integration point used by the network layer (M0-03).
This is a purely infrastructure layer -- it contains no screens or UI. Login, Register, and
Forgot Password screens are defined in M1-01, M1-02, and M1-03 respectively.

### User Stories

- As a **buyer**, I want my login session to persist across app restarts so I do not have to log in every time I open the app.
- As a **buyer**, I want my session to refresh automatically so I am not logged out unexpectedly while browsing or checking out.
- As a **buyer**, I want to use biometric authentication for quick login after my first successful login (future M3).
- As a **developer**, I want a clear auth state model (Loading, Authenticated, Guest) so I can gate features on login status throughout the app.
- As a **developer**, I want the auth interceptor to handle 401 responses transparently so feature code does not need to worry about token expiry.
- As a **developer**, I want token storage encrypted at rest so sensitive credentials are protected.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Secure token storage (encrypted) | Login screen UI (M1-01) |
| Auth state model and state manager | Register screen UI (M1-02) |
| Session create/destroy API calls | Forgot Password screen UI (M1-03) |
| Token refresh flow | Biometric authentication prompt (M3) |
| Auth interceptor/middleware hook for network layer | Customer profile fetching (M3-03) |
| Login and register API call coordination | Customer creation (POST /store/customers) |
| Logout flow (clear tokens, reset state) | Push notification token registration |
| DTOs for auth request/response | Password reset flow (M1-03) |
| DI registration of auth components | Cart clearing on logout (M2-01 concern) |
| Biometric key storage interface (stub only) | Social login / OAuth providers |

### Dependencies on Other Features

| Feature | Dependency |
|---------|-----------|
| M0-03 (Network Layer) | Provides API client, HTTP interceptor/middleware, base URL resolution |
| M0-05 (DI Setup) | Provides Hilt modules (Android) and Factory container (iOS) for registering auth components |
| M0-01 (App Scaffold) | Provides encrypted storage libraries (Tink, KeychainAccess) in dependency catalog |

### Features That Depend on This

| Feature | What It Needs |
|---------|--------------|
| M1-01 (Login Screen) | `SessionManager.login(email, password)`, `AuthState` observation |
| M1-02 (Register Screen) | `SessionManager.register(email, password)`, `AuthState` observation |
| M1-03 (Forgot Password) | Auth state to redirect after password reset |
| M0-04 (Navigation) | `AuthState` observation to gate protected screens and handle redirects |
| M2-01 (Cart) | `AuthState` to require login before checkout |
| M2-02 (Wishlist) | `AuthState` to sync wishlist when authenticated |
| M3-03 (User Profile) | `AuthState.Authenticated` token for authorized API calls |
| All auth-required features | `TokenStorage` provides token to network interceptor/middleware |

---

## 1. API Mapping

All endpoints are defined in `shared/api-contracts/auth.json`. Base path: `/auth`.

### 1.1 Login

```
POST /auth/customer/emailpass
```

| Property | Value |
|----------|-------|
| Auth Required | No |
| Content-Type | application/json |

**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response 200:**
```json
{
  "token": "string (JWT)"
}
```

**Error 401:**
```json
{
  "type": "unauthorized",
  "message": "Invalid email or password"
}
```

### 1.2 Register

```
POST /auth/customer/emailpass/register
```

| Property | Value |
|----------|-------|
| Auth Required | No |
| Content-Type | application/json |

**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response 200:**
```json
{
  "token": "string (JWT)"
}
```

**Error 422:**
```json
{
  "type": "duplicate",
  "message": "Email already registered"
}
```

### 1.3 Create Session

```
POST /auth/session
```

| Property | Value |
|----------|-------|
| Auth Required | Yes (Bearer token) |
| Content-Type | application/json |

**Request Body:** (empty)

**Response 200:** (empty body, 200 status confirms session created)

### 1.4 Logout (Destroy Session)

```
DELETE /auth/session
```

| Property | Value |
|----------|-------|
| Auth Required | Yes (Bearer token) |

**Request Body:** (empty)

**Response 200:** (empty body, 200 status confirms session destroyed)

### 1.5 Refresh Token

```
POST /auth/token/refresh
```

| Property | Value |
|----------|-------|
| Auth Required | Yes (Bearer token -- current/expired token) |
| Content-Type | application/json |

**Request Body:** (empty)

**Response 200:**
```json
{
  "token": "string (new JWT)"
}
```

**Error 401:** Token is irrecoverably expired. Client must clear tokens and redirect to Guest state.

---

## 2. Data Models

### 2.1 Auth State

A sealed interface (Android) / enum (iOS) representing the current authentication state of the app.

```
AuthState
  |-- Loading         No properties. App startup -- checking stored token.
  |-- Authenticated   token: String. Valid session with JWT.
  |-- Guest           No properties. No token, browsing as guest.
```

**Android (Kotlin):**
```
@Stable
sealed interface AuthState {
    data object Loading : AuthState
    data class Authenticated(val token: String) : AuthState
    data object Guest : AuthState
}
```

**iOS (Swift):**
```
enum AuthState: Equatable, Sendable {
    case loading
    case authenticated(token: String)
    case guest
}
```

### 2.2 Token Storage (Interface / Protocol)

Abstracts secure storage so implementations can be swapped (encrypted preferences, keychain, in-memory for tests).

| Method | Signature (Android) | Signature (iOS) | Description |
|--------|---------------------|-----------------|-------------|
| getAccessToken | `suspend fun getAccessToken(): String?` | `func getAccessToken() -> String?` | Retrieve stored JWT |
| saveAccessToken | `suspend fun saveAccessToken(token: String)` | `func saveAccessToken(_ token: String)` | Persist JWT securely |
| clearTokens | `suspend fun clearTokens()` | `func clearTokens()` | Remove all stored tokens |
| getAccessTokenFlow | `fun getAccessTokenFlow(): Flow<String?>` | N/A (not needed; iOS uses direct reads) | Observe token changes reactively |

### 2.3 Auth State Manager (Interface / Protocol)

Manages the observable auth state and coordinates state transitions.

| Method | Signature (Android) | Signature (iOS) | Description |
|--------|---------------------|-----------------|-------------|
| authState | `val authState: StateFlow<AuthState>` | `var authState: AuthState { get }` (published via `@Observable`) | Current auth state, observable |
| onLoginSuccess | `suspend fun onLoginSuccess(token: String)` | `func onLoginSuccess(token: String)` | Store token, set Authenticated |
| onLogout | `suspend fun onLogout()` | `func onLogout()` | Clear tokens, set Guest |
| checkStoredToken | `suspend fun checkStoredToken()` | `func checkStoredToken() async` | App launch: check storage, validate, set state |

### 2.4 Session Manager

Coordinates end-to-end auth flows by combining API calls, token storage, and state management.

| Method | Signature (Android) | Signature (iOS) | Description |
|--------|---------------------|-----------------|-------------|
| login | `suspend fun login(email: String, password: String): Result<Unit>` | `func login(email: String, password: String) async throws` | Full login flow |
| register | `suspend fun register(email: String, password: String): Result<Unit>` | `func register(email: String, password: String) async throws` | Full registration flow |
| logout | `suspend fun logout()` | `func logout() async` | Full logout flow |
| refreshToken | `suspend fun refreshToken(): Result<String>` | `func refreshToken() async throws -> String` | Refresh and store new token |

### 2.5 DTOs

**LoginRequest:**
```
Fields:
  email: String
  password: String

Android: @Serializable data class LoginRequest(val email: String, val password: String)
iOS:     struct LoginRequest: Encodable { let email: String; let password: String }
```

**RegisterRequest:**
```
Fields:
  email: String
  password: String

Android: @Serializable data class RegisterRequest(val email: String, val password: String)
iOS:     struct RegisterRequest: Encodable { let email: String; let password: String }
```

**AuthTokenResponse:**
```
Fields:
  token: String

Android: @Serializable data class AuthTokenResponse(val token: String)
iOS:     struct AuthTokenResponse: Decodable { let token: String }
```

### 2.6 Auth API / Endpoint Definitions

**Android (Retrofit interface):**
```
interface AuthApi {
    @POST("auth/customer/emailpass")
    suspend fun login(@Body request: LoginRequest): AuthTokenResponse

    @POST("auth/customer/emailpass/register")
    suspend fun register(@Body request: RegisterRequest): AuthTokenResponse

    @POST("auth/session")
    suspend fun createSession()

    @DELETE("auth/session")
    suspend fun destroySession()

    @POST("auth/token/refresh")
    suspend fun refreshToken(): AuthTokenResponse
}
```

**iOS (Endpoint enum):**
```
enum AuthEndpoint: Endpoint {
    case login(email: String, password: String)
    case register(email: String, password: String)
    case createSession
    case destroySession
    case refreshToken

    // Each case maps to path, method, body, and auth requirement
}
```

---

## 3. UI Wireframe

Not applicable. This feature is infrastructure only with no user-facing screens.

Auth screens are defined in:
- **M1-01**: Login Screen
- **M1-02**: Register Screen
- **M1-03**: Forgot Password Screen

---

## 4. Navigation Flow

Auth infrastructure does not own any screens, but it drives navigation decisions through `AuthState` observation.

### 4.1 Auth State Navigation Effects

```
AuthState Change                    Navigation Action
-------------------------------     -------------------------------------------
Guest -> Authenticated              Pop auth flow, navigate to returnTo or Home
Authenticated -> Guest (logout)     Pop all stacks, switch to Home tab
Loading -> Guest                    No navigation (app remains on current screen)
Loading -> Authenticated            No navigation (app remains on current screen)
```

### 4.2 Protected Route Gating

The navigation layer (M0-04) observes `AuthState` and implements route guards:

```
User taps protected action (checkout, view orders, etc.)
  |
  |-- AuthState == Authenticated?
  |     YES -> Allow navigation to protected screen
  |     NO  -> Store returnTo destination, present Login modal
  |              |
  |              |-- Login success -> AuthState = Authenticated -> navigate to returnTo
  |              |-- Login dismissed -> Stay on current screen
```

### 4.3 Integration Points

- **Navigation layer (M0-04)** observes `AuthStateManager.authState` to handle redirects
- **Tab bar Profile section** displays different content based on `AuthState`
- **Cart Checkout button** checks `AuthState` before allowing checkout

---

## 5. State Management

### 5.1 App Launch Flow

```
+------------------------------------------------------------------+
|  1. App starts                                                   |
|     AuthState = Loading                                          |
|                                                                  |
|  2. AuthStateManager.checkStoredToken()                          |
|     |                                                            |
|     +-- Token found in storage?                                  |
|     |     |                                                      |
|     |     +-- YES:                                               |
|     |     |     a. Set AuthState = Authenticated(token)          |
|     |     |     b. Call POST /auth/session to validate           |
|     |     |        |                                             |
|     |     |        +-- 200 OK: Session valid, stay Authenticated |
|     |     |        |                                             |
|     |     |        +-- 401 Unauthorized:                         |
|     |     |              c. Call POST /auth/token/refresh        |
|     |     |                 |                                    |
|     |     |                 +-- 200 OK:                          |
|     |     |                 |     Store new token                |
|     |     |                 |     AuthState = Authenticated(new) |
|     |     |                 |     Call POST /auth/session        |
|     |     |                 |                                    |
|     |     |                 +-- 401 / Error:                     |
|     |     |                       clearTokens()                  |
|     |     |                       AuthState = Guest              |
|     |     |                                                      |
|     |     +-- Network error during validation:                   |
|     |           Stay Authenticated(token) -- offline-capable     |
|     |           (token may work when network returns)            |
|     |                                                            |
|     +-- NO token in storage:                                     |
|           AuthState = Guest                                      |
+------------------------------------------------------------------+
```

### 5.2 Login Flow

```
1. UI calls SessionManager.login(email, password)
2. SessionManager calls AuthApi: POST /auth/customer/emailpass
3. Receives AuthTokenResponse { token }
4. Calls TokenStorage.saveAccessToken(token)
5. Calls AuthApi: POST /auth/session (with new token in header)
6. Calls AuthStateManager.onLoginSuccess(token)
7. AuthState transitions to Authenticated(token)
8. Returns Result.success / no throw
```

**On failure at step 2:**
- 401 -> Map to AppError.Unauthorized, return Result.failure / throw
- Network error -> Map to AppError.Network, return Result.failure / throw

**On failure at step 5 (session creation):**
- Log warning but do NOT fail the login -- token is valid
- Some endpoints may work without explicit session

### 5.3 Register Flow

```
1. UI calls SessionManager.register(email, password)
2. SessionManager calls AuthApi: POST /auth/customer/emailpass/register
3. Receives AuthTokenResponse { token }
4. Calls TokenStorage.saveAccessToken(token)
5. Calls AuthApi: POST /auth/session (with new token in header)
6. Calls AuthStateManager.onLoginSuccess(token)
7. AuthState transitions to Authenticated(token)
8. Returns Result.success / no throw
```

**On failure at step 2:**
- 422 -> Map to AppError.Server(422, "Email already registered"), return Result.failure / throw
- Network error -> Map to AppError.Network, return Result.failure / throw

**Note:** Customer profile creation (`POST /store/customers`) is the responsibility of the
Register Screen (M1-02) after successful auth registration, not this infrastructure layer.

### 5.4 Logout Flow

```
1. UI calls SessionManager.logout()
2. SessionManager calls AuthApi: DELETE /auth/session
   (fire-and-forget -- do NOT block logout on API failure)
3. Calls TokenStorage.clearTokens()
4. Calls AuthStateManager.onLogout()
5. AuthState transitions to Guest
6. Navigation layer observes Guest state and handles redirect to Home
```

**Important:** Logout must always succeed locally even if the API call fails (network offline).
The local state is authoritative for the client.

### 5.5 Token Refresh Flow (Auth Interceptor Integration)

```
1. Network interceptor/middleware detects 401 response on any API call
2. Acquire refresh mutex/lock (prevent concurrent refresh attempts)
3. Check if token was already refreshed by another request (compare tokens)
   |
   +-- Token changed since this request was made:
   |     Retry original request with new token (no refresh needed)
   |
   +-- Token has NOT changed (this is the first 401):
         4. Call POST /auth/token/refresh (using current token)
            |
            +-- 200 OK:
            |     a. Store new token via TokenStorage.saveAccessToken(newToken)
            |     b. Update AuthState to Authenticated(newToken)
            |     c. Retry original request with new token
            |     d. Release mutex
            |
            +-- 401 / Error:
                  a. Call TokenStorage.clearTokens()
                  b. Set AuthState = Guest
                  c. Release mutex
                  d. Propagate AppError.Unauthorized to caller
```

**Mutex requirement:** Only one refresh request should be in-flight at a time. If multiple
requests receive 401 simultaneously, only the first triggers a refresh. Subsequent requests
wait for the refresh result and then retry with the new token.

**Android implementation:** Use `Mutex` from `kotlinx.coroutines.sync`.
**iOS implementation:** Use an `actor` or `NSLock` / `AsyncSemaphore` pattern.

### 5.6 Auth State Lifecycle Diagram

```
                    +----------+
     App Launch --> | Loading  |
                    +----+-----+
                         |
              +----------+----------+
              |                     |
        token found            no token
              |                     |
              v                     v
     +-----------------+      +---------+
     | Authenticated   |<---->|  Guest  |
     | (token: String) |      |         |
     +-----------------+      +---------+
          |        ^             ^  |
          |        |             |  |
     logout/    login/        logout |
     token     register              |
     expired                    login/register
```

---

## 6. Error Scenarios

### 6.1 Error Mapping Table

| Scenario | HTTP Status | AppError | User Message Key | Recommended Action |
|----------|-------------|----------|------------------|--------------------|
| Invalid email or password | 401 | `Unauthorized` | `auth_error_invalid_credentials` | Show inline error on login form |
| Email already registered | 422 | `Server(422, msg)` | `auth_error_email_exists` | Show inline error on register form |
| Network unreachable during login | N/A | `Network` | `common_error_network` | Show error with retry option |
| Network unreachable during register | N/A | `Network` | `common_error_network` | Show error with retry option |
| Token refresh fails (401) | 401 | `Unauthorized` | `common_error_unauthorized` | Clear tokens, redirect to Guest state |
| Token refresh fails (network) | N/A | `Network` | `common_error_network` | Keep current state, retry on next request |
| Session creation fails | Any | Logged (not surfaced) | N/A | Log warning, continue -- token is still valid |
| Logout API fails | Any | Ignored | N/A | Always clear local tokens regardless |
| Server error during login | 5xx | `Server(code, msg)` | `common_error_server` | Show error with retry option |
| Server error during register | 5xx | `Server(code, msg)` | `common_error_server` | Show error with retry option |
| Corrupted stored token | N/A | N/A | N/A | Clear tokens, set Guest state (silent recovery) |

### 6.2 Edge Cases

**Concurrent 401 responses:**
Multiple API requests may receive 401 simultaneously. The refresh mutex ensures only one
refresh request is made. Other requests queue behind the mutex and retry with the new token.

**Refresh during logout:**
If a token refresh is in progress when the user taps logout, the logout must win. After
`clearTokens()`, any pending refresh result is discarded.

**App killed during token save:**
If the app is killed between receiving a new token and saving it, the next launch will
attempt to use the old token. The `checkStoredToken()` flow handles this by attempting refresh
if session validation fails.

**Empty/null token from API:**
If the server returns an empty or null token, treat as a login failure. Map to
`AppError.Unknown`.

**Storage corruption:**
If `TokenStorage.getAccessToken()` throws due to decryption failure (e.g., device keystore
reset), catch the error, call `clearTokens()`, and set `AuthState = Guest`.

---

## 7. Accessibility

This feature has no user-facing UI. Accessibility considerations apply only at integration
points:

- **Auth state change announcements:** When `AuthState` transitions from `Authenticated` to
  `Guest` (e.g., forced logout), the navigation layer should announce the transition via
  accessibility announcement so screen reader users are informed.
  - Android: `announceForAccessibility("You have been logged out")`
  - iOS: `AccessibilityNotification.Announcement`
- **Error messages:** All `AppError` user messages (`auth_error_invalid_credentials`,
  `auth_error_email_exists`, etc.) must be localized and screen-reader-friendly. These
  are surfaced by M1-01 and M1-02 screens, not this layer.
- **No interactive elements:** This infrastructure layer has no buttons, text fields, or
  touch targets. Accessibility for auth UI is specified in M1-01, M1-02, and M1-03.

---

## 8. Security Requirements

### 8.1 Token Storage

| Platform | Storage Mechanism | Encryption |
|----------|-------------------|------------|
| Android | Proto DataStore | Google Tink (AEAD encryption) |
| iOS | Keychain Services | KeychainAccess wrapper (hardware-backed encryption) |

**Rules:**
- Token is encrypted at rest. Never stored in plain SharedPreferences or UserDefaults.
- Token is never written to log output. All request logging must redact the `Authorization` header value.
- Token is transmitted only in the `Authorization: Bearer {token}` HTTP header. Never in URL query parameters.
- Token is cleared from storage on explicit logout.
- iOS Keychain item should use `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` accessibility level so the token is not included in backups and is tied to the device.
- Android DataStore file should not be included in auto-backup (`android:fullBackupContent` exclusion rule).

### 8.2 Network Security

- All auth endpoints use HTTPS. Cleartext traffic is blocked in production via `network_security_config.xml` (Android) and App Transport Security (iOS).
- Certificate pinning for `api.molt.mt` in production builds (implementation detail in M0-03 network layer).

### 8.3 Biometric Key Hook

This layer defines a stub interface/protocol for biometric token storage. The actual
implementation is deferred to M3 (Biometric Authentication).

**Android:**
```
interface BiometricTokenStorage {
    suspend fun storeRefreshTokenWithBiometric(token: String)
    suspend fun retrieveRefreshTokenWithBiometric(): String?
    suspend fun clearBiometricToken()
    fun isBiometricAvailable(): Boolean
}
```

**iOS:**
```
protocol BiometricTokenStorage: Sendable {
    func storeRefreshToken(_ token: String) async throws
    func retrieveRefreshToken() async throws -> String?
    func clearBiometricToken() async
    func isBiometricAvailable() -> Bool
}
```

These interfaces are defined but not implemented in M0-06. No DI registration until M3.

### 8.4 Multi-Device Policy

- Users can be logged in on multiple devices simultaneously.
- No session limit. No forced logout on other devices.
- Each device has its own independent access token.
- No inactivity timeout. Session persists until explicit logout or token expiry.
- Server-side token revocation (if needed) causes 401 on next request, triggering the refresh flow.

---

## 9. File Manifest

### 9.1 Android Files

Base path: `android/app/src/main/java/com/molt/marketplace/core/auth/`

| # | File | Description |
|---|------|-------------|
| 1 | `TokenStorage.kt` | Interface: `getAccessToken()`, `saveAccessToken(token)`, `clearTokens()`, `getAccessTokenFlow()` |
| 2 | `EncryptedTokenStorage.kt` | Implementation using Proto DataStore + Google Tink AEAD encryption. `@Singleton`. |
| 3 | `AuthState.kt` | Sealed interface: `Loading`, `Authenticated(token: String)`, `Guest`. Annotated `@Stable`. |
| 4 | `AuthStateManager.kt` | Interface: `authState: StateFlow<AuthState>`, `onLoginSuccess(token)`, `onLogout()`, `checkStoredToken()` |
| 5 | `AuthStateManagerImpl.kt` | Implementation: `MutableStateFlow<AuthState>`, coordinates with `TokenStorage`. `@Singleton`. |
| 6 | `SessionManager.kt` | Class: `login(email, password)`, `register(email, password)`, `logout()`, `refreshToken()`. Coordinates `AuthApi` + `TokenStorage` + `AuthStateManager`. `@Singleton`. |
| 7 | `AuthApi.kt` | Retrofit interface with 5 endpoint methods (login, register, createSession, destroySession, refreshToken) |
| 8 | `dto/LoginRequest.kt` | `@Serializable data class LoginRequest(val email: String, val password: String)` |
| 9 | `dto/RegisterRequest.kt` | `@Serializable data class RegisterRequest(val email: String, val password: String)` |
| 10 | `dto/AuthTokenResponse.kt` | `@Serializable data class AuthTokenResponse(val token: String)` |
| 11 | `BiometricTokenStorage.kt` | Interface stub: `storeRefreshTokenWithBiometric`, `retrieveRefreshTokenWithBiometric`, `clearBiometricToken`, `isBiometricAvailable`. No implementation in M0-06. |
| 12 | `di/AuthModule.kt` | Hilt `@Module @InstallIn(SingletonComponent::class)`: binds `TokenStorage` to `EncryptedTokenStorage`, binds `AuthStateManager` to `AuthStateManagerImpl`, provides `AuthApi` (via Retrofit), provides `SessionManager` |

**Modify existing (M0-03 network layer):**

| # | File | Modification |
|---|------|-------------|
| 13 | `core/network/AuthInterceptor.kt` | OkHttp Interceptor: reads token from `TokenStorage`, adds `Authorization: Bearer` header, handles 401 by calling `SessionManager.refreshToken()` with mutex |

### 9.2 iOS Files

Base path: `ios/MoltMarketplace/Core/Auth/`

| # | File | Description |
|---|------|-------------|
| 1 | `TokenStorage.swift` | Protocol: `getAccessToken() -> String?`, `saveAccessToken(_ token: String)`, `clearTokens()` |
| 2 | `KeychainTokenStorage.swift` | Implementation using KeychainAccess. `final class`, `Sendable`. |
| 3 | `AuthState.swift` | Enum: `loading`, `authenticated(token: String)`, `guest`. Conforms to `Equatable, Sendable`. |
| 4 | `AuthStateManager.swift` | Protocol: `authState: AuthState`, `onLoginSuccess(token:)`, `onLogout()`, `checkStoredToken() async` |
| 5 | `AuthStateManagerImpl.swift` | `@MainActor @Observable final class`. Holds `authState` property, coordinates with `TokenStorage`. |
| 6 | `SessionManager.swift` | `final class`, `Sendable`. `login(email:password:) async throws`, `register(email:password:) async throws`, `logout() async`, `refreshToken() async throws -> String`. Coordinates `APIClient` + `TokenStorage` + `AuthStateManager`. |
| 7 | `AuthEndpoint.swift` | Enum conforming to `Endpoint` protocol. Cases: `login(email:password:)`, `register(email:password:)`, `createSession`, `destroySession`, `refreshToken`. Each case provides path, method, body, and auth requirement. |
| 8 | `DTO/LoginRequest.swift` | `struct LoginRequest: Encodable { let email: String; let password: String }` |
| 9 | `DTO/RegisterRequest.swift` | `struct RegisterRequest: Encodable { let email: String; let password: String }` |
| 10 | `DTO/AuthTokenResponse.swift` | `struct AuthTokenResponse: Decodable { let token: String }` |
| 11 | `BiometricTokenStorage.swift` | Protocol stub: `storeRefreshToken`, `retrieveRefreshToken`, `clearBiometricToken`, `isBiometricAvailable`. No implementation in M0-06. |

**Modify existing:**

| # | File | Modification |
|---|------|-------------|
| 12 | `Core/DI/Container+Extensions.swift` | Add Factory registrations: `tokenStorage` (singleton), `authStateManager` (singleton), `sessionManager` (singleton) |
| 13 | `Core/Network/AuthMiddleware.swift` | URLSession middleware: reads token from `TokenStorage`, adds `Authorization: Bearer` header, handles 401 by calling `SessionManager.refreshToken()` with actor-based mutex |

### 9.3 String Resources

Add these keys to existing string resource files:

**Android** (`res/values/strings.xml`, `res/values-mt/strings.xml`, `res/values-tr/strings.xml`):

| Key | English (en) | Maltese (mt) | Turkish (tr) |
|-----|-------------|-------------|-------------|
| `auth_login_title` | Log In | Idhlol | Giris Yap |
| `auth_login_email_placeholder` | Enter your email | Dahhalna l-email tieghek | E-postanizi girin |
| `auth_login_password_placeholder` | Enter your password | Dahhalna l-password tieghek | Sifrenizi girin |
| `auth_login_button` | Log In | Idhlol | Giris Yap |
| `auth_register_title` | Create Account | Ohlod Kont | Hesap Olustur |
| `auth_register_link` | Create an account | Ohlod kont | Hesap olustur |
| `auth_forgot_password_link` | Forgot password? | Insejt il-password? | Sifremi unuttum? |
| `auth_logout_button` | Log Out | Ohlrog | Cikis Yap |
| `auth_error_invalid_credentials` | Invalid email or password | Email jew password mhux korrett | Gecersiz e-posta veya sifre |
| `auth_error_email_exists` | This email is already registered | Dan l-email digà reigistrat | Bu e-posta zaten kayitli |

**iOS** (`Localizable.xcstrings`): Same keys and translations added to the String Catalog.

**Note:** These string keys are consumed by M1-01 and M1-02 screens. They are defined here
because the auth infrastructure spec is the canonical source for auth-related string keys.

### 9.4 Test Files

**Android** (base: `android/app/src/test/java/com/molt/marketplace/core/auth/`):

| # | File | Description |
|---|------|-------------|
| 1 | `FakeTokenStorage.kt` | In-memory `TokenStorage` implementation for testing |
| 2 | `TokenStorageTest.kt` | Tests: save/get/clear token, getAccessTokenFlow emissions |
| 3 | `AuthStateManagerTest.kt` | Tests: Loading->Guest (no token), Loading->Authenticated (token found), onLoginSuccess->Authenticated, onLogout->Guest, checkStoredToken with expired token |
| 4 | `SessionManagerTest.kt` | Tests: login success flow, login 401 failure, register success flow, register 422 failure, logout always clears local state, refreshToken success, refreshToken failure clears state |
| 5 | `AuthInterceptorTest.kt` | Tests: adds auth header when token exists, skips header when no token, triggers refresh on 401, retries with new token, concurrent 401 handling (single refresh) |

**iOS** (base: `ios/MoltMarketplaceTests/Core/Auth/`):

| # | File | Description |
|---|------|-------------|
| 1 | `FakeTokenStorage.swift` | In-memory `TokenStorage` implementation for testing |
| 2 | `TokenStorageTests.swift` | Tests: save/get/clear token |
| 3 | `AuthStateManagerTests.swift` | Tests: loading->guest (no token), loading->authenticated (token found), onLoginSuccess, onLogout, checkStoredToken with expired token |
| 4 | `SessionManagerTests.swift` | Tests: login success, login failure, register success, register 422 failure, logout always clears, refreshToken success, refreshToken failure |
| 5 | `AuthEndpointTests.swift` | Tests: correct path, method, body for each endpoint case |

---

## 10. Implementation Notes for Developers

### 10.1 For Android Developer

1. **Start with DTOs** (`dto/LoginRequest.kt`, `dto/RegisterRequest.kt`, `dto/AuthTokenResponse.kt`) -- simple `@Serializable` data classes.
2. **Create `AuthApi.kt`** -- Retrofit interface with 5 annotated methods. Note: `createSession()` and `destroySession()` return `Unit` (no response body).
3. **Create `AuthState.kt`** -- sealed interface with `@Stable` annotation for Compose stability.
4. **Create `TokenStorage.kt` interface** then `EncryptedTokenStorage.kt` implementation:
   - Use `DataStore<Preferences>` with Tink `Aead` for encryption.
   - `getAccessTokenFlow()` returns `Flow<String?>` from DataStore.
   - All methods are `suspend` functions.
5. **Create `AuthStateManager.kt` interface** then `AuthStateManagerImpl.kt`:
   - Internal `MutableStateFlow<AuthState>(AuthState.Loading)` with public `StateFlow` exposure via `stateIn`.
   - `checkStoredToken()` reads from `TokenStorage` and attempts session validation.
6. **Create `SessionManager.kt`**:
   - Inject `AuthApi`, `TokenStorage`, `AuthStateManager`.
   - `login()` and `register()` orchestrate the full flow (API call -> save token -> create session -> update state).
   - `refreshToken()` includes a `Mutex` to prevent concurrent refresh.
   - `logout()` is fire-and-forget on the API call but always clears local state.
7. **Create `di/AuthModule.kt`**:
   - `@Binds` for `TokenStorage` -> `EncryptedTokenStorage`.
   - `@Binds` for `AuthStateManager` -> `AuthStateManagerImpl`.
   - `@Provides` for `AuthApi` (from Retrofit instance).
   - `@Provides` for `SessionManager`.
8. **Modify `AuthInterceptor.kt`** (in `core/network/`):
   - Read token synchronously from `TokenStorage` (use `runBlocking` for interceptor, or store token in-memory cache).
   - On 401: call `SessionManager.refreshToken()`, retry original request.
   - Use `Mutex` to serialize refresh attempts.
9. **Create test fakes and unit tests**.

### 10.2 For iOS Developer

1. **Start with DTOs** (`DTO/LoginRequest.swift`, `DTO/RegisterRequest.swift`, `DTO/AuthTokenResponse.swift`) -- simple `Encodable`/`Decodable` structs.
2. **Create `AuthEndpoint.swift`** -- enum conforming to `Endpoint` protocol with 5 cases. Map each to correct HTTP method, path, and body.
3. **Create `AuthState.swift`** -- enum with `Equatable, Sendable` conformance.
4. **Create `TokenStorage.swift` protocol** then `KeychainTokenStorage.swift`:
   - Use `KeychainAccess` with service identifier `"com.molt.marketplace.auth"`.
   - Set accessibility to `.whenUnlockedThisDeviceOnly`.
   - Mark class as `final class` conforming to `TokenStorage & Sendable`.
5. **Create `AuthStateManager.swift` protocol** then `AuthStateManagerImpl.swift`:
   - `@MainActor @Observable final class`.
   - Published `authState` property.
   - `checkStoredToken()` is `async` -- calls `tokenStorage.getAccessToken()`, attempts session validation.
6. **Create `SessionManager.swift`**:
   - `final class` with `Sendable` conformance.
   - Uses `actor`-based pattern or `NSLock` for refresh mutex.
   - `login()` and `register()` orchestrate the full flow.
   - `logout()` always clears local state regardless of API result.
7. **Register in `Container+Extensions.swift`**:
   ```swift
   var tokenStorage: Factory<TokenStorage> {
       self { KeychainTokenStorage() }.singleton
   }
   var authStateManager: Factory<AuthStateManagerImpl> {
       self { AuthStateManagerImpl(tokenStorage: self.tokenStorage()) }.singleton
   }
   var sessionManager: Factory<SessionManager> {
       self { SessionManager(apiClient: self.apiClient(), tokenStorage: self.tokenStorage(), authStateManager: self.authStateManager()) }.singleton
   }
   ```
8. **Modify `AuthMiddleware.swift`** (in `Core/Network/`):
   - URLSession delegate or request modifier that adds `Authorization` header.
   - On 401: call `SessionManager.refreshToken()`, retry original request.
   - Use actor for serializing refresh attempts.
9. **Create test fakes and unit tests**.

### 10.3 Common Rules

- Follow CLAUDE.md exactly for naming conventions, file locations, and architecture patterns.
- `SessionManager` is the only public API that M1-01 (Login) and M1-02 (Register) screens call. ViewModels in those features should inject `SessionManager` and `AuthStateManager`.
- Token must NEVER appear in logs. Redact `Authorization` header in all HTTP logging.
- The refresh mutex is critical. Without it, multiple concurrent 401 responses cause multiple refresh requests, potentially invalidating tokens.
- Test all state transitions thoroughly. The auth state machine has well-defined transitions and any deviation is a bug.
- `logout()` must ALWAYS succeed locally. Never let a network failure prevent the user from logging out.

---

## 11. Build Verification Criteria

### Android

- [ ] `EncryptedTokenStorage` successfully saves and retrieves a token using Tink encryption
- [ ] `AuthStateManagerImpl` transitions correctly: Loading -> Guest (no token), Loading -> Authenticated (stored token)
- [ ] `SessionManager.login()` calls AuthApi, stores token, creates session, updates AuthState
- [ ] `SessionManager.logout()` clears tokens and sets Guest even when API call fails
- [ ] `SessionManager.refreshToken()` stores new token and updates AuthState
- [ ] `AuthInterceptor` adds Bearer header to requests when token exists
- [ ] `AuthInterceptor` handles 401 by refreshing token and retrying
- [ ] Concurrent 401 handling uses single refresh (mutex test)
- [ ] All auth DTOs serialize/deserialize correctly
- [ ] Hilt module compiles and provides all auth dependencies
- [ ] All unit tests pass: `./gradlew test --tests "*.core.auth.*"`

### iOS

- [ ] `KeychainTokenStorage` saves and retrieves token from Keychain
- [ ] `AuthStateManagerImpl` transitions correctly: loading -> guest (no token), loading -> authenticated (stored token)
- [ ] `SessionManager.login()` calls API, stores token, creates session, updates AuthState
- [ ] `SessionManager.logout()` clears tokens and sets guest even when API call fails
- [ ] `SessionManager.refreshToken()` stores new token and updates AuthState
- [ ] `AuthMiddleware` adds Bearer header when token exists
- [ ] `AuthMiddleware` handles 401 by refreshing and retrying
- [ ] `AuthEndpoint` produces correct URL path, method, and body for all 5 cases
- [ ] Factory container resolves `tokenStorage`, `authStateManager`, `sessionManager` without crash
- [ ] All unit tests pass: `swift test --filter Auth`
