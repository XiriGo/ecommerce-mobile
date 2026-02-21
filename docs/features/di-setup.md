# M0-05: DI Setup

## Overview

The DI Setup establishes the dependency injection infrastructure for the Molt Marketplace buyer app. It creates the Hilt modules (Android) and Factory container registrations (iOS) that provide network, storage, coroutine, and common infrastructure dependencies as singletons. It also defines the canonical pattern that every M1+ feature module must follow when registering its own repositories, use cases, and ViewModels.

This is a pure infrastructure feature — no business logic, no UI screens.

**Status**: Complete
**Phase**: M0 (Foundation)
**Platforms**: Android (Kotlin + Hilt) + iOS (Swift + Factory)
**Blocks**: M0-06 (Auth Infrastructure), all M1+ features

### What This Feature Provides

- Five qualifier annotations for coroutine dispatchers and HTTP client variants (Android)
- `CoroutineModule`: three dispatcher providers + app-scoped `CoroutineScope` with `SupervisorJob` (Android)
- `StorageModule`: `DataStore<Preferences>` (general) + `MoltDatabase` Room shell (Android)
- `NetworkModule` updated with `@AuthenticatedClient` / `@UnauthenticatedClient` OkHttpClient split (Android)
- `Container+Extensions.swift` verified with `apiClient`, `tokenProvider`, `networkMonitor` singletons (iOS)
- `NetworkMonitor` interface + `NWPathMonitor`-based implementation (iOS)
- Canonical feature DI pattern for M1+ (both platforms)
- Test replacement patterns using `@TestInstallIn` (Android) and container overrides (iOS)

### Dependencies

| Depends On | What Is Needed |
|-----------|----------------|
| M0-01: App Scaffold | `@HiltAndroidApp` on `MoltApplication`, `Container+Extensions.swift` shell, `BuildConfig.API_BASE_URL`, `Config.apiBaseURL` |
| M0-03: Network Layer | `NetworkModule.kt`, `OkHttpClientFactory`, `NetworkMonitor`, `APIClient`, `TokenProvider` already created |

### Features That Depend on This

| Feature | What It Needs |
|---------|--------------|
| M0-06: Auth Infrastructure | `StorageModule` for encrypted DataStore / Keychain storage, `CoroutineModule` for dispatcher injection, `@AuthenticatedClient` / `@UnauthenticatedClient` OkHttpClient qualifiers |
| All M1+ features | Feature DI pattern (repository `@Binds`, use case `@Inject constructor`, `Container` extension for iOS), `CoroutineModule` dispatcher qualifiers, `Retrofit` for API service creation |

---

## Architecture

### DI Scoping Rules

| Scope | Android (Hilt) | iOS (Factory) | Used For |
|-------|---------------|---------------|----------|
| Singleton | `@Singleton` + `@InstallIn(SingletonComponent::class)` | `.singleton` | OkHttpClient, Retrofit, APIClient, Database, DataStore, TokenStorage, NetworkMonitor, Json |
| ViewModel | `@InstallIn(ViewModelComponent::class)` | N/A (owned by ViewModel) | Feature repositories (via `@Binds`) |
| Transient | Default (no scope annotation) | Default (no scope) | Use cases (via `@Inject constructor`), iOS repositories |

Repositories are scoped to `ViewModelComponent` (Android) rather than `SingletonComponent` to avoid stale state across screen navigations and to make `@TestInstallIn` replacements simpler. The underlying data sources (Retrofit, Room, DataStore) remain singletons.

### Android Qualifier Annotations

Five `@Qualifier` annotations defined in `Qualifiers.kt` disambiguate multiple bindings of the same type:

| Annotation | Target Type | Purpose |
|-----------|-------------|---------|
| `@IoDispatcher` | `CoroutineDispatcher` | Background I/O work (network, disk) |
| `@MainDispatcher` | `CoroutineDispatcher` | UI thread work |
| `@DefaultDispatcher` | `CoroutineDispatcher` | CPU-intensive work |
| `@AuthenticatedClient` | `OkHttpClient` | Includes `AuthInterceptor` + `TokenRefreshAuthenticator` |
| `@UnauthenticatedClient` | `OkHttpClient` | No auth headers; used for login, register, public endpoints |

