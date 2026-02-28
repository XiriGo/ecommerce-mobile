# Testing Strategy Guide

**Scope**: XiriGo Ecommerce Mobile Buyer App — Android + iOS
**Last Updated**: 2026-02-20

This guide defines the testing approach for the XiriGo Ecommerce mobile buyer app across both platforms. It covers the test pyramid, frameworks, patterns, tooling, and CI integration used by every feature team. All rules here derive from the CLAUDE.md standards.

---

## 1. Test Pyramid

The project follows a standard three-tier pyramid. More tests live at the bottom (cheap, fast, isolated) and fewer at the top (slow, broad, expensive).

```
        /\
       /  \   E2E / UI Tests (few)
      /----\  Critical user flows only
     /      \
    / Integr-\ Integration Tests (some)
   /  ation   \ API + Repository, DB + Repository
  /------------\
 /              \
/  Unit Tests    \ (most)
/ ViewModel       \
/ UseCase          \
/ Repository        \
/ Mapper             \
/--------------------\
```

### Layer Responsibilities

| Layer | What Is Tested | Speed | Count |
|-------|---------------|-------|-------|
| Unit | ViewModel, UseCase, Repository impl, Mapper, Domain model | Fast (ms) | Most |
| Integration | API client + Repository, Room/SwiftData + Repository | Medium (s) | Some |
| E2E / UI | Critical user flows end-to-end on device/simulator | Slow (min) | Few |

### Coverage Thresholds (from CLAUDE.md)

| Metric | Threshold |
|--------|-----------|
| Lines | >= 80% |
| Functions | >= 80% |
| Branches | >= 70% |

Coverage is measured per-platform. Jacoco produces the Android report; `xccov` produces the iOS report. Both are uploaded as CI artifacts on every PR.

---

## 2. Test Framework Summary

| Type | Android | iOS |
|------|---------|-----|
| Unit | JUnit 4 + Google Truth + MockK 1.13.16 + Turbine 1.2.0 | Swift Testing (`@Test` macro) |
| UI / Compose | Compose UI Test (`ui-test-junit4`) | ViewInspector 0.10.0 |
| Snapshot | Roborazzi or Paparazzi (from `@Preview` composables) | swift-snapshot-testing 1.17.0 |
| E2E | Compose UI Test + MockWebServer | XCTest UI Testing |
| Mocking strategy | Prefer fakes; MockK for unavoidable cases | Protocol-based fakes |
| Flow / async | Turbine 1.2.0 | `withCheckedThrowingContinuation` / `AsyncStream` |

### Library Versions in Project

Declared in `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/gradle/libs.versions.toml`:

```toml
junit       = "4.13.2"
truth       = "1.4.4"
mockk       = "1.13.16"
turbine     = "1.2.0"
coroutines  = "1.10.1"   # for kotlinx-coroutines-test
```

Declared in `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce.xcodeproj/project.pbxproj` (SPM):

```
ViewInspector           0.10.0
swift-snapshot-testing  1.17.0
```

---

## 3. E2E Test Scenarios

These are the minimum E2E flows that must be covered before any feature milestone is considered shippable. Each scenario maps to a `composeTestRule` (Android) or `XCTestCase` (iOS) test class.

| Scenario | Steps | Platform |
|----------|-------|----------|
| Guest Browse | Launch app → Home screen → Tap a category → Product list → Tap a product → Product detail → Back navigation returns to list | Both |
| Login Flow | Launch app → Profile tab → Tap "Log in" → Enter valid credentials → Confirm profile screen shows user name | Both |
| Add to Cart | Open Product detail → Select a variant (size / color) → Tap "Add to Cart" → Navigate to Cart tab → Verify item appears with correct name and price | Both |
| Checkout | Cart tab → Tap "Checkout" → Enter shipping address → Select shipping method → Enter payment details (Stripe) → Submit → Order confirmation screen shown | Both |
| Search | Home tab → Tap search bar → Type a product query → Results list appears → Tap a result → Product detail opens | Both |

