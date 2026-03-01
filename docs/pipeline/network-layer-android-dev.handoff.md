# Network Layer -- Android Dev Handoff

## Status: COMPLETE

## Summary

Implemented the Android network layer (M0-03) providing HTTP client infrastructure for communicating with the Medusa v2 REST API.

## Files Created

### Production Code

Base: `android/app/src/main/java/com/xirigo/ecommerce/core/`

| File | Description |
|------|-------------|
| `domain/error/AppError.kt` | Sealed class with 5 error subtypes + `toUserMessageResId()` extension |
| `network/TokenProvider.kt` | Interface for token storage (placeholder impl in DI module) |
| `network/MedusaErrorDto.kt` | `@Serializable` DTO for Medusa error responses |
| `network/ApiErrorMapper.kt` | Maps `Throwable` to `AppError` (HttpException, IOException, SerializationException) |
| `network/AuthInterceptor.kt` | OkHttp Interceptor injecting Bearer token, skipping public endpoints |
| `network/TokenRefreshAuthenticator.kt` | OkHttp Authenticator handling 401 with mutex-protected token refresh |
| `network/RetryInterceptor.kt` | OkHttp Interceptor retrying 5xx (500/502/503/504) with exponential backoff + jitter |
| `network/LoggingInterceptor.kt` | Timber-based OkHttp logging (BODY in debug, NONE in release) |
| `network/NetworkConfig.kt` | Timeout constants (30s connect, 60s read/write) and cache size |
| `network/OkHttpClientFactory.kt` | Assembles OkHttp with interceptor chain, authenticator, cache, timeouts |
| `network/ApiClient.kt` | Creates Retrofit with base URL, JSON converter, OkHttp client |
| `network/PaginationMeta.kt` | Pagination convenience data class with `hasMore` computed property |
| `network/NetworkMonitor.kt` | ConnectivityManager-based `StateFlow<Boolean>` for network state |
| `di/NetworkModule.kt` | Hilt module providing Json, OkHttpClient, Retrofit, NetworkMonitor, TokenProvider |

### Test Code

Base: `android/app/src/test/java/com/xirigo/ecommerce/core/`

| File | Tests |
|------|-------|
| `network/AuthInterceptorTest.kt` | 6 tests: token injection, null token, public endpoint skipping, no overwrite, accept header |
| `network/TokenRefreshAuthenticatorTest.kt` | 3 tests: successful refresh + retry, failed refresh + clear, already refreshed token |
| `network/RetryInterceptorTest.kt` | 12 tests: retry on 500/502/503/504, no retry on 4xx/200, max retries, delay calculations |
| `network/ApiErrorMapperTest.kt` | 16 tests: all HTTP status mappings, IOException, SerializationException, malformed body |
| `domain/error/AppErrorTest.kt` | 12 tests: string resource mapping, default messages, code/message preservation |

### Build Config Changes

| File | Change |
|------|--------|
| `android/gradle/libs.versions.toml` | Added `okhttp-mockwebserver` library for test dependency |
| `android/app/build.gradle.kts` | Added `testImplementation(libs.okhttp.mockwebserver)` |

## Architecture Decisions

- **Interceptor chain order**: Auth (application) -> Retry (application) -> Logging (network)
- **TokenRefreshAuthenticator**: Uses `kotlinx.coroutines.sync.Mutex` for concurrent refresh serialization
- **runBlocking in interceptors**: Required because OkHttp interceptors are synchronous; this is the standard pattern
- **No-op TokenProvider**: Placeholder returning null; replaced by real implementation in M0-06 (Auth Infra)
- **JSON config**: `ignoreUnknownKeys`, `coerceInputValues`, `isLenient`, `SnakeCase` naming strategy
- **PaginationMeta.hasMore**: Computed property using `offset + limit < count`

## Verification

- `./gradlew compileDebugKotlin` -- BUILD SUCCESSFUL
- `./gradlew testDebugUnitTest --tests "com.xirigo.ecommerce.core.*"` -- 49 tests PASSED
- No lint warnings in new code

## Dependencies

- **Depends on**: M0-01 (App Scaffold) -- project structure, BuildConfig, string resources
- **Depended on by**: M0-06 (Auth Infra), all feature modules (M1-01 through M4-05)

## Notes for Tester

- FakeTokenProvider is available in test source set for reuse
- MockWebServer pattern established for HTTP-level testing
- All interceptors can be tested independently via OkHttpClient.Builder