### Singleton Dependency Graph

| Dependency | Android Provider | iOS Provider |
|-----------|-----------------|-------------|
| `Json` (Kotlin Serialization) | `NetworkModule.provideJson()` | N/A (uses `JSONDecoder`/`JSONEncoder` inline) |
| `OkHttpClient` (`@AuthenticatedClient`) | `NetworkModule.provideAuthenticatedClient()` | N/A |
| `OkHttpClient` (`@UnauthenticatedClient`) | `NetworkModule.provideUnauthenticatedClient()` | N/A |
| `Retrofit` | `NetworkModule.provideRetrofit()` | N/A |
| `APIClient` | N/A | `Container.apiClient` (.singleton) |
| `DataStore<Preferences>` | `StorageModule.providePreferencesDataStore()` | N/A (UserDefaults) |
| `MoltDatabase` (Room) | `StorageModule.provideDatabase()` | N/A (SwiftData) |
| Token provider (no-op placeholder) | via `@Inject constructor` on `InMemoryTokenProvider` | `Container.tokenProvider` (.singleton) |
| `NetworkMonitor` | via `@Inject constructor` + `@Singleton` | `Container.networkMonitor` (.singleton) |
| App-scoped `CoroutineScope` | `CoroutineModule.provideApplicationScope()` | N/A (Swift `Task` / `actor`) |

### Room Database Shell (Android)

`MoltDatabase` starts empty. Each feature that requires local structured storage:

1. Creates its `@Entity` class in `feature/<name>/data/local/`
2. Creates its `@Dao` interface in `feature/<name>/data/local/`
3. Adds the entity to the `entities` array and exposes the DAO as an abstract function on `MoltDatabase`
4. Increments the database version and provides a `Migration` object

A `PlaceholderEntity` is present in M0-05 to satisfy the Room KSP annotation processor, which requires at least one entity. It is removed when the first real entity (e.g., `CartItem` in M2-01) is added.

---

## Feature DI Pattern (Canonical — Mandatory for M1+)

Every feature that introduces a repository, use case, or ViewModel must follow this pattern exactly.

### Android

```kotlin
// 1. Repository binding
// File: feature/<name>/di/<Name>Module.kt
@Module
@InstallIn(ViewModelComponent::class)
abstract class ProductModule {
    @Binds
    abstract fun bindProductRepository(impl: ProductRepositoryImpl): ProductRepository
}

// 2. Use case — no module needed, @Inject constructor is sufficient
class GetProductsUseCase @Inject constructor(
    private val repository: ProductRepository,
) {
    operator fun invoke(): Flow<List<Product>> = repository.getProductsStream()
}

// 3. ViewModel
@HiltViewModel
class ProductListViewModel @Inject constructor(
    private val getProductsUseCase: GetProductsUseCase,
) : ViewModel() { ... }

// 4. API service — option A: add to NetworkModule; option B: dedicated module
@Module
@InstallIn(SingletonComponent::class)
object ProductApiModule {
    @Provides
    fun provideProductApi(retrofit: Retrofit): ProductApi =
        retrofit.create(ProductApi::class.java)
}
```

Key rules:
- `@Module` with `@Binds` must be an `abstract class`; with `@Provides` only, use `object`
- Never mix `@Binds` and `@Provides` in the same class — split into abstract class + companion object if needed
- Use cases do NOT need a module — `@Inject constructor` is sufficient because they are concrete classes

### iOS

