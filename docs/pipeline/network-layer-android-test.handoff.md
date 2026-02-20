# Network Layer — Android Test Handoff

## Status: COMPLETE

## Summary

Added additional unit tests for the Android network layer (M0-03) to increase coverage.
The existing 49 tests written by the Android Dev were extended with 84 additional tests
across 8 new test files, targeting previously uncovered classes, edge cases, and branches.

---

## Test Files Added

Base: `android/app/src/test/java/com/molt/marketplace/core/`

| File | New Tests | Areas Covered |
|------|-----------|---------------|
| `network/NetworkConfigTest.kt` | 6 | Constant values: 30s connect, 60s read/write, 10 MB cache |
| `network/PaginationMetaTest.kt` | 11 | `hasMore` computed property: boundary, zero count, mid-page, overflow |
| `network/ApiClientTest.kt` | 4 | Retrofit creation, base URL, OkHttpClient, converter factory |
| `network/AuthInterceptorEdgeCasesTest.kt` | 9 | Sub-paths, cart/orders endpoints, null token on protected route, both public paths, Accept header on public paths, path-contains-but-not-ending-with |
| `network/RetryInterceptorEdgeCasesTest.kt` | 16 | All companion constants, non-retryable codes (403/422/201/204/301/429), jitter always non-negative, delay cap for large attempt, stops mid-sequence when non-retryable |
| `network/TokenRefreshAuthenticatorEdgeCasesTest.kt` | 7 | Retry-limit cap, null token path, token rebuild header, clear on null refresh, concurrent mutex serialisation, already-refreshed-token short-circuit |
| `network/ApiErrorMapperEdgeCasesTest.kt` | 17 | 502/504/599, 5xx default message, 422 default message, unknown 409/408, ConnectException, null message IOException, empty/partial JSON body, idempotency for all 4 AppError subtypes, 429 default message, 403 with parsed body |
| `domain/error/AppErrorEdgeCasesTest.kt` | 14 | Custom messages on all variants, `toUserMessageResId` for all subtypes, data-class equality/copy, throw-and-catch as Exception/AppError |

**Total additional tests: 84**
**Grand total (existing 49 + new 84): 133 tests, 0 failures**

---

## Test Coverage Focus

| Area | What Was Missing | What Was Added |
|------|-----------------|----------------|
| `NetworkConfig` | No tests at all | All 4 constant value assertions + relational checks |
| `PaginationMeta` | No tests at all | 11 boundary tests for `hasMore` computed property |
| `ApiClient` | No tests at all | 4 Retrofit creation/configuration tests |
| `AuthInterceptor` | Missing edge paths | 9 tests: all public endpoint paths, non-public sub-paths, pre-set header preserved, Accept on public endpoint |
| `RetryInterceptor` | Missing non-retryable codes, constant verification | 16 tests: 403/422/201/204/301/429, all constants, jitter non-negative invariant, cap for large attempt |
| `TokenRefreshAuthenticator` | Missing retry-limit, concurrent scenario | 7 tests: MAX_RETRY_COUNT cap, null token, concurrent mutex, already-refreshed short-circuit |
| `ApiErrorMapper` | Missing 502/504/599, ConnectException, idempotency, edge bodies | 17 tests covering remaining branches |
| `AppError` | Missing custom messages, equality, throw/catch | 14 tests across all sealed subclasses |

---

## Verification

```
./gradlew :app:testDebugUnitTest \
  --tests "com.molt.marketplace.core.network.*" \
  --tests "com.molt.marketplace.core.domain.error.*"
```

Result: **BUILD SUCCESSFUL** — 133 tests, 0 failures, 0 errors

---

## Testing Patterns Used

- **FakeTokenProvider**: Reused across all HTTP interceptor test classes (defined in `AuthInterceptorTest.kt`)
- **MockWebServer**: OkHttp `MockWebServer` for all HTTP-level interceptor tests
- **Direct construction**: `RetryInterceptor`, `PaginationMeta`, `NetworkConfig`, `ApiClient` tested directly without mocking
- **Truth assertions**: All assertions use `com.google.common.truth.Truth.assertThat`
- **Test naming**: `fun \`action should result when condition\`` (backtick format per project convention)
- **Test independence**: Each test method creates its own instances; no shared mutable state between tests

---

## Files NOT Changed

| File | Reason |
|------|--------|
| `network/NetworkMonitor.kt` | Requires `ConnectivityManager` (Android framework); not testable in JVM unit tests without Robolectric |
| `network/OkHttpClientFactory.kt` | Requires `android.content.Context` for cache directory; integration-level only |
| `network/LoggingInterceptor.kt` | Wraps `BuildConfig.DEBUG` and Timber; logging output not an observable contract |

---

## Dependencies

- **Reads**: `network-layer-android-dev.handoff.md`
- **Depended on by**: `network-layer-doc.handoff.md`, `network-layer-review.handoff.md`

---

## Commit

```
test(network): add network layer tests [agent:android-test] [platform:android]
```
