# DQ-05 Skeleton Base Components - Android Dev Handoff

## Status: COMPLETE

## Task
Implement skeleton base components (`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`, `XGSkeleton`) in the Android design system for loading placeholder layouts.

## Files Created / Modified

| File | Type | Purpose |
|------|------|---------|
| `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/Skeleton.kt` | NEW | All four skeleton composables + previews |
| `android/app/src/main/res/values/strings.xml` | MODIFIED | Added `skeleton_loading_placeholder` string |
| `android/app/src/main/res/values-mt/strings.xml` | MODIFIED | Added Maltese translation |
| `android/app/src/main/res/values-tr/strings.xml` | MODIFIED | Added Turkish translation |

## Implementation Details

### SkeletonBox(width, height, modifier, cornerRadius)
- Rectangular shimmer placeholder with configurable dimensions
- Default corner radius: `XGCornerRadius.Medium` (10dp)
- Fill: `XGColors.Shimmer` (#F1F5F9)
- Animation: `shimmerEffect()` from `ShimmerModifier.kt`
- Shape: `RoundedCornerShape(cornerRadius)`

### SkeletonLine(width, modifier, height)
- Text-line shimmer placeholder with fixed `XGCornerRadius.Small` (6dp) corner radius
- Default height: 14dp (approximates bodyMedium line height)
- Fill: `XGColors.Shimmer` (#F1F5F9)
- Animation: `shimmerEffect()`

### SkeletonCircle(size, modifier)
- Circular shimmer placeholder for avatars, icons, thumbnails
- Shape: `CircleShape`
- Fill: `XGColors.Shimmer` (#F1F5F9)
- Animation: `shimmerEffect()`

### XGSkeleton(visible, placeholder, modifier, content)
- Crossfade wrapper using `AnimatedContent` with `fadeIn`/`fadeOut`
- Duration: `XGMotion.Crossfade.CONTENT_SWITCH` (200ms)
- Accessibility: Announces `stringResource(R.string.skeleton_loading_placeholder)` ("Loading content") when `visible = true`
- Label: `"skeletonCrossfade"` for animation tooling

## Accessibility
- Individual shapes (`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`) are decorative -- no contentDescription
- `XGSkeleton` wrapper adds `semantics { contentDescription }` when `visible = true`
- Localized string: EN "Loading content", MT "Qed jitghabba l-kontenut", TR "Icerik yukleniyor"

## Design Token Usage
- `XGColors.Shimmer` -- background fill color
- `XGCornerRadius.Medium` -- default box corner radius
- `XGCornerRadius.Small` -- fixed line corner radius
- `XGCornerRadius.Large` -- used in preview to demonstrate configurability
- `XGMotion.Crossfade.CONTENT_SWITCH` -- crossfade animation duration
- `XGSpacing.Base` / `XGSpacing.SM` / `XGSpacing.XS` -- preview layout spacing

## Previews
1. `SkeletonBoxPreview` -- Box with default and large corner radius
2. `SkeletonLinePreview` -- Line with default and small height
3. `SkeletonCirclePreview` -- Circle with two sizes
4. `ProductCardSkeletonPreview` -- Composed layout mimicking a product card skeleton
5. `XGSkeletonCrossfadePreview` -- Interactive crossfade demo with toggle button

## Quality Checks
- [x] ktlint passes
- [x] detekt passes
- [x] assembleDebug succeeds
- [x] No hardcoded color/dimension values (all from design tokens)
- [x] No `!!` or `Any` usage
- [x] All Dp literals extracted to `private val` constants
- [x] All previews wrapped in `XGTheme`
- [x] Trailing commas on all multi-line parameter lists
- [x] All user-facing strings via `stringResource()`
- [x] Localized strings for EN, MT, TR

## Usage Example
```kotlin
// Skeleton shapes for a product card loading state
Column(verticalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
    SkeletonBox(width = 170.dp, height = 170.dp)
    SkeletonLine(width = 140.dp)
    SkeletonLine(width = 80.dp, height = 12.dp)
    Row(horizontalArrangement = Arrangement.spacedBy(XGSpacing.XS)) {
        SkeletonCircle(size = 12.dp)
        SkeletonLine(width = 30.dp, height = 12.dp)
    }
}

// Crossfade wrapper
XGSkeleton(
    visible = uiState is Loading,
    placeholder = { ProductCardSkeleton() },
) {
    XGProductCard(product = uiState.product)
}
```
