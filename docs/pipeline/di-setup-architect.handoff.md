# Handoff: di-setup -- Architect (Verified)

## Feature
**M0-05: DI Setup** -- Dependency injection module structure for network, storage, coroutine, and common infrastructure dependencies.

## Status
VERIFIED -- Spec reviewed against actual M0-03 codebase. Gap analysis complete.

## Artifacts

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/di-setup.md` |
| This Handoff | `docs/pipeline/di-setup-architect.handoff.md` |

---

## Gap Analysis: Spec vs Reality

M0-03 (Network Layer) has already been implemented. The spec was written assuming M0-05 would run before M0-03, but M0-03 ran first and created significant DI infrastructure. This handoff reconciles what exists with what still needs to be done.

### What Already Exists (from M0-03)

#### Android

| File | Path (relative to `android/app/src/main/java/com/molt/marketplace/`) | What It Provides |
|------|----------------------------------------------------------------------|-----------------|
| `NetworkModule.kt` | `core/di/NetworkModule.kt` | `Json`, single `OkHttpClient` (with auth interceptor + authenticator), `Retrofit`, `TokenProvider` (no-op), `AuthInterceptor`, `TokenRefreshAuthenticator` |
| `NetworkMonitor.kt` | `core/network/NetworkMonitor.kt` | Concrete class (not interface) with `@Inject constructor`, `ConnectivityManager` + `NetworkCallback`, exposes `StateFlow<Boolean>` |
| `TokenProvider.kt` | `core/network/TokenProvider.kt` | Interface: `getAccessToken()`, `refreshToken()`, `clearTokens()` |
| `AuthInterceptor.kt` | `core/network/AuthInterceptor.kt` | OkHttp `Interceptor` injecting auth headers |
| `TokenRefreshAuthenticator.kt` | `core/network/TokenRefreshAuthenticator.kt` | OkHttp `Authenticator` handling 401 refresh |
| `OkHttpClientFactory.kt` | `core/network/OkHttpClientFactory.kt` | Factory building the single `OkHttpClient` with cache, interceptors, authenticator |
| `ApiClient.kt` | `core/network/ApiClient.kt` | `object` with `createRetrofit()` factory method |
| `LoggingInterceptor.kt` | `core/network/LoggingInterceptor.kt` | Debug logging interceptor |
| `RetryInterceptor.kt` | `core/network/RetryInterceptor.kt` | Retry with backoff |
| `MoltApplication.kt` | `MoltApplication.kt` | `@HiltAndroidApp` annotation, Timber init |

#### iOS

| File | Path (relative to `ios/MoltMarketplace/`) | What It Provides |
|------|-------------------------------------------|-----------------|
| `Container+Extensions.swift` | `Core/DI/Container+Extensions.swift` | Registers `tokenProvider` (.singleton), `apiClient` (.singleton), `networkMonitor` (.singleton) |
| `APIClient.swift` | `Core/Network/APIClient.swift` | Concrete `final class` (not a protocol). Handles request building, auth token injection, 401 refresh, retry, error mapping. Creates its own `URLSession` internally. |
| `NetworkMonitor.swift` | `Core/Network/NetworkMonitor.swift` | Concrete `@Observable final class` (not protocol+impl). Uses `NWPathMonitor`. Exposes `isConnected: Bool`. |
| `TokenProvider.swift` | `Core/Network/TokenProvider.swift` | Protocol + `NoOpTokenProvider` placeholder |
| `AuthMiddleware.swift` | `Core/Network/AuthMiddleware.swift` | `TokenRefreshActor` for concurrent token refresh serialization |
| `NetworkConfig.swift` | `Core/Network/NetworkConfig.swift` | Timeout and cache constants |

### Spec Discrepancies

| # | Spec Says | Reality | Resolution |
|---|-----------|---------|------------|
| 1 | `NetworkModule` should have `@AuthenticatedClient` / `@UnauthenticatedClient` OkHttpClient qualifiers | M0-03 provides a single `OkHttpClient` with auth always attached | **Add qualifiers in M0-05.** Refactor: rename existing client to `@AuthenticatedClient`, add new `@UnauthenticatedClient` client without auth interceptor/authenticator. Update Retrofit to use authenticated client. |
| 2 | `NetworkMonitor` should be interface + impl | Android: concrete class with `@Inject`. iOS: concrete `@Observable` class. | **Keep as-is for now.** The concrete class pattern works. Adding an interface creates unnecessary indirection since there is only one implementation. If testability becomes an issue, a `FakeNetworkMonitor` subclass or wrapper can be used. No refactor needed in M0-05. |
| 3 | iOS `APIClient` should be a protocol | iOS `APIClient` is a concrete `final class` | **Keep as-is.** M0-03 built a complete concrete class. A protocol is not needed because test doubles can use init-based injection or `Container.shared.apiClient.register { MockAPIClient() }`. No refactor needed. |
| 4 | iOS Container should have `authenticatedSession` / `unauthenticatedSession` | `APIClient` creates its own `URLSession` internally | **Skip separate session registrations.** The `APIClient` already manages its session. Exposing raw `URLSession` in the container would duplicate concerns. |
| 5 | iOS Container should have `tokenStorage` registration | Not implemented | **Defer to M0-06 (Auth Infrastructure).** `tokenStorage` requires `KeychainTokenStorage` which is an auth feature, not a DI structural feature. |
| 6 | Spec expects `NetworkModule` does NOT have auth interceptors yet | M0-03 already wired `AuthInterceptor` + `TokenRefreshAuthenticator` with `InMemoryTokenProvider` | **Keep existing wiring.** The no-op `InMemoryTokenProvider` makes the auth interceptor harmless until M0-06 provides a real implementation. |

---

## Android Dev Tasks

### Files to CREATE

| # | File | Path | Description |
|---|------|------|-------------|
| 1 | `Qualifiers.kt` | `core/di/Qualifiers.kt` | Five `@Qualifier` annotations: `@IoDispatcher`, `@MainDispatcher`, `@DefaultDispatcher`, `@AuthenticatedClient`, `@UnauthenticatedClient` |
| 2 | `CoroutineModule.kt` | `core/di/CoroutineModule.kt` | `@Module @InstallIn(SingletonComponent::class)` providing three dispatchers and an app-scoped `CoroutineScope` |
| 3 | `StorageModule.kt` | `core/di/StorageModule.kt` | `@Module @InstallIn(SingletonComponent::class)` providing `DataStore<Preferences>` and `MoltDatabase` |
| 4 | `MoltDatabase.kt` | `core/data/local/MoltDatabase.kt` | `@Database(entities = [], version = 1, exportSchema = false)` empty Room database shell |

### Files to MODIFY

| # | File | Path | Changes |
|---|------|------|---------|
| 1 | `NetworkModule.kt` | `core/di/NetworkModule.kt` | Add `@AuthenticatedClient` qualifier to existing `provideOkHttpClient()`. Add new `@UnauthenticatedClient`-qualified client (same config but without `AuthInterceptor` / `TokenRefreshAuthenticator`). Add `@Provides @Singleton` for `NetworkMonitor`. Update `provideRetrofit()` to use `@AuthenticatedClient`-qualified client. |

### Detailed Implementation Guide

#### 1. Qualifiers.kt

```kotlin
package com.molt.marketplace.core.di

