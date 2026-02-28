# Home Screen (M1-04)

**GitHub Issue**: #42 (via onboarding commit reference)
**Milestone**: M1 — Core Features
**Platforms**: Android + iOS

---

## Overview

The Home Screen is the primary landing screen after authentication. It displays a vertically scrollable feed with seven sections sourced from a `HomeRepository`. All data loading is coordinated by `HomeViewModel` using parallel coroutine/async let calls, and the screen fully supports pull-to-refresh, loading, error, and empty states.

### Screen Sections (top to bottom)

| # | Section | Description |
|---|---------|-------------|
| 1 | Welcome Header | Personalized greeting ("Good morning / afternoon / evening") |
| 2 | Search Bar | Tappable field that navigates to Product Search (M1-08) |
| 3 | Hero Banner Carousel | Auto-scrolling promotional banners with `XGPaginationDots` |
| 4 | Categories | Horizontal row of `XGCategoryIcon` tiles |
| 5 | Popular Products | 2-column grid of `XGProductCard` with wishlist toggle |
| 6 | Daily Deal | Single `XGDailyDealCard` with live countdown timer |
| 7 | New Arrivals | 2-column grid of `XGProductCard` with delivery badge and add-to-cart |
| 8 | Flash Sale Banner | `XGFlashSaleBanner` with diagonal accent stripes |

---

## Architecture

### Clean Architecture Layers

```
HomeScreen / HomeScreenSections
        |
        v
  HomeViewModel  (@HiltViewModel / @MainActor @Observable)
  uiState: HomeUiState  (Loading | Success | Error)
        |
        v
  GetHomeBannersUseCase       GetHomeCategoriesUseCase
  GetPopularProductsUseCase   GetDailyDealUseCase
  GetNewArrivalsUseCase       GetFlashSaleUseCase
        |
        v
  HomeRepository (interface / protocol)
        |
        v
  FakeHomeRepository  (current: hardcoded sample data)
  HomeRepositoryImpl  (future: Medusa REST API)
```

### Data Flow

```
App Navigation → HomeScreen
    |
    v (Android: collectAsStateWithLifecycle / iOS: .task modifier)
HomeViewModel.loadHomeData()
    |
    +--> uiState = Loading
    |
    +--> [parallel fetch]
         getBanners()  getCategories()  getPopularProducts()
         getDailyDeal()  getNewArrivals()  getFlashSale()
    |
    +--> Success: uiState = Success(HomeScreenData)
    +--> Error:   uiState = Error(message)

User Pull-to-Refresh
    +--> HomeEvent.Refresh → refresh()
    +--> Preserves existing wishedProductIds
    +--> Same parallel fetch as loadHomeData()

User Wishlist Tap
    +--> HomeEvent.WishlistToggled(productId) → toggleWishlist()
    +--> Updates wishedProductIds Set in HomeScreenData (local only)
```

---

## Screen Sections

### 1. Welcome Header

Static greeting text using the time of day. No interactivity.

### 2. Search Bar

- Component: `XGTextField` (read-only, clickable)
- Event dispatched: `HomeEvent.SearchBarTapped`
- Navigation: wired to `Route.ProductSearch` (M1-08, currently no-op)

### 3. Hero Banner Carousel

- Component: `XGHeroBanner` + `XGPaginationDots`
- Mechanism: `HorizontalPager` (Android) / `TabView(.page)` (iOS)
- Auto-scroll: 5-second timer, resets on manual swipe
- Interaction: banner tap dispatches `HomeEvent.BannerTapped(banner)` (no-op until M1-06/M1-07)
- Data: `HomeScreenData.banners` (3 items in fake data)

### 4. Categories

- Component: `XGCategoryIcon`
- Layout: `LazyRow` (Android) / horizontal `ScrollView` (iOS)
- Interaction: category tap dispatches `HomeEvent.CategoryTapped(category)` (no-op until M1-05)
- Data: `HomeScreenData.categories` (6 items in fake data)

### 5. Popular Products

