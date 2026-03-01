# M0-05: DI Setup -- Feature Specification

## Overview

The DI Setup establishes the dependency injection module structure for the XiriGo Ecommerce buyer app.
It creates the Hilt modules (Android) and Factory container registrations (iOS) that provide
network, storage, coroutine/concurrency, and common infrastructure dependencies. It also defines the
canonical pattern that every future feature module must follow when registering its own repositories,
use cases, and ViewModels. No business logic or UI screens are produced by this task; it is purely
structural wiring that enables all subsequent features to declare and resolve their dependencies
in a consistent, testable, and compile-time-verified manner.

### User Stories

- As a **developer**, I want DI modules organized by concern (network, storage, coroutines) so that
  dependencies are easy to find and maintain.
- As a **developer**, I want a clear, documented pattern for registering feature-specific dependencies
  (repositories, use cases, ViewModels) so that every feature follows the same convention.
- As a **developer**, I want test modules that swap real implementations for fakes so that unit tests
  run without network or storage access.
- As a **developer**, I want qualifier annotations for dispatchers and HTTP clients so that I can
  inject the correct variant without ambiguity.
- As a **developer**, I want singleton-scoped infrastructure (HTTP clients, database, token storage)
  so that expensive resources are created only once.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Hilt modules: NetworkModule, StorageModule, CoroutineModule (Android) | Network layer implementation (M0-03 -- interceptors, error handling) |
| Qualifier annotations: dispatchers, HTTP client variants (Android) | Auth infrastructure (M0-06 -- AuthInterceptor, TokenRefreshAuthenticator) |
| Factory container registrations: apiClient, tokenStorage, networkMonitor (iOS) | Actual API service interfaces (created per feature) |
| Documented feature DI pattern with concrete examples | Navigation graph registration (M0-04) |
| Test replacement patterns for both platforms | Design system components (M0-02) |
| Room database abstract class shell (Android) | Room Entity/DAO definitions (created per feature) |

### Dependencies on Other Features

| Dependency | What It Provides |
|------------|-----------------|
| **M0-01: App Scaffold** | `@HiltAndroidApp` (XGApplication), `Container+Extensions.swift` (empty shell), Gradle/SPM dependencies declared, placeholder directories for `core/di/`, `core/network/`, environment config (`BuildConfig.API_BASE_URL`, `Config.apiBaseURL`) |

### Features That Depend on This

| Feature | What It Needs |
|---------|--------------|
| **M0-03: Network Layer** | `@AuthenticatedClient` / `@UnauthenticatedClient` OkHttpClient qualifiers, `Json` serialization instance, dispatcher qualifiers |
| **M0-06: Auth Infrastructure** | `StorageModule` for token storage (encrypted DataStore / Keychain), `CoroutineModule` for dispatcher injection |
| **All M1+ features** | The feature DI pattern (how to register repositories, use cases, ViewModels) |

---

## 1. API Mapping

Not applicable. This is an infrastructure feature with no backend API interaction. All API
service interfaces are created by individual features (starting in M0-03 and M1+). The DI
modules provide the underlying `Retrofit` instance and `OkHttpClient` that those services
depend on.

---

## 2. Data Models

This feature does not produce domain models or DTOs. It produces structural artifacts:
qualifier annotations, Hilt modules, Factory registrations, and a Room database shell.
The following subsections describe the DI graph structure and the types that are provided
or qualified.

### 2.1 Qualifier Annotations (Android)

Qualifier annotations disambiguate multiple bindings of the same type. They are defined in
a single `Qualifiers.kt` file inside `core/di/`.

| Annotation | Target Type | Purpose |
|-----------|-------------|---------|
| `@IoDispatcher` | `CoroutineDispatcher` | Background I/O work (network, disk) |
| `@MainDispatcher` | `CoroutineDispatcher` | UI thread work |
| `@DefaultDispatcher` | `CoroutineDispatcher` | CPU-intensive work |
| `@AuthenticatedClient` | `OkHttpClient` | Includes `AuthInterceptor` + `TokenRefreshAuthenticator` (wired in M0-06) |
| `@UnauthenticatedClient` | `OkHttpClient` | No auth headers; used for login, register, public endpoints |

Each annotation is a `@Qualifier` + `@Retention(AnnotationRetention.BINARY)` Kotlin annotation.

### 2.2 DI Graph Structure

**Singleton scope** (created once, lives for app lifetime):