E2E tests use `MockWebServer` (Android) or `MockURLProtocol` (iOS) to serve canned JSON from `shared/test-fixtures/` rather than hitting the real Medusa backend. This keeps the suite deterministic and fast.

---

## 4. API Mock Strategy

### Android — MockWebServer

`MockWebServer` (OkHttp) intercepts requests at the HTTP layer and returns pre-queued JSON responses. The app under test uses the mock server URL as `BuildConfig.API_BASE_URL`.

**Setup pattern:**

```kotlin
// app/src/androidTest/.../ProductListRepositoryTest.kt
class ProductListRepositoryTest {

    private val mockWebServer = MockWebServer()
    private lateinit var repository: ProductRepositoryImpl

    @Before
    fun setUp() {
        mockWebServer.start()
        val retrofit = Retrofit.Builder()
            .baseUrl(mockWebServer.url("/"))
            .addConverterFactory(Json.asConverterFactory("application/json".toMediaType()))
            .build()
        repository = ProductRepositoryImpl(
            api = retrofit.create(ProductApi::class.java),
            mapper = ProductMapper(),
        )
    }

    @After
    fun tearDown() {
        mockWebServer.shutdown()
    }

    @Test
    fun `getProductsStream emits mapped products when API returns 200`() = runTest {
        // Arrange
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(readFixture("products-list.json"))
        )

        // Act + Assert
        repository.getProductsStream(offset = 0, limit = 20).test {
            val products = awaitItem()
            assertThat(products).hasSize(3)
            awaitComplete()
        }
        // Verify the request
        val request = mockWebServer.takeRequest()
        assertThat(request.path).contains("/store/products")
    }
}
```

For tests that need multiple endpoints, use a `Dispatcher`:

```kotlin
mockWebServer.dispatcher = object : Dispatcher() {
    override fun dispatch(request: RecordedRequest): MockResponse {
        return when {
            request.path?.contains("/store/products") == true ->
                MockResponse().setBody(readFixture("products-list.json"))
            request.path?.contains("/store/carts") == true ->
                MockResponse().setBody(readFixture("cart.json"))
            else -> MockResponse().setResponseCode(404)
        }
    }
}
```

### iOS — MockURLProtocol

`MockURLProtocol` is a `URLProtocol` subclass registered in the test `URLSession` configuration. The `APIClient` instance created for the test receives a `URLSession` configured with this protocol.

**Setup pattern:**

```swift
// XiriGoEcommerceTests/Helpers/MockURLProtocol.swift
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// In test setUp
func makeAPIClient() -> APIClient {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return APIClient(
        baseURL: URL(string: "https://api-test.xirigo.com")!,
        session: URLSession(configuration: config)
    )
}
```

**Usage in a test:**

```swift
@Test func getProducts_returnsMappedProducts_whenAPIReturns200() async throws {
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let data = try loadFixture("products-list.json")
        return (response, data)
    }

    let products = try await repository.getProducts(offset: 0, limit: 20)
    #expect(products.count == 3)
}
```

### Shared Fixtures

Both platforms read JSON from `shared/test-fixtures/`. This directory does not exist yet and must be created as features are implemented.

**Directory layout:**

```
shared/
  test-fixtures/
    products-list.json        # GET /store/products list response
    product-detail.json       # GET /store/products/:id response
    categories.json           # GET /store/product-categories response
    cart.json                 # GET /store/carts/:id response
    cart-line-item.json       # POST /store/carts/:id/line-items response
    order.json                # GET /store/orders/:id response
    order-list.json           # GET /store/customers/me/orders response
    customer.json             # GET /store/customers/me response
    auth-token.json           # POST /auth/token response
    shipping-options.json     # GET /store/shipping-options response
```

**Fixture naming convention:** `{resource}-{scenario}.json`

Examples: `products-empty.json`, `product-detail-out-of-stock.json`, `cart-empty.json`

**Helper function (Android):**

```kotlin
// app/src/test/.../TestHelpers.kt
fun readFixture(filename: String): String =
    ClassLoader.getSystemResourceAsStream("fixtures/$filename")
        ?.bufferedReader()
        ?.readText()
        ?: error("Fixture not found: $filename")
```