import javax.inject.Qualifier

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class IoDispatcher

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class MainDispatcher

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class DefaultDispatcher

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class AuthenticatedClient

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class UnauthenticatedClient
```

#### 2. CoroutineModule.kt

```kotlin
package com.molt.marketplace.core.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object CoroutineModule {

    @Provides
    @IoDispatcher
    fun provideIoDispatcher(): CoroutineDispatcher = Dispatchers.IO

    @Provides
    @MainDispatcher
    fun provideMainDispatcher(): CoroutineDispatcher = Dispatchers.Main

    @Provides
    @DefaultDispatcher
    fun provideDefaultDispatcher(): CoroutineDispatcher = Dispatchers.Default

    @Provides
    @Singleton
    fun provideApplicationScope(
        @DefaultDispatcher dispatcher: CoroutineDispatcher,
    ): CoroutineScope = CoroutineScope(SupervisorJob() + dispatcher)
}
```

#### 3. NetworkModule.kt (MODIFY)

The existing `NetworkModule.kt` must be updated to:

a. Add `@AuthenticatedClient` qualifier to the existing `provideOkHttpClient()` method
b. Add a new `@UnauthenticatedClient`-qualified `provideUnauthenticatedClient()` that builds a client WITHOUT `AuthInterceptor` and `TokenRefreshAuthenticator`
c. Update `provideRetrofit()` parameter to use `@AuthenticatedClient` qualifier
d. Add `provideNetworkMonitor()` method (the existing `NetworkMonitor` class uses `@Inject constructor` so Hilt can resolve it automatically, but an explicit `@Provides` makes the dependency graph clearer and matches the spec)

The `@UnauthenticatedClient` client should use `OkHttpClient.Builder()` directly with the same cache/timeout config but no auth interceptors. Use the shared `NetworkConfig` constants.

**Important**: The existing single-client approach works because the `AuthInterceptor` checks `isPublicEndpoint()` and skips auth for login/register. Adding the qualified split is a cleaner separation for future features that explicitly want zero auth headers (e.g., health check, public catalog browsing).

```kotlin
// Add to NetworkModule.kt:

