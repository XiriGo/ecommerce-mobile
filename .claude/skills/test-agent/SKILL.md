---
name: test-agent
description: "Write comprehensive multi-layer tests for a mobile feature (Android + iOS)"
argument-hint: "[feature-name] [platform: android|ios|both]"
---

# Mobile Test Agent — Multi-Layer Testing

You write comprehensive, production-grade tests for mobile features.
Every feature must pass multiple test layers before moving forward.

## Arguments
Parse: `$ARGUMENTS` — feature name and optional platform filter.

## Pre-flight
1. Read `CLAUDE.md` — project overview and key rules
2. Read `docs/standards/testing.md` — test rules, coverage, patterns
3. Read `docs/TEST.md` — full iOS test architecture reference (13 layers)
4. Read platform-specific standards:
   - Android: `docs/standards/android.md`
   - iOS: `docs/standards/ios.md`
5. Read developer handoffs for file manifests
6. Read ALL source files for the feature being tested
7. Read existing test infrastructure:
   - iOS: `ios/XiriGoEcommerceTests/Infrastructure/` (helpers, base classes)
   - iOS: `ios/XiriGoEcommerceTests/Snapshot/SnapshotTestCase.swift`

## iOS Test Layers (Execute in Order)

### Layer 1: Unit Tests (MANDATORY)

**ViewModel Tests:**
- Test ALL states: `.loading`, `.success(data)`, `.error(message)`, `.empty`
- Test ALL user actions/events
- Test state transitions: loading → success, loading → error
- Use `@Suite` + `@Test` + `@MainActor`
- Verify with `#expect()`

**UseCase Tests:**
- Happy path + error path + edge cases
- Verify repository is called with correct parameters (use call counts)

**Repository Fake Tests:**
- Verify fake implementation matches protocol contract
- Test error injection (`errorToThrow`)

**Pattern:**
```swift
@Suite("FeatureViewModel Tests")
@MainActor
struct FeatureViewModelTests {
    @Test("initial state is loading")
    func initialState_isLoading() {
        let (vm, _) = makeViewModel()
        #expect(vm.uiState == .loading)
    }

    @Test("loadData success populates state")
    func loadData_success_populatesState() async {
        let (vm, repo) = makeViewModel()
        repo.itemsToReturn = [.mock]
        await vm.loadData()
        guard case .success(let data) = vm.uiState else {
            Issue.record("Expected .success"); return
        }
        #expect(data.items.count == 1)
        #expect(repo.getItemsCallCount == 1)
    }

    @Test("loadData error shows error state")
    func loadData_error_showsErrorState() async {
        let (vm, repo) = makeViewModel()
        repo.errorToThrow = .networkError(message: "timeout")
        await vm.loadData()
        guard case .error = vm.uiState else {
            Issue.record("Expected .error"); return
        }
    }
}
```

### Layer 2: Snapshot Tests (MANDATORY for screens/components)

Use `SnapshotTestCase` base class from `XiriGoEcommerceTests/Snapshot/`.

**Required variants per screen:**
1. Default state
2. Loading state
3. Success state (with data)
4. Error state
5. Empty state
6. Dark mode
7. Large accessibility font

**Pattern:**
```swift
final class FeatureScreenSnapshotTests: SnapshotTestCase {
    func test_featureScreen_defaultState() {
        let view = FeatureScreen(viewModel: makeLoadedVM())
        assertScreenSnapshot(view, named: "default")
    }

    func test_featureScreen_darkMode() {
        let view = FeatureScreen(viewModel: makeLoadedVM())
        assertScreenSnapshot(view, named: "dark", colorScheme: .dark)
    }

    func test_featureScreen_largeFont() {
        let view = FeatureScreen(viewModel: makeLoadedVM())
        assertAccessibilityFontSnapshot(view)
    }
}
```

### Layer 3: Integration Tests (API features)

Use `MockURLProtocol` for network stubbing.

**Test the full chain:** API call → JSON decode → DTO mapping → Domain model

**Pattern:**
```swift
@Suite("Feature API Integration Tests")
struct FeatureAPIIntegrationTests {
    init() { MockURLProtocol.reset() }

    @Test("fetchItems decodes response correctly")
    func fetchItems_decodesCorrectly() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
            {"products": [{"id": "1", "title": "Test"}]}
        """)
        let client = APIClient.makeTestClient()
        let endpoint = ProductEndpoint.list(offset: 0, limit: 10)
        let response: ProductListResponse = try await client.request(endpoint)
        #expect(response.products.count == 1)
    }
}
```

### Layer 4: Performance Tests (ViewModels + critical paths)

Use `PerformanceTestCase` from `XiriGoEcommerceTests/Infrastructure/`.

**MANDATORY for every ViewModel:**
```swift
final class FeaturePerformanceTests: PerformanceTestCase {
    func test_viewModel_noMemoryLeak() {
        var vm: FeatureViewModel? = FeatureViewModel(...)
        trackForMemoryLeaks(vm!)
        vm = nil
    }
}
```

### Layer 5-9: Auto Tests (Already Exist)

These test suites run automatically for ALL features:
- **ArchitectureTests** — layer boundary enforcement
- **SecurityTests** — HTTPS, secrets, sensitive logging
- **AccessibilityTests** — modifiers, touch targets, colors
- **LocalizableTests** — string translations
- **ConfigTests** — API URL, bundle version

You do NOT need to add to these unless the feature requires specific checks.

## Edge Cases Checklist (Verify for Every Feature)

- [ ] nil/optional inputs
- [ ] Empty string/array/collection
- [ ] Negative numbers, zero, Int.max
- [ ] Network timeout / error
- [ ] Concurrent access (race conditions)
- [ ] Memory leaks (weak references)
- [ ] Rapid user actions (double tap prevention)
- [ ] Background/foreground transitions
- [ ] Large data sets (100+ items)

## Android Tests

- **ViewModel**: MockK for mocking, Turbine for Flow testing
- **UseCase**: Mock repository, test business logic
- **Repository**: MockWebServer for API testing
- **UI**: composeTestRule for Compose testing
- Location: `android/app/src/test/` and `android/app/src/androidTest/`

## Rules
- Each test independent (no shared mutable state)
- Coverage >= 80% lines, >= 70% branches
- Test happy path AND error paths
- Never mock: DI containers, platform frameworks
- Only mock/fake: Network layer, time, local storage
- Prefer fakes over mocks (Google recommended pattern)

## Handoff
Create `docs/pipeline/{feature}-test.handoff.md` with test layer results.
Commit: `test({scope}): add {feature} tests [agent:test] [platform:{platform}]`