- Component: `XGProductCard` (via `XGCard`) + `XGSectionHeader`
- Layout: 2-column grid (chunked rows on Android / `LazyVGrid` on iOS)
- Interaction: product tap → `HomeEvent.ProductTapped(productId)`, wishlist → `HomeEvent.WishlistToggled(productId)`, "See All" → `HomeEvent.SeeAllPopularTapped`
- Data: `HomeScreenData.popularProducts` (6 items in fake data)

### 6. Daily Deal

- Component: `XGDailyDealCard` + `XGSectionHeader`
- Countdown: live timer ticking down to `DailyDeal.endTime` — shows "ENDED" at zero
- Timer implementation: `LaunchedEffect` + `delay(1000)` loop (Android) / `TimelineView(.periodic)` (iOS)
- Interaction: tap dispatches `HomeEvent.DailyDealTapped(productId)` (no-op until M1-07)
- Data: `HomeScreenData.dailyDeal` — optional; section hidden when null

### 7. New Arrivals

- Component: `XGProductCard` + `XGSectionHeader`
- Layout: 2-column grid with delivery label badge and add-to-cart button
- Interaction: product tap → `HomeEvent.ProductTapped`, wishlist → `HomeEvent.WishlistToggled`, add-to-cart → `onAddToCartClick` callback (no-op until M2-01), "See All" → `HomeEvent.SeeAllNewArrivalsTapped`
- Data: `HomeScreenData.newArrivals` — all items have `isNew = true` (6 items in fake data)

### 8. Flash Sale Banner

- Component: `XGFlashSaleBanner`
- Visual: yellow (`#FFD814`) banner with Canvas-drawn diagonal accent stripes
- Interaction: tap to navigate to flash sale product list (no-op until M1-06)
- Data: `HomeScreenData.flashSale` — optional; section hidden when null

---

## Design System Components

Six new components added to `core/designsystem/component/` for this feature.

| Component | Platform Files | Size | Design Token |
|-----------|----------------|------|--------------|
| `XGHeroBanner` | `XGHeroBanner.kt` / `XGHeroBanner.swift` | 192dp/pt card | `components.json > XGCard.heroBanner` |
| `XGCategoryIcon` | `XGCategoryIcon.kt` / `XGCategoryIcon.swift` | 79dp/pt tile | `components.json > XGCategoryIcon` |
| `XGSectionHeader` | `XGSectionHeader.kt` / `XGSectionHeader.swift` | Row layout | — |
| `XGWishlistButton` | `XGWishlistButton.kt` / `XGWishlistButton.swift` | 32dp/pt circle | `components.json > XGWishlistButton` |
| `XGDailyDealCard` | `XGDailyDealCard.kt` / `XGDailyDealCard.swift` | 163dp/pt card | `components.json > XGCard.dailyDeal` |
| `XGFlashSaleBanner` | `XGFlashSaleBanner.kt` / `XGFlashSaleBanner.swift` | 133dp/pt banner | `components.json > XGCard.flashSale` |

### XGHeroBanner

Async image background with `heroBannerOverlay` gradient (`#6000FE` 90% → transparent). Optional tag badge (`BrandSecondary` background). Headline and subtitle text overlaid bottom-left.

```kotlin
// Android
XGHeroBanner(
    title: String,
    subtitle: String,
    imageUrl: String?,
    tag: String?,
    modifier: Modifier = Modifier
)
```

```swift
// iOS
XGHeroBanner(
    title: String,
    subtitle: String,
    imageUrl: String?,
    tag: String?
)
```

### XGCategoryIcon

79dp/pt colored tile (`RoundedCornerShape(Medium)` / `RoundedRectangle(cornerRadius: medium)`). 40dp/pt white icon resolved by name (Material icon / SF Symbol). 12sp label below. Background color from hex string.

```kotlin
// Android
XGCategoryIcon(
    name: String,
    iconName: String,
    colorHex: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
)
```

```swift
// iOS
XGCategoryIcon(
    name: String,
    iconName: String,
    colorHex: String,
    onTap: () -> Void
)
```

### XGSectionHeader

Row: title (`titleMedium`/18sp semibold), optional subtitle (`bodySmall`/secondary), optional "See All" action with `chevron.right` icon.