**Helper function (iOS):**

```swift
// XiriGoEcommerceTests/Helpers/FixtureLoader.swift
func loadFixture(_ filename: String) throws -> Data {
    guard let url = Bundle(for: type(of: self) as! AnyClass)
        .url(forResource: filename, withExtension: nil, subdirectory: "Fixtures") else {
        throw TestError.fixtureNotFound(filename)
    }
    return try Data(contentsOf: url)
}
```

---

## 5. Fake Repository Pattern

Per CLAUDE.md (and Google's recommendation), **prefer fakes over mocks**. Fakes implement the repository interface with in-memory data. Use MockK (Android) or protocol mock objects (iOS) only when a fake is impractical (e.g., time-dependent behavior, one-off collaboration verification).

### Android Fake Pattern

```kotlin
// app/src/test/.../FakeProductRepository.kt
class FakeProductRepository : ProductRepository {
    private val products = mutableListOf<Product>()
    var shouldThrow: AppError? = null

    fun addProducts(vararg product: Product) { products.addAll(product) }

    override fun getProductsStream(offset: Int, limit: Int): Flow<List<Product>> = flow {
        shouldThrow?.let { throw it }
        emit(products.drop(offset).take(limit))
    }

    override suspend fun getProductById(id: String): Product {
        shouldThrow?.let { throw it }
        return products.first { it.id == id }
    }
}
```

Naming: `Fake{Name}` (e.g., `FakeCartRepository`, `FakeOrderRepository`).
Location: `app/src/test/.../repository/` (not in main sources).

### iOS Fake Pattern

```swift
// XiriGoEcommerceTests/Fakes/FakeProductRepository.swift
final class FakeProductRepository: ProductRepository, @unchecked Sendable {
    var products: [Product] = []
    var errorToThrow: AppError?

    func getProducts(offset: Int, limit: Int) async throws -> [Product] {
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

Naming: `Fake{Name}` (e.g., `FakeCartRepository`, `FakeOrderRepository`).
Location: `XiriGoEcommerceTests/Fakes/`.

---

## 6. Test Naming Convention

### Pattern

```
test_<method>_<condition>_<expected>
```

Or in natural language form (Android backtick style):

```
fun `<method> should <expected> when <condition>`()
```

### Android Examples

```kotlin
// ViewModel tests
@Test
fun `loadProducts should emit Loading state initially`() { ... }

@Test
fun `loadProducts should emit Success state when repository returns data`() { ... }

@Test
fun `loadProducts should emit Error state when repository throws NetworkError`() { ... }

@Test
fun `onProductClick should send NavigateToDetail event`() { ... }

// Repository tests
@Test
fun `getProductsStream should emit mapped products when API returns 200`() { ... }

@Test
fun `getProductsStream should throw Network error when API call fails`() { ... }

// Mapper tests
@Test
fun `toDomain should map all fields correctly from ProductDto`() { ... }
```

### iOS Examples

```swift
@Test func loadProducts_emitsLoadingState_initially() async { ... }

@Test func loadProducts_showsSuccess_whenRepositoryReturnsData() async throws { ... }

@Test func loadProducts_showsError_whenNetworkFails() async { ... }

@Test func onProductTap_firesNavigateToDetailEvent() async { ... }

@Test func toDomain_mapsAllFields_fromProductDTO() { ... }
```

### Arrange-Act-Assert Structure

Every test follows AAA:

```kotlin
@Test
fun `getProductsStream should emit mapped products`() = runTest {
    // Arrange
    val fakeRepo = FakeProductRepository()
    fakeRepo.addProducts(testProduct(id = "prod_1"))
    val useCase = GetProductsUseCase(fakeRepo)

    // Act
    val result = useCase(offset = 0, limit = 20).first()

    // Assert
    assertThat(result).hasSize(1)
    assertThat(result[0].id).isEqualTo("prod_1")
}
```

---

## 7. ViewModel Testing with Turbine (Android)

Turbine provides a structured API for consuming `Flow` emissions in tests.

```kotlin
// app/src/test/.../ProductListViewModelTest.kt
@OptIn(ExperimentalCoroutinesApi::class)
class ProductListViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val fakeRepository = FakeProductRepository()
    private lateinit var viewModel: ProductListViewModel

    @Before
    fun setUp() {
        fakeRepository.addProducts(testProduct("1"), testProduct("2"))
        viewModel = ProductListViewModel(
            getProductsUseCase = GetProductsUseCase(fakeRepository)
        )
    }

    @Test
    fun `uiState should be Loading initially`() = runTest {
        assertThat(viewModel.uiState.value).isInstanceOf(ProductListUiState.Loading::class.java)
    }

    @Test
    fun `uiState should emit Success when products load`() = runTest {
        viewModel.uiState.test {
            // Skip Loading
            assertThat(awaitItem()).isInstanceOf(ProductListUiState.Loading::class.java)
            // Assert Success
            val success = awaitItem() as ProductListUiState.Success
            assertThat(success.products).hasSize(2)
        }
    }

    @Test
    fun `uiState should emit Error when repository throws`() = runTest {
        fakeRepository.shouldThrow = AppError.Network()
        val vm = ProductListViewModel(GetProductsUseCase(fakeRepository))

        vm.uiState.test {
            skipItems(1) // Loading
            val error = awaitItem() as ProductListUiState.Error
            assertThat(error.message).isNotEmpty()
        }
    }
}
```

`MainDispatcherRule` replaces `Dispatchers.Main` with `UnconfinedTestDispatcher` for deterministic test execution.

---

## 8. Screenshot / Snapshot Testing

### Android — Paparazzi

Paparazzi renders Compose `@Preview` composables to a PNG without a device or emulator. Generated images are stored in the repository and compared on every CI run.

**Setup:**

```kotlin
// build.gradle.kts (app module)
plugins {
    id("app.cash.paparazzi") version "1.3.5"
}
```

**Test file:**

```kotlin
// app/src/test/.../ProductListScreenTest.kt
class ProductListScreenTest {