| Type | Android Provider | iOS Provider |
|------|-----------------|-------------|
| `Json` (Kotlin Serialization) | `NetworkModule.provideJson()` | N/A (use `JSONDecoder`/`JSONEncoder` inline) |
| `OkHttpClient` (@UnauthenticatedClient) | `NetworkModule.provideUnauthenticatedClient()` | N/A (URLSession) |
| `OkHttpClient` (@AuthenticatedClient) | `NetworkModule.provideAuthenticatedClient()` | N/A (URLSession) |
| `Retrofit` | `NetworkModule.provideRetrofit()` | N/A (use `APIClient`) |
| `APIClient` | N/A (use Retrofit) | `Container.apiClient` (.singleton) |
| `URLSession` (authenticated) | N/A | `Container.authenticatedSession` (.singleton) |
| `URLSession` (unauthenticated) | N/A | `Container.unauthenticatedSession` (.singleton) |
| `DataStore<Preferences>` | `StorageModule.providePreferencesDataStore()` | N/A (UserDefaults) |
| `XGDatabase` (Room) | `StorageModule.provideDatabase()` | N/A (SwiftData) |
| Token storage (encrypted) | `StorageModule.provideEncryptedDataStore()` | `Container.tokenStorage` (.singleton) |
| `NetworkMonitor` | `NetworkModule.provideNetworkMonitor()` | `Container.networkMonitor` (.singleton) |

**ViewModel scope** (Android only -- lives for ViewModel lifetime):

Feature repositories and use cases are scoped to `ViewModelComponent` so they are created
fresh per ViewModel instance. This avoids stale state across screen navigations.

**Transient / Factory scope** (iOS -- created fresh on each resolution):

Feature repositories and use cases in iOS use Factory's default scope (no `.singleton`,
no `.cached`), so each ViewModel gets its own instance.

### 2.3 Room Database Shell (Android)

```
@Database(entities = [], version = 1, exportSchema = false)
abstract class XGDatabase : RoomDatabase()
```

The entity list starts empty. Each feature that needs local structured storage will:
1. Create its `@Entity` class in `feature/<name>/data/local/`
2. Create its `@Dao` interface in `feature/<name>/data/local/`
3. Add the entity to the `entities` array and expose the DAO as an abstract function
4. Increment the database version and provide a migration

This pattern is documented here; the actual entities are out of scope for M0-05.

---

## 3. UI Wireframe

Not applicable. This is an infrastructure feature with no user-facing screens.

---

## 4. Navigation Flow

Not applicable. This feature produces no screens and no navigation destinations.

---

## 5. State Management

This feature does not produce ViewModels or UI states. However, it defines how stateful
infrastructure singletons are scoped and how ViewModels in future features will receive
their dependencies.

### 5.1 Singleton Provisions

The following are provided as singletons (one instance for the entire app lifetime):

| Dependency | Justification |
|-----------|---------------|
| `OkHttpClient` (both variants) | Expensive to create; maintains connection pool and cache |
| `Retrofit` | Built from `OkHttpClient`; no reason to recreate |
| `APIClient` (iOS) | Equivalent to Retrofit; wraps URLSession |
| `DataStore<Preferences>` | Single-writer constraint; must be singleton |
| Encrypted DataStore / Keychain token storage | Security-sensitive; single accessor |
| `XGDatabase` (Room) | Database connection pool; must be singleton |
| `NetworkMonitor` | Observes system connectivity; one observer is sufficient |
| `Json` (Kotlin Serialization) | Immutable configuration; no reason to recreate |

### 5.2 ViewModel-Scoped Provisions (Android)

Feature modules register repositories and use cases in `@InstallIn(ViewModelComponent::class)`.
This means:
- A new instance is created per ViewModel
- The instance is destroyed when the ViewModel is cleared
- Multiple screens using different ViewModel instances get separate repository instances

Use cases do NOT need explicit Hilt `@Module` registration. Because use case classes have
`@Inject constructor(...)`, Hilt can provide them automatically via constructor injection.
Only repository interfaces need `@Binds` because they map an interface to an implementation.

### 5.3 Transient Provisions (iOS)

In Factory, dependencies without an explicit scope are transient -- a new instance is created
each time the dependency is resolved. Feature repositories and use cases use this default:

```swift
var productRepository: Factory<ProductRepository> {
    self { ProductRepositoryImpl(apiClient: self.apiClient()) }
    // No .singleton or .cached -- transient by default
}
```

ViewModels use `@Injected` to pull dependencies at init time. Since ViewModels are `@Observable`
objects held by `@State` in the view, they live for the view's lifetime.