```kotlin
// Android
XGSectionHeader(
    title: String,
    subtitle: String? = null,
    onSeeAllClick: (() -> Unit)? = null
)
```

```swift
// iOS
XGSectionHeader(
    title: String,
    subtitle: String? = nil,
    onSeeAll: (() -> Void)? = nil
)
```

### XGWishlistButton

32dp/pt circle. Active state: `BrandPrimary` filled heart. Inactive: `onSurfaceVariant` outlined heart on white background. Extracted from `XGProductCard` so it can be used independently (Product Detail M1-07, Wishlist M2-02).

```kotlin
// Android
XGWishlistButton(
    isWished: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
)
```

```swift
// iOS
XGWishlistButton(
    isWished: Bool,
    onTap: () -> Void
)
```

### XGDailyDealCard

163dp/pt gradient card (`#111827` → `#6000FE`). Badge, product title, price (`BrandSecondary`), strikethrough original price, product image. Internal countdown timer runs independently — ViewModel only provides `endTime`.

```kotlin
// Android
XGDailyDealCard(
    title: String,
    imageUrl: String?,
    price: String,
    originalPrice: String,
    currencyCode: String,
    endTimeMillis: Long,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
)
```

```swift
// iOS
XGDailyDealCard(
    title: String,
    imageUrl: String?,
    price: String,
    originalPrice: String,
    currencyCode: String,
    endTime: Date,
    onTap: () -> Void
)
```

### XGFlashSaleBanner

133dp/pt yellow (`#FFD814`) banner. Canvas-drawn diagonal stripes: blue (`#9EBDF4`) left, pink (`#F60186`) right. Bold headline in near-black. Optional image via `XGImage`.

```kotlin
// Android
XGFlashSaleBanner(
    title: String,
    imageUrl: String?,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
)
```

```swift
// iOS
XGFlashSaleBanner(
    title: String,
    imageUrl: String?,
    onTap: () -> Void
)
```

### Modified: XGProductCard (XGCard)

`XGProductCard` was updated to add two optional parameters:

- `deliveryLabel: String?` — renders a 10sp badge in `BrandSecondary` color
- `onAddToCartClick`/`onAddToCartAction: (() -> Unit)?` — renders a 32dp/pt circular add-to-cart button (`BrandSecondary` background, white cart icon)
- Internal wishlist toggle replaced with `XGWishlistButton` component

---

## Domain Models

| Model | Fields | Notes |
|-------|--------|-------|
| `HomeBanner` | `id`, `title`, `subtitle`, `imageUrl?`, `tag?`, `actionProductId?`, `actionCategoryId?` | Tapping routes to product or category |
| `HomeCategory` | `id`, `name`, `handle`, `iconName`, `colorHex` | `iconName` maps to Material icon / SF Symbol |
| `HomeProduct` | `id`, `title`, `imageUrl?`, `price`, `currencyCode`, `originalPrice?`, `vendor`, `rating?`, `reviewCount?`, `isNew` | Used for both Popular Products and New Arrivals |
| `DailyDeal` | `productId`, `title`, `imageUrl?`, `price`, `originalPrice`, `currencyCode`, `endTime` | `endTime`: Long millis (Android) / Date (iOS) |
| `FlashSale` | `id`, `title`, `imageUrl?`, `actionUrl?` | Entire section optional |

All models are immutable (`data class` with `val` on Android; `struct` with `let` on iOS). Domain models have zero imports from data or presentation layers.

---

## State Management

### HomeUiState

```
HomeUiState
├── Loading         — initial state on every (re)load
├── Success(data: HomeScreenData)
│   └── HomeScreenData
│       ├── banners: [HomeBanner]
│       ├── categories: [HomeCategory]
│       ├── popularProducts: [HomeProduct]
│       ├── dailyDeal: DailyDeal?
│       ├── newArrivals: [HomeProduct]
│       ├── flashSale: FlashSale?
│       └── wishedProductIds: Set<String>
└── Error(message: String)
```

Android: `@Stable sealed interface`, `HomeScreenData` annotated `@Stable`.
iOS: `enum HomeUiState: Equatable, Sendable`, `HomeScreenData: Equatable, Sendable`.

### HomeEvent

