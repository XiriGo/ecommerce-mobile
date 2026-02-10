# CLAUDE.md - Molt Marketplace Mobile App Guide

## Project Identity

- **Project**: Molt Marketplace - Mobile Buyer App
- **Platforms**: Native Android + Native iOS
- **Android**: Kotlin + Jetpack Compose + Material 3
- **iOS**: Swift + SwiftUI
- **Architecture**: Clean Architecture (Data → Domain → Presentation)
- **Backend**: Medusa v2 REST API (base URL from environment)
- **Package Manager**: Gradle KTS (Android), SPM (iOS)

## Architecture

### Clean Architecture Layers

Each feature follows three layers:

1. **Data Layer**: Repository implementations, API DTOs, mappers, local storage
2. **Domain Layer**: Use cases, domain models, repository interfaces (protocols/interfaces)
3. **Presentation Layer**: UI components (Compose/SwiftUI), ViewModels, UI state models

### Feature Module Structure

```
feature/<name>/
  ├── data/
  │   ├── dto/           # API request/response DTOs
  │   ├── mapper/        # DTO ↔ Domain model mappers
  │   ├── remote/        # API service interface
  │   └── repository/    # Repository implementation
  ├── domain/
  │   ├── model/         # Domain models
  │   ├── repository/    # Repository interface
  │   └── usecase/       # Use cases
  └── presentation/
      ├── component/     # Reusable UI components for this feature
      ├── screen/        # Screen composables/views
      ├── viewmodel/     # ViewModels
      └── state/         # UI state models
```

### State Management

- **Unidirectional Data Flow (UDF)**: UI → Event → ViewModel → State → UI
- Screen state as a single sealed interface/enum with Loading, Success, Error variants
- Side effects (navigation, snackbar) via Channel/SharedFlow (Android) or AsyncSequence (iOS)

## Android Standards (Kotlin + Jetpack Compose)

### SDK Versions

- **minSdk**: 26 (Android 8.0)
- **targetSdk**: 35
- **compileSdk**: 35
- **Kotlin**: 2.1.x
- **Compose BOM**: 2025.x

### Dependencies

| Category | Library |
|----------|---------|
| UI | Jetpack Compose + Material 3 |
| DI | Hilt (Dagger) |
| Network | Retrofit + OkHttp + Kotlin Serialization |
| Image | Coil (Compose) |
| Navigation | Compose Navigation (type-safe) |
| Async | Kotlin Coroutines + Flow |
| State | StateFlow + collectAsStateWithLifecycle() |
| Storage | DataStore (preferences), Room (structured) |
| Testing | JUnit 5, MockK, Turbine, Compose UI Test |
| Lint | ktlint + detekt |

### Kotlin Rules

- **No `Any` type** in ViewModel, UseCase, or Domain layer. Use sealed class/interface.
- **Explicit return types** on all public functions.
- **No `!!` (force non-null)**. Use `requireNotNull()` with a message if truly needed.
- **No `var`** for state in ViewModels. Use `MutableStateFlow` with private setter.
- **Immutable data classes** for all models. No mutable properties.
- Use **`when` exhaustively** (no `else` branch on sealed classes).
- Prefer **extension functions** over utility classes.
- Use **`@Stable`** annotation on Compose state classes.
- **No `AndroidViewModel`**: Use `ViewModel()`. Pass dependencies via Hilt, not Context.
- **ViewModels at screen level only**: Never pass ViewModel to child composables. Hoist state.
- **Single `uiState` property**: Expose one `StateFlow<XxxUiState>` per ViewModel, use `stateIn(WhileSubscribed(5_000))`.

### Compose Rules

- **Stateless composables**: Pass state down, events up.
- **Previews**: Every screen composable has a `@Preview` function.
- **No side effects in composables**: Use `LaunchedEffect`, `SideEffect`, `DisposableEffect`.
- **Modifier parameter**: First optional parameter on every composable, default `Modifier`.
- **Material 3 theming**: Always use `MaterialTheme.colorScheme`, never hardcode colors.
- **No hardcoded strings**: Use `stringResource(R.string.xxx)`.

### Hilt DI Pattern

```kotlin
@HiltViewModel
class ProductListViewModel @Inject constructor(
    private val getProductsUseCase: GetProductsUseCase
) : ViewModel() { ... }

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    abstract fun bindProductRepository(impl: ProductRepositoryImpl): ProductRepository
}
```

### Network Pattern

```kotlin
interface ProductApi {
    @GET("store/products")
    suspend fun getProducts(@QueryMap filters: Map<String, String>): ProductListResponse
}
```