---

## 6. Error Scenarios

### 6.1 Compile-Time Errors (Expected and Desired)

| Error | Cause | Resolution |
|-------|-------|------------|
| Missing `@Provides` or `@Binds` | Repository interface not bound to implementation | Add `@Binds` in the feature's Hilt `@Module` |
| Missing `@Inject` on constructor | ViewModel or use case missing constructor annotation | Add `@Inject constructor(...)` |
| Duplicate bindings | Two modules provide the same type without qualifiers | Add `@Qualifier` annotation to disambiguate |
| Circular dependency | A depends on B which depends on A | Refactor to break the cycle (introduce a mediator or use `Provider<T>`) |
| Factory unresolved key (iOS) | Container property not defined | Add the registration to `Container+Extensions.swift` |

### 6.2 Runtime Errors

Under normal circumstances, there are no runtime DI errors because both Hilt and Factory
resolve dependencies at compile time (Hilt via annotation processing, Factory via Swift
type checking). The only runtime failure case is:

| Error | Cause | Mitigation |
|-------|-------|------------|
| Room migration failure | Database version incremented without migration | Always provide `Migration` objects or use `fallbackToDestructiveMigration()` during development |
| DataStore corruption | Interrupted write | DataStore handles this internally with atomic file operations |

### 6.3 Test Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| `@TestInstallIn` not replacing module | Missing `replaces` parameter | Specify `replaces = [NetworkModule::class]` |
| iOS test container not reset | Previous test's override leaking | Call `Container.shared.reset()` in `setUp()` |

---

## 7. Accessibility

Not applicable. This is an infrastructure feature with no user-facing UI elements.

---

## 8. Android Implementation Details

### 8.1 Qualifiers.kt

```
Package: com.xirigo.ecommerce.core.di

Annotations defined:
  @Qualifier @Retention(BINARY) annotation class IoDispatcher
  @Qualifier @Retention(BINARY) annotation class MainDispatcher
  @Qualifier @Retention(BINARY) annotation class DefaultDispatcher
  @Qualifier @Retention(BINARY) annotation class AuthenticatedClient
  @Qualifier @Retention(BINARY) annotation class UnauthenticatedClient
```

### 8.2 CoroutineModule.kt

```
Package: com.xirigo.ecommerce.core.di
@Module @InstallIn(SingletonComponent::class)

Provides:
  @IoDispatcher @Provides fun provideIoDispatcher(): CoroutineDispatcher = Dispatchers.IO
  @MainDispatcher @Provides fun provideMainDispatcher(): CoroutineDispatcher = Dispatchers.Main
  @DefaultDispatcher @Provides fun provideDefaultDispatcher(): CoroutineDispatcher = Dispatchers.Default
  @Provides @Singleton fun provideCoroutineScope(@DefaultDispatcher dispatcher: CoroutineDispatcher): CoroutineScope
      = CoroutineScope(SupervisorJob() + dispatcher)
```

The `CoroutineScope` provision creates an application-scoped coroutine scope that can be injected
into repositories or services that need to run work beyond a single ViewModel's lifetime (for
example, syncing data in the background). It uses `SupervisorJob` so that a single child failure
does not cancel sibling coroutines.

### 8.3 NetworkModule.kt

```
Package: com.xirigo.ecommerce.core.di
@Module @InstallIn(SingletonComponent::class)

Provides:
  @Provides @Singleton
  fun provideJson(): Json
      -- Json { ignoreUnknownKeys = true; isLenient = false; encodeDefaults = true; explicitNulls = false }

  @Provides @Singleton @UnauthenticatedClient
  fun provideUnauthenticatedClient(
      application: Application
  ): OkHttpClient
      -- OkHttpClient.Builder()
           .connectTimeout(30, SECONDS)
           .readTimeout(60, SECONDS)
           .writeTimeout(60, SECONDS)
           .cache(Cache(application.cacheDir / "http_cache", 10 * 1024 * 1024))
           .addInterceptor(HttpLoggingInterceptor() if DEBUG)
           .addInterceptor(ChuckerInterceptor(application) if DEBUG)
           .build()

  @Provides @Singleton @AuthenticatedClient
  fun provideAuthenticatedClient(
      @UnauthenticatedClient baseClient: OkHttpClient,
  ): OkHttpClient
      -- baseClient.newBuilder()
           // AuthInterceptor and TokenRefreshAuthenticator added in M0-06
           .build()
      Note: Returns a copy of the unauthenticated client in M0-05.
            M0-06 will update this method to add auth interceptor + authenticator.

  @Provides @Singleton
  fun provideRetrofit(
      @AuthenticatedClient client: OkHttpClient,
      json: Json,
  ): Retrofit
      -- Retrofit.Builder()
           .baseUrl(BuildConfig.API_BASE_URL)
           .client(client)
           .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
           .build()

  @Provides @Singleton
  fun provideNetworkMonitor(application: Application): NetworkMonitor
      -- NetworkMonitorImpl(application)
      Note: NetworkMonitor interface + implementation created in M0-03 or here.
            Exposes Flow<Boolean> for connectivity state.
```