```swift
// File: Core/DI/Container+<Name>.swift (one file per feature, preferred)
extension Container {
    var productRepository: Factory<ProductRepository> {
        // No .singleton or .cached — transient by default
        self { ProductRepositoryImpl(apiClient: self.apiClient()) }
    }

    var getProductsUseCase: Factory<GetProductsUseCase> {
        self { GetProductsUseCase(repository: self.productRepository()) }
    }
}

// ViewModel with init-based injection (preferred for testability)
@MainActor @Observable
final class ProductListViewModel {
    private let getProductsUseCase: GetProductsUseCase

    init(getProductsUseCase: GetProductsUseCase = Container.shared.getProductsUseCase()) {
        self.getProductsUseCase = getProductsUseCase
    }
}
```

Key rules:
- All `Factory` properties must be `var` (computed properties), not `let`
- No scope modifier = transient (new instance per resolution); this is correct for repositories and use cases
- Use `.singleton` only for infrastructure (never for repositories or use cases)
- Init-based injection is preferred over `@Injected` for ViewModels that need unit testing

### Test Replacement (Android)

```kotlin
// Replace module for unit tests (no Hilt framework overhead)
class ProductListViewModelTest {
    private val fakeRepository = FakeProductRepository()
    private val useCase = GetProductsUseCase(fakeRepository)
    private val viewModel = ProductListViewModel(useCase)

    @Test
    fun `should load data on init`() = runTest { ... }
}

// Replace module for integration tests using @TestInstallIn
@TestInstallIn(
    components = [ViewModelComponent::class],
    replaces = [ProductModule::class]
)
@Module
abstract class ProductTestModule {
    @Binds
    abstract fun bindProductRepository(impl: FakeProductRepository): ProductRepository
}
```

### Test Replacement (iOS)

```swift
// Preferred: init-based injection with fake
@Test func loadProducts_success() async {
    let fakeRepository = FakeProductRepository()
    let useCase = GetProductsUseCase(repository: fakeRepository)
    let viewModel = ProductListViewModel(getProductsUseCase: useCase)
    await viewModel.loadProducts()
    // assert...
}

// Alternative: container override (use @Suite(.serialized))
@Suite(.serialized)
struct ProductListViewModelTests {
    init() {
        Container.shared.reset()
        Container.shared.productRepository.register { FakeProductRepository() }
    }
}
```

---

## File Structure

### Android

Base path: `android/app/src/main/java/com/molt/marketplace/`

```
core/
  di/
    Qualifiers.kt          # @IoDispatcher, @MainDispatcher, @DefaultDispatcher,
                           # @AuthenticatedClient, @UnauthenticatedClient
    CoroutineModule.kt     # @Module @InstallIn(SingletonComponent::class)
                           # provideIoDispatcher, provideMainDispatcher, provideDefaultDispatcher,
                           # provideApplicationScope (CoroutineScope with SupervisorJob)
    NetworkModule.kt       # @Module @InstallIn(SingletonComponent::class)  [MODIFIED in M0-05]
                           # provideJson, provideAuthenticatedClient (@AuthenticatedClient),
                           # provideUnauthenticatedClient (@UnauthenticatedClient),
                           # provideRetrofit (uses @AuthenticatedClient)
    StorageModule.kt       # @Module @InstallIn(SingletonComponent::class)
                           # providePreferencesDataStore, provideDatabase (MoltDatabase)
  data/
    local/
      MoltDatabase.kt      # @Database(entities = [PlaceholderEntity::class], version = 1)
                           # Abstract Room shell; features add entities
      PlaceholderEntity.kt # Minimal Room entity for KSP; removed when first real entity added
  network/
    NetworkMonitor.kt      # Concrete class with @Inject constructor, @Singleton; StateFlow<Boolean>
    NetworkMonitorImpl.kt  # ConnectivityManager + NetworkCallback (pre-existing from M0-03)
```

### iOS

Base path: `ios/MoltMarketplace/`

```
Core/
  DI/
    Container+Extensions.swift  # [MODIFIED in M0-05 — feature DI pattern docs added]
                                # apiClient (.singleton), tokenProvider (.singleton),
                                # networkMonitor (.singleton)
  Network/
    NetworkMonitor.swift        # Concrete @Observable final class; isConnected: Bool
                                # Uses NWPathMonitor; registered as singleton in Container
    APIClient.swift             # (from M0-03) Concrete final class; manages its own URLSession
    TokenProvider.swift         # (from M0-03) Protocol + NoOpTokenProvider placeholder
```