## iOS Standards (Swift + SwiftUI)

### Versions

- **Minimum iOS**: 16.0
- **Target iOS**: 18.0
- **Swift**: 6.x
- **Xcode**: 16+

### Dependencies (SPM)

| Category | Library |
|----------|---------|
| UI | SwiftUI (built-in) |
| DI | Manual (protocol-based) / Factory |
| Network | URLSession + async/await + Codable |
| Image | Kingfisher (cache) + AsyncImage |
| Navigation | NavigationStack + NavigationPath |
| Async | Swift Concurrency (async/await, Task) |
| Storage | UserDefaults, SwiftData |
| Testing | Swift Testing + XCTest, ViewInspector |
| Lint | SwiftLint (strict) |

### Swift Rules

- **No force unwrap (`!`)**: Always use `guard let`, `if let`, or nil coalescing (`??`).
- **No `Any` or `AnyObject`** in domain/presentation. Use protocols and generics.
- **Explicit access control**: `public`, `internal`, `private` on all declarations.
- **`@MainActor`** on all ViewModels and UI-related classes.
- **Sendable conformance** for all types passed across concurrency boundaries.
- **`final class`** by default. Only remove `final` when subclassing is explicitly needed.
- **Prefer value types** (struct, enum) over reference types (class).
- **Use `@Observable`** (iOS 17+) for view models. Provide `@ObservableObject` wrapper for iOS 16.

### SwiftUI Rules

- **Body should be simple**: Extract complex views into separate structs.
- **Use `@Environment`** for dependency injection in views.
- **No `AnyView`**: Use `@ViewBuilder` or `some View` generics.
- **Previews**: Every view has a `#Preview` block.
- **No hardcoded strings**: Use `String(localized:)` or `.localizable` pattern.
- **Theme tokens**: Always use theme constants, never hardcode colors/fonts.

### DI Pattern (iOS)

```swift
protocol ProductRepository: Sendable {
    func getProducts(filters: ProductFilters) async throws -> ProductListResponse
}

final class ProductRepositoryImpl: ProductRepository {
    private let apiClient: APIClient
    init(apiClient: APIClient) { self.apiClient = apiClient }
}

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()
    lazy var apiClient: APIClient = { APIClientImpl(baseURL: Config.apiBaseURL) }()
    lazy var productRepository: ProductRepository = { ProductRepositoryImpl(apiClient: apiClient) }()
}
```

### Network Pattern (iOS)

```swift
struct APIClient {
    let baseURL: URL
    let session: URLSession

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let (data, response) = try await session.data(for: endpoint.urlRequest(baseURL: baseURL))
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        return try JSONDecoder.api.decode(T.self, from: data)
    }
}
```

## Common Standards (Both Platforms)

### Naming Conventions

| Element | Android (Kotlin) | iOS (Swift) |
|---------|-------------------|-------------|
| Classes/Structs | PascalCase | PascalCase |
| Functions | camelCase | camelCase |
| Variables | camelCase | camelCase |
| Constants | SCREAMING_SNAKE | PascalCase (static let) |
| Files | PascalCase.kt | PascalCase.swift |
| Packages/Modules | lowercase.dotted | PascalCase |

### Architecture Naming Rules

| Type | Pattern | Android Example | iOS Example |
|------|---------|-----------------|-------------|
| DTO | `{Name}Dto` | `ProductDto` | `ProductDTO` |
| Domain model | `{Name}` | `Product` | `Product` |
| UI state | `{Screen}UiState` | `ProductListUiState` | `ProductListUiState` |
| UI event | `{Screen}Event` | `ProductListEvent` | `ProductListEvent` |
| Repository interface | `{Name}Repository` | `ProductRepository` | `ProductRepository` |
| Repository impl | `{Name}RepositoryImpl` | `ProductRepositoryImpl` | `ProductRepositoryImpl` |
| Use case | `{Verb}{Name}UseCase` | `GetProductsUseCase` | `GetProductsUseCase` |
| ViewModel | `{Screen}ViewModel` | `ProductListViewModel` | `ProductListViewModel` |
| API service | `{Name}Api` | `ProductApi` | N/A (use Endpoint enum) |
| Mapper | `{Name}Mapper` | `ProductMapper` | extension on DTO |
| Stream getter | `get{Name}Stream()` | `getProductsStream(): Flow<List<Product>>` | `getProductsStream() -> AsyncStream<[Product]>` |
| Test fake | `Fake{Name}` | `FakeProductRepository` | `FakeProductRepository` |
| Test file | `{Name}Test` | `ProductListViewModelTest` | `ProductListViewModelTests` |

### Import Order

