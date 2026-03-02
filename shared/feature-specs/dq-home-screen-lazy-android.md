# DQ-34: Refactor Android HomeScreen to LazyColumn

## Summary

Replace the eager `Column + verticalScroll` layout in `HomeScreen` with a `LazyColumn` for proper lazy rendering. This is a performance refactor -- no new features, no API changes, no domain model changes.

## Problem

The current `HomeScreenContent` (Success branch) uses:
```kotlin
Column(
    modifier = Modifier
        .fillMaxSize()
        .verticalScroll(rememberScrollState()),
) { /* all sections */ }
```

This eagerly composes **every** section and child item, even those off-screen. For a home screen with banners, categories, product rows, daily deals, new arrivals, and flash sales, this causes unnecessary composition work and memory pressure.

## Solution

Replace with `LazyColumn` which only composes visible items.

### Architecture Impact

| Layer | Change? | Details |
|-------|---------|---------|
| Domain | NO | No model changes |
| Data | NO | No repository changes |
| Presentation/ViewModel | NO | No state or event changes |
| Presentation/Screen | YES | `HomeScreenContent` refactored to `LazyColumn` |

### File Changes

Only one file changes: `HomeScreen.kt`

Path: `android/app/src/main/java/com/xirigo/ecommerce/feature/home/presentation/screen/HomeScreen.kt`

## Detailed Design

### LazyColumn Structure

```
LazyColumn
  item { SearchBar }
  item { HeroBannerSection (HorizontalPager) }
  item { CategoriesSection (LazyRow) }
  item { PopularProductsSection (LazyRow) }
  item { DailyDealSection } (conditional)
  item { NewArrivalsSectionHeader }
  // New arrivals grid: chunked into rows, each as an item
  items(newArrivalsRows) { ProductGridRow }
  item { FlashSaleSection } (conditional)
  item { BottomSpacer }
```

### Key Decisions

1. **Nested scrollable containers**: `LazyRow` inside `item {}` is supported by Compose. `HorizontalPager` inside `item {}` is also supported. No height constraints needed for fixed-height children.

2. **New Arrivals grid**: The current `ProductGrid` composable uses `Column` with `chunked(2)` rows. Inside `LazyColumn`, we have two options:
   - **Option A**: Keep `ProductGrid` as-is inside a single `item {}` -- simpler but the grid items are not individually lazy.
   - **Option B**: Flatten the grid rows into individual `items {}` blocks in the `LazyColumn` -- truly lazy per row.

   **Decision**: Option A (single `item {}`) because the new arrivals list is typically small (4-8 items, 2-4 rows), so the performance gain from per-row laziness is negligible, and Option A preserves the existing `ProductGrid` composable unchanged.

3. **Scroll state preservation**: Replace `rememberScrollState()` with `rememberLazyListState()`. `LazyListState` automatically survives recomposition. For configuration changes (rotation), the state is saved/restored by Compose's `rememberSaveable` integration in `rememberLazyListState`.

4. **Pull-to-refresh**: `PullToRefreshBox` wrapping `LazyColumn` works identically to wrapping `Column + verticalScroll`. No changes needed to the pull-to-refresh behavior.

5. **Section spacing**: Replace `Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))` between sections with:
   - `verticalArrangement = Arrangement.spacedBy(XGSpacing.SectionSpacing)` on the `LazyColumn`, OR
   - Keep explicit `Spacer` items.

   **Decision**: Use `verticalArrangement = Arrangement.spacedBy(...)` for cleaner code. However, since some sections are conditional (dailyDeal, flashSale), the spacing automatically handles only visible items.

6. **Content padding**: Use `contentPadding` parameter on `LazyColumn` for top/bottom spacing instead of manual `Spacer` items.

### Import Changes

Remove:
- `import androidx.compose.foundation.rememberScrollState`
- `import androidx.compose.foundation.verticalScroll`

Add:
- `import androidx.compose.foundation.lazy.LazyColumn`
- `import androidx.compose.foundation.lazy.rememberLazyListState` (if explicit state needed)

### Unchanged Composables

These private composables remain exactly as-is:
- `HeroBannerSection` -- already a self-contained composable
- `CategoriesSection` -- already uses `LazyRow`
- `PopularProductsSection` -- already uses `LazyRow`
- `DailyDealSection` -- self-contained
- `NewArrivalsSection` -- self-contained
- `ProductGrid` / `ProductGridRow` -- self-contained
- `FlashSaleSection` -- self-contained
- `mapCategoryIcon` / `parseHexColor` -- utility functions
- All Preview functions (update `HomeScreenContent` call if signature changes)

### Acceptance Criteria

- [ ] `Column + verticalScroll` replaced with `LazyColumn`
- [ ] Each section is a separate `item {}` block
- [ ] `LazyRow` sections work inside `item {}` (categories, popular products)
- [ ] `HorizontalPager` works inside `item {}` (hero banners)
- [ ] Pull-to-refresh behavior preserved
- [ ] Scroll position preserved on configuration change
- [ ] No eager rendering of off-screen content
- [ ] All existing previews compile and render
- [ ] Build passes (ktlintCheck, detekt, test)
- [ ] No changes to domain, data, or ViewModel layers

## Platform

Android-only (label: `platform:android`)

## Dependencies

- DQ-22 (XGProductCard upgrade) -- closed/done
