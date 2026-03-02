# DQ-34: Refactor Android HomeScreen to LazyColumn

## Summary

Replaced the eager `Column + verticalScroll` layout in `HomeScreen.kt` with a `LazyColumn` for proper lazy rendering. Only visible items are now composed, improving performance on the home screen.

## Changes

### File Modified
- `android/app/src/main/java/com/xirigo/ecommerce/feature/home/presentation/screen/HomeScreen.kt`

### What Changed
- `Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()))` replaced with `LazyColumn`
- Each home screen section (search bar, hero banners, categories, popular products, daily deal, new arrivals, flash sale) is now a separate `item {}` block with stable string keys
- Section spacing handled via `verticalArrangement = Arrangement.spacedBy(XGSpacing.SectionSpacing)` instead of manual `Spacer` composables between sections
- Top/bottom padding via `contentPadding = PaddingValues(top = XGSpacing.Base, bottom = XGSpacing.SectionSpacing)`

### What Did NOT Change
- All section composables (HeroBannerSection, CategoriesSection, PopularProductsSection, DailyDealSection, NewArrivalsSection, FlashSaleSection) remain unchanged
- ProductGrid and ProductGridRow remain unchanged
- HomeViewModel, HomeUiState, HomeEvent -- zero changes
- Domain models and data layer -- zero changes
- All Preview functions -- unchanged

## Performance Impact
- Off-screen sections are no longer eagerly composed
- LazyColumn only measures and composes items in the viewport
- Scroll state automatically preserved across recomposition and configuration changes via `rememberLazyListState()`

## Pull-to-Refresh
- `PullToRefreshBox` wrapping `LazyColumn` works identically to the previous `Column + verticalScroll` setup

## Platform
Android-only

## Issue
Closes #78 ([DQ-34] Refactor Android HomeScreen to LazyColumn)

## Dependencies
- DQ-22 (XGProductCard upgrade) -- completed