**Important note on Retrofit's default client**: The primary `Retrofit` instance uses the
`@AuthenticatedClient` because the majority of API calls require authentication. Endpoints
that must NOT send auth tokens (login, register) will use a dedicated `@UnauthenticatedClient`-qualified
Retrofit or direct OkHttpClient. This split is finalized in M0-06 when auth interceptors are wired.

### 8.4 StorageModule.kt

```
Package: com.xirigo.ecommerce.core.di
@Module @InstallIn(SingletonComponent::class)

Provides:
  @Provides @Singleton
  fun providePreferencesDataStore(application: Application): DataStore<Preferences>
      -- application.preferencesDataStore(name = "xg_preferences")
      Note: Uses the property delegate pattern at module level:
            private val Context.preferencesDataStore by preferencesDataStore(name = "xg_preferences")
            The @Provides method returns application.preferencesDataStore

  @Provides @Singleton
  fun provideDatabase(application: Application): XGDatabase
      -- Room.databaseBuilder(application, XGDatabase::class.java, "xg_database")
           .fallbackToDestructiveMigration()  // Development only; replace with migrations before release
           .build()

  @Provides @Singleton
  fun provideEncryptedDataStore(application: Application): DataStore<Preferences>
      -- Encrypted preferences DataStore using Tink for token storage.
         Qualified separately from the general DataStore (use a @TokenDataStore qualifier
         or provide via a wrapper type like TokenStorage).
         Implementation detail: Tink's AeadConfig.register() must be called,
         then create an Aead instance for encryption/decryption.
         The exact approach (EncryptedFile-backed DataStore vs wrapper) is specified in M0-06.
```

### 8.5 XGDatabase.kt

```
Package: com.xirigo.ecommerce.core.data.local
File location: core/data/local/XGDatabase.kt

@Database(entities = [], version = 1, exportSchema = false)
abstract class XGDatabase : RoomDatabase()

-- Empty entity list. Features add entities as needed.
-- Each feature's DAO is exposed as an abstract function:
   abstract fun cartDao(): CartDao        // Added by M2-01
   abstract fun wishlistDao(): WishlistDao // Added by M2-02
   etc.
```

### 8.6 Feature DI Pattern (Reference for All Future Features)

This is the canonical pattern every feature must follow when registering dependencies in Android.

**Repository binding** (required for every feature with a repository):

```
Package: com.xirigo.ecommerce.feature.<name>.di

@Module
@InstallIn(ViewModelComponent::class)
abstract class <Name>Module {
    @Binds
    abstract fun bind<Name>Repository(impl: <Name>RepositoryImpl): <Name>Repository
}
```

**Use case injection** (no module needed):

```
// Use cases are NOT registered in a module. They use @Inject constructor:
class Get<Name>UseCase @Inject constructor(
    private val repository: <Name>Repository,
) {
    operator fun invoke(...): Flow<...> = repository.get<Name>Stream(...)
}
```

**ViewModel injection**:

```
@HiltViewModel
class <Name>ViewModel @Inject constructor(
    private val get<Name>UseCase: Get<Name>UseCase,
) : ViewModel() { ... }
```

**API service provision** (add to NetworkModule or create a per-feature provider):

```
// Option A: Add a @Provides to NetworkModule (preferred for few services)
@Provides
fun provide<Name>Api(retrofit: Retrofit): <Name>Api =
    retrofit.create(<Name>Api::class.java)

// Option B: Create <Name>ApiModule (preferred when features are numerous)
@Module
@InstallIn(SingletonComponent::class)
object <Name>ApiModule {
    @Provides
    fun provide<Name>Api(retrofit: Retrofit): <Name>Api =
        retrofit.create(<Name>Api::class.java)
}
```

### 8.7 Test Replacement Pattern (Android)