Imports must follow this order, separated by blank lines:

1. Platform imports (android.*, UIKit, SwiftUI)
2. Framework imports (androidx.*, Foundation)
3. Third-party imports
4. Internal/project imports
5. Relative imports

### Error Handling

- Domain errors as sealed class (Kotlin) / enum (Swift)
- Map API errors to domain errors in repository layer
- UI-friendly error messages in presentation layer
- Never swallow errors silently
- Log errors for debugging
- **Never send one-off events from ViewModel to UI** (Google strongly recommended). Process the event immediately in ViewModel and update state with the result.

### API Integration

- All backend API calls go through the repository layer
- DTOs are separate from domain models (always map)
- API contracts defined in `shared/api-contracts/`
- Base URL from environment/build config (never hardcoded)
- Auth token injected via interceptor (Android) / middleware (iOS)
- Pagination: offset-based (Medusa standard)

### Localization

- All user-facing strings in resource files
- **Android**: `res/values/strings.xml`, `res/values-tr/strings.xml`
- **iOS**: `Localizable.xcstrings` or `.strings` files
- **Default language**: Turkish (tr)
- **Secondary**: English (en)

## Code Templates (Reference Implementations)

Every feature implementation MUST follow these templates exactly. Agents should
copy these patterns for each new feature, replacing `Product` with the feature name.

### Android: UiState Pattern

```kotlin
// feature/product/presentation/state/ProductListUiState.kt
@Stable
sealed interface ProductListUiState {
    data object Loading : ProductListUiState
    data class Success(
        val products: List<Product>,
        val isLoadingMore: Boolean = false,
        val hasMore: Boolean = true,
    ) : ProductListUiState
    data class Error(val message: String) : ProductListUiState
}

sealed interface ProductListEvent {
    data class NavigateToDetail(val productId: String) : ProductListEvent
    data class ShowSnackbar(val message: String) : ProductListEvent
}
```

### Android: ViewModel Pattern

```kotlin
// feature/product/presentation/viewmodel/ProductListViewModel.kt
@HiltViewModel
class ProductListViewModel @Inject constructor(
    private val getProductsUseCase: GetProductsUseCase,
) : ViewModel() {

    private val _event = Channel<ProductListEvent>(Channel.BUFFERED)
    val event: Flow<ProductListEvent> = _event.receiveAsFlow()

    private var offset = 0
    private val limit = 20

    val uiState: StateFlow<ProductListUiState> = getProductsUseCase(
        offset = 0, limit = limit
    ).map<List<Product>, ProductListUiState> { products ->
        ProductListUiState.Success(
            products = products,
            hasMore = products.size >= limit,
        )
    }.catch { e ->
        emit(ProductListUiState.Error(e.toUserMessage()))
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = ProductListUiState.Loading,
    )

    fun onLoadMore() {
        val current = uiState.value
        if (current !is ProductListUiState.Success || current.isLoadingMore || !current.hasMore) return
        viewModelScope.launch {
            // update state, fetch next page, merge results
        }
    }

    fun onProductClick(productId: String) {
        viewModelScope.launch {
            _event.send(ProductListEvent.NavigateToDetail(productId))
        }
    }
}
```

### Android: Screen Pattern

```kotlin
// feature/product/presentation/screen/ProductListScreen.kt
@Composable
fun ProductListScreen(
    viewModel: ProductListViewModel = hiltViewModel(),
    onNavigateToDetail: (String) -> Unit,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        viewModel.event.collect { event ->
            when (event) {
                is ProductListEvent.NavigateToDetail -> onNavigateToDetail(event.productId)
                is ProductListEvent.ShowSnackbar -> { /* show snackbar */ }
            }
        }
    }

    ProductListContent(
        uiState = uiState,
        onLoadMore = viewModel::onLoadMore,
        onProductClick = viewModel::onProductClick,
    )
}

@Composable
private fun ProductListContent(
    uiState: ProductListUiState,
    onLoadMore: () -> Unit,
    onProductClick: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    when (uiState) {
        is ProductListUiState.Loading -> LoadingView(modifier)
        is ProductListUiState.Error -> ErrorView(message = uiState.message, modifier = modifier)
        is ProductListUiState.Success -> {
            LazyVerticalGrid(columns = GridCells.Fixed(2), modifier = modifier) {
                items(uiState.products, key = { it.id }) { product ->
                    ProductCard(product = product, onClick = { onProductClick(product.id) })
                }
                if (uiState.isLoadingMore) {
                    item(span = { GridItemSpan(2) }) { LoadingIndicator() }
                }
            }
            // Trigger load more when near end
            LaunchedEffect(uiState.products.size) {
                if (uiState.hasMore) onLoadMore()
            }
        }
    }
}

@Preview
@Composable
private fun ProductListContentPreview() {
    MoltTheme {
        ProductListContent(
            uiState = ProductListUiState.Success(products = previewProducts()),
            onLoadMore = {},
            onProductClick = {},
        )
    }
}
```

