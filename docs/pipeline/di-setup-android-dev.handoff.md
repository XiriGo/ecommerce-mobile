# Handoff: di-setup -- Android Dev

## Feature
**M0-05: DI Setup** -- Dependency injection module structure for network, storage, coroutine, and common infrastructure dependencies.

## Status
COMPLETE -- All source files created/modified. Build passes. Existing tests pass.

## Files Created

| # | File | Absolute Path | Description |
|---|------|---------------|-------------|
| 1 | `Qualifiers.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/di/Qualifiers.kt` | 5 `@Qualifier` annotations: `@IoDispatcher`, `@MainDispatcher`, `@DefaultDispatcher`, `@AuthenticatedClient`, `@UnauthenticatedClient` |
| 2 | `CoroutineModule.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/di/CoroutineModule.kt` | `@Module @InstallIn(SingletonComponent)` providing 3 dispatchers + app-scoped `CoroutineScope` with `SupervisorJob` |
| 3 | `StorageModule.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/di/StorageModule.kt` | `@Module @InstallIn(SingletonComponent)` providing `DataStore<Preferences>` and `XGDatabase` (Room) |
| 4 | `XGDatabase.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/data/local/XGDatabase.kt` | `@Database(entities = [PlaceholderEntity::class], version = 1)` Room database shell |
| 5 | `PlaceholderEntity.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/data/local/PlaceholderEntity.kt` | Minimal Room entity required by Room annotation processor (to be removed when first real entity is added) |

## Files Modified

| # | File | Absolute Path | Changes |
|---|------|---------------|---------|
| 1 | `NetworkModule.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/di/NetworkModule.kt` | Renamed `provideOkHttpClient()` to `provideAuthenticatedClient()` with `@AuthenticatedClient` qualifier. Added `provideUnauthenticatedClient()` with `@UnauthenticatedClient` qualifier (same timeout/cache config, no auth interceptors). Updated `provideRetrofit()` to accept `@AuthenticatedClient`-qualified client. Added imports for `Cache`, `File`, `TimeUnit`, `LoggingInterceptor`, `NetworkConfig`. |

## Key Design Decisions

1. **PlaceholderEntity**: Room 2.7.1 KSP processor requires at least one entity in the `entities` array. Created a minimal `PlaceholderEntity` with a single `Int` primary key. This is `internal` and should be removed when the first real entity (e.g., `CartItem` in M2-01) is added.

2. **Unauthenticated client config**: Built with `OkHttpClient.Builder()` directly (not via `OkHttpClientFactory`) because the factory always adds auth interceptors. Uses the same `NetworkConfig` timeouts and cache size, but with a separate cache directory (`http_cache_public`).

3. **fallbackToDestructiveMigration(dropAllTables = true)**: Used the non-deprecated overload (Room 2.7+). Development-only; must be replaced with proper migrations before release.

4. **NetworkMonitor not added to NetworkModule**: The existing `NetworkMonitor` class uses `@Inject constructor` with `@Singleton` scope, so Hilt resolves it automatically without an explicit `@Provides`. No modification needed.

5. **Dispatchers are not `@Singleton`**: Dispatcher providers in `CoroutineModule` are intentionally unscoped because `Dispatchers.IO/Main/Default` are singleton objects in the Kotlin Coroutines library. Only `CoroutineScope` is `@Singleton` to ensure a single app-scoped scope.

## Build Verification

- [x] `./gradlew assembleDebug` succeeds with no errors
- [x] No deprecation warnings in project code
- [x] `./gradlew testDebugUnitTest` -- all existing tests pass
- [x] Hilt component graph resolves without missing bindings

## Test Recommendations for Android Tester

### CoroutineModuleTest
- Verify `@IoDispatcher` provides `Dispatchers.IO`
- Verify `@MainDispatcher` provides `Dispatchers.Main`
- Verify `@DefaultDispatcher` provides `Dispatchers.Default`
- Verify `CoroutineScope` uses `SupervisorJob` (check `coroutineContext[Job]` is a `CompletableJob`)

### NetworkModuleTest
- Verify `provideJson()` config: `ignoreUnknownKeys = true`, `isLenient = true`, `explicitNulls = false`
- Verify `@AuthenticatedClient` OkHttpClient has auth interceptor
- Verify `@UnauthenticatedClient` OkHttpClient does NOT have auth interceptor
- Verify `provideRetrofit()` base URL matches `BuildConfig.API_BASE_URL`

### StorageModuleTest (requires Robolectric)
- Verify `DataStore<Preferences>` can be provided (use Robolectric `ApplicationProvider`)
- Verify `XGDatabase` can be built in-memory for test

---

**Completed**: 2026-02-21
**Agent**: android-dev
