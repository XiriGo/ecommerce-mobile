# Testing Standards

Comprehensive testing standards for the XiriGo Ecommerce mobile app.
Reference: `docs/TEST.md` for full iOS test architecture (13 layers).

---

## Coverage Thresholds (ENFORCED)

| Module Type | Lines | Functions | Branches |
|-------------|-------|-----------|----------|
| ViewModel / Business Logic | >= 80% | >= 80% | >= 70% |
| UseCase | >= 80% | >= 80% | >= 70% |
| Utility / Helper | >= 90% | >= 90% | >= 85% |
| Network Layer | >= 70% | >= 70% | >= 60% |
| UI Components | >= 50% | >= 50% | >= 40% |

## Test Layers

Every feature MUST have tests across these layers. Auto layers run for all features automatically.

| # | Layer | Type | iOS Location | Frequency |
|---|-------|------|-------------|-----------|
| 1 | Unit (ViewModel) | Manual | `XiriGoEcommerceTests/**/ViewModel/*Tests.swift` | Every feature |
| 2 | Unit (UseCase) | Manual | `XiriGoEcommerceTests/**/UseCase/*Tests.swift` | Every feature |
| 3 | Unit (Repository) | Manual | `XiriGoEcommerceTests/**/Repository/*Tests.swift` | Every feature |
| 4 | Snapshot | Manual | `XiriGoEcommerceTests/Snapshot/*Tests.swift` | Every screen |
| 5 | Integration (API) | Manual | `XiriGoEcommerceTests/Integration/*Tests.swift` | API features |
| 6 | Performance | Manual | `XiriGoEcommerceTests/Performance/*Tests.swift` | Every ViewModel |
| 7 | Architecture | Auto | `XiriGoEcommerceTests/ArchitectureTests.swift` | All features |
| 8 | Security | Auto | `XiriGoEcommerceTests/Security/SecurityTests.swift` | All features |
| 9 | Accessibility | Auto | `XiriGoEcommerceTests/Accessibility/AccessibilityTests.swift` | All features |
| 10 | Localization | Auto | `XiriGoEcommerceTests/Resources/LocalizableTests.swift` | All features |
| 11 | Configuration | Auto | `XiriGoEcommerceTests/ConfigTests.swift` | All features |
| 12 | UI / E2E | Manual | `XiriGoEcommerceUITests/` | Critical flows |
| 13 | Contract | Future | — | API-dependent features |

### Android Test Types

| Type | Location | Pattern |
|------|----------|---------|
| Unit (ViewModel) | `app/src/test/**/viewmodel/*Test.kt` | JUnit 4 + MockK + Turbine |
| Unit (UseCase) | `app/src/test/**/usecase/*Test.kt` | JUnit 4 + MockK |
| Unit (Repository) | `app/src/test/**/repository/*Test.kt` | JUnit 4 + MockWebServer |
| UI | `app/src/androidTest/**/*Test.kt` | Compose Test Rule |

---

## Test Rules

### General (Both Platforms)

- **Prefer fakes over mocks** (Google strongly recommended). Create `Fake{Name}Repository` classes that implement the interface with in-memory data. Use mocks only when fakes are impractical.
- **Never mock**: DI container, navigation, platform frameworks
- **Only mock/fake**: Network layer, time, local storage
- Each test is independent (no shared mutable state)
- Test happy path AND error paths AND edge cases
- **Test naming**: `test_<method>_<condition>_<expected>`

### iOS-Specific

- **Swift Testing** framework with `@Test` macro for unit tests
- **XCTest** only for performance measurement (`measure()`) and snapshot tests
- `@Suite` struct with `@MainActor` for ViewModel tests
- `#expect()` for assertions (not `XCTAssert`)
- `ViewInspector` for SwiftUI component testing
- `SnapshotTestCase` base class for visual regression tests
- `PerformanceTestCase` base class for performance + memory leak tests

### Android-Specific

- **Turbine** for Flow testing
- **composeTestRule** for Compose UI testing
- Assert on `uiState.value` directly when possible
- **MockK** for mocking dependencies

---

## iOS Test Infrastructure

### Helpers (in `XiriGoEcommerceTests/Infrastructure/`)

| File | Purpose |
|------|---------|
| `TestHelpers.swift` | `MemoryLeakTracker`, `waitForCondition()`, `SourceFileScanner` |
| `SecurityTestHelpers.swift` | Secret scanning, HTTPS audit, sensitive logging detection |
| `PerformanceTestHelpers.swift` | `PerformanceTestCase` base class, `MemorySnapshot` |

### Base Classes (in `XiriGoEcommerceTests/Snapshot/`)

| File | Purpose |
|------|---------|
| `SnapshotTestCase.swift` | `assertScreenSnapshot()`, `assertComponentSnapshot()`, `assertLightAndDarkSnapshot()` |

### Network Testing (in `XiriGoEcommerceTests/Core/Network/`)

| File | Purpose |
|------|---------|
| `MockURLProtocol.swift` | HTTP request interception, response stubbing |

---

## iOS: Fake Repository Pattern (TEMPLATE)