### Android: Repository Pattern

```kotlin
// feature/product/domain/repository/ProductRepository.kt
interface ProductRepository {
    fun getProductsStream(offset: Int, limit: Int): Flow<List<Product>>
    suspend fun getProductById(id: String): Product
}

// feature/product/data/repository/ProductRepositoryImpl.kt
class ProductRepositoryImpl @Inject constructor(
    private val api: ProductApi,
    private val mapper: ProductMapper,
) : ProductRepository {

    override fun getProductsStream(offset: Int, limit: Int): Flow<List<Product>> = flow {
        val response = api.getProducts(mapOf("offset" to "$offset", "limit" to "$limit"))
        emit(response.products.map(mapper::toDomain))
    }

    override suspend fun getProductById(id: String): Product {
        val response = api.getProductById(id)
        return mapper.toDomain(response.product)
    }
}
```

### Android: UseCase Pattern

```kotlin
// feature/product/domain/usecase/GetProductsUseCase.kt
class GetProductsUseCase @Inject constructor(
    private val repository: ProductRepository,
) {
    operator fun invoke(offset: Int, limit: Int): Flow<List<Product>> =
        repository.getProductsStream(offset, limit)
}
```

### Android: Domain Error Pattern

```kotlin
// core/domain/error/AppError.kt
sealed class AppError : Exception() {
    data class Network(override val message: String = "Network error") : AppError()
    data class Server(val code: Int, override val message: String) : AppError()
    data class NotFound(override val message: String = "Not found") : AppError()
    data class Unauthorized(override val message: String = "Unauthorized") : AppError()
    data class Unknown(override val message: String = "Unknown error") : AppError()
}

// Extension for user-friendly messages
fun Throwable.toUserMessage(): String = when (this) {
    is AppError.Network -> "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin."
    is AppError.Server -> "Sunucu hatası ($code). Lütfen tekrar deneyin."
    is AppError.Unauthorized -> "Oturum süreniz doldu. Lütfen tekrar giriş yapın."
    is AppError.NotFound -> "İçerik bulunamadı."
    else -> "Bir hata oluştu. Lütfen tekrar deneyin."
}
```

### Android: Fake Repository for Tests

```kotlin
// feature/product/data/repository/FakeProductRepository.kt (in test source set)
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

---

### iOS: UiState Pattern

```swift
// Feature/Product/Presentation/ProductListUiState.swift
enum ProductListUiState: Equatable {
    case loading
    case success(products: [Product], isLoadingMore: Bool = false, hasMore: Bool = true)
    case error(message: String)
}

enum ProductListEvent {
    case navigateToDetail(productId: String)
    case showToast(message: String)
}
```

### iOS: ViewModel Pattern

```swift
// Feature/Product/Presentation/ProductListViewModel.swift
@MainActor @Observable
final class ProductListViewModel {
    private(set) var uiState: ProductListUiState = .loading
    private let getProductsUseCase: GetProductsUseCase

    private var offset = 0
    private let limit = 20
    var onEvent: ((ProductListEvent) -> Void)?

    init(getProductsUseCase: GetProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
    }

    func loadProducts() async {
        uiState = .loading
        do {
            let products = try await getProductsUseCase.execute(offset: 0, limit: limit)
            offset = products.count
            uiState = .success(products: products, hasMore: products.count >= limit)
        } catch {
            uiState = .error(message: error.toUserMessage())
        }
    }

    func loadMore() async {
        guard case .success(let products, false, true) = uiState else { return }
        uiState = .success(products: products, isLoadingMore: true, hasMore: true)
        do {
            let newProducts = try await getProductsUseCase.execute(offset: offset, limit: limit)
            offset += newProducts.count
            uiState = .success(
                products: products + newProducts,
                hasMore: newProducts.count >= limit
            )
        } catch {
            uiState = .success(products: products, hasMore: true) // keep existing data
        }
    }

    func onProductTap(_ productId: String) {
        onEvent?(.navigateToDetail(productId: productId))
    }
}
```

### iOS: View Pattern

```swift
// Feature/Product/Presentation/ProductListView.swift
struct ProductListView: View {
    @State private var viewModel: ProductListViewModel

