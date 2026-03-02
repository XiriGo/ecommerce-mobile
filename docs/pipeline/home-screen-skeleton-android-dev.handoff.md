# Android Dev Handoff: HomeScreenSkeleton (DQ-36)

## Files Created
- `android/app/src/main/java/com/xirigo/ecommerce/feature/home/presentation/component/HomeScreenSkeleton.kt`

## Files Modified
- `android/app/src/main/java/com/xirigo/ecommerce/feature/home/presentation/screen/HomeScreen.kt`
  - Replaced `XGLoadingView(modifier = modifier)` with `HomeScreenSkeleton(modifier = modifier)` in Loading state
  - Removed unused `XGLoadingView` import, added `HomeScreenSkeleton` import

## Implementation Notes
- All dimensions extracted as `private val` constants (detekt compliant)
- Uses `LazyRow` for categories and popular products (matches real HomeScreen pattern)
- Uses `Column` with `Row` for 2x2 new arrivals grid (non-lazy, since only 4 items)
- `verticalScroll` on root Column to enable scrolling even in skeleton state
- Accessibility: single `contentDescription` on root Column for "Loading content"
- Individual skeleton shapes remain decorative (no accessibility annotations)
- Preview with `showSystemUi = true` for full-screen preview