    @get:Rule
    val paparazzi = Paparazzi(
        deviceConfig = DeviceConfig.PIXEL_6,
        theme = "android:Theme.Material3.DayNight.NoActionBar",
    )

    @Test
    fun productListLoading() {
        paparazzi.snapshot {
            XGTheme {
                ProductListContent(
                    uiState = ProductListUiState.Loading,
                    onLoadMore = {},
                    onProductClick = {},
                )
            }
        }
    }

    @Test
    fun productListSuccess() {
        paparazzi.snapshot {
            XGTheme {
                ProductListContent(
                    uiState = ProductListUiState.Success(products = testProducts()),
                    onLoadMore = {},
                    onProductClick = {},
                )
            }
        }
    }

    @Test
    fun productListError() {
        paparazzi.snapshot {
            XGTheme {
                ProductListContent(
                    uiState = ProductListUiState.Error("Network error"),
                    onLoadMore = {},
                    onProductClick = {},
                )
            }
        }
    }
}
```

**Record mode** (update baselines):

```bash
./gradlew recordPaparazziDebug
```

**Verify mode** (CI default):

```bash
./gradlew verifyPaparazziDebug
```

Baseline images are stored under `app/src/test/snapshots/images/`. Commit them alongside code changes.

### iOS — swift-snapshot-testing

`swift-snapshot-testing` (1.17.0) is already declared as an SPM dependency. It captures SwiftUI views at test time and compares against stored baselines.

**Test file:**

```swift
// XiriGoEcommerceTests/Snapshots/ProductListViewSnapshotTests.swift
import SnapshotTesting
import SwiftUI
import XCTest
@testable import XiriGoEcommerce

final class ProductListViewSnapshotTests: XCTestCase {

