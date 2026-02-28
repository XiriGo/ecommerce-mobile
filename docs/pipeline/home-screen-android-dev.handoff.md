# Home Screen Android Dev Handoff

## Feature: M1-04 Home Screen
## Platform: Android
## Agent: android-dev
## Date: 2026-02-28

## Summary

Implemented the full Home Screen feature for Android with Clean Architecture layers (domain/data/presentation), 6 new design system components (XGHeroBanner, XGCategoryIcon, XGSectionHeader, XGWishlistButton, XGDailyDealCard, XGFlashSaleBanner), Hilt DI module, ViewModel with UDF state management, and a refactored HomeScreen composable with 7 scrollable sections including hero banner auto-scroll carousel, category icons, popular products grid, daily deal countdown timer, new arrivals grid with delivery badges and add-to-cart, and flash sale banner.

## Files Created

### Design System Components (`android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/`)

| File | Description |
|------|-------------|
| `XGHeroBanner.kt` | 192dp card with async image background, heroBannerOverlay gradient (#6000FE 90% to transparent), optional tag badge (BrandSecondary), headline and subtitle text. Includes @Preview. |
| `XGCategoryIcon.kt` | 79dp colored tile with RoundedCornerShape(Medium), 40dp white Material icon resolved by name, 12sp label below. Background color parsed from hex string. Includes @Preview. |
| `XGSectionHeader.kt` | Row with title (titleMedium, Bold), optional subtitle (bodySmall, onSurfaceVariant), and optional "See All" action text with ChevronRight icon. Uses stringResource(R.string.common_see_all). Includes @Preview. |
| `XGWishlistButton.kt` | 32dp circle button with 2dp shadow. Active state: BrandPrimary filled heart. Inactive state: OnSurfaceVariant outlined heart on white background. Includes @Preview for both states. |
| `XGDailyDealCard.kt` | 163dp card with dailyDealCard gradient (#111827 to #6000FE). Contains badge (BrandSecondary bg), title, countdown timer (LaunchedEffect + delay loop), price in BrandSecondary, strikethrough original price, and product image. formatCountdown() uses Locale.ROOT. Includes @Preview. |
| `XGFlashSaleBanner.kt` | 133dp yellow (#FFD814) banner with Canvas-drawn diagonal accent stripes (blue #9EBDF4 left, pink #F60186 right). Optional image via XGImage. Bold headline text. Includes @Preview. |

### Domain Layer (`android/app/src/main/java/com/xirigo/ecommerce/feature/home/domain/`)

| File | Description |
|------|-------------|
| `model/HomeBanner.kt` | Data class: id, title, subtitle, imageUrl, tag, actionProductId, actionCategoryId. |
| `model/HomeCategory.kt` | Data class: id, name, handle, iconName, colorHex. |
| `model/HomeProduct.kt` | Data class: id, title, imageUrl, price, currencyCode, originalPrice, vendor, rating, reviewCount, isNew. |
| `model/DailyDeal.kt` | Data class: productId, title, imageUrl, price, originalPrice, currencyCode, endTime (Long millis). |
| `model/FlashSale.kt` | Data class: id, title, imageUrl, actionUrl. |
| `repository/HomeRepository.kt` | Interface with 6 suspend methods: getBanners(), getCategories(), getPopularProducts(), getDailyDeal(), getNewArrivals(), getFlashSale(). |
| `usecase/GetHomeBannersUseCase.kt` | @Inject constructor, suspend operator fun invoke() delegates to repository.getBanners(). |
| `usecase/GetHomeCategoriesUseCase.kt` | @Inject constructor, suspend operator fun invoke() delegates to repository.getCategories(). |
| `usecase/GetPopularProductsUseCase.kt` | @Inject constructor, suspend operator fun invoke() delegates to repository.getPopularProducts(). |
| `usecase/GetDailyDealUseCase.kt` | @Inject constructor, suspend operator fun invoke() delegates to repository.getDailyDeal(). |
| `usecase/GetNewArrivalsUseCase.kt` | @Inject constructor, suspend operator fun invoke() delegates to repository.getNewArrivals(). |
| `usecase/GetFlashSaleUseCase.kt` | @Inject constructor, suspend operator fun invoke() delegates to repository.getFlashSale(). |

### Data Layer (`android/app/src/main/java/com/xirigo/ecommerce/feature/home/data/`)

| File | Description |
|------|-------------|
| `repository/FakeHomeRepository.kt` | @Inject constructor implementing HomeRepository. Returns hardcoded sample data from private SampleData object. DailyDeal endTime is currentTimeMillis + 8 hours. Sample data includes 3 banners, 6 categories, 6 popular products, 6 new arrivals, 1 flash sale. |

### Presentation Layer (`android/app/src/main/java/com/xirigo/ecommerce/feature/home/presentation/`)

| File | Description |
|------|-------------|
| `state/HomeUiState.kt` | @Stable sealed interface: Loading (object), Success(data: HomeScreenData), Error(message: String). HomeScreenData is @Immutable data class holding banners, categories, popularProducts, dailyDeal, newArrivals, flashSale, wishedProductIds. |
| `state/HomeEvent.kt` | Sealed interface: Refresh, BannerTapped(bannerId), CategoryTapped(categoryId), ProductTapped(productId), WishlistToggled(productId), DailyDealTapped, SeeAllPopularTapped, SeeAllNewArrivalsTapped, SearchBarTapped, RetryTapped. |
| `viewmodel/HomeViewModel.kt` | @HiltViewModel with 6 use cases injected. loadHomeData() launches all 6 in parallel via async. refresh() preserves wishedProductIds across reloads. toggleWishlist() updates local state. onEvent() dispatches HomeEvent. Catches IOException for error state. |

### DI (`android/app/src/main/java/com/xirigo/ecommerce/feature/home/di/`)

| File | Description |
|------|-------------|
| `HomeModule.kt` | @Module @InstallIn(SingletonComponent::class) with @Binds @Singleton binding FakeHomeRepository to HomeRepository. |

## Files Modified

| File | Change |
|------|--------|
| `core/designsystem/component/XGCard.kt` | Added `deliveryLabel: String?` and `onAddToCartClick: (() -> Unit)?` parameters to XGProductCard. Added delivery label text (10sp, BrandSecondary). Added 32dp circular add-to-cart button (BrandSecondary bg, white cart icon). Replaced inline WishlistButton with XGWishlistButton component. |
| `feature/home/presentation/screen/HomeScreen.kt` | Complete refactoring from inline-data stateless composable to ViewModel-driven screen. HomeScreenContent dispatches on HomeUiState (Loading/Error/Success). Sections: WelcomeHeader, SearchBarSection, HeroBannerSection (HorizontalPager + auto-scroll 5s + XGPaginationDots + snapshotFlow page tracking), CategoriesSection (LazyRow + XGCategoryIcon), PopularProductsSection (2-col grid + XGWishlistButton), DailyDealSection (XGSectionHeader + XGDailyDealCard), NewArrivalsSection (2-col grid with delivery badge + add-to-cart), FlashSaleSection (XGFlashSaleBanner). PullToRefreshBox (ExperimentalMaterial3Api). All inline components replaced with XG* design system versions. |
| `res/values/strings.xml` | Added 12 new string keys: home_daily_deal_badge, home_daily_deal_title, home_daily_deal_ended, home_flash_sale_title, home_flash_sale_badge, common_see_all, home_section_daily_deal, home_section_flash_sale, home_error_message, home_error_retry, home_delivery_badge, home_add_to_cart. |

## Key Decisions

1. **FakeHomeRepository with SampleData object**: Sample data extracted to a private SampleData object with constants for repeated strings (vendor names, currency code, image base URL) to satisfy detekt LongMethod and StringLiteralDuplication rules.
2. **HorizontalPager with LaunchedEffect auto-scroll**: Uses snapshotFlow to track settled page, auto-advances every 5 seconds with animateScrollToPage. Resets timer on user interaction.
3. **ProductGridRow extracted composable**: The 2-column product grid uses a manually chunked list with ProductGridRow composable to keep cognitive complexity within detekt thresholds. Uses chunked(2) for row grouping.
4. **PullToRefreshBox over Modifier.pullToRefresh**: Uses the ExperimentalMaterial3Api PullToRefreshBox which is the recommended approach and provides built-in indicator.
5. **Navigation events as no-ops**: BannerTapped, CategoryTapped, ProductTapped, DailyDealTapped, SeeAllPopularTapped, SeeAllNewArrivalsTapped, SearchBarTapped are declared as events but currently no-op in ViewModel. They will be wired to navigation when Route destinations are available.
6. **Wishlist toggle is local state only**: WishlistToggled updates wishedProductIds in HomeScreenData as a local Set. Will be backed by a shared wishlist repository in M2-02.
7. **Daily deal countdown in design system**: The countdown timer logic lives inside XGDailyDealCard (design system layer) since it is purely presentational. The ViewModel only provides the endTime.

## Build Verification

- Build compiles successfully (`compileDebugKotlin`)
- ktlint passes with zero warnings
- detekt passes with zero weighted issues
- All design system components have @Preview annotations
- All screen composables have @Preview annotations
- Domain layer has zero imports from data/ or presentation/
- No `Any` type, no `!!` force unwrap anywhere
- All user-facing strings use stringResource() -- zero hardcoded text
- HomeUiState uses @Stable annotation
- HomeScreenData uses @Immutable annotation

## Test Entry Points for Tester

- `HomeViewModel`: Test Loading state on init, Success state after loadHomeData(), Error state on IOException, Refresh preserves wishedProductIds, toggleWishlist adds/removes productId, onEvent dispatches correctly
- `GetHomeBannersUseCase` (and all 5 other use cases): Delegates to corresponding repository method
- `FakeHomeRepository`: Returns non-empty lists for all methods, DailyDeal endTime is in the future
- UI Testing: Hero banner auto-scrolls, pull-to-refresh works, countdown timer ticks, all 7 sections render, Loading/Error states display correctly

## Integration Points for Future Features

- M1-05 (Category Browsing): Reuses XGCategoryIcon component, CategoryTapped event wires to Route.CategoryBrowsing
- M1-06 (Product List): Reuses XGSectionHeader, XGWishlistButton, SeeAllPopularTapped/SeeAllNewArrivalsTapped wire to Route.ProductList
- M1-07 (Product Detail): Reuses XGWishlistButton, ProductTapped wires to Route.ProductDetail(productId)
- M2-01 (Cart): onAddToCartClick callbacks wire to cart use cases
- M2-02 (Wishlist): wishedProductIds will sync with shared wishlist repository
