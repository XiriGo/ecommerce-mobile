# Home Screen iOS Dev Handoff

## Feature: M1-04 Home Screen
## Platform: iOS
## Agent: ios-dev
## Date: 2026-02-28

## Summary

Implemented the full Home Screen feature for iOS with Clean Architecture layers (domain/data/presentation), 6 new design system components (XGHeroBanner, XGCategoryIcon, XGSectionHeader, XGWishlistButton, XGDailyDealCard, XGFlashSaleBanner), Factory DI container, @Observable ViewModel with UDF state management, and a refactored HomeScreen view with 7 scrollable sections including hero banner auto-scroll carousel, category icons, popular products grid, daily deal countdown timer, new arrivals grid with delivery badges and add-to-cart, and flash sale banner.

## Files Created

### Design System Components (`ios/XiriGoEcommerce/Core/DesignSystem/Component/`)

| File | Description |
|------|-------------|
| `XGHeroBanner.swift` | 192pt card with async image background (XGImage), gradient overlay (brandPrimary 90% to transparent), optional tag badge (brandSecondary bg), headline and subtitle text. Fallback gradient when no image. #Preview for both states. |
| `XGCategoryIcon.swift` | 79pt colored tile with RoundedRectangle(cornerRadius: medium), 40pt white SF Symbol icon, 12sp label below. Background color from Color(hex:) string. #Preview included. |
| `XGSectionHeader.swift` | HStack with title (18sp semibold), optional subtitle, and optional "See All" action with chevron.right icon in brandPrimary. Uses String(localized:). #Preview included. |
| `XGWishlistButton.swift` | 32pt circle button with elevation level 2. Active: brandPrimary filled heart. Inactive: onSurfaceVariant outlined heart on white background. Toggle accessibility trait. #Preview for both states. |
| `XGDailyDealCard.swift` | 163pt card with gradient (#111827 to brandPrimary). Badge (brandSecondary bg), title, countdown timer (TimelineView periodic 1s), price in brandSecondary, strikethrough original price, product image via XGImage. #Preview included. |
| `XGFlashSaleBanner.swift` | 133pt yellow (#FFD814) banner with Canvas-drawn diagonal accent stripes (blue #9EBDF4 left, pink #F60186 right). Bold headline text in near-black. #Preview included. |

### Domain Layer (`ios/XiriGoEcommerce/Feature/Home/Domain/`)

| File | Description |
|------|-------------|
| `Model/HomeBanner.swift` | Struct: id, title, subtitle, imageUrl?, tag?, actionProductId?, actionCategoryId?. Conforms to Identifiable, Equatable, Sendable. |
| `Model/HomeCategory.swift` | Struct: id, name, handle, iconName, colorHex. Conforms to Identifiable, Equatable, Sendable. |
| `Model/HomeProduct.swift` | Struct: id, title, imageUrl?, price, currencyCode, originalPrice?, vendor, rating?, reviewCount?, isNew. Conforms to Identifiable, Equatable, Sendable. |
| `Model/DailyDeal.swift` | Struct: productId, title, imageUrl?, price, originalPrice, currencyCode, endTime (Date). Conforms to Equatable, Sendable. |
| `Model/FlashSale.swift` | Struct: id, title, imageUrl?, actionUrl?. Conforms to Identifiable, Equatable, Sendable. |
| `Repository/HomeRepository.swift` | Protocol with 6 async throws methods: getBanners(), getCategories(), getPopularProducts(), getDailyDeal(), getNewArrivals(), getFlashSale(). |
| `UseCase/GetHomeBannersUseCase.swift` | final class Sendable, init(repository:), execute() async throws -> [HomeBanner]. |
| `UseCase/GetHomeCategoriesUseCase.swift` | Same pattern for [HomeCategory]. |
| `UseCase/GetPopularProductsUseCase.swift` | Same pattern for [HomeProduct]. |
| `UseCase/GetDailyDealUseCase.swift` | Same pattern for DailyDeal?. |
| `UseCase/GetNewArrivalsUseCase.swift` | Same pattern for [HomeProduct]. |
| `UseCase/GetFlashSaleUseCase.swift` | Same pattern for FlashSale?. |

### Data Layer (`ios/XiriGoEcommerce/Feature/Home/Data/Repository/`)

| File | Description |
|------|-------------|
| `FakeHomeRepository.swift` | final class implementing HomeRepository, @unchecked Sendable. All methods delegate to HomeSampleData enum. |
| `HomeSampleData.swift` | Enum with static properties for all sample data: 3 banners, 6 categories, 4 popular products, 1 daily deal (8h countdown), 6 new arrivals, 1 flash sale. Named constants for ratings, review counts, and timing. |

### Presentation Layer (`ios/XiriGoEcommerce/Feature/Home/Presentation/`)

| File | Description |
|------|-------------|
| `State/HomeUiState.swift` | Enum: loading, success(data: HomeScreenData), error(message: String). HomeScreenData struct with banners, categories, popularProducts, dailyDeal?, newArrivals, flashSale?, wishedProductIds: Set<String>. |
| `State/HomeEvent.swift` | Enum: refresh, bannerTapped(bannerId), categoryTapped(categoryId, categoryName), productTapped(productId), wishlistToggled(productId), dailyDealTapped(productId), seeAllPopularTapped, seeAllNewArrivalsTapped, searchBarTapped, retryTapped. |
| `ViewModel/HomeViewModel.swift` | @MainActor @Observable final class with 6 use cases. loadHomeData() uses async let for parallel fetching. onEvent() dispatches events. refresh() preserves wishedProductIds. toggleWishlist() updates local Set. |
| `Screen/HomeScreenSections.swift` | Extension on HomeScreen with extracted section views: welcomeHeader, searchBar, heroBannerCarousel (TabView + auto-scroll Timer.publish 5s + XGPaginationDots), categoriesSection, popularProductsSection, dailyDealSection, newArrivalsSection, flashSaleSection. Product grids and cards extracted to private methods for closure_body_length compliance. |

### DI (`ios/XiriGoEcommerce/Feature/Home/DI/`)

| File | Description |
|------|-------------|
| `Container+Home.swift` | Extension on Container registering homeRepository (.singleton), 6 use cases, and homeViewModel (using MainActor.assumeIsolated). |

## Files Modified

| File | Change |
|------|--------|
| `Core/DesignSystem/Component/XGCard.swift` | Added `deliveryLabel: String?` and `onAddToCartAction: (() -> Void)?` parameters to XGProductCard. Added delivery badge text (10pt, brandSecondary). Added 32pt circular add-to-cart button (green bg, white plus icon). Replaced inline wishlist with XGWishlistButton. |
| `Feature/Home/Presentation/Screen/HomeScreen.swift` | Refactored from inline-data view to ViewModel-driven screen. Switch on HomeUiState for Loading (XGLoadingView), Error (XGErrorView), Success (ScrollView with all 7 sections). Uses .task for initial load, .refreshable for pull-to-refresh. Factory DI via Container.shared.homeViewModel(). |
| `Resources/Localizable.xcstrings` | Added 10 new localization keys: common_see_all, common_add_to_cart, common_double_tap_to_view, home_daily_deal_badge, home_daily_deal_title, home_daily_deal_ended, home_flash_sale_title, home_flash_sale_badge, home_delivery_badge_sample, home_category_gaming. With en/tr/mt translations. |
| `XiriGoEcommerce.xcodeproj/project.pbxproj` | Added 25 new file references, build file entries, and PBXGroup entries for all new files. Removed HomeScreenSampleData.swift references. |

## Files Deleted

| File | Reason |
|------|--------|
| `Feature/Home/Presentation/Screen/HomeScreenSampleData.swift` | Replaced by domain models + HomeSampleData.swift in data layer. |

## Key Decisions

1. **@Observable over ObservableObject**: Uses iOS 17+ @Observable macro for HomeViewModel instead of ObservableObject/Published, per project standards.
2. **HomeSampleData enum**: Sample data extracted to a separate file to keep FakeHomeRepository methods under SwiftLint's function_body_length threshold (60 lines error).
3. **TabView with Timer.publish auto-scroll**: Hero banner carousel uses TabView(.page) with Timer.publish(every: 5) and onReceive for auto-advance. Consistent with Android's HorizontalPager approach.
4. **TimelineView for countdown**: XGDailyDealCard uses TimelineView(.periodic(from:by:1)) for real-time countdown, which is the SwiftUI-native approach vs. manual Timer.
5. **Navigation via AppRouter**: All navigation events dispatch through the existing AppRouter pattern (router.navigate(to:)). Events like BannerTapped resolve to either productDetail or categoryProducts routes.
6. **Wishlist toggle is local state only**: wishedProductIds stored as Set<String> in HomeScreenData. Will be backed by shared wishlist repository in M2-02.
7. **Canvas-drawn accent stripes**: XGFlashSaleBanner draws diagonal stripes using SwiftUI Canvas, matching Android's Canvas.drawPath approach.
8. **Extracted sub-views for lint**: popularProductsSection and newArrivalsSection grid content extracted to separate private methods to satisfy SwiftLint's closure_body_length rule (max 30 lines).

## Build Verification

- SwiftLint passes with zero warnings on all new and modified files
- All design system components have #Preview annotations
- HomeScreen has #Preview annotation
- Domain layer has zero imports from data/ or presentation/
- No force unwrap (`!`) anywhere
- No `Any`/`AnyObject` in domain layer
- All user-facing strings use String(localized:) -- zero hardcoded text
- project.pbxproj has balanced braces and parentheses (490/490, 128/128)

## Test Entry Points for Tester

- `HomeViewModel`: Test loading state on init, success state after loadHomeData(), error state on thrown error, refresh preserves wishedProductIds, toggleWishlist adds/removes productId, onEvent dispatches correctly
- `GetHomeBannersUseCase` (and all 5 other use cases): Delegates to corresponding repository method
- `FakeHomeRepository`: Returns non-empty lists for all methods, dailyDeal endTime is in the future
- UI Testing: Hero banner auto-scrolls, pull-to-refresh works, countdown timer ticks, all 7 sections render, Loading/Error states display correctly

## Integration Points for Future Features

- M1-05 (Category Browsing): Reuses XGCategoryIcon component, categoryTapped event wires to Route.categoryProducts
- M1-06 (Product List): Reuses XGSectionHeader, XGWishlistButton, seeAll events wire to Route.productList
- M1-07 (Product Detail): Reuses XGWishlistButton, productTapped wires to Route.productDetail(productId)
- M2-01 (Cart): onAddToCartAction callbacks wire to cart use cases
- M2-02 (Wishlist): wishedProductIds will sync with shared wishlist repository