    func test_productListView_loading() {
        let view = ProductListView(
            viewModel: ProductListViewModel(
                getProductsUseCase: GetProductsUseCase(repository: FakeProductRepository())
            )
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }

    func test_productListView_success_lightMode() {
        let fake = FakeProductRepository()
        fake.products = testProducts()
        let view = ProductListView(
            viewModel: ProductListViewModel(
                getProductsUseCase: GetProductsUseCase(repository: fake)
            )
        )
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .light))
        )
    }

    func test_productListView_success_darkMode() {
        // Same as above, pass .dark userInterfaceStyle
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .dark))
        )
    }
}
```

**Record mode** (update baselines): set `isRecording = true` on the `assertSnapshot` call, or set the `SNAPSHOT_TESTING_RECORD` environment variable to `1` in the test scheme.

**Baseline directory**: `__Snapshots__/` next to the test file. Commit these PNG files.

### Snapshot Configuration Guidelines

- Test at minimum: **Loading**, **Success**, and **Error** states for every screen.
- Test both **light and dark mode** for any screen with color-sensitive content.
- Test at **default Dynamic Type** and at **accessibilityExtraExtraLarge** for screens with variable-length text.
- Name snapshot tests to match the composable or view they capture.

---

## 9. Performance Testing Baselines

Performance tests run in CI on a cadence (nightly or pre-release), not on every PR. They establish regression baselines and alert when a build degrades.

| Metric | Target | Android Tool | iOS Tool |
|--------|--------|-------------|----------|
| Cold start | < 2 s | Macrobenchmark (`StartupMode.COLD`) | XCTest Performance Metrics (`XCTApplicationLaunchMetric`) |
| Screen transition | < 300 ms | Macrobenchmark (`TimingMetric`) | XCTest Performance Metrics (`XCTClockMetric`) |
| List scroll jank | 60 fps (16 ms/frame) | Macrobenchmark (`FrameTimingMetric`) | Instruments (Core Animation FPS) |
| Image load (first visible) | < 500 ms | Custom `SystemClock.elapsedRealtime()` timing | Custom `CFAbsoluteTimeGetCurrent()` timing |

### Android — Macrobenchmark

```kotlin
// benchmarks/src/androidTest/.../AppStartupBenchmark.kt
@RunWith(AndroidJUnit4::class)
class AppStartupBenchmark {

    @get:Rule
    val benchmarkRule = MacrobenchmarkRule()

    @Test
    fun coldStartup() = benchmarkRule.measureRepeated(
        packageName = "com.xirigo.ecommerce",
        metrics = listOf(StartupTimingMetric()),
        iterations = 5,
        startupMode = StartupMode.COLD,
    ) {
        pressHome()
        startActivityAndWait()
    }
}
```

### iOS — XCTest Performance

```swift
// XiriGoEcommerceUITests/PerformanceTests.swift
final class AppStartupPerformanceTests: XCTestCase {