### Test Files

| Platform | File | Tests | Description |
|----------|------|-------|-------------|
| Android | `core/di/QualifiersTest.kt` | 11 | All 5 qualifier annotations verified for `@Qualifier` + `BINARY` retention |
| Android | `core/di/CoroutineModuleTest.kt` | 10 | Dispatcher types, `CoroutineScope` uses `SupervisorJob` + provided dispatcher |
| Android | `core/di/NetworkModuleTest.kt` | 25 | Json config, `@AuthenticatedClient` has `AuthInterceptor`, `@UnauthenticatedClient` does not, Retrofit base URL |
| Android | `core/di/StorageModuleTest.kt` | 9 | `MoltDatabase` in-memory creation, `DataStore` read/write (Robolectric) |
| iOS | `MoltMarketplaceTests/Core/DI/ContainerTests.swift` | 14 | Resolution, singleton behavior, override mechanism, reset behavior, cross-registration independence |
| iOS | `MoltMarketplaceTests/Core/Network/NetworkMonitorTests.swift` | 7 | Initialization, default `isConnected` state, `Sendable` conformance, independent instances, deinit safety |

Test base paths:
- Android unit: `android/app/src/test/java/com/molt/marketplace/`
- iOS: `ios/MoltMarketplaceTests/`

---

## NetworkMonitor

`NetworkMonitor` is a cross-cutting concern provided as a singleton by the DI layer.

**Android** (`core/network/NetworkMonitor.kt` + `NetworkMonitorImpl.kt`):
- Concrete class with `@Inject constructor` and `@Singleton`; Hilt resolves it automatically without an explicit `@Provides`
- Exposes `isConnected: StateFlow<Boolean>` via `ConnectivityManager` + `NetworkCallback`

**iOS** (`Core/Network/NetworkMonitor.swift`):
- Concrete `@Observable final class`; registered in `Container` as `.singleton`
- Exposes `isConnected: Bool` (observed by SwiftUI via `@Observable`) via `NWPathMonitor`

---

## Testing Summary

| Platform | Test Files | Test Cases |
|----------|-----------|-----------|
| Android | 4 | 55 |
| iOS | 2 | 21 |
| **Total** | **6** | **76** |

Coverage targets met: >= 80% lines, >= 70% branches on both platforms.

Test approach:
- Android: Module provider methods called directly as plain functions — no Hilt component graph tested
- Android: Robolectric `@Config(sdk = [33])` used for `StorageModuleTest` to obtain an Android `Context`
- iOS: Init-based injection used in `NetworkMonitorTests`; container overrides with `@Suite(.serialized)` in `ContainerTests`

---

## Integration Points for Future Features

| Feature | What Needs to Change |
|---------|---------------------|
| M0-06: Auth Infrastructure | Add `KeychainTokenStorage` and wire `tokenStorage` into `Container`; replace `NoOpTokenProvider` / `InMemoryTokenProvider` with a real implementation; `@AuthenticatedClient` OkHttpClient already prepared |
| All M1+ features | Create `Container+<Name>.swift` (iOS) or `<Name>Module.kt` (Android) following the canonical feature DI pattern above |
| M2-01: Cart | Add `CartItem` `@Entity` to `MoltDatabase.entities`; expose `cartDao()` abstract function; increment DB version |

---

## Documentation References

- **Feature Spec**: `shared/feature-specs/di-setup.md`
- **Architect Handoff**: `docs/pipeline/di-setup-architect.handoff.md`
- **CLAUDE.md Standards**: `CLAUDE.md`
- **Android Standards**: `docs/standards/android.md`
- **iOS Standards**: `docs/standards/ios.md`

---

**Last Updated**: 2026-02-21
**Agent**: doc-writer
**Status**: Complete