| Event | Payload | Handler |
|-------|---------|---------|
| `Refresh` | — | `refresh()` — reloads all sections, preserves `wishedProductIds` |
| `RetryTapped` | — | `loadHomeData()` — full reload from Loading state |
| `WishlistToggled` | `productId: String` | `toggleWishlist()` — local Set update only |
| `BannerTapped` | `HomeBanner` | No-op (future: navigate to product/category) |
| `CategoryTapped` | `HomeCategory` | No-op (future: M1-05 Category Browsing) |
| `ProductTapped` | `productId: String` | No-op (future: M1-07 Product Detail) |
| `DailyDealTapped` | `productId: String` | No-op (future: M1-07 Product Detail) |
| `SeeAllPopularTapped` | — | No-op (future: M1-06 Product List) |
| `SeeAllNewArrivalsTapped` | — | No-op (future: M1-06 Product List) |
| `SearchBarTapped` | — | No-op (future: M1-08 Search) |

### ViewModel Flow

```
init
  └─> loadHomeData()
        ├─> _uiState = Loading
        ├─> async parallel: 6 use cases
        ├─> _uiState = Success(HomeScreenData) on all success
        └─> _uiState = Error(message) on IOException / thrown error

onEvent(Refresh)
  └─> refresh()
        ├─> _isRefreshing = true
        ├─> capture existing wishedProductIds
        ├─> async parallel: 6 use cases
        ├─> _uiState = Success(data with preserved wishedProductIds)
        └─> _isRefreshing = false (finally / always)

onEvent(WishlistToggled(productId))
  └─> toggleWishlist(productId)
        ├─> guard uiState is Success
        └─> copy HomeScreenData with toggled wishedProductIds Set
```

**Android**: `StateFlow<HomeUiState>` + `StateFlow<Boolean> isRefreshing`. Parallel fetch via `async { }` in `viewModelScope`.
**iOS**: `@Observable` `private(set) var uiState` + `var currentBannerPage`. Parallel fetch via `async let`.

---

## Mock Data

`FakeHomeRepository` (Android) / `FakeHomeRepository` + `HomeSampleData` (iOS) provide hardcoded sample data. This is the current `HomeRepository` implementation bound via Hilt / Factory DI.

### Android

`FakeHomeRepository` at `android/app/src/main/java/com/xirigo/ecommerce/feature/home/data/repository/FakeHomeRepository.kt`.
Sample data in private `SampleData` object within the same file.

### iOS

`FakeHomeRepository` at `ios/XiriGoEcommerce/Feature/Home/Data/Repository/FakeHomeRepository.swift`.
Sample data extracted to `HomeSampleData.swift` enum (same directory) to stay within SwiftLint `function_body_length` thresholds.

### Data Shapes

| Section | Fake Count | Notable Values |
|---------|-----------|----------------|
| Banners | 3 | Tags: "NEW SEASON", null, "LIMITED TIME" |
| Categories | 6 | Electronics, Fashion, Home, Sports, Books, Gaming |
| Popular Products | 6 | Mix of sale/non-sale; `isNew = false`; ratings 4.0–4.8 |
| Daily Deal | 1 | `endTime = now + 8 hours` |
| New Arrivals | 6 | All `isNew = true`; mix of sale/non-sale |
| Flash Sale | 1 | `actionUrl = null` |

---

## API Integration Plan

When the Medusa backend integration is implemented, a `HomeRepositoryImpl` replaces `FakeHomeRepository`. The `HomeRepository` interface and all use cases remain unchanged.

| Section | Medusa Endpoint | Notes |
|---------|----------------|-------|
| Banners | Custom CMS endpoint (TBD) | Not in base Medusa; needs custom module |
| Categories | `GET /store/product-categories` | Filter by parent_category_id = null, limit = 6 |
| Popular Products | `GET /store/products?order=-created_at&limit=6` | Or custom popularity signal |
| Daily Deal | Custom CMS endpoint (TBD) | Needs scheduled deal entity |
| New Arrivals | `GET /store/products?order=-created_at&is_new=true&limit=6` | Requires `is_new` tag |
| Flash Sale | Custom CMS endpoint (TBD) | Needs campaign entity |