    func test_coldLaunchPerformance() throws {
        let app = XCUIApplication()
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
}
```

---

## 10. Test Data and Fixture Management

### Fixture Files

`shared/test-fixtures/` is the single source of fixture JSON for both platforms. Both test suites read from the same files to ensure parity in mock data.

**Naming convention:** `{resource}-{scenario}.json`

| File | Endpoint Simulated | Notes |
|------|--------------------|-------|
| `products-list.json` | `GET /store/products` | 3 products, all in-stock |
| `products-empty.json` | `GET /store/products` | `count: 0`, empty array |
| `product-detail.json` | `GET /store/products/:id` | 1 product, with variants |
| `product-detail-out-of-stock.json` | `GET /store/products/:id` | All variants `inventory_quantity: 0` |
| `categories.json` | `GET /store/product-categories` | Top-level categories |
| `cart.json` | `GET /store/carts/:id` | Cart with 2 line items |
| `cart-empty.json` | `GET /store/carts/:id` | Cart with 0 line items |
| `order.json` | `GET /store/orders/:id` | Completed order |
| `customer.json` | `GET /store/customers/me` | Authenticated customer profile |
| `auth-token.json` | `POST /auth/token` | JWT access + refresh tokens |
| `shipping-options.json` | `GET /store/shipping-options` | 2 shipping options |

### Fake Repository Naming

| Feature | Android Fake | iOS Fake |
|---------|-------------|---------|
| Products | `FakeProductRepository` | `FakeProductRepository` |
| Cart | `FakeCartRepository` | `FakeCartRepository` |
| Orders | `FakeOrderRepository` | `FakeOrderRepository` |
| Customer | `FakeCustomerRepository` | `FakeCustomerRepository` |
| Search | `FakeSearchRepository` | `FakeSearchRepository` |
| Auth | `FakeAuthRepository` | `FakeAuthRepository` |

Fakes live in the test source set only — never in main application sources.

---

## 11. CI Integration

### Test Execution by Trigger

| Trigger | Tests Run |
|---------|-----------|
| Every commit to any branch | Unit tests |
| Pull request to `develop` or `main` | Unit tests + UI / snapshot tests |
| Merge to `main` | Unit + UI + snapshot + performance baselines |
| Nightly scheduled run | Full suite including E2E and performance |

### Android CI Steps

```yaml
# .github/workflows/android.yml (excerpt)
- name: Run unit tests
  run: ./gradlew testDebugUnitTest

- name: Run instrumented tests
  uses: reactivecircus/android-emulator-runner@v2
  with:
    api-level: 34
    script: ./gradlew connectedDebugAndroidTest

- name: Generate coverage report
  run: ./gradlew jacocoTestReport

- name: Upload coverage
  uses: codecov/codecov-action@v4
  with:
    files: app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.xml

- name: Verify snapshots
  run: ./gradlew verifyPaparazziDebug
```

Run tests manually:

```bash
# Unit tests
cd android && ./gradlew testDebugUnitTest

# Coverage report
./gradlew testDebugUnitTest jacocoTestReport

# Snapshot record (update baselines)
./gradlew recordPaparazziDebug

# Snapshot verify
./gradlew verifyPaparazziDebug

# Specific test class
./gradlew test --tests com.xirigo.ecommerce.feature.product.viewmodel.ProductListViewModelTest
```

### iOS CI Steps

```yaml
# .github/workflows/ios.yml (excerpt)
- name: Run unit tests
  run: xcodebuild test
    -project ios/XiriGoEcommerce.xcodeproj
    -scheme XiriGoEcommerce
    -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0'
    -only-testing XiriGoEcommerceTests

- name: Run UI tests
  run: xcodebuild test
    -project ios/XiriGoEcommerce.xcodeproj
    -scheme XiriGoEcommerce
    -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0'
    -only-testing XiriGoEcommerceUITests

- name: Generate coverage report
  run: xcrun xccov view --report
    DerivedData/Logs/Test/*.xcresult --json > coverage.json

- name: Upload coverage
  uses: codecov/codecov-action@v4
```

Run tests manually:

```bash
# Unit tests
xcodebuild test \
  -project ios/XiriGoEcommerce.xcodeproj \
  -scheme XiriGoEcommerce \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
  -only-testing XiriGoEcommerceTests

# All tests
xcodebuild test \
  -project ios/XiriGoEcommerce.xcodeproj \
  -scheme XiriGoEcommerce \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0'
```

### Test Result Artifacts

Both platforms upload the following as CI artifacts on each run:

- Unit test XML report (`TEST-*.xml`)
- Coverage report (Jacoco XML / xccov JSON)
- Snapshot diff images (when snapshots fail)
- Build logs

### Flaky Test Policy

1. A test is considered **flaky** if it fails 3 consecutive times on CI without a code change.
2. The owning team **quarantines** the test (marks `@Ignore` / `@Test(.disabled)`) and files a task.
3. The flaky test must be fixed within the **current sprint**.
4. Quarantined tests are tracked in a CI dashboard label so they are not forgotten.

---

## 12. Agentic Testing Strategy

The multi-agent pipeline includes two dedicated test agents: `android-tester` and `ios-tester`. These agents run after the dev agents complete their feature implementation.

### Agent Responsibilities

| Agent | Task | Deliverable |
|-------|------|-------------|
| `android-tester` | Write unit tests for ViewModel, UseCase, Repository, Mapper | Test files + handoff file |
| `ios-tester` | Write unit tests for ViewModel, UseCase, Repository, Domain model | Test files + handoff file |

### Agent Conventions

- Agents **always create fakes**, never mocks, unless the collaborator has no interface (follow project convention).
- Agents verify: all written tests pass, coverage meets thresholds, no test pollutes another.
- Agents count actual test methods and include the count in their handoff file.
- Agents follow the naming pattern: `test_<method>_<condition>_<expected>`.
- Agents do not write E2E or snapshot tests — those are created with the feature's UI implementation.

### Handoff Protocol

```
android-dev / ios-dev  →  [commits code]  →  android-tester / ios-tester
                                                       |
                                               [reads handoff]
                                               [writes tests]
                                               [commits tests]
                                               [creates test handoff]
                                                       |
                                                   doc-writer
                                                       |
                                                   reviewer
```

Each test agent produces: `docs/pipeline/{feature}-android-test.handoff.md` or `docs/pipeline/{feature}-ios-test.handoff.md`.

### Test File Locations

| Type | Android | iOS |
|------|---------|-----|
| Unit tests | `android/app/src/test/java/com/xirigo/ecommerce/**/*Test.kt` | `ios/XiriGoEcommerceTests/**/*Tests.swift` |
| UI / Compose tests | `android/app/src/androidTest/java/com/xirigo/ecommerce/**/*Test.kt` | `ios/XiriGoEcommerceUITests/**/*UITests.swift` |
| Snapshot tests | `android/app/src/test/**/*SnapshotTest.kt` | `ios/XiriGoEcommerceTests/Snapshots/**/*SnapshotTests.swift` |
| Fakes | `android/app/src/test/**/ Fake*.kt` | `ios/XiriGoEcommerceTests/Fakes/Fake*.swift` |
| Helpers / fixtures | `android/app/src/test/**/TestHelpers.kt` | `ios/XiriGoEcommerceTests/Helpers/*.swift` |

---

## 13. Existing Test Suite (M0-01 App Scaffold)

The scaffold delivered 83 tests across both platforms. These serve as the reference implementation for test style and structure.

### Android (33 tests)

| File | Tests | What Is Covered |
|------|-------|-----------------|
| `/android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/theme/XGColorsTest.kt` | 11 | 67 color constants against design token values |
| `/android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/theme/XGSpacingTest.kt` | 4 | 16 spacing constants, min touch target (48dp) |
| `/android/app/src/test/java/com/xirigo/ecommerce/BuildConfigTest.kt` | 6 | API base URL, version code, version name, build type |
| `/android/app/src/test/java/com/xirigo/ecommerce/StringResourcesTest.kt` | 9 | All 12 common strings in en/mt/tr via locale context |
| `/android/app/src/test/java/com/xirigo/ecommerce/XGApplicationTest.kt` | 3 | `@HiltAndroidApp` annotation, Timber setup, Application superclass |

Framework: JUnit 4 + Google Truth.
Pattern: backtick test names, direct value assertions, no mocking.

### iOS (50 tests)

| File | Tests | What Is Covered |
|------|-------|-----------------|
| `/ios/XiriGoEcommerceTests/ConfigTests.swift` | 6 | API base URL per environment, version format, build number |
| `/ios/XiriGoEcommerceTests/Core/DesignSystem/Theme/XGColorsTests.swift` | 17 | Color constants, hex extension, contrast pairs |
| `/ios/XiriGoEcommerceTests/Core/DesignSystem/Theme/XGSpacingTests.swift` | 16 | All spacing values, min touch target (44pt) |
| `/ios/XiriGoEcommerceTests/Resources/LocalizableTests.swift` | 11 | String keys in en/mt/tr, completeness for all 3 languages |

Framework: Swift Testing (`@Test` macro, `#expect`).
Pattern: `@Suite` groups, `#expect` assertions, locale-parameterized string tests.

---

## Related Files

| File | Purpose |
|------|---------|
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/CLAUDE.md` | Coverage thresholds, test rules, naming conventions |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/gradle/libs.versions.toml` | Test library versions (JUnit, Truth, MockK, Turbine) |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/src/test/` | Android unit test root |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/src/androidTest/` | Android instrumented test root |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerceTests/` | iOS unit test root |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerceUITests/` | iOS UI test root |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/shared/test-fixtures/` | Shared JSON fixtures (created as features land) |
