# Handoff: auth-infrastructure -- Architect

## Feature
**M0-06: Auth Infrastructure** -- Authentication token storage, auth state management, session lifecycle, and token refresh for the Molt Marketplace buyer app.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/auth-infrastructure.md` |
| This Handoff | `docs/pipeline/auth-infrastructure-architect.handoff.md` |

## Summary of Spec

The auth-infrastructure spec defines the complete authentication infrastructure layer for both Android and iOS. This is a non-UI layer -- no screens, no views, no composables.

### Core Components

1. **AuthState** -- Sealed interface (Android) / enum (iOS) with three states: `Loading`, `Authenticated(token)`, `Guest`
2. **TokenStorage** -- Interface/protocol for secure token persistence. Android uses DataStore + Tink. iOS uses KeychainAccess.
3. **AuthStateManager** -- Manages the observable auth state. Coordinates startup token check, login success, and logout transitions.
4. **SessionManager** -- Orchestrates end-to-end auth flows: login, register, logout, token refresh. Single public API for feature screens.
5. **AuthApi / AuthEndpoint** -- 5 Medusa auth endpoints: login, register, create session, destroy session, refresh token.
6. **DTOs** -- LoginRequest, RegisterRequest, AuthTokenResponse.
7. **BiometricTokenStorage** -- Interface stub only (implementation deferred to M3).
8. **AuthInterceptor / AuthMiddleware** -- Modification to existing network layer for automatic token injection and 401 handling.

### Key Flows

- **App Launch**: Loading -> check storage -> validate session -> Authenticated or Guest
- **Login**: API call -> store token -> create session -> set Authenticated
- **Register**: API call -> store token -> create session -> set Authenticated
- **Logout**: API call (fire-and-forget) -> clear tokens -> set Guest (always succeeds locally)
- **Token Refresh**: Mutex-protected single refresh on 401 -> retry original request

### API Endpoints (from shared/api-contracts/auth.json)

| # | Method | Path | Auth | Purpose |
|---|--------|------|------|---------|
| 1 | POST | /auth/customer/emailpass | No | Login |
| 2 | POST | /auth/customer/emailpass/register | No | Register |
| 3 | POST | /auth/session | Yes | Create session |
| 4 | DELETE | /auth/session | Yes | Destroy session (logout) |
| 5 | POST | /auth/token/refresh | Yes | Refresh expired token |

### File Counts

| Platform | New Files | Modified Files | Test Files |
|----------|-----------|---------------|------------|
| Android | 12 | 1 (AuthInterceptor) | 5 (+ 1 fake) |
| iOS | 11 | 2 (Container+Extensions, AuthMiddleware) | 5 (+ 1 fake) |

## Key Decisions

1. **SessionManager as single public API**: Feature screens (M1-01 Login, M1-02 Register) inject SessionManager. They do NOT interact with TokenStorage or AuthApi directly.
2. **Fire-and-forget logout**: Logout always clears local state regardless of API call result. Network failure must never block the user from logging out.
3. **Mutex-protected refresh**: Only one token refresh in-flight at a time. Concurrent 401s queue behind the mutex and retry with the refreshed token.
4. **Optimistic session on network failure**: During app launch, if a stored token exists but session validation fails due to network error, the app stays in Authenticated state. The token may work when connectivity returns.
5. **Customer profile creation not in this layer**: POST /store/customers is M1-02 Register Screen's responsibility, not auth infrastructure.
6. **Biometric stub only**: BiometricTokenStorage interface defined but not implemented. No DI registration until M3.
7. **String keys defined here, consumed by M1**: Auth error message string keys are defined in this spec for consistency, but they are surfaced by the Login/Register screen UI.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | File manifest (section 9.1), data models (section 2), state flows (section 5), implementation notes (section 10.1) |
| iOS Dev | File manifest (section 9.2), data models (section 2), state flows (section 5), implementation notes (section 10.2) |

## Verification

Downstream developers should verify their implementation against the build verification criteria in spec section 11.

## Notes for Next Features

- **M1-01 (Login Screen)**: Inject `SessionManager` and `AuthStateManager`. Call `sessionManager.login(email, password)`. Observe `authStateManager.authState` for navigation.
- **M1-02 (Register Screen)**: Inject `SessionManager`. Call `sessionManager.register(email, password)`. Then call customer creation API (POST /store/customers) separately.
- **M1-03 (Forgot Password)**: Uses customer endpoints (`/store/customers/password-token`, `/store/customers/password`), not auth endpoints. Auth infrastructure not directly involved.
- **M0-04 (Navigation)**: Observe `AuthStateManager.authState` to implement route guards and auth-required redirects.
- **M3 (Biometric)**: Implement `BiometricTokenStorage` protocol, register in DI, integrate with `SessionManager`.