**Steps to switch from fake to real**:
1. Implement `HomeRepositoryImpl` with `ApiClient` calls
2. Add DTOs in `feature/home/data/dto/`
3. Add mappers in `feature/home/data/mapper/`
4. Update DI binding: `FakeHomeRepository` → `HomeRepositoryImpl`
5. No changes needed in domain or presentation layers

---

## Testing

### Summary

| Platform | Test Files | Total Tests |
|----------|-----------|-------------|
| Android | 8 files | 65 tests |
| iOS | 8 files | 92 tests |
| **Total** | **16 files** | **157 tests** |

### Android Test Coverage

| File | Tests | Focus |
|------|-------|-------|
| `FakeHomeRepositoryTest.kt` | 19 | All 6 methods, IOException propagation, null returns |
| `GetHomeBannersUseCaseTest.kt` | 6 | Success, empty, custom data, error propagation |
| `GetHomeCategoriesUseCaseTest.kt` | 6 | Same pattern |
| `GetPopularProductsUseCaseTest.kt` | 6 | Same pattern |
| `GetDailyDealUseCaseTest.kt` | 6 | Null return, future endTime assertion |
| `GetNewArrivalsUseCaseTest.kt` | 6 | `isNew = true` assertion |
| `GetFlashSaleUseCaseTest.kt` | 6 | Null return, delegation |
| `HomeViewModelTest.kt` | 30 | Loading/Success/Error transitions, Refresh, WishlistToggled, RetryTapped, no-op nav events, data integrity |

Coverage targets met: ≥80% lines, ≥70% branches across all layers.

### iOS Test Coverage

| File | Tests | Focus |
|------|-------|-------|
| `FakeHomeRepositoryTests.swift` | 15 | Default state, configurable values, error propagation, call count tracking |
| `GetHomeBannersUseCaseTests.swift` | 6 | Success, empty, error propagation, delegation |
| `GetHomeCategoriesUseCaseTests.swift` | 6 | Same pattern |
| `GetPopularProductsUseCaseTests.swift` | 6 | Same pattern |
| `GetDailyDealUseCaseTests.swift` | 6 | nil return, future endTime, error propagation |
| `GetNewArrivalsUseCaseTests.swift` | 6 | Same pattern |
| `GetFlashSaleUseCaseTests.swift` | 7 | nil return, delegation |
| `HomeViewModelTests.swift` | 34 | Loading/Success/Error, refresh, wishedProductIds preservation, wishlist toggle, currentBannerPage, no-op nav events |

### Test Patterns

- **FakeHomeRepository**: Configurable via properties (iOS: call count tracking + per-method error injection). Placed in test target — separate from the main-target `FakeHomeRepository`.
- **Android**: `MainDispatcherRule` (JUnit4 `TestWatcher` with `StandardTestDispatcher`) + `Turbine` for flow assertion ordering + `runTest + advanceUntilIdle`.
- **iOS**: `@MainActor` test isolation with `await MainActor.run {}` for state inspection.
- **Fakes over mocks** per project standard.

### Bugs Fixed During Testing (iOS)

| # | File | Issue | Fix |
|---|------|-------|-----|
| 1 | `project.pbxproj` | Unquoted `+` in `Container+Home.swift` path broke OpenStep parser | Added quotes around filename |
| 2 | `HomeScreen.swift` | `private` access blocked `HomeScreenSections` extension | Changed to internal access |
| 3 | `HomeScreenSections.swift` | `bannerTimer` return type mismatch (`Timer.TimerPublisher` vs `Publishers.Autoconnect<Timer.TimerPublisher>`) | Fixed return type, added `import Combine` |
| 4 | `XGDailyDealCard.swift` | `Constants.titleMaxLines` referenced but not defined | Added `static let titleMaxLines = 2` |
| 5 | `HomeViewModel.swift` | `refresh()` did not preserve `wishedProductIds` | Captured existing IDs before reload, restored after |

---

## File Map

### Android

**Design System** — `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/`

