# Handoff: di-setup -- Architect

## Feature
**M0-05: DI Setup** -- Dependency injection module structure for network, storage, and common dependencies.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/di-setup.md` |
| This Handoff | `docs/pipeline/di-setup-architect.handoff.md` |

## Summary of Spec

The DI Setup spec defines the complete dependency injection wiring for both Android and iOS platforms.
No business logic or UI screens are produced. This is structural infrastructure that enables all
subsequent features to declare and resolve dependencies consistently.

### Android (Hilt)

- **Qualifiers.kt**: Five `@Qualifier` annotations -- `@IoDispatcher`, `@MainDispatcher`,
  `@DefaultDispatcher`, `@AuthenticatedClient`, `@UnauthenticatedClient`
- **CoroutineModule.kt**: `@Module @InstallIn(SingletonComponent)` providing three dispatchers
  and an application-scoped `CoroutineScope` with `SupervisorJob`
- **NetworkModule.kt**: `@Module @InstallIn(SingletonComponent)` providing `Json` (Kotlin
  Serialization), two `OkHttpClient` instances (authenticated and unauthenticated), `Retrofit`
  (with `BuildConfig.API_BASE_URL`), and `NetworkMonitor`
- **StorageModule.kt**: `@Module @InstallIn(SingletonComponent)` providing
  `DataStore<Preferences>` and `MoltDatabase` (Room, empty entity list)
- **MoltDatabase.kt**: Empty `@Database` abstract class in `core/data/local/`; features add
  entities as they are implemented
- **NetworkMonitor**: Interface + implementation in `core/network/` using `ConnectivityManager`
- **Feature DI pattern**: Documented canonical pattern -- `@Binds` in `ViewModelComponent` for
  repositories, `@Inject constructor` for use cases (no module needed), `@HiltViewModel` for ViewModels

### iOS (Factory)

- **Container+Extensions.swift** (MODIFY): Add registrations for `apiClient` (.singleton),
  `authenticatedSession` (.singleton), `unauthenticatedSession` (.singleton), `tokenStorage`
  (.singleton), `networkMonitor` (.singleton)
- **NetworkMonitor**: Protocol + implementation in `Core/Network/` using `NWPathMonitor`
- **Stub protocols**: If M0-03/M0-06 are not yet implemented, create minimal stubs for
  `APIClient`, `APIClientImpl`, `TokenStorage`, `KeychainTokenStorage` so the container compiles
- **Feature DI pattern**: Documented canonical pattern -- `Container` extension per feature,
  `@Injected(\.propertyName)` in ViewModels, init-based injection for testability

### Scoping Rules

| Scope | Android | iOS | Used For |
|-------|---------|-----|----------|
| Singleton | `@Singleton` + `SingletonComponent` | `.singleton` | OkHttpClient, Retrofit, APIClient, Database, DataStore, TokenStorage, NetworkMonitor |
| ViewModel | `ViewModelComponent` | N/A | Feature repositories |
| Transient | Default | Default | Use cases, iOS repositories |

### Test Replacement Patterns

- **Android**: `@TestInstallIn` to swap modules; manual construction preferred for ViewModel unit tests
- **iOS**: `Container.shared.reset()` + `.register { }` overrides; init-based injection preferred for unit tests

## Key Decisions

1. **Repositories are ViewModel-scoped (Android)**: Avoids stale state, improves memory efficiency,
   simplifies test replacement. Underlying data sources (Retrofit, Room, DataStore) remain singleton.
2. **Use cases do not need Hilt modules**: Concrete classes with `@Inject constructor` are
   automatically provided by Hilt. Only interface-to-implementation bindings require `@Binds`.
3. **Two OkHttpClient qualifiers**: `@AuthenticatedClient` (with auth interceptor, wired in M0-06)
   and `@UnauthenticatedClient` (for login/register). In M0-05, authenticated is a copy of
   unauthenticated until M0-06 adds auth interceptors.
4. **NetworkMonitor in DI layer**: Created here because it is cross-cutting infrastructure needed
   by multiple features (offline banners, checkout gating, retry logic).
5. **Stub protocols for compile order**: If M0-05 is implemented before M0-03/M0-06, stub
   protocols are created so the project compiles. Real implementations replace stubs later.
6. **Empty Room database**: Entity list starts empty. Features add entities as they are implemented,
   with version increments and migrations.
7. **Application-scoped CoroutineScope**: Provided as singleton for background sync work that must
   outlive individual ViewModels. Uses `SupervisorJob` for failure isolation.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | Qualifiers.kt (section 8.1), all module implementations (sections 8.2-8.5), MoltDatabase (section 8.5), NetworkMonitor (section 11), feature DI pattern (section 8.6), test patterns (section 8.7), file manifest (section 12.1) |
| iOS Dev | Container+Extensions.swift modifications (section 9.1), NetworkMonitor (section 11), stub protocols (section 12.2), feature DI pattern (section 9.2), test patterns (section 9.3), file manifest (section 12.2) |

## Verification

Downstream developers should verify their DI setup build succeeds using the criteria in spec section 13.

## Notes for Next Features

- **M0-03 (Network Layer)**: Uses `Json`, `OkHttpClient`, `Retrofit` from `NetworkModule`.
  Implements `APIClient` protocol (iOS), `AuthInterceptor` placeholder, error parsing.
  Replace any stub protocols with real implementations.
- **M0-06 (Auth Infrastructure)**: Updates `NetworkModule.provideAuthenticatedClient()` to add
  `AuthInterceptor` and `TokenRefreshAuthenticator`. Implements `TokenStorage` / `KeychainTokenStorage`.
  Uses `StorageModule` for encrypted DataStore. Replace stubs.
- **M1+ features**: Follow the feature DI pattern documented in sections 8.6 (Android) and 9.2 (iOS).
  Each feature creates its own `<Name>Module.kt` (Android) and `Container+<Name>.swift` (iOS).