**Replace a module in tests using `@TestInstallIn`:**

```
// test source set: feature/<name>/di/<Name>TestModule.kt
@TestInstallIn(
    components = [ViewModelComponent::class],
    replaces = [<Name>Module::class]
)
@Module
abstract class <Name>TestModule {
    @Binds
    abstract fun bind<Name>Repository(impl: Fake<Name>Repository): <Name>Repository
}
```

**Replace NetworkModule for integration tests:**

```
@TestInstallIn(
    components = [SingletonComponent::class],
    replaces = [NetworkModule::class]
)
@Module
class FakeNetworkModule {
    @Provides @Singleton
    fun provideJson(): Json = Json { ignoreUnknownKeys = true }

    @Provides @Singleton @UnauthenticatedClient
    fun provideClient(): OkHttpClient = OkHttpClient.Builder().build()

    // ... provide MockWebServer-backed Retrofit if needed
}
```

**Unit tests (no Hilt, manual construction):**

```
// Preferred for ViewModel tests -- no DI framework overhead
class <Name>ViewModelTest {
    private val fakeRepository = Fake<Name>Repository()
    private val useCase = Get<Name>UseCase(fakeRepository)
    private val viewModel = <Name>ViewModel(useCase)

    @Test
    fun `should load data on init`() = runTest { ... }
}
```

---

## 9. iOS Implementation Details

### 9.1 Container+Extensions.swift (MODIFY Existing File)

The existing empty `Container+Extensions.swift` is modified to register core infrastructure
dependencies.

```
File: ios/XiriGoEcommerce/Core/DI/Container+Extensions.swift

import Factory
import Foundation

extension Container {
    // MARK: - Network

    var apiClient: Factory<APIClient> {
        self { APIClientImpl(baseURL: Config.apiBaseURL, session: self.authenticatedSession()) }
            .singleton
    }

    var authenticatedSession: Factory<URLSession> {
        self {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 60
            config.urlCache = URLCache(
                memoryCapacity: 10 * 1024 * 1024,
                diskCapacity: 50 * 1024 * 1024
            )
            // Auth protocol delegate / interceptor added in M0-06
            return URLSession(configuration: config)
        }
        .singleton
    }

    var unauthenticatedSession: Factory<URLSession> {
        self {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 60
            return URLSession(configuration: config)
        }
        .singleton
    }

    // MARK: - Storage

    var tokenStorage: Factory<TokenStorage> {
        self { KeychainTokenStorage() }
            .singleton
    }

    // MARK: - Monitoring

    var networkMonitor: Factory<NetworkMonitor> {
        self { NetworkMonitorImpl() }
            .singleton
    }
}
```

**Types referenced** (defined in M0-03 and M0-06, documented here for context):

| Type | Defined In | Description |
|------|-----------|-------------|
| `APIClient` (protocol) | M0-03 | Protocol with `func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T` |
| `APIClientImpl` (class) | M0-03 | Implementation using URLSession |
| `TokenStorage` (protocol) | M0-06 | Protocol with `func getAccessToken() async -> String?`, `func save(accessToken:refreshToken:)`, `func clear()` |
| `KeychainTokenStorage` (class) | M0-06 | KeychainAccess-based implementation |
| `NetworkMonitor` (protocol) | M0-03 or M0-05 | Protocol with `var isConnected: Bool { get }` and `var connectivityStream: AsyncStream<Bool> { get }` |
| `NetworkMonitorImpl` (class) | M0-03 or M0-05 | NWPathMonitor-based implementation |

Note: The `Container+Extensions.swift` file can reference these types even before they are
implemented, as long as the protocols and implementations exist by the time the project compiles.
In practice, M0-03 (Network Layer) and M0-06 (Auth Infrastructure) create these types, and
M0-05 wires them into the DI container. If M0-05 is implemented before M0-03/M0-06, stub
protocols and placeholder implementations should be created so the project compiles.

### 9.2 Feature DI Pattern (Reference for All Future Features)

**Repository and use case registration:**

```swift
// Option A: Add to Container+Extensions.swift (small project)
extension Container {
    var productRepository: Factory<ProductRepository> {
        self { ProductRepositoryImpl(apiClient: self.apiClient()) }
    }

    var getProductsUseCase: Factory<GetProductsUseCase> {
        self { GetProductsUseCase(repository: self.productRepository()) }
    }
}

// Option B: Separate file per feature (recommended for larger projects)
// File: Core/DI/Container+Product.swift
extension Container {
    var productRepository: Factory<ProductRepository> {
        self { ProductRepositoryImpl(apiClient: self.apiClient()) }
    }

    var getProductsUseCase: Factory<GetProductsUseCase> {
        self { GetProductsUseCase(repository: self.productRepository()) }
    }

    var getProductByIdUseCase: Factory<GetProductByIdUseCase> {
        self { GetProductByIdUseCase(repository: self.productRepository()) }
    }
}
```