| File | Type |
|------|------|
| `XGHeroBanner.kt` | New |
| `XGCategoryIcon.kt` | New |
| `XGSectionHeader.kt` | New |
| `XGWishlistButton.kt` | New |
| `XGDailyDealCard.kt` | New |
| `XGFlashSaleBanner.kt` | New |
| `XGCard.kt` | Modified — added `deliveryLabel`, `onAddToCartClick`, replaced inline wishlist |

**Domain** — `android/app/src/main/java/com/xirigo/ecommerce/feature/home/domain/`

| File | Type |
|------|------|
| `model/HomeBanner.kt` | New |
| `model/HomeCategory.kt` | New |
| `model/HomeProduct.kt` | New |
| `model/DailyDeal.kt` | New |
| `model/FlashSale.kt` | New |
| `repository/HomeRepository.kt` | New |
| `usecase/GetHomeBannersUseCase.kt` | New |
| `usecase/GetHomeCategoriesUseCase.kt` | New |
| `usecase/GetPopularProductsUseCase.kt` | New |
| `usecase/GetDailyDealUseCase.kt` | New |
| `usecase/GetNewArrivalsUseCase.kt` | New |
| `usecase/GetFlashSaleUseCase.kt` | New |

**Data** — `android/app/src/main/java/com/xirigo/ecommerce/feature/home/data/`

| File | Type |
|------|------|
| `repository/FakeHomeRepository.kt` | New |

**Presentation** — `android/app/src/main/java/com/xirigo/ecommerce/feature/home/presentation/`

| File | Type |
|------|------|
| `state/HomeUiState.kt` | New |
| `state/HomeEvent.kt` | New |
| `viewmodel/HomeViewModel.kt` | New |
| `screen/HomeScreen.kt` | Modified — full refactor to ViewModel-driven, 7 sections |

**DI** — `android/app/src/main/java/com/xirigo/ecommerce/feature/home/di/`

| File | Type |
|------|------|
| `HomeModule.kt` | New |

**Resources**

| File | Change |
|------|--------|
| `android/app/src/main/res/values/strings.xml` | +12 new keys |

**Tests** — `android/app/src/test/java/com/xirigo/ecommerce/feature/home/`

| File | Type |
|------|------|
| `repository/FakeHomeRepositoryTest.kt` | New |
| `viewmodel/MainDispatcherRule.kt` | New |
| `usecase/GetHomeBannersUseCaseTest.kt` | New |
| `usecase/GetHomeCategoriesUseCaseTest.kt` | New |
| `usecase/GetPopularProductsUseCaseTest.kt` | New |
| `usecase/GetDailyDealUseCaseTest.kt` | New |
| `usecase/GetNewArrivalsUseCaseTest.kt` | New |
| `usecase/GetFlashSaleUseCaseTest.kt` | New |
| `viewmodel/HomeViewModelTest.kt` | New |

---

### iOS

**Design System** — `ios/XiriGoEcommerce/Core/DesignSystem/Component/`

| File | Type |
|------|------|
| `XGHeroBanner.swift` | New |
| `XGCategoryIcon.swift` | New |
| `XGSectionHeader.swift` | New |
| `XGWishlistButton.swift` | New |
| `XGDailyDealCard.swift` | New |
| `XGFlashSaleBanner.swift` | New |
| `XGCard.swift` | Modified — added `deliveryLabel`, `onAddToCartAction`, replaced inline wishlist |

**Domain** — `ios/XiriGoEcommerce/Feature/Home/Domain/`

| File | Type |
|------|------|
| `Model/HomeBanner.swift` | New |
| `Model/HomeCategory.swift` | New |
| `Model/HomeProduct.swift` | New |
| `Model/DailyDeal.swift` | New |
| `Model/FlashSale.swift` | New |
| `Repository/HomeRepository.swift` | New |
| `UseCase/GetHomeBannersUseCase.swift` | New |
| `UseCase/GetHomeCategoriesUseCase.swift` | New |
| `UseCase/GetPopularProductsUseCase.swift` | New |
| `UseCase/GetDailyDealUseCase.swift` | New |
| `UseCase/GetNewArrivalsUseCase.swift` | New |
| `UseCase/GetFlashSaleUseCase.swift` | New |

**Data** — `ios/XiriGoEcommerce/Feature/Home/Data/Repository/`

