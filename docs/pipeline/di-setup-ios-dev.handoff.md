# Handoff: di-setup -- iOS Dev

## Feature
**M0-05: DI Setup** -- Factory container registrations and feature DI pattern documentation for iOS.

## Status
COMPLETE -- Existing registrations verified, feature DI pattern documented, tests written.

## Summary

All iOS source files for DI infrastructure already existed from M0-03 (Network Layer). The iOS Dev task for M0-05 focused on verification, documentation, and test coverage.

### What Was Done

1. **Verified existing Container+Extensions.swift registrations** -- all three registrations (`tokenProvider`, `apiClient`, `networkMonitor`) are correct singletons with proper dependency wiring
2. **Added feature DI pattern documentation** as structured MARK comments in `Container+Extensions.swift` -- covers repository registration, use case registration, ViewModel injection (both `@Injected` and init-based patterns), scoping rules, and test replacement patterns
3. **Created ContainerTests.swift** -- verifies all container registrations resolve without crash, singleton behavior (same instance on multiple resolutions), test override mechanism, and container reset behavior
4. **Created NetworkMonitorTests.swift** -- verifies initialization, default `isConnected` state, Sendable conformance, and reference type semantics

### What Was NOT Changed

- `APIClient.swift` -- concrete final class from M0-03, no protocol wrapper needed
- `NetworkMonitor.swift` -- concrete `@Observable` class from M0-03, no protocol+impl split needed
- `TokenProvider.swift` -- protocol + `NoOpTokenProvider` placeholder from M0-03, replaced by M0-06
- No `authenticatedSession`/`unauthenticatedSession` registrations -- `APIClient` manages its own `URLSession` internally
- No `tokenStorage` registration -- deferred to M0-06 (Auth Infrastructure)

## Artifacts

| Artifact | Path |
|----------|------|
| Container Registrations (modified) | `ios/XiriGoEcommerce/Core/DI/Container+Extensions.swift` |
| Container Tests (new) | `ios/XiriGoEcommerceTests/Core/DI/ContainerTests.swift` |
| NetworkMonitor Tests (new) | `ios/XiriGoEcommerceTests/Core/Network/NetworkMonitorTests.swift` |
| This Handoff | `docs/pipeline/di-setup-ios-dev.handoff.md` |

## Container Registrations

| Registration | Type | Scope | Description |
|-------------|------|-------|-------------|
| `tokenProvider` | `any TokenProvider` | `.singleton` | No-op placeholder; replaced by M0-06 |
| `apiClient` | `APIClient` | `.singleton` | Network client with auth, retry, error mapping |
| `networkMonitor` | `NetworkMonitor` | `.singleton` | NWPathMonitor-based connectivity observer |

## Test Coverage

### ContainerTests.swift (8 tests)
- Resolution: `apiClient`, `tokenProvider`, `networkMonitor` all resolve without crash
- Singleton: all three return same instance on multiple resolutions
- Override: container registration can be replaced for tests
- Reset: `Container.shared.reset()` restores original registrations

### NetworkMonitorTests.swift (4 tests)
- Initialization does not crash
- `isConnected` defaults to `true`
- Conforms to `Sendable`
- Reference type semantics (class, not struct)

## Consistency with Android

| Concern | Android | iOS | Consistent? |
|---------|---------|-----|------------|
| Singleton infra | Hilt `@Singleton` | Factory `.singleton` | Yes |
| Token provider | `InMemoryTokenProvider` (no-op) | `NoOpTokenProvider` (no-op) | Yes |
| Network monitor | Concrete class with `@Inject` | Concrete `@Observable` class | Yes (platform conventions differ) |
| Feature DI pattern | `@Module @InstallIn(ViewModelComponent)` + `@Binds` | `Container` extension with transient scope | Yes (platform conventions differ) |

## For iOS Tester

- Run `ContainerTests.swift` and `NetworkMonitorTests.swift`
- Verify all 12 tests pass (8 container + 4 network monitor)
- Verify app launches in simulator without DI-related crashes
- Verify `Container.shared.reset()` in test `init()` prevents cross-test contamination

---

**Completed**: 2026-02-21
**Agent**: ios-dev
