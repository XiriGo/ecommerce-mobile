# Handoff: di-setup -- Reviewer

## Feature
**M0-05: DI Setup** -- Hilt modules (Android) + Factory container registrations (iOS) for network, storage, coroutine, and common infrastructure dependencies.

## Status
**APPROVED**

All five review dimensions pass. No critical or warning issues remain.

---

## Review Summary

### 1. Spec Compliance

**Verdict: PASS**

The architect handoff (`docs/pipeline/di-setup-architect.handoff.md`) performed a gap analysis between the original spec and the actual M0-03 codebase, producing six justified spec deviations. All deviations were reviewed and accepted as correct.

#### Android -- Spec Compliance

| Spec Requirement | Status | Evidence |
|-----------------|--------|----------|
| `Qualifiers.kt` with 5 `@Qualifier` annotations | DONE | `core/di/Qualifiers.kt` -- `@IoDispatcher`, `@MainDispatcher`, `@DefaultDispatcher`, `@AuthenticatedClient`, `@UnauthenticatedClient` |
| `CoroutineModule` with 3 dispatchers + app-scoped `CoroutineScope` | DONE | `core/di/CoroutineModule.kt` -- `@Module @InstallIn(SingletonComponent::class) object`, 4 `@Provides` methods |
| `NetworkModule` with `@AuthenticatedClient` / `@UnauthenticatedClient` split | DONE | `core/di/NetworkModule.kt` -- `provideAuthenticatedClient()` and `provideUnauthenticatedClient()` with correct qualifiers |
| `Retrofit` uses `@AuthenticatedClient` | DONE | `provideRetrofit(@AuthenticatedClient okHttpClient: OkHttpClient, ...)` |
| `StorageModule` with `DataStore<Preferences>` + `XGDatabase` | DONE | `core/di/StorageModule.kt` -- both provisions present with `@Singleton` scope |
| `XGDatabase` Room shell | DONE | `core/data/local/XGDatabase.kt` -- `@Database(entities = [PlaceholderEntity::class], version = 1, exportSchema = false)` |
| `NetworkMonitor` with `StateFlow<Boolean>` | DONE | `core/network/NetworkMonitor.kt` -- concrete class with `@Inject constructor`, `@Singleton`, `ConnectivityManager` + `NetworkCallback` |

#### iOS -- Spec Compliance

| Spec Requirement | Status | Evidence |
|-----------------|--------|----------|
| `Container+Extensions.swift` with `apiClient` (.singleton) | DONE | Lines 18-26 |
| `Container+Extensions.swift` with `tokenProvider` (.singleton) | DONE | Lines 11-14 |
| `Container+Extensions.swift` with `networkMonitor` (.singleton) | DONE | Lines 32-35 |
| `NetworkMonitor` concrete class | DONE | `Core/Network/NetworkMonitor.swift` -- `@Observable final class: @unchecked Sendable`, `NWPathMonitor` |
| Feature DI pattern documented | DONE | `Container+Extensions.swift` lines 38-96 -- inline MARK comments with code examples |

#### Accepted Spec Deviations (Architect-Approved)

