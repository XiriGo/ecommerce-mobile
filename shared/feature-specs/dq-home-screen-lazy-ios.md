# DQ-35: Refactor iOS HomeScreen to LazyVStack/LazyHStack

## Summary

Replace eager `VStack`/`HStack` inside `ScrollView` with `LazyVStack`/`LazyHStack` on the iOS HomeScreen for proper lazy rendering. This is a performance refactor -- no new features, no API changes, no domain model changes.

## Problem

The current `HomeScreen.successContent` uses:
```swift
ScrollView {
    VStack(spacing: XGSpacing.sectionSpacing) {
        searchBar
        heroBannerCarousel(data.banners)
        categoriesSection(data.categories)
        popularProductsSection(data)
        dailyDealSection(data.dailyDeal)
        newArrivalsSection(data)
        flashSaleSection(data.flashSale)
    }
    .padding(.bottom, XGSpacing.xl)
}
```

The `VStack` eagerly lays out all sections, including those off-screen. The horizontal `HStack` containers inside `categoriesSection` and `popularProductsSection` also eagerly render all items.

## Solution

Replace `VStack` with `LazyVStack` and `HStack` with `LazyHStack` where appropriate.

### Architecture Impact

| Layer | Change? | Details |
|-------|---------|---------|
| Domain | NO | No model changes |
| Data | NO | No repository changes |
| Presentation/ViewModel | NO | No state or event changes |
| Presentation/Screen | YES | `HomeScreen.swift` + `HomeScreenSections.swift` refactored |

### File Changes

Two files change:

1. `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreen.swift`
   - Replace `VStack` with `LazyVStack` inside the ScrollView

2. `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreenSections.swift`
   - Replace `HStack` with `LazyHStack` in `categoriesSection`
   - Replace `HStack` with `LazyHStack` in `popularProductsSection`

## Detailed Design

### LazyVStack in ScrollView

```swift
ScrollView {
    LazyVStack(spacing: XGSpacing.sectionSpacing) {
        searchBar
        heroBannerCarousel(data.banners)
        categoriesSection(data.categories)
        popularProductsSection(data)
        dailyDealSection(data.dailyDeal)
        newArrivalsSection(data)
        flashSaleSection(data.flashSale)
    }
    .padding(.bottom, XGSpacing.xl)
}
```

### LazyHStack for Horizontal Lists

Categories section:
```swift
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: XGSpacing.base) {
        ForEach(categories) { category in ... }
    }
    .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
}
```

Popular products section:
```swift
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: XGSpacing.productGridSpacing) {
        ForEach(data.popularProducts) { product in ... }
    }
    .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
}
```

### Key Decisions

1. **LazyVStack alignment**: Use `.leading` alignment to match the existing `VStack` alignment behavior for section headers.

2. **LazyVStack pinned headers**: Not needed -- sections are not grouped under sticky headers.

3. **Hero banner carousel**: `TabView` inside a `LazyVStack` item works fine. The `TabView` has a fixed height (`.frame(height: BannerConstants.carouselHeight)`) so no sizing issues.

4. **New Arrivals grid**: Already uses `LazyVGrid` -- no changes needed.

5. **Pull-to-refresh**: `.refreshable {}` works with `ScrollView { LazyVStack {} }` identically to `ScrollView { VStack {} }`. No changes needed.

6. **Conditional sections (dailyDeal, flashSale)**: `Group { if let ... }` inside `LazyVStack` works correctly. The lazy stack simply skips empty sections.

## Testing

- Verify all sections render correctly
- Verify pull-to-refresh works
- Verify horizontal scrolling in categories and popular products works
- Verify banner auto-scroll works
- No new tests required -- existing ViewModel tests cover data flow; this is a pure layout change

## Platform

iOS-only