    init(viewModel: ProductListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                LoadingView()
            case .error(let message):
                ErrorView(message: message, onRetry: { Task { await viewModel.loadProducts() } })
            case .success(let products, let isLoadingMore, let hasMore):
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(products) { product in
                            ProductCard(product: product)
                                .onTapGesture { viewModel.onProductTap(product.id) }
                        }
                    }
                    .padding(.horizontal)

                    if isLoadingMore {
                        ProgressView()
                            .padding()
                    }

                    if hasMore {
                        Color.clear
                            .frame(height: 1)
                            .onAppear { Task { await viewModel.loadMore() } }
                    }
                }
                .refreshable { await viewModel.loadProducts() }
            }
        }
        .task { await viewModel.loadProducts() }
    }
}

#Preview {
    ProductListView(viewModel: ProductListViewModel(
        getProductsUseCase: GetProductsUseCase(repository: FakeProductRepository())
    ))
}
```

### iOS: Repository Pattern

```swift
// Feature/Product/Domain/ProductRepository.swift
protocol ProductRepository: Sendable {
    func getProducts(offset: Int, limit: Int) async throws -> [Product]
    func getProductById(_ id: String) async throws -> Product
}

// Feature/Product/Data/ProductRepositoryImpl.swift
final class ProductRepositoryImpl: ProductRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getProducts(offset: Int, limit: Int) async throws -> [Product] {
        let response: ProductListResponse = try await apiClient.request(
            .getProducts(offset: offset, limit: limit)
        )
        return response.products.map(\.toDomain)
    }

    func getProductById(_ id: String) async throws -> Product {
        let response: ProductDetailResponse = try await apiClient.request(
            .getProduct(id: id)
        )
        return response.product.toDomain
    }
}
```

### iOS: UseCase Pattern

```swift
// Feature/Product/Domain/GetProductsUseCase.swift
final class GetProductsUseCase: Sendable {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(offset: Int, limit: Int) async throws -> [Product] {
        try await repository.getProducts(offset: offset, limit: limit)
    }
}
```

### iOS: Domain Error Pattern

```swift
// Core/Network/AppError.swift
enum AppError: Error, Equatable {
    case network(message: String = "Network error")
    case server(code: Int, message: String)
    case notFound(message: String = "Not found")
    case unauthorized(message: String = "Unauthorized")
    case unknown(message: String = "Unknown error")
}

extension Error {
    var toUserMessage: String {
        guard let appError = self as? AppError else {
            return "Bir hata oluştu. Lütfen tekrar deneyin."
        }
        switch appError {
        case .network: return "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin."
        case .server(let code, _): return "Sunucu hatası (\(code)). Lütfen tekrar deneyin."
        case .unauthorized: return "Oturum süreniz doldu. Lütfen tekrar giriş yapın."
        case .notFound: return "İçerik bulunamadı."
        case .unknown: return "Bir hata oluştu. Lütfen tekrar deneyin."
        }
    }
}
```

### iOS: Fake Repository for Tests

```swift
// MoltMarketplaceTests/Fakes/FakeProductRepository.swift
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

### Pagination Helper (Both Platforms)

All list screens use offset-based pagination with these rules:
- `offset`: starts at 0, incremented by `limit` each page
- `limit`: 20 items per page (Medusa default)
- `hasMore`: `true` if returned items count >= limit
- Trigger load more when last item becomes visible
- Show loading indicator at bottom during load more
- Keep existing data on load more failure

### File Checklist Per Feature

When implementing a feature, create these files in order:

**Android** (`android/app/src/main/java/com/molt/marketplace/feature/{name}/`):
1. `data/dto/{Name}Dto.kt` — `@Serializable` data class
2. `domain/model/{Name}.kt` — domain data class
3. `data/mapper/{Name}Mapper.kt` — DTO ↔ Domain
4. `domain/repository/{Name}Repository.kt` — interface
5. `data/remote/{Name}Api.kt` — Retrofit interface
6. `data/repository/{Name}RepositoryImpl.kt` — implementation
7. `domain/usecase/{Verb}{Name}UseCase.kt` — business logic
8. `presentation/state/{Screen}UiState.kt` — sealed interface
9. `presentation/viewmodel/{Screen}ViewModel.kt` — @HiltViewModel
10. `presentation/screen/{Screen}Screen.kt` — @Composable + @Preview
11. `di/{Name}Module.kt` — Hilt @Module