| # | Deviation | Rationale |
|---|-----------|-----------|
| 1 | `NetworkMonitor` is concrete class, not interface+impl | Single implementation; `@Inject constructor` / `@Observable` pattern is idiomatic per platform |
| 2 | iOS `APIClient` is concrete class, not protocol | M0-03 built full concrete class; protocol is unnecessary since test doubles use init-based injection |
| 3 | No `authenticatedSession`/`unauthenticatedSession` on iOS | `APIClient` manages its own `URLSession` internally |
| 4 | No `tokenStorage` registration on iOS | Deferred to M0-06 (Auth Infrastructure) |
| 5 | `encodeDefaults = false` and `isLenient = true` (vs spec's `encodeDefaults = true`, `isLenient = false`) | M0-03 chose these values for the Medusa v2 API; architect handoff accepted existing config |
| 6 | `coerceInputValues = true` and `namingStrategy = SnakeCase` added (not in original spec) | M0-03 additions for Medusa API compatibility; accepted as-is |

### 2. Code Quality

**Verdict: PASS**

#### Android

| Rule | Status | Notes |
|------|--------|-------|
| No `!!` in production code | PASS | Verified via grep; zero occurrences in `core/di/` and `core/data/local/` |
| No `Any` type in domain/presentation | PASS | Verified via grep; zero occurrences |
| Explicit types on all `@Provides` | PASS | All return types explicit: `CoroutineDispatcher`, `CoroutineScope`, `Json`, `OkHttpClient`, `Retrofit`, `TokenProvider`, etc. |
| Correct Hilt annotations | PASS | `@Module`, `@InstallIn(SingletonComponent::class)`, `@Provides`, `@Singleton` on all singletons |
| `object` for `@Provides`-only modules | PASS | `CoroutineModule`, `NetworkModule`, `StorageModule` are all `object` |
| Immutable models | PASS | `PlaceholderEntity` is a `data class` with `val` properties |
| `internal` visibility for `PlaceholderEntity` | PASS | `internal data class PlaceholderEntity` |
| `InMemoryTokenProvider` is `private` | PASS | `private class InMemoryTokenProvider` |
| No hardcoded URLs/secrets | PASS | API base URL via `BuildConfig.API_BASE_URL` |
| File length <= 400 lines | PASS | Longest DI file is `NetworkModule.kt` at 107 lines |
| Cyclomatic complexity <= 10 | PASS | All functions are simple provider functions |

#### iOS

| Rule | Status | Notes |
|------|--------|-------|
| No force unwraps (`!`) | PASS | Verified via grep; zero occurrences in `Core/DI/` |
| `Sendable` conformance | PASS | `NetworkMonitor: @unchecked Sendable`, `APIClient: Sendable`, `NoOpTokenProvider: @unchecked Sendable` |
| `@MainActor` on mutable state | PASS | `@MainActor private(set) var isConnected: Bool` on `NetworkMonitor` |
| `@Observable` on monitor | PASS | `@Observable final class NetworkMonitor` |
| `weak self` in closures | PASS | `monitor.pathUpdateHandler` uses `[weak self]` in both closure and Task |
| `deinit` calls `monitor.cancel()` | PASS | Prevents NWPathMonitor leak |
| All `Factory` properties are `var` | PASS | `var tokenProvider`, `var apiClient`, `var networkMonitor` |
| `.singleton` for infrastructure only | PASS | All three registrations are `.singleton`; feature DI pattern docs specify transient default |
| No hardcoded URLs/secrets | PASS | API base URL via `Config.apiBaseURL` |
| File length <= 400 lines | PASS | `Container+Extensions.swift` is 96 lines; `NetworkMonitor.swift` is 37 lines |

#### Test Code Quality Notes (Non-Blocking)

- Android test code contains `!!` usage in `QualifiersTest.kt` (5 occurrences), `CoroutineModuleTest.kt` (1), and `StorageModuleTest.kt` (2). These are in test code only and are guarded by preceding `assertThat(x).isNotNull()` assertions. Acceptable in test code per CLAUDE.md rules (which target production code).
- iOS test code has zero force unwraps.

### 3. Cross-Platform Consistency

**Verdict: PASS**

| Concern | Android | iOS | Consistent? |
|---------|---------|-----|-------------|
| Singleton infrastructure | Hilt `@Singleton` + `@InstallIn(SingletonComponent)` | Factory `.singleton` | Yes |
| No-op token provider | `InMemoryTokenProvider` (private in NetworkModule) | `NoOpTokenProvider` (public, in TokenProvider.swift) | Yes -- naming differs but semantics are identical (all methods return nil/null, no-op) |
| Network monitor | Concrete `@Singleton` class with `StateFlow<Boolean>` | Concrete `@Observable` class with `@MainActor var isConnected: Bool` | Yes -- platform-idiomatic reactive patterns |
| HTTP client auth split | `@AuthenticatedClient` / `@UnauthenticatedClient` qualifiers | `APIClient` manages auth internally (endpoint-level `requiresAuth` flag) | Yes -- different mechanism, same result |
| Feature DI pattern | `@Binds` in `ViewModelComponent` + `@Inject constructor` | `Container` extension with transient scope + init-based injection | Yes -- documented for both platforms |
| Test replacement pattern | Manual construction with fakes; `@TestInstallIn` for integration | Init-based injection with fakes; `Container.shared.reset()` + `.register {}` for override | Yes |
| Database shell | Room `XGDatabase` with `PlaceholderEntity` | N/A (SwiftData, deferred) | N/A -- Android-only concern |
| DataStore / preferences | `DataStore<Preferences>` via `StorageModule` | N/A (UserDefaults, deferred) | N/A -- Android-only concern |
| CoroutineScope | App-scoped `CoroutineScope` with `SupervisorJob` | N/A (Swift `Task` / `actor`) | N/A -- Android-only concern |

### 4. Test Coverage

**Verdict: PASS**

| Platform | Test Files | Test Count | Coverage Estimate | Threshold |
|----------|-----------|------------|-------------------|-----------|
| Android | 4 files | 55 tests | ~90% lines, ~80% branches | >= 80% lines, >= 70% branches |
| iOS | 2 files | 21 tests | ~85% lines, ~75% branches | >= 80% lines, >= 70% branches |
| **Total** | **6 files** | **76 tests** | **MEETS THRESHOLDS** | |

#### Android Test Details

| Test File | Tests | What It Covers |
|-----------|-------|---------------|
| `QualifiersTest.kt` | 11 | All 5 annotations verified for `@Qualifier` + `BINARY` retention; all are annotation classes |
| `CoroutineModuleTest.kt` | 10 | 3 dispatchers correct type, `CoroutineScope` with `SupervisorJob` + provided dispatcher, dispatcher distinctness |
| `NetworkModuleTest.kt` | 25 | Json config flags (6 tests), `InMemoryTokenProvider` behavior (4 tests), `AuthInterceptor` + `TokenRefreshAuthenticator` creation (4 tests), client interceptor lists (2 tests), timeouts match `NetworkConfig` (3 tests), Retrofit creation + base URL (4 tests), converter factory presence (1 test), authenticated client usage (1 test) |
| `StorageModuleTest.kt` | 9 | `XGDatabase` creation/open/close/fallback (5 tests), `DataStore` creation/emit/read/write (4 tests, Robolectric) |

#### iOS Test Details

| Test File | Tests | What It Covers |
|-----------|-------|---------------|
| `ContainerTests.swift` | 14 | Resolution (3), singleton behavior (3), test override (1), reset (1), override+reset cycle (1), singleton cache clearing (1), shared identity (1), independent resolution (1), override specificity (2) |
| `NetworkMonitorTests.swift` | 7 | Init safety (1), default `isConnected` (1), `Sendable` conformance (1), reference type (1), independent instances (1), deinit safety (1), consistent reads (1) |

#### Test Approach Validation

- **Fakes over mocks**: Android uses `InMemoryTokenProvider` (no-op); iOS uses `FakeTokenProvider` (from `TokenProviderTests.swift`). No mock frameworks used.
- **No DI container mocked**: Tests call module methods directly (Android) or use container overrides (iOS).
- **Test isolation**: iOS uses `@Suite(.serialized)` + `Container.shared.reset()` in `init()`. Android uses `@Before`/`@After` lifecycle.
- **Test naming**: Android follows `should <expected> when <condition>` backtick style. iOS follows `test_<method>_<condition>_<expected>` underscore style. Both are acceptable per `docs/standards/testing.md`.

### 5. Security

**Verdict: PASS**

| Security Concern | Status | Evidence |
|-----------------|--------|----------|
| No secrets in code | PASS | API base URL via `BuildConfig`/`Config`; no hardcoded keys, tokens, or passwords |
| No sensitive data in logs | PASS | `LoggingInterceptor.create()` used (from M0-03); no custom logging in DI modules |
| Token provider returns null | PASS | `InMemoryTokenProvider` and `NoOpTokenProvider` are no-op placeholders that never store real tokens |
| Encrypted storage pattern prepared | PASS | Spec defers `EncryptedDataStore` / Keychain to M0-06; `StorageModule` provides unencrypted `DataStore<Preferences>` for general (non-sensitive) preferences |
| `PlaceholderEntity` contains no sensitive data | PASS | Single `Int` primary key, `internal` visibility |
| Auth interceptor safe with null token | PASS | `AuthInterceptor` checks token nullability; `InMemoryTokenProvider.getAccessToken()` returns `null` so no auth header is added |

---

## Issues Found

### Critical: None

### Warning: None

### Info (Non-Blocking)

| # | Severity | Platform | Location | Description |
|---|----------|----------|----------|-------------|
| 1 | Info | Android | `QualifiersTest.kt`, `CoroutineModuleTest.kt`, `StorageModuleTest.kt` | Test code uses `!!` (force unwrap). Acceptable in test code; each occurrence is preceded by a non-null assertion. |
| 2 | Info | Android | `NetworkModule.kt:35-39` | `Json` configuration differs from spec: `encodeDefaults = false` (spec says `true`), `isLenient = true` (spec says `false`), added `coerceInputValues = true` and `namingStrategy = SnakeCase`. These are M0-03 decisions accepted by the architect. |
| 3 | Info | Android | `XGDatabase.kt:6` | Uses `PlaceholderEntity` instead of empty entity list. Necessary workaround for Room KSP; well-documented for removal when first real entity is added. |
| 4 | Info | Both | NetworkMonitor | Both platforms use concrete classes instead of interface+impl. The architect explicitly approved this (spec discrepancy #2). |
| 5 | Info | Android | `NetworkModuleTest.kt:155-171` | Client interceptor tests construct `OkHttpClient` manually rather than calling `provideAuthenticatedClient()` / `provideUnauthenticatedClient()` directly (which require Android Context). Tests verify the concept correctly but do not exercise the exact provider methods. Acceptable given that `StorageModuleTest` uses Robolectric for Context-dependent tests. |

---

## Artifacts Reviewed

### Source Files

| Platform | File | Path |
|----------|------|------|
| Android | `Qualifiers.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/di/Qualifiers.kt` |
| Android | `CoroutineModule.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/di/CoroutineModule.kt` |
| Android | `NetworkModule.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/di/NetworkModule.kt` |
| Android | `StorageModule.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/di/StorageModule.kt` |
| Android | `XGDatabase.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/data/local/XGDatabase.kt` |
| Android | `PlaceholderEntity.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/data/local/PlaceholderEntity.kt` |
| Android | `NetworkMonitor.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/network/NetworkMonitor.kt` |
| Android | `TokenProvider.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/network/TokenProvider.kt` |
| Android | `OkHttpClientFactory.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/network/OkHttpClientFactory.kt` |
| Android | `NetworkConfig.kt` | `android/app/src/main/java/com/xirigo/ecommerce/core/network/NetworkConfig.kt` |
| iOS | `Container+Extensions.swift` | `ios/XiriGoEcommerce/Core/DI/Container+Extensions.swift` |
| iOS | `NetworkMonitor.swift` | `ios/XiriGoEcommerce/Core/Network/NetworkMonitor.swift` |
| iOS | `APIClient.swift` | `ios/XiriGoEcommerce/Core/Network/APIClient.swift` |
| iOS | `TokenProvider.swift` | `ios/XiriGoEcommerce/Core/Network/TokenProvider.swift` |

### Test Files

| Platform | File | Path |
|----------|------|------|
| Android | `QualifiersTest.kt` | `android/app/src/test/java/com/xirigo/ecommerce/core/di/QualifiersTest.kt` |
| Android | `CoroutineModuleTest.kt` | `android/app/src/test/java/com/xirigo/ecommerce/core/di/CoroutineModuleTest.kt` |
| Android | `NetworkModuleTest.kt` | `android/app/src/test/java/com/xirigo/ecommerce/core/di/NetworkModuleTest.kt` |
| Android | `StorageModuleTest.kt` | `android/app/src/test/java/com/xirigo/ecommerce/core/di/StorageModuleTest.kt` |
| iOS | `ContainerTests.swift` | `ios/XiriGoEcommerceTests/Core/DI/ContainerTests.swift` |
| iOS | `NetworkMonitorTests.swift` | `ios/XiriGoEcommerceTests/Core/Network/NetworkMonitorTests.swift` |

### Handoff Files

| Agent | Path |
|-------|------|
| Architect | `docs/pipeline/di-setup-architect.handoff.md` |
| Android Dev | `docs/pipeline/di-setup-android-dev.handoff.md` |
| iOS Dev | `docs/pipeline/di-setup-ios-dev.handoff.md` |
| Android Tester | `docs/pipeline/di-setup-android-test.handoff.md` |
| iOS Tester | `docs/pipeline/di-setup-ios-test.handoff.md` |
| Doc Writer | `docs/pipeline/di-setup-doc.handoff.md` |

### Documentation

| File | Path |
|------|------|
| Feature README | `docs/features/di-setup.md` |
| CHANGELOG | `CHANGELOG.md` |
| Feature Spec | `shared/feature-specs/di-setup.md` |

---

## Verdict

**APPROVED** -- The DI Setup feature (M0-05) meets all review criteria across both platforms. The implementation correctly establishes the DI module structure, provides all required singletons, documents the canonical feature DI pattern for M1+ features, and achieves adequate test coverage. All spec deviations are architect-approved and well-justified. No critical or warning issues were found.

---

**Reviewed**: 2026-02-21
**Agent**: reviewer
