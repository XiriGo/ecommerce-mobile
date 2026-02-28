# M1-04: Home Screen -- Feature Specification

## Overview

The Home Screen is the primary landing screen after onboarding/login. It displays a curated
vertical feed of sections: search bar, hero banner carousel, category icons, popular products,
daily deal, new arrivals, and flash sale banner. The screen uses Clean Architecture with a
repository pattern providing fake data initially and a clear path to Medusa API integration.

### User Stories

- As a **buyer**, I want to see featured banners so I discover promotions and new collections.
- As a **buyer**, I want to browse categories so I can quickly navigate to products I am interested in.
- As a **buyer**, I want to see popular products so I know what others are buying.
- As a **buyer**, I want to see a daily deal with a countdown so I know time-limited offers.
- As a **buyer**, I want to see new arrivals so I can discover recently added products.
- As a **buyer**, I want to search for products by tapping the search bar.
- As a **buyer**, I want to toggle wishlist on product cards so I can save products I like.
- As a **buyer**, I want to pull-to-refresh the home screen to get the latest content.
- As a **developer**, I want the home screen to use Clean Architecture so it is testable and maintainable.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Hero banner carousel with auto-scroll, pagination dots | Banner management admin |
| Category icon tiles (horizontal scroll) | Category CRUD |
| Popular products 2-column grid with wishlist button | Wishlist sync with backend (M2-02) |
| Daily Deal section with countdown timer | Backend deal scheduling |
| New Arrivals 2-column grid with delivery badge + add-to-cart FAB | Cart logic (M2-01) |
| Flash Sale promotional banner | Flash sale product filtering |
| Search bar (tap navigates to search screen) | Search implementation (M1-08) |
| Pull-to-refresh | Offline caching |
| Loading, Error, Empty states | Analytics events |
| Clean Architecture layers (domain, data, presentation) | Real API integration (future) |
| 6 new design system components | Bottom navigation changes |

### Dependencies on Other Features

| Feature | What This Feature Needs |
|---------|------------------------|
| M0-01: App Scaffold | Project structure, `XGTheme`, entry points |
| M0-02: Design System | `XGProductCard`, `XGImage`, `XGPriceText`, `XGRatingBar`, `XGBadge`, `XGLoadingView`, `XGErrorView`, `XGEmptyView` |
| M0-04: Navigation | `Route.ProductDetail`, `Route.ProductSearch`, `Route.CategoryProducts`, `AppRouter` |
| M0-05: DI Setup | DI container for repository binding |
| M4-05: App Onboarding | `XGPaginationDots` (reused for hero carousel and flash sale) |

### Features That Depend on This

| Feature | What It Reuses |
|---------|---------------|
| M1-06: Product List | `XGSectionHeader`, `XGWishlistButton` |
| M1-07: Product Detail | `XGWishlistButton` |
| M2-02: Wishlist | `XGWishlistButton` toggle state |
| M1-05: Category Browsing | `XGCategoryIcon` |

---

## 1. API Mapping

The home screen fetches data from multiple Medusa v2 endpoints. During the initial implementation,
a `FakeHomeRepository` provides hardcoded sample data. The repository interface is designed to
match the API shape so the transition to real API calls requires only swapping the implementation.

| Section | Method | Endpoint | Query Parameters | Notes |
|---------|--------|----------|------------------|-------|
| Banners | GET | /store/collections | `limit=5` | Collections with metadata for banner images. Initially fake. |
| Categories | GET | /store/product-categories | `limit=10` | Top-level categories. |
| Popular Products | GET | /store/products | `order=-sales&limit=6` | Sorted by sales descending. Custom field, may use tags. |
| Daily Deal | GET | /store/products/:id | `fields=+variants,+images` | Single product with deal metadata. Initially fake. |
| New Arrivals | GET | /store/products | `order=-created_at&limit=6` | Sorted by creation date descending. |
| Flash Sales | GET | /store/collections | `handle=flash-sale` | Collection metadata for flash sale banner. Initially fake. |

### Response Mapping

Products API response fields map to domain models:

| API Field | Domain Field | Notes |
|-----------|-------------|-------|
| `product.id` | `HomeProduct.id` | String identifier |
| `product.title` | `HomeProduct.title` | Product name |
| `product.thumbnail` | `HomeProduct.imageUrl` | Nullable URL string |
| `product.variants[0].prices[0].amount` | `HomeProduct.price` | In smallest unit (cents), convert to display format |
| `product.variants[0].prices[0].currency_code` | `HomeProduct.currencyCode` | e.g. "try", "usd" |
| `product.metadata.original_price` | `HomeProduct.originalPrice` | Nullable, for strikethrough display |
| `product.categories[0].name` | `HomeProduct.vendor` | Vendor name from metadata or first category |
| `product_category.id` | `HomeCategory.id` | String identifier |
| `product_category.name` | `HomeCategory.name` | Category label |
| `product_category.handle` | `HomeCategory.handle` | URL-safe slug |

---

## 2. Data Models

### 2.1 HomeBanner (Domain Model)

A single hero banner in the carousel.

**Android (Kotlin)**:

```
Data class: HomeBanner
Package: com.xirigo.ecommerce.feature.home.domain.model

Properties:
  - id: String                    -- unique banner identifier
  - title: String                 -- headline text (e.g. "Urban Fashion Collection")
  - subtitle: String              -- supporting text (e.g. "Explore the latest trends")
  - imageUrl: String?             -- product photo URL for background (nullable, gradient fallback)
  - tag: String?                  -- optional badge text (e.g. "NEW SEASON")
  - actionProductId: String?      -- product ID for navigation on tap (nullable)
  - actionCategoryId: String?     -- category ID for navigation on tap (nullable)
```

**iOS (Swift)**:

```
Struct: HomeBanner
File: HomeBanner.swift (in Feature/Home/Domain/Model/)
Conforms to: Identifiable, Equatable, Sendable

Properties:
  - let id: String
  - let title: String
  - let subtitle: String
  - let imageUrl: String?
  - let tag: String?
  - let actionProductId: String?
  - let actionCategoryId: String?
```

### 2.2 HomeCategory (Domain Model)

A category tile displayed in the horizontal scroll row.

**Android (Kotlin)**:

```
Data class: HomeCategory
Package: com.xirigo.ecommerce.feature.home.domain.model

Properties:
  - id: String                    -- category ID
  - name: String                  -- display name
  - handle: String                -- URL slug for API calls
  - iconName: String              -- icon identifier (SF Symbol name or Material icon name)
  - colorHex: String              -- background color hex from category color tokens
```

**iOS (Swift)**:

```
Struct: HomeCategory
File: HomeCategory.swift (in Feature/Home/Domain/Model/)
Conforms to: Identifiable, Equatable, Sendable

Properties:
  - let id: String
  - let name: String
  - let handle: String
  - let iconName: String
  - let colorHex: String
```

### 2.3 HomeProduct (Domain Model)

A product displayed in Popular Products or New Arrivals sections.