**iOS** (`ios/MoltMarketplace/Feature/{Name}/`):
1. `Data/{Name}DTO.swift` — Codable struct
2. `Domain/{Name}.swift` — domain struct
3. `Data/{Name}DTO+Extensions.swift` — DTO → Domain mapping
4. `Domain/{Name}Repository.swift` — protocol
5. `Data/{Name}Endpoint.swift` — API endpoint enum
6. `Data/{Name}RepositoryImpl.swift` — implementation
7. `Domain/{Verb}{Name}UseCase.swift` — business logic
8. `Presentation/{Screen}UiState.swift` — enum
9. `Presentation/{Screen}ViewModel.swift` — @Observable @MainActor
10. `Presentation/{Screen}View.swift` — SwiftUI View + #Preview
11. Register in `DependencyContainer.swift`

## Git Workflow

### Branch Naming

- `feature/m<phase>/<feature-name>` (e.g., `feature/m1/product-list`)
- `fix/m<phase>/<description>` (e.g., `fix/m1/login-validation`)
- `infra/<description>` (e.g., `infra/ci-android`)

### Commit Convention

Format: `<type>(<scope>): <description> [agent:<name>] [platform:<android|ios|both>]`

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `infra`, `chore`

Examples:
```
feat(product): implement product list screen [agent:android-dev] [platform:android]
feat(product): implement product list screen [agent:ios-dev] [platform:ios]
test(product): add product list unit tests [agent:android-test] [platform:android]
docs(product): add product list documentation [agent:doc] [platform:both]
```

### Merge Strategy

- **Feature → develop**: Squash merge
- **develop → main**: Merge commit

## Test Requirements

### Coverage Thresholds

- **Lines**: >= 80%
- **Functions**: >= 80%
- **Branches**: >= 70%

### Test Types

| Type | Android Location | iOS Location |
|------|-----------------|--------------|
| Unit (ViewModel) | `app/src/test/**/viewmodel/*Test.kt` | `MoltMarketplaceTests/**/ViewModel/*Tests.swift` |
| Unit (UseCase) | `app/src/test/**/usecase/*Test.kt` | `MoltMarketplaceTests/**/UseCase/*Tests.swift` |
| Unit (Repository) | `app/src/test/**/repository/*Test.kt` | `MoltMarketplaceTests/**/Repository/*Tests.swift` |
| UI | `app/src/androidTest/**/*Test.kt` | `MoltMarketplaceUITests/**/*UITests.swift` |

### Test Rules

- **Prefer fakes over mocks** (Google strongly recommended). Create `Fake{Name}Repository` classes that implement the interface with in-memory data. Use mocks (MockK/protocol mocks) only when fakes are impractical.
- **Never mock**: DI container, navigation, platform frameworks
- **Only mock/fake**: Network layer, time, local storage
- Each test is independent (no shared mutable state)
- **Test naming**: `test_<method>_<condition>_<expected>` or `fun methodName should expectedResult when condition`
- **Android**: Use `Turbine` for Flow testing, `composeTestRule` for UI testing, assert on `uiState.value` directly when possible
- **iOS**: Use `Swift Testing` framework with `@Test` macro, `ViewInspector` for SwiftUI testing

## Multi-Agent Pipeline (Claude Code Agent Teams)

### How It Works

This project uses **Claude Code Agent Teams** for feature implementation.
A team lead orchestrates specialized teammates, each a separate Claude Code session.

Enable: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `.claude/settings.local.json`

### Team Structure

| Teammate | Model | Responsibility | Skill Reference |
|----------|-------|----------------|-----------------|
| **Architect** | Opus | Feature spec, API mapping, UI wireframe | `.claude/skills/architect/` |
| **Android Dev** | Opus | Kotlin/Compose implementation | `.claude/skills/android-dev/` |
| **iOS Dev** | Opus | Swift/SwiftUI implementation | `.claude/skills/ios-dev/` |
| **Android Tester** | Sonnet | Android unit + UI tests | `.claude/skills/test-agent/` |
| **iOS Tester** | Sonnet | iOS unit + UI tests | `.claude/skills/test-agent/` |
| **Doc Writer** | Sonnet | Feature documentation | `.claude/skills/doc-agent/` |
| **Reviewer** | Opus | Cross-platform code review | `.claude/skills/review-agent/` |

### Pipeline Flow

```
Architect → [Android Dev ‖ iOS Dev] → [Android Tester ‖ iOS Tester] → Doc → Review → PR
```

(‖ = parallel — teammates work simultaneously)

### Running the Pipeline

Invoke: `/pipeline-run M1-06 product-list`

The team lead creates an agent team, spawns teammates, creates tasks with
dependencies, and coordinates the full lifecycle.

### Teammate Communication

- Teammates message each other directly (iOS Dev asks Android Dev about API usage)
- Reviewer sends change requests directly to the relevant developer
- Shared task list auto-unblocks downstream tasks when dependencies complete

