# Handoff: home-screen -- Architect

## Feature
**M1-04: Home Screen** -- Primary landing screen with hero banner carousel, categories, popular products, daily deal, new arrivals, flash sale banner, and Clean Architecture integration.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/home-screen.md` |
| This Handoff | `docs/pipeline/home-screen-architect.handoff.md` |

## Summary of Spec

The home-screen spec defines a vertical scrollable feed with 7 sections, 6 new design system components, Clean Architecture layers with a FakeHomeRepository, and a ViewModel-driven state management approach.

### CRITICAL: Extend Existing Code, Do NOT Recreate

Both platforms already have a HomeScreen with basic sections and sample data. The pipeline MUST refactor and extend the existing code -- NOT delete and recreate from scratch.

**Existing files to modify:**
- Android: `android/app/src/main/java/com/xirigo/ecommerce/feature/home/presentation/screen/HomeScreen.kt`
- iOS: `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreen.swift`

**Existing file to DELETE (iOS only):**
- `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreenSampleData.swift` -- replaced by FakeHomeRepository

### Screen Sections (top to bottom)
1. **Search Bar** -- existing, add navigation callback (Android needs wiring)
2. **Hero Banner Carousel** -- replace existing static LazyRow/ScrollView with HorizontalPager/TabView, add auto-scroll (5s), add XGPaginationDots
3. **Categories** -- replace inline category circles with XGCategoryIcon component
4. **Popular Products** -- existing 2-col grid, add XGWishlistButton, wire to ViewModel
5. **Daily Deal** -- NEW section, XGDailyDealCard with countdown timer
6. **New Arrivals** -- CHANGE from horizontal scroll to 2-col grid, add delivery badge + add-to-cart FAB
7. **Flash Sale Banner** -- NEW section, XGFlashSaleBanner

### New Design System Components (6 total, in core/designsystem/component/)
1. **XGHeroBanner** -- Async image bg + gradient overlay + tag badge + headline. Token: `components.json > XGCard.heroBanner`
2. **XGCategoryIcon** -- 79x79dp colored tile + icon + label. Token: `components.json > XGCategoryIcon`
3. **XGSectionHeader** -- Title + optional subtitle + optional "See All" action. Replaces inline helpers.
4. **XGWishlistButton** -- 32x32dp heart toggle. Token: `components.json > XGWishlistButton`. Extracts from XGCard.
5. **XGDailyDealCard** -- Gradient card with countdown + product info. Token: `components.json > XGCard.dailyDeal`
6. **XGFlashSaleBanner** -- Yellow banner with accent stripes. Token: `components.json > XGCard.flashSale`

### Existing Components (DO NOT RECREATE)
- **XGPaginationDots** -- Already exists from onboarding pipeline. Reuse for hero carousel.
- **XGProductCard** -- Already exists. UPDATE to add `deliveryLabel` and `onAddToCartClick`/`onAddToCartAction` params. Use `XGWishlistButton` internally.
- **XGImage, XGPriceText, XGRatingBar, XGBadge** -- Already exist. Use as-is.

### Architecture (Clean Architecture)
- **Domain**: `HomeRepository` interface, 6 use cases (one per section), 5 domain models (`HomeBanner`, `HomeCategory`, `HomeProduct`, `DailyDeal`, `FlashSale`)
- **Data**: `FakeHomeRepository` with hardcoded sample data (replaces inline sample data)
- **Presentation**: `HomeViewModel` with `HomeUiState` (Loading/Success/Error), `HomeEvent` sealed interface/enum, `HomeScreenData` composite state
- **DI**: Hilt module (Android) / Factory container extension (iOS)

### Android Specifics
- 23 new files (17 feature + 6 design system)
- 2 modified files (HomeScreen.kt, XGCard.kt)
- Hero carousel: `HorizontalPager` with `LaunchedEffect` timer
- Countdown: `LaunchedEffect` with `delay(1000)` loop
- Pull-to-refresh: `Modifier.pullToRefresh()` or `PullToRefreshBox`
- New arrivals: change from `LazyRow` to `LazyVerticalGrid(GridCells.Fixed(2))`
- Search bar: wire `clickable` to `AppRouter.navigate(Route.ProductSearch)`
- Replace inline `SectionHeader` composable with `XGSectionHeader`

### iOS Specifics
- 23 new files (17 feature + 6 design system)
- 2 modified files (HomeScreen.swift, XGCard.swift)
- 1 deleted file (HomeScreenSampleData.swift)
- Hero carousel: `TabView(.page)` with `Timer.publish` for auto-scroll
- Countdown: `TimelineView(.periodic(from:, by: 1))`
- Pull-to-refresh: `.refreshable { await viewModel.refresh() }`
- New arrivals: change from horizontal `ScrollView` to `LazyVGrid` with 2 columns
- Replace inline `sectionHeader()` function with `XGSectionHeader`
- Delete `HomeScreenSampleData.swift` (data moves to FakeHomeRepository)

### Localization
- 11 new string keys in English and Turkish
- All existing string keys preserved

## Key Decisions

1. **FakeHomeRepository over inline sample data**: Moving sample data to a proper repository implementation establishes the Clean Architecture pattern and makes the transition to real API calls a single-file swap.

2. **One use case per repository method**: Each section has its own use case (GetHomeBannersUseCase, GetPopularProductsUseCase, etc.) following single-responsibility. This allows sections to be loaded in parallel with `async/await`.

3. **Composite HomeScreenData state**: All section data is grouped into a single `HomeScreenData` class held by `HomeUiState.Success`. This simplifies state observation -- the screen renders from one state object rather than multiple flows.

4. **Navigation in Screen, not ViewModel**: Navigation events (product tap, category tap, etc.) are handled directly in the screen composable/view, not routed through the ViewModel. This keeps the ViewModel focused on data state and avoids platform-specific navigation coupling.

5. **XGWishlistButton extracted from XGCard**: The wishlist toggle is extracted into a standalone design system component because it will be reused on Product Detail (M1-07) and Wishlist screen (M2-02) independently of product cards.

6. **New arrivals changed to 2-column grid**: The BUYER_APP.md spec and design tokens define new arrivals as a grid layout with delivery badges and add-to-cart FABs. The existing horizontal scroll is being refactored to match the spec.

7. **Daily deal countdown uses platform-native timers**: Android uses `LaunchedEffect` coroutine loop, iOS uses `TimelineView` for efficient clock-driven updates. Both avoid polling-based approaches.

8. **Welcome header preserved**: The existing welcome header section is kept since it exists on both platforms and provides user context. It can be removed in a future design iteration.

9. **Domain models replace sample data types**: The new `HomeBanner`, `HomeCategory`, `HomeProduct` domain models replace the existing `HomeBanner`, `HomeCategory`, `HomeProduct` structs/data classes that were defined inline in the sample data files.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | File manifest (section 11.1), component APIs (section 4), architecture (section 3), Android notes (section 12.1), verification criteria (section 13) |
| iOS Dev | File manifest (section 11.2), component APIs (section 4), architecture (section 3), iOS notes (section 12.2), verification criteria (section 13) |

## Verification

Downstream developers should verify their implementation using the criteria in spec section 13. Key areas:
- All 7 sections render correctly
- Hero banner auto-scrolls and supports manual swipe
- Daily deal countdown ticks and shows "ENDED" at zero
- Pull-to-refresh reloads all sections
- Loading/Error states work correctly
- All new XG* components have previews
- No raw platform UI components in feature screens
- Domain layer has zero data/presentation imports

## Notes for Next Features

- **M1-05 (Category Browsing)**: Reuses `XGCategoryIcon` component.
- **M1-06 (Product List)**: Reuses `XGSectionHeader` and `XGWishlistButton`.
- **M1-07 (Product Detail)**: Reuses `XGWishlistButton`.
- **M2-01 (Cart)**: The `onAddToCartClick`/`onAddToCartAction` callbacks on `XGProductCard` will wire into cart use cases.
- **M2-02 (Wishlist)**: The `wishedProductIds` in `HomeScreenData` will eventually sync with a shared wishlist repository.