**Android (Kotlin)**:

```
Data class: HomeProduct
Package: com.xirigo.ecommerce.feature.home.domain.model

Properties:
  - id: String                    -- product ID
  - title: String                 -- product name (max 2 lines in UI)
  - imageUrl: String?             -- thumbnail URL
  - price: String                 -- formatted price string (e.g. "79.99")
  - currencyCode: String          -- currency code (e.g. "try", "usd")
  - originalPrice: String?        -- nullable, for strikethrough display
  - vendor: String                -- vendor/store name
  - rating: Float?                -- average rating (0.0-5.0), nullable for new products
  - reviewCount: Int?             -- number of reviews, nullable
  - isNew: Boolean                -- true for new arrivals (shows delivery badge)
```

**iOS (Swift)**:

```
Struct: HomeProduct
File: HomeProduct.swift (in Feature/Home/Domain/Model/)
Conforms to: Identifiable, Equatable, Sendable

Properties:
  - let id: String
  - let title: String
  - let imageUrl: String?
  - let price: String
  - let currencyCode: String
  - let originalPrice: String?
  - let vendor: String
  - let rating: Double?
  - let reviewCount: Int?
  - let isNew: Bool
```

### 2.4 DailyDeal (Domain Model)

The daily deal section with countdown timer.

**Android (Kotlin)**:

```
Data class: DailyDeal
Package: com.xirigo.ecommerce.feature.home.domain.model

Properties:
  - productId: String             -- product ID for navigation
  - title: String                 -- product name (e.g. "Nike Air Zoom Pegasus")
  - imageUrl: String?             -- product image URL
  - price: String                 -- deal price (formatted)
  - originalPrice: String         -- original price (formatted, for strikethrough)
  - currencyCode: String          -- currency code
  - endTime: Long                 -- epoch millis when deal expires
```

**iOS (Swift)**:

```
Struct: DailyDeal
File: DailyDeal.swift (in Feature/Home/Domain/Model/)
Conforms to: Equatable, Sendable

Properties:
  - let productId: String
  - let title: String
  - let imageUrl: String?
  - let price: String
  - let originalPrice: String
  - let currencyCode: String
  - let endTime: Date
```

### 2.5 FlashSale (Domain Model)

Flash sale promotional banner data.

**Android (Kotlin)**:

```
Data class: FlashSale
Package: com.xirigo.ecommerce.feature.home.domain.model

Properties:
  - id: String                    -- flash sale identifier
  - title: String                 -- banner title text
  - imageUrl: String?             -- promotional image URL (nullable)
  - actionUrl: String?            -- deep link or collection URL (nullable)
```

**iOS (Swift)**:

```
Struct: FlashSale
File: FlashSale.swift (in Feature/Home/Domain/Model/)
Conforms to: Identifiable, Equatable, Sendable

Properties:
  - let id: String
  - let title: String
  - let imageUrl: String?
  - let actionUrl: String?
```

### 2.6 HomeUiState (Presentation State)

**Android (Kotlin)**:

```
Sealed interface: HomeUiState
Package: com.xirigo.ecommerce.feature.home.presentation.state

Cases:
  - Loading                       -- initial load, show shimmer/skeleton
  - Success(data: HomeScreenData) -- all sections loaded
  - Error(message: String)        -- load failed, show error view with retry

Data class: HomeScreenData
Properties:
  - banners: List<HomeBanner>
  - categories: List<HomeCategory>
  - popularProducts: List<HomeProduct>
  - dailyDeal: DailyDeal?
  - newArrivals: List<HomeProduct>
  - flashSale: FlashSale?
  - wishedProductIds: Set<String>
```

**iOS (Swift)**:

```
Enum: HomeUiState
File: HomeUiState.swift (in Feature/Home/Presentation/State/)
Conforms to: Equatable, Sendable

Cases:
  - loading
  - success(data: HomeScreenData)
  - error(message: String)

Struct: HomeScreenData
Conforms to: Equatable, Sendable
Properties:
  - let banners: [HomeBanner]
  - let categories: [HomeCategory]
  - let popularProducts: [HomeProduct]
  - let dailyDeal: DailyDeal?
  - let newArrivals: [HomeProduct]
  - let flashSale: FlashSale?
  - let wishedProductIds: Set<String>
```

### 2.7 HomeEvent (Presentation Events)

**Android (Kotlin)**:

```
Sealed interface: HomeEvent
Package: com.xirigo.ecommerce.feature.home.presentation.state

Cases:
  - Refresh                                      -- pull-to-refresh triggered
  - BannerTapped(banner: HomeBanner)             -- user tapped a hero banner
  - CategoryTapped(category: HomeCategory)       -- user tapped a category
  - ProductTapped(productId: String)             -- user tapped a product card
  - WishlistToggled(productId: String)           -- user toggled wishlist heart
  - DailyDealTapped(productId: String)           -- user tapped daily deal
  - SeeAllPopularTapped                          -- "See All" on popular section
  - SeeAllNewArrivalsTapped                      -- "See All" on new arrivals section
  - SearchBarTapped                              -- user tapped search bar
  - RetryTapped                                  -- user tapped retry on error state
```

**iOS (Swift)**:

```
Enum: HomeEvent
File: HomeEvent.swift (in Feature/Home/Presentation/State/)
Conforms to: Equatable, Sendable

Cases:
  - refresh
  - bannerTapped(HomeBanner)
  - categoryTapped(HomeCategory)
  - productTapped(productId: String)
  - wishlistToggled(productId: String)
  - dailyDealTapped(productId: String)
  - seeAllPopularTapped
  - seeAllNewArrivalsTapped
  - searchBarTapped
  - retryTapped
```

---

## 3. Architecture

### 3.1 Clean Architecture Layers

```
HomeScreen
    |
    v
HomeViewModel
    |
    v
GetHomeBannersUseCase / GetHomeCategoriesUseCase / GetPopularProductsUseCase
GetDailyDealUseCase / GetNewArrivalsUseCase / GetFlashSaleUseCase
    |
    v
HomeRepository (interface)
    |
    v
FakeHomeRepository (initial) / HomeRepositoryImpl (future, Medusa API)
```

### 3.2 Domain Layer

#### HomeRepository Interface

**Android (Kotlin)**:

```
Interface: HomeRepository
Package: com.xirigo.ecommerce.feature.home.domain.repository

Methods:
  - suspend fun getBanners(): List<HomeBanner>
  - suspend fun getCategories(): List<HomeCategory>
  - suspend fun getPopularProducts(): List<HomeProduct>
  - suspend fun getDailyDeal(): DailyDeal?
  - suspend fun getNewArrivals(): List<HomeProduct>
  - suspend fun getFlashSale(): FlashSale?
```

**iOS (Swift)**:

```
Protocol: HomeRepository
File: HomeRepository.swift (in Feature/Home/Domain/Repository/)
Conforms to: Sendable

Methods:
  - func getBanners() async throws -> [HomeBanner]
  - func getCategories() async throws -> [HomeCategory]
  - func getPopularProducts() async throws -> [HomeProduct]
  - func getDailyDeal() async throws -> DailyDeal?
  - func getNewArrivals() async throws -> [HomeProduct]
  - func getFlashSale() async throws -> FlashSale?
```

#### Use Cases

Each section has its own use case for single-responsibility:

**GetHomeBannersUseCase**:

```
Android:
  Class: GetHomeBannersUseCase
  Package: com.xirigo.ecommerce.feature.home.domain.usecase
  Constructor: @Inject constructor(private val repository: HomeRepository)
  Method: suspend operator fun invoke(): List<HomeBanner> = repository.getBanners()

iOS:
  Struct: GetHomeBannersUseCase
  File: GetHomeBannersUseCase.swift
  Conforms to: Sendable
  Property: private let repository: HomeRepository
  Method: func execute() async throws -> [HomeBanner]
```

**GetHomeCategoriesUseCase**:

```
Android:
  Class: GetHomeCategoriesUseCase
  Package: com.xirigo.ecommerce.feature.home.domain.usecase
  Constructor: @Inject constructor(private val repository: HomeRepository)
  Method: suspend operator fun invoke(): List<HomeCategory> = repository.getCategories()

iOS:
  Struct: GetHomeCategoriesUseCase
  File: GetHomeCategoriesUseCase.swift
  Conforms to: Sendable
  Property: private let repository: HomeRepository
  Method: func execute() async throws -> [HomeCategory]
```

**GetPopularProductsUseCase**:

```
Android:
  Class: GetPopularProductsUseCase
  Package: com.xirigo.ecommerce.feature.home.domain.usecase
  Constructor: @Inject constructor(private val repository: HomeRepository)
  Method: suspend operator fun invoke(): List<HomeProduct> = repository.getPopularProducts()

iOS:
  Struct: GetPopularProductsUseCase
  File: GetPopularProductsUseCase.swift
  Conforms to: Sendable
  Property: private let repository: HomeRepository
  Method: func execute() async throws -> [HomeProduct]
```

**GetDailyDealUseCase**:

```
Android:
  Class: GetDailyDealUseCase
  Package: com.xirigo.ecommerce.feature.home.domain.usecase
  Constructor: @Inject constructor(private val repository: HomeRepository)
  Method: suspend operator fun invoke(): DailyDeal? = repository.getDailyDeal()

iOS:
  Struct: GetDailyDealUseCase
  File: GetDailyDealUseCase.swift
  Conforms to: Sendable
  Property: private let repository: HomeRepository
  Method: func execute() async throws -> DailyDeal?
```

**GetNewArrivalsUseCase**:

```
Android:
  Class: GetNewArrivalsUseCase
  Package: com.xirigo.ecommerce.feature.home.domain.usecase
  Constructor: @Inject constructor(private val repository: HomeRepository)
  Method: suspend operator fun invoke(): List<HomeProduct> = repository.getNewArrivals()

iOS:
  Struct: GetNewArrivalsUseCase
  File: GetNewArrivalsUseCase.swift
  Conforms to: Sendable
  Property: private let repository: HomeRepository
  Method: func execute() async throws -> [HomeProduct]
```

**GetFlashSaleUseCase**:

```
Android:
  Class: GetFlashSaleUseCase
  Package: com.xirigo.ecommerce.feature.home.domain.usecase
  Constructor: @Inject constructor(private val repository: HomeRepository)
  Method: suspend operator fun invoke(): FlashSale? = repository.getFlashSale()

iOS:
  Struct: GetFlashSaleUseCase
  File: GetFlashSaleUseCase.swift
  Conforms to: Sendable
  Property: private let repository: HomeRepository
  Method: func execute() async throws -> FlashSale?
```

### 3.3 Data Layer

#### FakeHomeRepository

Provides hardcoded sample data. This is the implementation used during initial development.
It replaces the existing inline sample data in the current HomeScreen files.

**Android (Kotlin)**:

```
Class: FakeHomeRepository
Package: com.xirigo.ecommerce.feature.home.data.repository
Implements: HomeRepository

Methods:
  All methods return hardcoded sample data equivalent to the current
  inline sample data in HomeScreen.kt (popularProducts, newProducts,
  banners, categories) plus new daily deal and flash sale data.

  - suspend fun getBanners(): List<HomeBanner>
    Returns 3 banners with localized titles from string resources.

  - suspend fun getCategories(): List<HomeCategory>
    Returns 6 categories: Electronics, Fashion, Home, Sports, Books, Gaming.
    Colors cycle through category color tokens (#37B4F2, #FE75D4, #FDF29C, #90D3B1, #FEF170).

  - suspend fun getPopularProducts(): List<HomeProduct>
    Returns 4 products matching existing sample data (headphones, sneakers, watch, backpack).

  - suspend fun getDailyDeal(): DailyDeal?
    Returns a single deal product with endTime = current time + 8 hours.

  - suspend fun getNewArrivals(): List<HomeProduct>
    Returns 6 products (extends existing 3 to fill a 2-column grid).

  - suspend fun getFlashSale(): FlashSale?
    Returns a single flash sale banner with localized title.
```

**iOS (Swift)**:

```
Final class: FakeHomeRepository
File: FakeHomeRepository.swift (in Feature/Home/Data/Repository/)
Conforms to: HomeRepository, Sendable

Same structure as Android, returning equivalent hardcoded data.
```

**Important**: The existing `HomeScreenSampleData.swift` file and inline sample data in
`HomeScreen.kt` will be deleted once the ViewModel + FakeRepository are wired up.

### 3.4 Presentation Layer

#### HomeViewModel

**Android (Kotlin)**:

```
Class: HomeViewModel
Package: com.xirigo.ecommerce.feature.home.presentation.viewmodel
Annotation: @HiltViewModel
Constructor: @Inject constructor(
    private val getBanners: GetHomeBannersUseCase,
    private val getCategories: GetHomeCategoriesUseCase,
    private val getPopularProducts: GetPopularProductsUseCase,
    private val getDailyDeal: GetDailyDealUseCase,
    private val getNewArrivals: GetNewArrivalsUseCase,
    private val getFlashSale: GetFlashSaleUseCase
)

State:
  - private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
  - val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

  - private val _currentBannerPage = MutableStateFlow(0)
  - val currentBannerPage: StateFlow<Int> = _currentBannerPage.asStateFlow()

  - private val _isRefreshing = MutableStateFlow(false)
  - val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

Init:
  - loadHomeData()

Methods:
  - fun onEvent(event: HomeEvent)
    when (event) {
        is HomeEvent.Refresh -> refresh()
        is HomeEvent.BannerTapped -> { /* navigation handled by screen */ }
        is HomeEvent.CategoryTapped -> { /* navigation handled by screen */ }
        is HomeEvent.ProductTapped -> { /* navigation handled by screen */ }
        is HomeEvent.WishlistToggled -> toggleWishlist(event.productId)
        is HomeEvent.DailyDealTapped -> { /* navigation handled by screen */ }
        is HomeEvent.RetryTapped -> loadHomeData()
        else -> { /* navigation events handled by screen */ }
    }

  - private fun loadHomeData()
    viewModelScope.launch {
        _uiState.value = HomeUiState.Loading
        try {
            val banners = async { getBanners() }
            val categories = async { getCategories() }
            val popular = async { getPopularProducts() }
            val deal = async { getDailyDeal() }
            val arrivals = async { getNewArrivals() }
            val flash = async { getFlashSale() }

            _uiState.value = HomeUiState.Success(
                data = HomeScreenData(
                    banners = banners.await(),
                    categories = categories.await(),
                    popularProducts = popular.await(),
                    dailyDeal = deal.await(),
                    newArrivals = arrivals.await(),
                    flashSale = flash.await(),
                    wishedProductIds = emptySet()
                )
            )
        } catch (e: Exception) {
            _uiState.value = HomeUiState.Error(
                message = e.message ?: "An error occurred"
            )
        }
    }

  - private fun refresh()
    viewModelScope.launch {
        _isRefreshing.value = true
        loadHomeData()  // reloads all data
        _isRefreshing.value = false
    }

  - private fun toggleWishlist(productId: String)
    val current = (_uiState.value as? HomeUiState.Success)?.data ?: return
    val updatedIds = if (productId in current.wishedProductIds) {
        current.wishedProductIds - productId
    } else {
        current.wishedProductIds + productId
    }
    _uiState.value = HomeUiState.Success(
        data = current.copy(wishedProductIds = updatedIds)
    )

  - fun onBannerPageChanged(page: Int)
    _currentBannerPage.value = page
```

**iOS (Swift)**:

```
@MainActor @Observable
Final class: HomeViewModel
File: HomeViewModel.swift (in Feature/Home/Presentation/ViewModel/)

Properties:
  - private let getBanners: GetHomeBannersUseCase
  - private let getCategories: GetHomeCategoriesUseCase
  - private let getPopularProducts: GetPopularProductsUseCase
  - private let getDailyDeal: GetDailyDealUseCase
  - private let getNewArrivals: GetNewArrivalsUseCase
  - private let getFlashSale: GetFlashSaleUseCase

  - private(set) var uiState: HomeUiState = .loading
  - var currentBannerPage: Int = 0
  - private(set) var isRefreshing: Bool = false

Init:
  - init(getBanners:, getCategories:, getPopularProducts:, getDailyDeal:, getNewArrivals:, getFlashSale:)

Methods:
  - func loadHomeData() async
    uiState = .loading
    do {
        async let bannersResult = getBanners.execute()
        async let categoriesResult = getCategories.execute()
        async let popularResult = getPopularProducts.execute()
        async let dealResult = getDailyDeal.execute()
        async let arrivalsResult = getNewArrivals.execute()
        async let flashResult = getFlashSale.execute()

        let data = HomeScreenData(
            banners: try await bannersResult,
            categories: try await categoriesResult,
            popularProducts: try await popularResult,
            dailyDeal: try await dealResult,
            newArrivals: try await arrivalsResult,
            flashSale: try await flashResult,
            wishedProductIds: []
        )
        uiState = .success(data: data)
    } catch {
        uiState = .error(message: error.localizedDescription)
    }

  - func onEvent(_ event: HomeEvent)
    switch event {
    case .refresh: Task { await refresh() }
    case .wishlistToggled(let productId): toggleWishlist(productId)
    case .retryTapped: Task { await loadHomeData() }
    default: break  // navigation events handled by screen
    }

  - func refresh() async
    isRefreshing = true
    await loadHomeData()
    isRefreshing = false

  - private func toggleWishlist(_ productId: String)
    guard case .success(var data) = uiState else { return }
    if data.wishedProductIds.contains(productId) {
        data.wishedProductIds.remove(productId)
    } else {
        data.wishedProductIds.insert(productId)
    }
    uiState = .success(data: data)
```

### 3.5 DI Registration

**Android (Hilt)**:

```
Module: HomeModule
Package: com.xirigo.ecommerce.feature.home.di
Annotations: @Module, @InstallIn(SingletonComponent::class)

Bindings:
  @Binds @Singleton
  fun bindHomeRepository(impl: FakeHomeRepository): HomeRepository
```

**iOS (Factory)**:

```
Extension on Container (in Container+Home.swift):

  var homeRepository: Factory<HomeRepository> {
      self { FakeHomeRepository() }.singleton
  }

  var getHomeBannersUseCase: Factory<GetHomeBannersUseCase> {
      self { GetHomeBannersUseCase(repository: self.homeRepository()) }
  }

  var getHomeCategoriesUseCase: Factory<GetHomeCategoriesUseCase> {
      self { GetHomeCategoriesUseCase(repository: self.homeRepository()) }
  }

  var getPopularProductsUseCase: Factory<GetPopularProductsUseCase> {
      self { GetPopularProductsUseCase(repository: self.homeRepository()) }
  }

  var getDailyDealUseCase: Factory<GetDailyDealUseCase> {
      self { GetDailyDealUseCase(repository: self.homeRepository()) }
  }

  var getNewArrivalsUseCase: Factory<GetNewArrivalsUseCase> {
      self { GetNewArrivalsUseCase(repository: self.homeRepository()) }
  }

  var getFlashSaleUseCase: Factory<GetFlashSaleUseCase> {
      self { GetFlashSaleUseCase(repository: self.homeRepository()) }
  }

  var homeViewModel: Factory<HomeViewModel> {
      self { HomeViewModel(
          getBanners: self.getHomeBannersUseCase(),
          getCategories: self.getHomeCategoriesUseCase(),
          getPopularProducts: self.getPopularProductsUseCase(),
          getDailyDeal: self.getDailyDealUseCase(),
          getNewArrivals: self.getNewArrivalsUseCase(),
          getFlashSale: self.getFlashSaleUseCase()
      )}
  }
```

---

## 4. New Design System Components

Six new components are added to `core/designsystem/component/`. These are reusable across
features and follow the `XG*` naming convention.

### 4.1 XGHeroBanner

Displays a hero banner card with an async image background, gradient overlay, tag badge,
headline text, and subtitle.

**Token Source**: `components.json > XGCard.heroBanner`, `gradients.json > heroBannerOverlay`