@Provides
@Singleton
@AuthenticatedClient  // Add this qualifier to existing provideOkHttpClient
fun provideAuthenticatedClient(
    @ApplicationContext context: Context,
    authInterceptor: AuthInterceptor,
    tokenRefreshAuthenticator: TokenRefreshAuthenticator,
): OkHttpClient = OkHttpClientFactory.create(
    context = context,
    authInterceptor = authInterceptor,
    tokenRefreshAuthenticator = tokenRefreshAuthenticator,
)

@Provides
@Singleton
@UnauthenticatedClient
fun provideUnauthenticatedClient(
    @ApplicationContext context: Context,
): OkHttpClient {
    val cache = Cache(
        directory = File(context.cacheDir, "http_cache_public"),
        maxSize = NetworkConfig.CACHE_SIZE_BYTES,
    )
    return OkHttpClient.Builder()
        .connectTimeout(NetworkConfig.CONNECT_TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .readTimeout(NetworkConfig.READ_TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .writeTimeout(NetworkConfig.WRITE_TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .cache(cache)
        .addNetworkInterceptor(LoggingInterceptor.create())
        .build()
}

// Update existing provideRetrofit to reference @AuthenticatedClient:
@Provides
@Singleton
fun provideRetrofit(
    @AuthenticatedClient okHttpClient: OkHttpClient,
    json: Json,
): Retrofit = ApiClient.createRetrofit(
    baseUrl = BuildConfig.API_BASE_URL,
    okHttpClient = okHttpClient,
    json = json,
)
```

#### 4. StorageModule.kt

```kotlin
package com.molt.marketplace.core.di

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.preferencesDataStore
import com.molt.marketplace.core.data.local.MoltDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton
import androidx.room.Room

private val Context.preferencesDataStore by preferencesDataStore(name = "molt_preferences")

@Module
@InstallIn(SingletonComponent::class)
object StorageModule {

    @Provides
    @Singleton
    fun providePreferencesDataStore(
        @ApplicationContext context: Context,
    ): DataStore<Preferences> = context.preferencesDataStore

    @Provides
    @Singleton
    fun provideDatabase(
        @ApplicationContext context: Context,
    ): MoltDatabase = Room.databaseBuilder(
        context,
        MoltDatabase::class.java,
        "molt_database",
    ).fallbackToDestructiveMigration().build()
}
```

#### 5. MoltDatabase.kt

```kotlin
package com.molt.marketplace.core.data.local

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [], version = 1, exportSchema = false)
abstract class MoltDatabase : RoomDatabase()
```

### Android Test Files to CREATE

| # | File | Path |
|---|------|------|
| 1 | `CoroutineModuleTest.kt` | `app/src/test/java/com/molt/marketplace/core/di/CoroutineModuleTest.kt` |
| 2 | `NetworkModuleTest.kt` | `app/src/test/java/com/molt/marketplace/core/di/NetworkModuleTest.kt` |
| 3 | `StorageModuleTest.kt` | `app/src/test/java/com/molt/marketplace/core/di/StorageModuleTest.kt` |

Test focus:
- `CoroutineModuleTest`: Verify dispatchers are correct types (IO, Main, Default); verify `CoroutineScope` uses `SupervisorJob`
- `NetworkModuleTest`: Verify `Json` config flags; verify two `OkHttpClient` instances differ (authenticated has interceptor, unauthenticated does not); verify `Retrofit` base URL
- `StorageModuleTest`: Verify `DataStore` and `MoltDatabase` can be created (use Robolectric context)

---

## iOS Dev Tasks

### Files to CREATE

None. All required files already exist from M0-03.

### Files to MODIFY

| # | File | Path | Changes |
|---|------|------|---------|
| 1 | `Container+Extensions.swift` | `Core/DI/Container+Extensions.swift` | No changes needed. Current registrations (`tokenProvider`, `apiClient`, `networkMonitor`) are correct and sufficient for M0-05 scope. |

### What the iOS Dev Does NOT Need to Do

The spec originally listed several tasks that are no longer applicable:

1. **Stub protocols for `APIClient`**: Not needed. `APIClient` is already a full implementation (concrete class).
2. **Stub protocols for `TokenStorage` / `KeychainTokenStorage`**: Not needed. These are M0-06 scope, not M0-05.
3. **`authenticatedSession` / `unauthenticatedSession` container registrations**: Not needed. `APIClient` manages its own `URLSession` internally.
4. **`NetworkMonitor` protocol + impl split**: Not needed. The concrete `@Observable` class works well with SwiftUI observation.

### What the iOS Dev SHOULD Do

1. **Verify the existing Container registrations resolve correctly** by writing `ContainerTests.swift`
2. **Verify `NetworkMonitor` works** by writing `NetworkMonitorTests.swift`
3. **Document the feature DI pattern** for future features (as inline comments in `Container+Extensions.swift` or a separate doc)

### iOS Test Files to CREATE

| # | File | Path |
|---|------|------|
| 1 | `ContainerTests.swift` | `MoltMarketplaceTests/Core/DI/ContainerTests.swift` |
| 2 | `NetworkMonitorTests.swift` | `MoltMarketplaceTests/Core/Network/NetworkMonitorTests.swift` |

Test focus:
- `ContainerTests`: Verify `Container.shared.apiClient()` resolves singleton; verify `Container.shared.networkMonitor()` resolves singleton; verify `Container.shared.tokenProvider()` resolves `NoOpTokenProvider`; verify singletons return the same instance on second resolution
- `NetworkMonitorTests`: Verify initial `isConnected` state; verify `NWPathMonitor` integration does not crash

---

## Feature DI Pattern (Reference -- Both Platforms)

This pattern is mandatory for all M1+ features. It is documented in the spec (sections 8.6/9.2) and reproduced here for quick reference.

### Android Pattern

```kotlin
// 1. Repository binding (core/di/<Name>Module.kt or feature/<name>/di/<Name>Module.kt)
@Module
@InstallIn(ViewModelComponent::class)
abstract class ProductModule {
    @Binds
    abstract fun bindProductRepository(impl: ProductRepositoryImpl): ProductRepository
}

// 2. Use case -- no module needed, just @Inject constructor
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

// 4. API service (add to NetworkModule or create separate module)
@Module
@InstallIn(SingletonComponent::class)
object ProductApiModule {
    @Provides
    fun provideProductApi(retrofit: Retrofit): ProductApi =
        retrofit.create(ProductApi::class.java)
}
```

### iOS Pattern

```swift
// 1. Container extension (Core/DI/Container+Product.swift)
extension Container {
    var productRepository: Factory<ProductRepository> {
        self { ProductRepositoryImpl(apiClient: self.apiClient()) }
    }

    var getProductsUseCase: Factory<GetProductsUseCase> {
        self { GetProductsUseCase(repository: self.productRepository()) }
    }
}

// 2. ViewModel with init-based injection (preferred for testability)
@MainActor @Observable
final class ProductListViewModel {
    private let getProductsUseCase: GetProductsUseCase

    init(getProductsUseCase: GetProductsUseCase = Container.shared.getProductsUseCase()) {
        self.getProductsUseCase = getProductsUseCase
    }
}
```

---

## Build Verification Criteria

### Android

- [ ] `./gradlew assembleDebug` succeeds
- [ ] `Qualifiers.kt` compiles with all five `@Qualifier` annotations
- [ ] `CoroutineModule` provides three dispatchers and an app-scoped `CoroutineScope`
- [ ] `NetworkModule` provides two `OkHttpClient` instances with correct qualifiers
- [ ] `NetworkModule` provides `Retrofit` using `@AuthenticatedClient` client
- [ ] `StorageModule` provides `DataStore<Preferences>` and `MoltDatabase`
- [ ] `MoltDatabase` compiles as empty Room database
- [ ] Existing `NetworkMonitor` still resolves via Hilt (via `@Inject constructor`)
- [ ] All unit tests pass
- [ ] App launches on emulator without DI-related crashes

### iOS

- [ ] Xcode build succeeds
- [ ] `Container.shared.apiClient()` resolves a singleton instance
- [ ] `Container.shared.networkMonitor()` resolves a singleton instance
- [ ] `Container.shared.tokenProvider()` resolves a singleton instance
- [ ] Singletons return same instance on multiple resolutions
- [ ] All unit tests pass
- [ ] App launches in simulator without DI-related crashes

---

## Summary: Effort Split

| Agent | Effort | Description |
|-------|--------|-------------|
| **Android Dev** | Medium | Create 4 new files (`Qualifiers.kt`, `CoroutineModule.kt`, `StorageModule.kt`, `MoltDatabase.kt`). Modify 1 file (`NetworkModule.kt` to add client qualifiers). Write 3 test files. |
| **iOS Dev** | Low | All source files already exist from M0-03. Write 2 test files to verify existing container registrations and `NetworkMonitor`. |

---

## Downstream Dependencies

| Downstream Feature | What It Needs From M0-05 |
|-------------------|--------------------------|
| **M0-06 (Auth Infrastructure)** | `StorageModule` for encrypted DataStore / Keychain storage. `CoroutineModule` for dispatcher injection. `@AuthenticatedClient` / `@UnauthenticatedClient` qualifiers for client separation. `TokenProvider` interface (already exists from M0-03). |
| **All M1+ features** | Feature DI pattern (repository `@Binds` in `ViewModelComponent`, use case `@Inject constructor`, `Container` extension for iOS). `CoroutineModule` dispatcher qualifiers for repository/use case background work. `Retrofit` instance for API service creation. |

---

**Verified**: 2026-02-21
**Agent**: architect