**ViewModel injection pattern:**

```swift
@MainActor @Observable
final class ProductListViewModel {
    @ObservationIgnored @Injected(\.getProductsUseCase) private var useCase
    private(set) var uiState: ProductListUiState = .loading

    // ViewModel uses injected use case...
}
```

**ViewModel with init-based injection (for testability):**

```swift
@MainActor @Observable
final class ProductListViewModel {
    private let getProductsUseCase: GetProductsUseCase

    init(getProductsUseCase: GetProductsUseCase = Container.shared.getProductsUseCase()) {
        self.getProductsUseCase = getProductsUseCase
    }
}
```

The init-based pattern is preferred for ViewModels that need unit testing, as it allows
injecting fakes without modifying the DI container.

### 9.3 Test Replacement Pattern (iOS)

**Override container in tests:**

```swift
import Testing
@testable import XiriGoEcommerce

@Suite(.serialized)
struct ProductListViewModelTests {
    init() {
        // Reset and override for tests
        Container.shared.reset()
        Container.shared.apiClient.register { MockAPIClient() }
        Container.shared.productRepository.register { FakeProductRepository() }
    }

    @Test func loadProducts_success() async {
        // Container now resolves fakes
        let viewModel = ProductListViewModel()
        await viewModel.loadProducts()
        // assert...
    }
}
```

**Init-based injection (preferred):**

```swift
@Test func loadProducts_success() async {
    let fakeRepository = FakeProductRepository()
    fakeRepository.products = [Product.stub()]
    let useCase = GetProductsUseCase(repository: fakeRepository)
    let viewModel = ProductListViewModel(getProductsUseCase: useCase)

    await viewModel.loadProducts()
    // assert...
}
```

---

## 10. Scoping Rules Summary

| Scope | Android (Hilt) | iOS (Factory) | Used For |
|-------|---------------|---------------|----------|
| **Singleton** | `@Singleton` + `@InstallIn(SingletonComponent::class)` | `.singleton` | OkHttpClient, Retrofit, APIClient, Database, DataStore, TokenStorage, NetworkMonitor, Json |
| **ViewModel** | `@InstallIn(ViewModelComponent::class)` | N/A (owned by ViewModel) | Feature repositories (via `@Binds`) |
| **Transient** | Default (no scope annotation) | Default (no scope) | Use cases (via `@Inject constructor`), iOS repositories |
| **Activity** | `@InstallIn(ActivityComponent::class)` | N/A | Not used (single-activity architecture) |

### Why Repositories Are ViewModel-Scoped (Android)

Repositories are bound in `ViewModelComponent` rather than `SingletonComponent` because:

1. **Stale state avoidance**: A singleton repository could accumulate stale cached data
   across screen navigations.
2. **Memory efficiency**: Repositories for rarely-used features are garbage collected when
   the ViewModel is cleared.
3. **Testing simplicity**: `@TestInstallIn` replacements at `ViewModelComponent` scope
   require fewer wiring changes.

The underlying data sources (Retrofit, Room, DataStore) are still singletons -- only the
repository facade is ViewModel-scoped.

### Why Use Cases Do Not Need Module Registration (Android)

Hilt can instantiate any class that has an `@Inject constructor` without a `@Module`.
Since use cases are concrete classes (not interfaces), and their constructor parameters are
all provided by the DI graph, no `@Binds` or `@Provides` is needed. This keeps the module
files lean -- only interface-to-implementation bindings need explicit registration.

---

## 11. NetworkMonitor