**Visual Spec**:
- Width: full width (350dp design reference)
- Height: 192dp
- Corner radius: 10dp (`cornerRadius.medium`)
- Background: async product image, fallback to `XGBrandGradient`
- Overlay: linear gradient from left (`#6000FE` 90% opacity) to right (`#6000FE` 0% opacity)
- Tag badge (optional): top-left, `$brand.secondary` bg (#94D63A), `$brand.primary` text (#6000FE), 12sp semiBold
- Headline: bottom-left, 24sp semiBold, white
- Subtitle: below headline, 14sp regular, white

**API**:

```
Android:
  @Composable
  fun XGHeroBanner(
      title: String,
      subtitle: String,
      modifier: Modifier = Modifier,
      imageUrl: String? = null,
      tag: String? = null,
      onClick: (() -> Unit)? = null,
  )

iOS:
  struct XGHeroBanner: View {
      let title: String
      let subtitle: String
      var imageUrl: URL? = nil
      var tag: String? = nil
      var action: (() -> Void)? = nil
  }
```

**Implementation Notes**:
- Image loads asynchronously via `XGImage` (Android: Coil, iOS: AsyncImage wrapper).
- When `imageUrl` is nil, fall back to a `XGBrandGradient` fill.
- The gradient overlay is always applied on top of the image.
- Text content is positioned at bottom-leading with padding `XGSpacing.base` (16dp).
- Tag badge positioned at top-leading with padding `XGSpacing.md` (12dp).
- `onClick` makes the entire card tappable.

### 4.2 XGCategoryIcon

A colored rounded-rectangle tile with an icon and label below.

**Token Source**: `components.json > XGCategoryIcon`

**Visual Spec**:
- Tile size: 79x79dp
- Corner radius: 10dp (`cornerRadius.medium`)
- Background: one of category colors (#37B4F2, #FE75D4, #FDF29C, #90D3B1, #FEF170)
- Icon: 40dp, centered in tile, white or dark depending on background
- Label: below tile, 12sp medium, `$light.textPrimary`, spacing 6dp from tile
- Label max lines: 1, ellipsis overflow

**API**:

```
Android:
  @Composable
  fun XGCategoryIcon(
      name: String,
      icon: ImageVector,
      backgroundColor: Color,
      onClick: () -> Unit,
      modifier: Modifier = Modifier,
  )

iOS:
  struct XGCategoryIcon: View {
      let name: String
      let systemIconName: String
      let backgroundColor: Color
      let action: () -> Void
  }
```

**Implementation Notes**:
- Icon color should use contrast detection: white for dark backgrounds, dark for light backgrounds.
  For simplicity in the initial implementation, use white icons on all category colors since the
  provided category colors are all medium-brightness pastels. Revisit if contrast issues arise.
- Minimum touch target: 48dp (the 79dp tile exceeds this).
- Accessibility label is the category `name`.

### 4.3 XGSectionHeader

Section title with optional subtitle and optional "See All" action link.

**Token Source**: `typography.json > typeScale.subtitle` (18sp semiBold)

**Visual Spec**:
- Title: 18sp semiBold, `$light.textPrimary`
- Subtitle (optional): 14sp regular, `$light.textSecondary`, below title
- "See All" action (optional): right-aligned, 14sp medium, `$brand.primary` (#6000FE), with trailing arrow icon
- Horizontal padding: `screenPaddingHorizontal` (20dp) -- applied internally
- Vertical padding: 0 (caller controls spacing)

**API**:

```
Android:
  @Composable
  fun XGSectionHeader(
      title: String,
      modifier: Modifier = Modifier,
      subtitle: String? = null,
      onSeeAllClick: (() -> Unit)? = null,
  )

iOS:
  struct XGSectionHeader: View {
      let title: String
      var subtitle: String? = nil
      var onSeeAllAction: (() -> Void)? = nil
  }
```

**Implementation Notes**:
- Replaces the inline `sectionHeader()` helper in both existing HomeScreen files.
- When `onSeeAllClick`/`onSeeAllAction` is non-null, shows "See All" text with a small
  trailing arrow icon. The "See All" text uses localized string key `common_see_all`.
- The "See All" button must have a minimum touch target of 48dp.

### 4.4 XGWishlistButton

A heart icon toggle button overlaid on product cards.

**Token Source**: `components.json > XGWishlistButton`

**Visual Spec**:
- Size: 32x32dp
- Icon size: 16dp
- Corner radius: 16dp (circle)
- Background: `$light.surface` (#FFFFFF) with elevation level 2
- Active icon: filled heart, `$brand.primary` (#6000FE)
- Inactive icon: outlined heart, `$light.textSecondary` (#8E8E93)

**API**:

```
Android:
  @Composable
  fun XGWishlistButton(
      isWishlisted: Boolean,
      onToggle: () -> Unit,
      modifier: Modifier = Modifier,
  )

iOS:
  struct XGWishlistButton: View {
      let isWishlisted: Bool
      let onToggle: () -> Void
  }
```

**Implementation Notes**:
- This component extracts the existing `WishlistButton` from `XGCard.kt` and the implicit
  wishlist logic in `XGCard.swift` into a standalone design system component.
- The existing `XGProductCard` should be updated to use `XGWishlistButton` internally instead
  of its own inline implementation.
- Accessibility: toggles between "Add to wishlist" and "Remove from wishlist" content descriptions.
- Uses localized strings `common_add_to_wishlist` and `common_remove_from_wishlist` (already exist).

### 4.5 XGDailyDealCard

A gradient card displaying the daily deal with countdown timer and product info.

**Token Source**: `components.json > XGCard.dailyDeal`, `gradients.json > dailyDealCard`

**Visual Spec**:
- Width: full width (350dp design reference)
- Height: 163dp
- Corner radius: 10dp (`cornerRadius.medium`)
- Background: linear gradient left-to-right from `#111827` to `#6000FE`
- Layout: horizontal split -- left side has text content, right side has product image
- Badge: "DAILY DEAL", `$brand.secondary` bg (#94D63A), `$brand.primary` text (#6000FE), 12sp semiBold
- Title: 20sp semiBold, white
- Countdown: 12sp regular, white, format "HH:MM:SS"
- Price: `XGPriceText` deal variant, `$semantic.priceDeal` color (#94D63A)
- Original price: strikethrough, `$semantic.priceStrikethrough` (#8E8E93)

**API**:

```
Android:
  @Composable
  fun XGDailyDealCard(
      title: String,
      price: String,
      originalPrice: String,
      endTime: Long,
      modifier: Modifier = Modifier,
      imageUrl: String? = null,
      onClick: (() -> Unit)? = null,
  )

iOS:
  struct XGDailyDealCard: View {
      let title: String
      let price: String
      let originalPrice: String
      let endTime: Date
      var imageUrl: URL? = nil
      var action: (() -> Void)? = nil
  }
```

**Implementation Notes**:
- **Countdown timer**: Uses a timer that ticks every second. On Android: `LaunchedEffect` with
  `delay(1000)` loop reading `System.currentTimeMillis()`. On iOS: `TimelineView(.periodic(from:, by: 1))`
  or `Timer.publish(every: 1, on: .main, in: .common)`.
- Countdown format: `String.format("%02d:%02d:%02d", hours, minutes, seconds)`.
- When countdown reaches zero, display "ENDED" text instead of timer.
- Product image on the right side: aspect ratio 1:1, rounded corners, loaded via `XGImage`.
- The badge text "DAILY DEAL" uses localized string key `home_daily_deal_badge`.

### 4.6 XGFlashSaleBanner

A promotional banner card with accent stripes for flash sale events.

**Token Source**: `components.json > XGCard.flashSale`, `colors.json > flashSale`

**Visual Spec**:
- Width: full width (350dp design reference)
- Height: 133dp
- Corner radius: 10dp (`cornerRadius.medium`)
- Background: `$flashSale.background` (#FFD814, bright yellow)
- Left accent stripe: `$flashSale.accentBlue` (#9EBDF4), diagonal
- Right accent stripe: `$flashSale.accentPink` (#F60186), diagonal
- Text color: `$flashSale.text` (#1D1D1B, near-black)
- Title text: centered, bold
- Promotional image/illustration area (optional)

**API**:

```
Android:
  @Composable
  fun XGFlashSaleBanner(
      title: String,
      modifier: Modifier = Modifier,
      imageUrl: String? = null,
      onClick: (() -> Unit)? = null,
  )

iOS:
  struct XGFlashSaleBanner: View {
      let title: String
      var imageUrl: URL? = nil
      var action: (() -> Void)? = nil
  }
```

**Implementation Notes**:
- The accent stripes are decorative diagonal shapes drawn with `Canvas` (Android) or `Shape`/`Path` (iOS).
- The left stripe is a parallelogram on the left edge, the right stripe is on the right edge.
- The banner is tappable when `onClick`/`action` is provided.
- Accessibility label combines the title with "Flash Sale" context.

---

## 5. Existing Component Updates

### 5.1 XGProductCard Updates

The existing `XGProductCard` in both platforms needs the following additions:

| Addition | Description |
|----------|-------------|
| `deliveryLabel` parameter | Optional `String?` for delivery badge text (e.g. "Order before 23:59, delivered Monday") |
| `onAddToCartClick` parameter | Optional `(() -> Unit)?` / `(() -> Void)?` for add-to-cart FAB button |
| Use `XGWishlistButton` | Replace inline wishlist button implementation with the new `XGWishlistButton` component |

**Updated API** (additions only, existing params unchanged):

```
Android:
  @Composable
  fun XGProductCard(
      // ... existing params ...
      deliveryLabel: String? = null,
      onAddToCartClick: (() -> Unit)? = null,
  )

iOS:
  struct XGProductCard: View {
      // ... existing params ...
      var deliveryLabel: String? = nil
      var onAddToCartAction: (() -> Void)? = nil
  }
```

**Delivery Badge**: Displayed below the rating bar. Uses `XGBadge.delivery` variant:
`$semantic.deliveryText` color (#94D63A), 10sp regular. The bold part (day name) uses
`boldPartFontWeight: bold`.

**Add-to-Cart FAB**: Displayed at bottom-right of the card when `onAddToCartClick` is non-null.
Size: 32x32dp, corner radius 16dp (circle), background `$semantic.addToCart` (#94D63A),
icon: white plus/cart icon, 16dp.

### 5.2 XGPaginationDots (Already Exists)

`XGPaginationDots` already exists in both platforms from the onboarding pipeline. **Do NOT
recreate this component.** Reuse it directly for the hero banner carousel and flash sale banner.

Existing API (verified):
- Android: `XGPaginationDots(totalPages: Int, currentPage: Int, modifier: Modifier, activeColor: Color, inactiveColor: Color)`
- iOS: Equivalent `XGPaginationDots` view

---

## 6. Screen Layout

The home screen is a vertical scrollable list with sections in this order (top to bottom):

| # | Section | Component | Layout |
|---|---------|-----------|--------|
| 1 | Search Bar | Inline (existing) | Full width, tap navigates to search |
| 2 | Hero Banner Carousel | `XGHeroBanner` + `XGPaginationDots` | Full width pager, auto-scroll 5s |
| 3 | Categories | `XGCategoryIcon` | Horizontal scroll row |
| 4 | Popular Products | `XGSectionHeader` + `XGProductCard` | 2-column grid, "See All" action |
| 5 | Daily Deal | `XGSectionHeader` + `XGDailyDealCard` | Full width card |
| 6 | New Arrivals | `XGSectionHeader` + `XGProductCard` | 2-column grid, "See All" action, delivery badge + add-to-cart |
| 7 | Flash Sale Banner | `XGFlashSaleBanner` | Full width promotional card |

### Section Spacing

All sections are separated by `XGSpacing.SectionSpacing` (24dp), matching the existing
implementation.

### Hero Banner Auto-Scroll Behavior

- Auto-scrolls to the next banner every 5 seconds.
- Pauses auto-scroll when the user is manually swiping.
- Resumes auto-scroll 3 seconds after the user stops interacting.
- Loops back to the first banner after the last one.
- Android: `HorizontalPager` with `LaunchedEffect` timer.
- iOS: `TabView` with `.tabViewStyle(.page)` or `ScrollView` with `scrollPosition` and `Timer`.

### Pull-to-Refresh

- Android: `pullToRefresh` modifier (Material 3) wrapping the scroll content.
- iOS: `.refreshable { await viewModel.refresh() }` modifier on `ScrollView`.
- Triggers `HomeEvent.Refresh` which reloads all sections.

---

## 7. Screen States

### 7.1 Loading State

- Show a shimmer/skeleton placeholder layout matching the content structure.
- Skeleton sections: search bar placeholder, banner placeholder (rounded rect), category circles,
  product card placeholders (2x2 grid).
- Use `XGLoadingView` inline variant for skeleton shapes.

### 7.2 Success State

- Render all sections with data from `HomeScreenData`.
- Sections with null data (e.g. `dailyDeal == null`) are hidden, not shown as empty.
- Sections with empty lists are hidden.

### 7.3 Error State

- Show `XGErrorView` with the error message and a "Retry" button.
- Retry triggers `HomeEvent.RetryTapped` which calls `loadHomeData()`.
- Error state replaces the entire scroll content.

---

## 8. Navigation

All navigation events are handled by the screen composable/view, not the ViewModel.
The ViewModel only manages data state.

| User Action | Navigation Target | Route |
|-------------|-------------------|-------|
| Tap search bar | Search screen | `Route.ProductSearch` |
| Tap hero banner | Product detail or Category products | `Route.ProductDetail(id)` or `Route.CategoryProducts(id, name)` |
| Tap category icon | Category products | `Route.CategoryProducts(id, name)` |
| Tap product card | Product detail | `Route.ProductDetail(id)` |
| Tap daily deal | Product detail | `Route.ProductDetail(id)` |
| Tap "See All" Popular | Product list (popular) | `Route.ProductList(filter: "popular")` |
| Tap "See All" New Arrivals | Product list (new arrivals) | `Route.ProductList(filter: "new")` |
| Tap flash sale banner | Collection/deep link | `Route.ProductList(collectionId)` or external URL |

---

## 9. Localization

### New String Keys

| Key | English | Turkish | Context |
|-----|---------|---------|---------|
| `home_daily_deal_badge` | DAILY DEAL | GUNUN FIRSATI | Badge on daily deal card |
| `home_daily_deal_title` | Daily Deal | Gunun Firsati | Section header |
| `home_daily_deal_ended` | ENDED | SONA ERDI | Countdown expired text |
| `home_flash_sale_title` | Flash Sale | Indirim Firsati | Flash sale banner title |
| `home_flash_sale_badge` | FLASH SALE | KAMPANYA | Flash sale badge text |
| `common_see_all` | See All | Tumunu Gor | Section header action |
| `home_section_daily_deal` | Daily Deal | Gunun Firsati | Section header title |
| `home_section_flash_sale` | Flash Sale | Indirim Firsati | Section header title |
| `home_error_message` | Something went wrong | Bir hata olustu | Error state message |
| `home_error_retry` | Retry | Tekrar Dene | Error state button |
| `home_delivery_badge` | Order before %@, delivered %@ | %@ oncesi siparis, %@ teslim | Delivery badge template |

### Existing String Keys (Verified, No Changes)

The following keys already exist and should continue to be used:
- `home_welcome_title`, `home_welcome_subtitle`
- `home_search_placeholder` / `home_search_hint`
- `home_featured_title`, `home_categories_title`, `home_popular_title`, `home_new_arrivals_title`
- `home_banner_*` keys
- `home_category_*` keys
- `home_product_*` keys
- `common_add_to_wishlist`, `common_remove_from_wishlist`

---

## 10. Accessibility

| Element | Accessibility |
|---------|--------------|
| Hero banner | Role: button. Label: "{tag} - {title}. {subtitle}". Hint: "Double tap to view" |
| Pagination dots | Label: "Page {n} of {total}" (already implemented in XGPaginationDots) |
| Category icon | Role: button. Label: category name |
| Product card | Role: button. Combined label: "{title}, {price}, {vendor}, {rating}" (existing) |
| Wishlist button | Role: toggle. Label: "Add to wishlist" / "Remove from wishlist" |
| Daily deal card | Role: button. Label: "Daily deal: {title}, {price}, ends in {time}" |
| Flash sale banner | Role: button. Label: "Flash sale: {title}" |
| Section header "See All" | Role: button. Label: "See all {section name}" |
| Pull to refresh | Platform-native accessibility (automatic) |

---

## 11. File Manifest

### 11.1 Android Files

**New files** (in `android/app/src/main/java/com/xirigo/ecommerce/`):

```
# Domain Layer
feature/home/domain/model/HomeBanner.kt
feature/home/domain/model/HomeCategory.kt
feature/home/domain/model/HomeProduct.kt
feature/home/domain/model/DailyDeal.kt
feature/home/domain/model/FlashSale.kt
feature/home/domain/repository/HomeRepository.kt
feature/home/domain/usecase/GetHomeBannersUseCase.kt
feature/home/domain/usecase/GetHomeCategoriesUseCase.kt
feature/home/domain/usecase/GetPopularProductsUseCase.kt
feature/home/domain/usecase/GetDailyDealUseCase.kt
feature/home/domain/usecase/GetNewArrivalsUseCase.kt
feature/home/domain/usecase/GetFlashSaleUseCase.kt

# Data Layer
feature/home/data/repository/FakeHomeRepository.kt

# Presentation Layer
feature/home/presentation/state/HomeUiState.kt
feature/home/presentation/state/HomeEvent.kt
feature/home/presentation/viewmodel/HomeViewModel.kt

# DI
feature/home/di/HomeModule.kt

# Design System Components (core)
core/designsystem/component/XGHeroBanner.kt
core/designsystem/component/XGCategoryIcon.kt
core/designsystem/component/XGSectionHeader.kt
core/designsystem/component/XGWishlistButton.kt
core/designsystem/component/XGDailyDealCard.kt
core/designsystem/component/XGFlashSaleBanner.kt
```

**Modified files**:

```
feature/home/presentation/screen/HomeScreen.kt    -- refactor to use ViewModel + new components
core/designsystem/component/XGCard.kt             -- add deliveryLabel, onAddToCartClick params; use XGWishlistButton
```

**Deleted files**:

```
(none -- inline sample data in HomeScreen.kt is removed during refactor, not a separate file)
```

**New string resources** (in `res/values/strings.xml` and translations):

```
home_daily_deal_badge, home_daily_deal_title, home_daily_deal_ended,
home_flash_sale_title, home_flash_sale_badge, common_see_all,
home_section_daily_deal, home_section_flash_sale,
home_error_message, home_error_retry, home_delivery_badge
```

**Total new files**: 23 (17 feature + 6 design system)
**Total modified files**: 2

### 11.2 iOS Files

**New files** (in `ios/XiriGoEcommerce/`):

```
# Domain Layer
Feature/Home/Domain/Model/HomeBanner.swift
Feature/Home/Domain/Model/HomeCategory.swift
Feature/Home/Domain/Model/HomeProduct.swift
Feature/Home/Domain/Model/DailyDeal.swift
Feature/Home/Domain/Model/FlashSale.swift
Feature/Home/Domain/Repository/HomeRepository.swift
Feature/Home/Domain/UseCase/GetHomeBannersUseCase.swift
Feature/Home/Domain/UseCase/GetHomeCategoriesUseCase.swift
Feature/Home/Domain/UseCase/GetPopularProductsUseCase.swift
Feature/Home/Domain/UseCase/GetDailyDealUseCase.swift
Feature/Home/Domain/UseCase/GetNewArrivalsUseCase.swift
Feature/Home/Domain/UseCase/GetFlashSaleUseCase.swift

# Data Layer
Feature/Home/Data/Repository/FakeHomeRepository.swift

# Presentation Layer
Feature/Home/Presentation/State/HomeUiState.swift
Feature/Home/Presentation/State/HomeEvent.swift
Feature/Home/Presentation/ViewModel/HomeViewModel.swift

# DI
Feature/Home/DI/Container+Home.swift

# Design System Components (core)
Core/DesignSystem/Component/XGHeroBanner.swift
Core/DesignSystem/Component/XGCategoryIcon.swift
Core/DesignSystem/Component/XGSectionHeader.swift
Core/DesignSystem/Component/XGWishlistButton.swift
Core/DesignSystem/Component/XGDailyDealCard.swift
Core/DesignSystem/Component/XGFlashSaleBanner.swift
```

**Modified files**:

```
Feature/Home/Presentation/Screen/HomeScreen.swift         -- refactor to use ViewModel + new components
Core/DesignSystem/Component/XGCard.swift                  -- add deliveryLabel, onAddToCartAction params; use XGWishlistButton
```

**Deleted files**:

```
Feature/Home/Presentation/Screen/HomeScreenSampleData.swift  -- sample data moves to FakeHomeRepository
```

**New localization keys** (in `Localizable.xcstrings`):

```
home_daily_deal_badge, home_daily_deal_title, home_daily_deal_ended,
home_flash_sale_title, home_flash_sale_badge, common_see_all,
home_section_daily_deal, home_section_flash_sale,
home_error_message, home_error_retry, home_delivery_badge
```

**Total new files**: 23 (17 feature + 6 design system)
**Total modified files**: 2
**Total deleted files**: 1

---

## 12. Platform-Specific Implementation Notes

### 12.1 Android

1. **Hero Banner Carousel**: Use `HorizontalPager` from `accompanist` or `foundation.pager`.
   Auto-scroll with `LaunchedEffect` + `delay(5000)`. Cancel/restart on user interaction
   via `PagerState.isScrollInProgress`.

2. **Countdown Timer**: Use `LaunchedEffect(Unit)` with a `while(true) { delay(1000) }` loop.
   Calculate remaining time from `System.currentTimeMillis()`. Store formatted string in a
   `remember { mutableStateOf("") }`.

3. **Pull-to-Refresh**: Use `Modifier.pullToRefresh()` (Material 3 1.3+) or
   `PullToRefreshBox` wrapping the scroll content.

4. **New Arrivals Grid**: Change from current `LazyRow` to `LazyVerticalGrid` with
   `GridCells.Fixed(2)` matching the popular products section. Add `deliveryLabel` and
   `onAddToCartClick` to each card.

5. **Gradient Drawing**: Use `Brush.linearGradient` for daily deal card and hero banner overlay.
   Use `Canvas` with `drawPath` for flash sale accent stripes.

6. **Search Bar**: Add `onClick` navigation callback. Currently has `clickable { /* Visual only */ }`.
   Wire to `AppRouter.navigate(Route.ProductSearch)`.

7. **Section Headers**: Replace inline `SectionHeader` composable with `XGSectionHeader` from
   design system. Add `onSeeAllClick` callbacks.

8. **Welcome Header**: The existing `WelcomeHeader` can be kept as-is or removed per design.
   The spec keeps it since it exists and provides context.

### 12.2 iOS

1. **Hero Banner Carousel**: Use `TabView` with `.tabViewStyle(.page(indexDisplayMode: .never))`
   to hide native dots (use `XGPaginationDots` instead). Auto-scroll with
   `Timer.publish(every: 5, on: .main, in: .common).autoconnect()`.

2. **Countdown Timer**: Use `TimelineView(.periodic(from: .now, by: 1))` for efficient
   clock-driven updates. Or use `Timer.publish(every: 1, on: .main, in: .common)`.

3. **Pull-to-Refresh**: Apply `.refreshable { await viewModel.refresh() }` modifier to the
   `ScrollView`.

4. **New Arrivals Grid**: Change from current horizontal `ScrollView` + `HStack` to
   `LazyVGrid` with two columns matching the popular products section. Add `deliveryLabel`
   and `onAddToCartAction` to each card.

5. **ViewModel Integration**: The existing `HomeScreen` uses `@Environment(AppRouter.self)`.
   Add `HomeViewModel` as an `@State` property initialized from the DI container, or inject
   via the environment.

6. **Search Bar**: Already wired to `router.navigate(to: .productSearch)`. Verify this works
   with the refactored screen.

7. **Section Headers**: Replace inline `sectionHeader()` function with `XGSectionHeader`
   component. Add `onSeeAllAction` callbacks.

8. **Sample Data Deletion**: Delete `HomeScreenSampleData.swift`. The `HomeBanner`,
   `HomeCategory`, and `HomeProduct` types in that file are replaced by the new domain models.

---

## 13. Verification Criteria

Developers should verify their implementation against these criteria:

### Functional

- [ ] Home screen loads with all 7 sections visible (search, banners, categories, popular, daily deal, new arrivals, flash sale)
- [ ] Hero banner auto-scrolls every 5 seconds
- [ ] Hero banner supports manual swipe
- [ ] Pagination dots update correctly with banner position
- [ ] Category icons are tappable and navigate to category products screen
- [ ] Popular products display in 2-column grid
- [ ] Product cards show wishlist button
- [ ] Wishlist toggle works (heart fills/unfills)
- [ ] Daily deal countdown timer ticks every second
- [ ] Daily deal shows "ENDED" when countdown reaches zero
- [ ] New arrivals display in 2-column grid with delivery badge and add-to-cart FAB
- [ ] Flash sale banner is visible and tappable
- [ ] "See All" links on Popular and New Arrivals sections are tappable
- [ ] Search bar tap navigates to search screen
- [ ] Pull-to-refresh reloads all sections
- [ ] Loading state shows skeleton/shimmer
- [ ] Error state shows error view with retry button
- [ ] Retry button reloads data

### Design System

- [ ] All new XG* components have `@Preview` / `#Preview`
- [ ] No raw Material 3 or SwiftUI components used in feature screens
- [ ] All XG* components use design tokens (no hardcoded colors, sizes, fonts)
- [ ] XGPaginationDots is reused from onboarding (not recreated)
- [ ] XGProductCard updated with deliveryLabel and onAddToCartClick/onAddToCartAction
- [ ] XGWishlistButton extracted as standalone design system component

### Architecture

- [ ] Domain layer has zero imports from data or presentation
- [ ] All models are immutable (data class / struct)
- [ ] ViewModel uses UDF pattern (event -> state)
- [ ] Repository pattern with interface in domain, implementation in data
- [ ] FakeHomeRepository provides sample data
- [ ] DI registration binds FakeHomeRepository to HomeRepository interface
- [ ] No `Any` type in domain/presentation
- [ ] No force unwrap (`!!` / `!`)

### Accessibility

- [ ] All interactive elements have content descriptions
- [ ] Minimum touch target 48dp on all tappable elements
- [ ] VoiceOver/TalkBack correctly reads section content

### Localization

- [ ] All user-facing strings use localized keys
- [ ] New string keys added in English and Turkish
- [ ] No hardcoded text in composables/views

---

## 14. Migration Notes

### What Changes From Existing Code

The existing HomeScreen files on both platforms have inline sample data and no architecture
layers. The migration path is:

1. **Create domain models** -- new `HomeBanner`, `HomeCategory`, `HomeProduct`, `DailyDeal`, `FlashSale` in domain layer
2. **Create repository** -- `HomeRepository` interface + `FakeHomeRepository` with sample data from existing inline data
3. **Create use cases** -- one per repository method
4. **Create ViewModel** -- `HomeViewModel` with `HomeUiState` and `HomeEvent`
5. **Create design system components** -- 6 new XG* components
6. **Refactor HomeScreen** -- inject ViewModel, replace inline data with state observation, replace inline helpers with XG* components, add new sections (daily deal, flash sale)
7. **Delete sample data file** (iOS only) -- `HomeScreenSampleData.swift`
8. **Update XGProductCard** -- add new parameters

### Backward Compatibility

- The existing search bar navigation (iOS) continues to work.
- The existing product card component API is extended (new optional params), not changed.
- The existing bottom navigation is not modified.
- The existing welcome header is preserved.