| File | Type |
|------|------|
| `FakeHomeRepository.swift` | New |
| `HomeSampleData.swift` | New |

**Presentation** — `ios/XiriGoEcommerce/Feature/Home/Presentation/`

| File | Type |
|------|------|
| `State/HomeUiState.swift` | New |
| `State/HomeEvent.swift` | New |
| `ViewModel/HomeViewModel.swift` | New |
| `Screen/HomeScreen.swift` | Modified — full refactor to ViewModel-driven, 7 sections |
| `Screen/HomeScreenSections.swift` | New — extension with extracted section sub-views |

**DI**

| File | Type |
|------|------|
| `DI/Container+Home.swift` | New |

**Deleted**

| File | Reason |
|------|--------|
| `Presentation/Screen/HomeScreenSampleData.swift` | Replaced by domain models + `HomeSampleData.swift` |

**Resources**

| File | Change |
|------|--------|
| `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` | +10 new localization keys (en/tr/mt) |
| `ios/XiriGoEcommerce.xcodeproj/project.pbxproj` | +25 new file references, groups, and build phases |

**Tests** — `ios/XiriGoEcommerceTests/Feature/Home/`

| File | Type |
|------|------|
| `Fakes/FakeHomeRepository.swift` | New |
| `Repository/FakeHomeRepositoryTests.swift` | New |
| `UseCase/GetHomeBannersUseCaseTests.swift` | New |
| `UseCase/GetHomeCategoriesUseCaseTests.swift` | New |
| `UseCase/GetPopularProductsUseCaseTests.swift` | New |
| `UseCase/GetDailyDealUseCaseTests.swift` | New |
| `UseCase/GetNewArrivalsUseCaseTests.swift` | New |
| `UseCase/GetFlashSaleUseCaseTests.swift` | New |
| `ViewModel/HomeViewModelTests.swift` | New |

---

## Localization

### Android — 12 new string keys (`res/values/strings.xml`)

| Key | English |
|-----|---------|
| `home_daily_deal_badge` | DEAL OF THE DAY |
| `home_daily_deal_title` | Daily Deal |
| `home_daily_deal_ended` | ENDED |
| `home_flash_sale_title` | Flash Sale |
| `home_flash_sale_badge` | UP TO 70% OFF |
| `common_see_all` | See All |
| `home_section_daily_deal` | Daily Deal |
| `home_section_flash_sale` | Flash Sale |
| `home_error_message` | Something went wrong. |
| `home_error_retry` | Retry |
| `home_delivery_badge` | Free Delivery |
| `home_add_to_cart` | Add to Cart |

### iOS — 10 new keys (`Resources/Localizable.xcstrings`, en/tr/mt)

`common_see_all`, `common_add_to_cart`, `common_double_tap_to_view`, `home_daily_deal_badge`, `home_daily_deal_title`, `home_daily_deal_ended`, `home_flash_sale_title`, `home_flash_sale_badge`, `home_delivery_badge_sample`, `home_category_gaming`

---

## Dependencies

| Feature | What This Feature Uses |
|---------|----------------------|
| M0-02: Design System | `XGProductCard`, `XGImage`, `XGPriceText`, `XGRatingBar`, `XGBadge`, `XGLoadingView`, `XGErrorView`, `XGEmptyView` |
| M4-05: App Onboarding | `XGPaginationDots` (hero carousel) |
| M0-04: Navigation | `Route`, `AppRouter` (tap callbacks will wire here) |
| M0-05: DI Setup | Hilt `SingletonComponent` (Android) / Factory `Container` (iOS) |

## Downstream Dependents

| Feature | What It Reuses |
|---------|---------------|
| M1-05: Category Browsing | `XGCategoryIcon`, `CategoryTapped` event routing |
| M1-06: Product List | `XGSectionHeader`, `XGWishlistButton`, SeeAll event routing |
| M1-07: Product Detail | `XGWishlistButton`, `ProductTapped` event routing |
| M2-01: Cart | `onAddToCartClick`/`onAddToCartAction` callbacks on `XGProductCard` |
| M2-02: Wishlist | `wishedProductIds` backed by shared wishlist repository |