### Handoff Protocol

1. Teammate completes work and commits: `<type>(<scope>): <desc> [agent:<name>] [platform:<platform>]`
2. Teammate creates handoff: `docs/pipeline/<feature>-<agent>.handoff.md`
3. Next teammate verifies artifacts before starting (auto-unblocked by task dependency)
4. Verification passes → teammate begins work

### Pipeline Rules

1. **Code-writing teammates always use Opus model.**
2. Every teammate produces a **handoff file**: `docs/pipeline/<feature>-<agent>.handoff.md`.
3. Next teammate validates previous artifacts before starting work.
4. Teammates commit with the `[agent:<name>]` and `[platform:<platform>]` suffixes.
5. Team lead handles git branch, push, and PR creation — teammates only commit.

## Documentation Requirements

- **Feature README**: `docs/features/<name>/README.md` (feature overview, architecture, screens)
- **API Integration**: `docs/api/<resource>.md` (endpoint mapping, request/response models)
- **Component Library**: `docs/components/<name>.md` (reusable components, usage examples)
- **ADR**: `docs/adr/ADR-NNN-<title>.md` (context, decision, consequences)
- **CHANGELOG**: Updated at end of each sprint milestone

## Key File Locations

### Shared (Cross-Platform)
- `CLAUDE.md` - This file (coding standards)
- `PROMPTS/BUYER_APP.md` - Full buyer app requirements
- `shared/api-contracts/` - Backend API endpoint definitions
- `shared/design-tokens/` - Design system tokens (colors, typography)
- `shared/feature-specs/` - Platform-agnostic feature specifications
- `scripts/feature-queue.jsonl` - Feature queue
- `docs/pipeline/` - Agent handoff files

### Android
- `android/app/src/main/java/com/molt/marketplace/` - Android source root
- `android/app/src/main/java/com/molt/marketplace/core/` - Core utilities, DI, network
- `android/app/src/main/java/com/molt/marketplace/feature/` - Feature modules
- `android/app/src/main/res/` - Android resources (strings, drawables, themes)
- `android/app/build.gradle.kts` - App-level Gradle configuration
- `android/build.gradle.kts` - Project-level Gradle configuration

### iOS
- `ios/MoltMarketplace/` - iOS source root
- `ios/MoltMarketplace/Core/` - Core utilities, DI, network
- `ios/MoltMarketplace/Feature/` - Feature modules
- `ios/MoltMarketplace/Resources/` - iOS resources (assets, localization)
- `ios/MoltMarketplace.xcodeproj/` - Xcode project file
- `ios/Package.swift` - Swift Package Manager dependencies

## Environment Configuration

### Android (BuildConfig)
```kotlin
// build.gradle.kts
android {
    buildTypes {
        debug {
            buildConfigField("String", "API_BASE_URL", "\"https://api-dev.molt.com\"")
        }
        release {
            buildConfigField("String", "API_BASE_URL", "\"https://api.molt.com\"")
        }
    }
}
```

### iOS (Config.xcconfig / Info.plist)
```swift
// Config.swift
enum Config {
    static let apiBaseURL: URL = {
        #if DEBUG
        return URL(string: "https://api-dev.molt.com")!
        #else
        return URL(string: "https://api.molt.com")!
        #endif
    }()
}
```

## Security Standards

### API Keys & Secrets
- **Never commit** API keys, tokens, or secrets to version control
- Use environment-specific configuration files (gitignored)
- Android: `local.properties` for local secrets
- iOS: `.xcconfig` files for local secrets
- Production secrets via CI/CD environment variables

### Authentication
- Store auth tokens securely:
  - Android: EncryptedSharedPreferences
  - iOS: Keychain Services
- Auto-refresh expired tokens via interceptor/middleware
- Clear tokens on logout or 401 Unauthorized

### Network Security
- Enforce HTTPS for all API calls
- Certificate pinning for production builds
- Android: Network Security Configuration
- iOS: App Transport Security (ATS)

## Accessibility Standards

### Android
- All interactive elements have `contentDescription`
- Minimum touch target size: 48dp × 48dp
- Support TalkBack screen reader
- Test with Accessibility Scanner
- Color contrast ratio >= 4.5:1 (WCAG AA)

### iOS
- All interactive elements have `accessibilityLabel`
- Minimum touch target size: 44pt × 44pt
- Support VoiceOver screen reader
- Test with Accessibility Inspector
- Support Dynamic Type (text scaling)

## Performance Standards