The `NetworkMonitor` is a cross-cutting concern that multiple features need (showing "No
Internet" banners, disabling checkout when offline, etc.). It is provided as a singleton
by the DI layer.

### Android

```
Interface: com.xirigo.ecommerce.core.network.NetworkMonitor
  val isConnected: StateFlow<Boolean>

Implementation: com.xirigo.ecommerce.core.network.NetworkMonitorImpl
  Uses ConnectivityManager + NetworkCallback
  Emits connectivity changes as StateFlow<Boolean>
  Provided by NetworkModule as @Singleton
```

### iOS

```
Protocol: Core/Network/NetworkMonitor.swift
  var isConnected: Bool { get }
  var connectivityStream: AsyncStream<Bool> { get }

Implementation: Core/Network/NetworkMonitorImpl.swift
  Uses NWPathMonitor
  Publishes connectivity changes via AsyncStream
  Registered in Container as .singleton
```

---

## 12. File Manifest

### 12.1 Android Files

Base path: `android/app/src/main/java/com/xirigo/ecommerce/`

| # | File Path (relative to base) | Description |
|---|------------------------------|-------------|
| 1 | `core/di/Qualifiers.kt` | `@Qualifier` annotations: `@IoDispatcher`, `@MainDispatcher`, `@DefaultDispatcher`, `@AuthenticatedClient`, `@UnauthenticatedClient` |
| 2 | `core/di/CoroutineModule.kt` | `@Module @InstallIn(SingletonComponent::class)`. Provides `CoroutineDispatcher` for IO, Main, Default; provides application-scoped `CoroutineScope` |
| 3 | `core/di/NetworkModule.kt` | `@Module @InstallIn(SingletonComponent::class)`. Provides `Json`, `OkHttpClient` (two qualifiers), `Retrofit`, `NetworkMonitor` |
| 4 | `core/di/StorageModule.kt` | `@Module @InstallIn(SingletonComponent::class)`. Provides `DataStore<Preferences>`, `XGDatabase` (Room) |
| 5 | `core/data/local/XGDatabase.kt` | `@Database(entities = [], version = 1)` abstract class. Empty shell; features add entities. |
| 6 | `core/network/NetworkMonitor.kt` | Interface: `val isConnected: StateFlow<Boolean>` |
| 7 | `core/network/NetworkMonitorImpl.kt` | Implementation using `ConnectivityManager` + `NetworkCallback` |

### 12.2 iOS Files

Base path: `ios/XiriGoEcommerce/`

| # | File Path (relative to base) | Action | Description |
|---|------------------------------|--------|-------------|
| 1 | `Core/DI/Container+Extensions.swift` | MODIFY | Add registrations: `apiClient` (.singleton), `authenticatedSession` (.singleton), `unauthenticatedSession` (.singleton), `tokenStorage` (.singleton), `networkMonitor` (.singleton) |
| 2 | `Core/Network/NetworkMonitor.swift` | CREATE | Protocol: `isConnected: Bool`, `connectivityStream: AsyncStream<Bool>` |
| 3 | `Core/Network/NetworkMonitorImpl.swift` | CREATE | Implementation using `NWPathMonitor` |

Note: `APIClient`, `APIClientImpl`, `TokenStorage`, and `KeychainTokenStorage` are defined
in M0-03 (Network Layer) and M0-06 (Auth Infrastructure) respectively. If M0-05 is
implemented first, create minimal stub protocols so the container compiles:

| # | Stub File | Contents | Replaced By |
|---|-----------|----------|-------------|
| S1 | `Core/Network/APIClient.swift` | `protocol APIClient: Sendable { }` | M0-03 |
| S2 | `Core/Network/APIClientImpl.swift` | `final class APIClientImpl: APIClient { init(baseURL: URL, session: URLSession) { } }` | M0-03 |
| S3 | `Core/Storage/TokenStorage.swift` | `protocol TokenStorage: Sendable { }` | M0-06 |
| S4 | `Core/Storage/KeychainTokenStorage.swift` | `final class KeychainTokenStorage: TokenStorage { }` | M0-06 |

### 12.3 Test Files

| # | Platform | File Path | Description |
|---|----------|-----------|-------------|
| 1 | Android | `app/src/test/java/com/xirigo/ecommerce/core/di/CoroutineModuleTest.kt` | Verify dispatcher qualifiers provide correct types |
| 2 | Android | `app/src/test/java/com/xirigo/ecommerce/core/di/NetworkModuleTest.kt` | Verify Json config, OkHttpClient qualifiers, Retrofit base URL |
| 3 | Android | `app/src/test/java/com/xirigo/ecommerce/core/di/StorageModuleTest.kt` | Verify DataStore and Room database provision |
| 4 | Android | `app/src/test/java/com/xirigo/ecommerce/core/network/NetworkMonitorImplTest.kt` | Verify connectivity state emission |
| 5 | iOS | `XiriGoEcommerceTests/Core/DI/ContainerTests.swift` | Verify all container registrations resolve without crash |
| 6 | iOS | `XiriGoEcommerceTests/Core/Network/NetworkMonitorTests.swift` | Verify connectivity stream behavior |

---

## 13. Build Verification Criteria

The DI setup is complete when:

### Android

- [ ] `./gradlew assembleDebug` succeeds without errors
- [ ] All qualifier annotations compile without warnings
- [ ] `NetworkModule` provides `Json`, two `OkHttpClient` instances, `Retrofit`, and `NetworkMonitor`
- [ ] `StorageModule` provides `DataStore<Preferences>` and `XGDatabase`
- [ ] `CoroutineModule` provides three dispatchers and an application-scoped `CoroutineScope`
- [ ] `XGDatabase` compiles as an empty Room database
- [ ] `NetworkMonitorImpl` emits connectivity state changes
- [ ] Hilt component graph resolves without missing bindings
- [ ] All unit tests in `core/di/` pass
- [ ] App launches on emulator without DI-related crashes

### iOS

- [ ] `xcodebuild -scheme XiriGoEcommerce-Debug build` succeeds
- [ ] `Container.shared.apiClient()` resolves a singleton instance
- [ ] `Container.shared.tokenStorage()` resolves a singleton instance
- [ ] `Container.shared.networkMonitor()` resolves a singleton instance
- [ ] `Container.shared.authenticatedSession()` resolves a singleton instance
- [ ] `Container.shared.unauthenticatedSession()` resolves a singleton instance
- [ ] `NetworkMonitorImpl` publishes connectivity changes via `AsyncStream`
- [ ] All unit tests in `ContainerTests.swift` pass
- [ ] App launches in simulator without DI-related crashes
- [ ] No strict concurrency warnings related to DI types

---

## 14. Implementation Notes for Developers

### For Android Developer

1. Start with `Qualifiers.kt` -- define all five qualifier annotations
2. Create `CoroutineModule.kt` -- simplest module, provides dispatchers
3. Create `XGDatabase.kt` in `core/data/local/` -- empty Room database
4. Create `StorageModule.kt` -- provides DataStore and Room database
5. Create `NetworkMonitor.kt` (interface) and `NetworkMonitorImpl.kt` in `core/network/`
6. Create `NetworkModule.kt` -- provides Json, OkHttpClient variants, Retrofit, NetworkMonitor
7. Verify: `./gradlew assembleDebug` compiles; app launches without crash
8. Write unit tests for each module
9. The `@AuthenticatedClient` OkHttpClient is a copy of `@UnauthenticatedClient` in this phase.
   M0-06 will add the `AuthInterceptor` and `TokenRefreshAuthenticator`.

**Key Hilt rules to follow:**
- All `@Module` classes use `object` (for `@Provides`) or `abstract class` (for `@Binds`)
- `@Provides` methods must be annotated with scope (`@Singleton`) if the type should be singleton
- `@InstallIn` determines component lifetime -- use `SingletonComponent` for infrastructure
- Never mix `@Binds` and `@Provides` in the same module class. Split into abstract + companion if needed.

### For iOS Developer

1. Define stub protocols for `APIClient`, `TokenStorage`, `NetworkMonitor` (if M0-03/M0-06 not yet done)
2. Create `NetworkMonitor.swift` (protocol) and `NetworkMonitorImpl.swift` in `Core/Network/`
3. Modify `Container+Extensions.swift` to add all registrations
4. Verify: scheme builds; app launches without crash
5. Write `ContainerTests.swift` to verify resolution
6. When M0-03 and M0-06 are implemented, replace stubs with real implementations

**Key Factory rules to follow:**
- Use `.singleton` for types that must be created once
- Default scope (no modifier) = transient; new instance per resolution
- Use `.cached` sparingly -- only when you need "create once, but resettable"
- All `Factory` properties must be `var` (not `let`) -- Factory requires computed properties
- `@Injected` uses the key path syntax: `@Injected(\.propertyName)`

### Common Rules (Both Platforms)

- Follow `CLAUDE.md` exactly for naming conventions, file locations, package names
- Qualifier annotations exist to prevent ambiguity -- always use them when providing
  multiple instances of the same type
- Singletons are for infrastructure only -- never make repositories or use cases singleton
- The feature DI pattern documented in sections 8.6/9.2 is mandatory for all future features
- Test replacement patterns in sections 8.7/9.3 must be followed for all feature tests
- The `NetworkMonitor` is created here because it is needed by multiple features and the DI
  layer itself (for offline-aware dependency resolution in the future)