```swift
// XiriGoEcommerceTests/Feature/{Name}/Fakes/Fake{Name}Repository.swift
final class FakeProductRepository: ProductRepository, @unchecked Sendable {
    // Configurable return values
    var products: [Product] = []
    var errorToThrow: AppError?

    // Call tracking
    var getProductsCallCount = 0
    var capturedOffsets: [Int] = []

    func getProducts(offset: Int, limit: Int) async throws -> [Product] {
        getProductsCallCount += 1
        capturedOffsets.append(offset)
        if let error = errorToThrow { throw error }
        return Array(products.dropFirst(offset).prefix(limit))
    }

    func getProductById(_ id: String) async throws -> Product {
        if let error = errorToThrow { throw error }
        guard let product = products.first(where: { $0.id == id }) else {
            throw AppError.notFound()
        }
        return product
    }
}
```

## iOS: ViewModel Test Pattern (TEMPLATE)

```swift
@Suite("ProductListViewModel Tests")
@MainActor
struct ProductListViewModelTests {

    // Factory helper
    private static func makeViewModel() -> (ProductListViewModel, FakeProductRepository) {
        let repo = FakeProductRepository()
        let vm = ProductListViewModel(getProductsUseCase: GetProductsUseCase(repository: repo))
        return (vm, repo)
    }

    @Test("initial state is loading")
    func initialState_isLoading() {
        let (vm, _) = Self.makeViewModel()
        #expect(vm.uiState == .loading)
    }

    @Test("loadProducts success populates list")
    func loadProducts_success_populatesList() async {
        let (vm, repo) = Self.makeViewModel()
        repo.products = [Product.mock]
        await vm.loadProducts()
        guard case .success(let data) = vm.uiState else {
            Issue.record("Expected .success"); return
        }
        #expect(data.products.count == 1)
        #expect(repo.getProductsCallCount == 1)
    }

    @Test("loadProducts error shows error state")
    func loadProducts_error_showsError() async {
        let (vm, repo) = Self.makeViewModel()
        repo.errorToThrow = .networkError(message: "timeout")
        await vm.loadProducts()
        guard case .error = vm.uiState else {
            Issue.record("Expected .error"); return
        }
    }

    @Test("loadProducts empty shows empty state")
    func loadProducts_empty_showsEmpty() async {
        let (vm, repo) = Self.makeViewModel()
        repo.products = []
        await vm.loadProducts()
        // Verify empty state handling
    }
}
```

## iOS: Snapshot Test Pattern (TEMPLATE)

```swift
final class ProductListSnapshotTests: SnapshotTestCase {
    func test_productList_loadedState() {
        let view = ProductListScreen(viewModel: makeLoadedVM())
        assertScreenSnapshot(view, named: "loaded")
    }

    func test_productList_darkMode() {
        let view = ProductListScreen(viewModel: makeLoadedVM())
        assertScreenSnapshot(view, named: "dark", colorScheme: .dark)
    }

    func test_productList_largeFont() {
        let view = ProductListScreen(viewModel: makeLoadedVM())
        assertAccessibilityFontSnapshot(view)
    }

    func test_productList_emptyState() {
        let view = ProductListScreen(viewModel: makeEmptyVM())
        assertScreenSnapshot(view, named: "empty")
    }
}
```

## iOS: Memory Leak Test Pattern (TEMPLATE)

```swift
final class ProductPerformanceTests: PerformanceTestCase {
    func test_productListViewModel_noMemoryLeak() {
        var vm: ProductListViewModel? = ProductListViewModel(...)
        trackForMemoryLeaks(vm!)
        vm = nil
        // trackForMemoryLeaks asserts nil at teardown
    }
}
```

---

## Edge Cases Checklist (Every Feature)

- [ ] nil/optional inputs
- [ ] Empty string, empty array, empty collection
- [ ] Boundary values: 0, -1, Int.max, Double.infinity
- [ ] Network timeout, connection error, server error (500)
- [ ] Malformed JSON response (decode failure)
- [ ] Concurrent access (race conditions)
- [ ] Memory leaks (retain cycles in closures)
- [ ] Rapid user actions (double tap)
- [ ] Large data sets (100+ items, pagination)
- [ ] Special characters: emoji, RTL text, Unicode

---

## Test Maintenance Rules

When refactoring production code, you MUST update corresponding tests in the same commit:

- **UiState field changes** (rename, type change): Update all test assertions
- **ViewModel API changes** (removed/merged methods): Update all tests
- **Error model changes**: Update error state assertions
- **State behavior changes**: Update test expectations
- **Run tests locally before pushing**: `xcodebuild test` (iOS) / `./gradlew test` (Android)

Detekt excludes test files from `LargeClass` rule (test classes are naturally large).

---

## CI Pipeline Test Stages

| Stage | Trigger | What Runs |
|-------|---------|-----------|
| Lint | Every commit | SwiftLint --strict + SwiftFormat |
| Build | Every commit | xcodebuild build |
| Unit Tests | Every commit | All unit + auto tests |
| Snapshot Tests | Every PR | Visual regression checks |
| Integration Tests | Every PR | API chain tests |
| Coverage Report | Every PR | Enforce >= 80% lines |
| Thread Sanitizer | Weekly/nightly | Data race detection |
| Address Sanitizer | Weekly/nightly | Memory corruption detection |
| Security Scan | Weekly | Dependency vulnerabilities + secret detection |