### Android
- App startup time (cold): < 2 seconds
- Screen navigation: < 300ms
- List scrolling: 60fps (16ms per frame)
- Image loading: Progressive (placeholder → thumbnail → full)
- Memory leaks: Zero detected by LeakCanary

### iOS
- App startup time (cold): < 2 seconds
- Screen navigation: < 300ms
- List scrolling: 60fps (16ms per frame)
- Image loading: Progressive with caching
- Memory leaks: Zero detected by Instruments

## Code Review Checklist

### Architecture
- [ ] Clean Architecture layers respected (Data → Domain → Presentation)
- [ ] No business logic in ViewModels or UI
- [ ] Repository pattern used for data access
- [ ] Use cases encapsulate business logic

### Code Quality
- [ ] No `Any` type (Kotlin) or force unwrap (Swift)
- [ ] All functions have explicit return types
- [ ] Immutable data models
- [ ] Proper error handling (no silent failures)
- [ ] No hardcoded strings or colors

### Testing
- [ ] Unit tests for ViewModels and UseCases
- [ ] UI tests for critical user flows
- [ ] Coverage >= 80% for new code
- [ ] All tests pass before merge

### UI/UX
- [ ] Follows design system (Material 3 / SwiftUI design)
- [ ] Responsive to different screen sizes
- [ ] Loading and error states implemented
- [ ] Accessibility labels present
- [ ] No hardcoded strings (all localized)

### Documentation
- [ ] Public APIs documented
- [ ] Complex logic explained with comments
- [ ] Feature README updated
- [ ] CHANGELOG updated

## Common Pitfalls

### Android (Kotlin + Compose)
- **Don't**: Put `viewModelScope.launch` in composables → **Do**: Use `LaunchedEffect`
- **Don't**: Use `GlobalScope` → **Do**: Use structured concurrency (viewModelScope)
- **Don't**: Pass ViewModels down the tree → **Do**: Hoist state, pass data and events
- **Don't**: Use `remember` for state that survives configuration changes → **Do**: Use ViewModel + StateFlow
- **Don't**: Access `Context` in ViewModels → **Do**: Inject dependencies via Hilt. Never use `AndroidViewModel`.

### iOS (Swift + SwiftUI)
- **Don't**: Use `@State` in ViewModels → **Do**: Use `@Published` in ObservableObject or `@Observable`
- **Don't**: Perform async work in view initializers → **Do**: Use `.task` or `.onAppear`
- **Don't**: Force unwrap optionals → **Do**: Use `guard let`, `if let`, or `??`
- **Don't**: Use `DispatchQueue.main.async` → **Do**: Use `@MainActor` and async/await
- **Don't**: Create retain cycles with `self` in closures → **Do**: Use `[weak self]` or `[unowned self]`

## Debugging Tools

### Android
- **Logcat**: Standard logging with Timber
- **Layout Inspector**: UI hierarchy debugging
- **Network Profiler**: API request/response inspection
- **LeakCanary**: Memory leak detection
- **Chucker**: HTTP traffic inspector (debug builds only)

### iOS
- **Console**: Standard logging with OSLog
- **View Hierarchy**: UI hierarchy debugging (Xcode)
- **Network Link Conditioner**: Network simulation
- **Instruments**: Performance profiling
- **Proxyman**: HTTP traffic inspector

## Continuous Integration

### Android CI Pipeline
1. Lint (ktlint + detekt)
2. Unit tests (JUnit)
3. Build debug APK
4. UI tests (on emulator)
5. Code coverage report
6. Build release APK (signed)

### iOS CI Pipeline
1. Lint (SwiftLint)
2. Unit tests (Swift Testing)
3. Build debug app
4. UI tests (on simulator)
5. Code coverage report
6. Build release IPA (signed)

### CI Requirements
- All checks must pass before merge
- Coverage must not decrease
- No new lint warnings
- Build succeeds for both debug and release

## Release Process

### Versioning
- Follow semantic versioning: `MAJOR.MINOR.PATCH`
- Increment MAJOR for breaking changes
- Increment MINOR for new features
- Increment PATCH for bug fixes

### Android Release
1. Update `versionCode` and `versionName` in `build.gradle.kts`
2. Update CHANGELOG.md
3. Create git tag: `android/v1.2.3`
4. Build signed release APK/AAB
5. Upload to Google Play Console (internal test → beta → production)

### iOS Release
1. Update version and build number in Xcode
2. Update CHANGELOG.md
3. Create git tag: `ios/v1.2.3`
4. Archive and upload to App Store Connect
5. Submit for review (TestFlight → App Store)

---

**Last Updated**: 2026-02-10
**Maintained By**: Molt Development Team
**Questions**: Refer to project lead or update this guide via PR
