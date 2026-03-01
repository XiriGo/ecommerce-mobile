# DQ-07 XGImage Shimmer + Motion Tokens - Android Dev Handoff

## Status: COMPLETE

## Task
Upgrade `XGImage.kt` to replace static placeholder with animated shimmer, use motion tokens for crossfade, and add branded error fallback.

## Files Modified

| File | Change |
|------|--------|
| `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGImage.kt` | Replaced AsyncImage with SubcomposeAsyncImage; shimmer loading; branded error fallback; motion token crossfade |

## Implementation Details

### 1. SubcomposeAsyncImage Migration
- Replaced `coil3.compose.AsyncImage` with `coil3.compose.SubcomposeAsyncImage` to support composable slots for loading, error, and content states
- Removed `ColorPainter` placeholder (was a static solid color)
- Uses `SubcomposeAsyncImageContent(contentScale = contentScale)` for the loaded content slot

### 2. Crossfade Duration (Motion Token)
- Removed hardcoded `private const val CROSSFADE_DURATION_MS = 250`
- Now uses `XGMotion.Crossfade.IMAGE_FADE_IN` (300ms) passed directly to `.crossfade(Int)` on the ImageRequest builder
- Single `.crossfade(Int)` call replaces the previous `.crossfade(true)` + `.crossfade(Int)` double-call

### 3. Loading State (Shimmer)
- `loading` slot renders a `Box` with `Modifier.matchParentSize()`, `background(XGColors.Shimmer)`, and `.shimmerEffect()`
- Produces an animated shimmer sweep instead of a static gray rectangle

### 4. Error State (Branded Fallback)
- `error` slot renders a `Box` with `background(XGColors.SurfaceVariant)` and a centered `Icons.Outlined.Image` icon
- Icon tint uses `XGColors.OnSurfaceVariant` for brand consistency
- Visually distinct from the loading shimmer (no animation, different background color)

### 5. Null URL State
- When `url` is `null`, renders a Box with `background(XGColors.Shimmer)` + `.shimmerEffect()` and a centered image icon
- Replaced previous static-only background

### 6. Dimension Extraction
- `PlaceholderIconSize = 27.dp` -- from `shared/design-tokens/foundations/spacing.json` (`layout.iconSize.large`)
- `PreviewImageSize = 200.dp` -- preview-only constant
- No inline dp literals remain in composable bodies

### 7. Previews
Three `@Preview` composables:
1. `XGImagePlaceholderPreview` -- null URL (shimmer + icon)
2. `XGImageWithUrlPreview` -- valid URL (shows loading shimmer, then content)
3. `XGImageErrorPreview` -- broken URL (shows error fallback)

## Design Token Usage
- `XGMotion.Crossfade.IMAGE_FADE_IN` -- crossfade duration (300ms)
- `XGColors.Shimmer` -- loading placeholder background
- `XGColors.SurfaceVariant` -- error fallback background
- `XGColors.OnSurfaceVariant` -- error/placeholder icon tint
- `Modifier.shimmerEffect()` -- animated shimmer gradient from `ShimmerModifier.kt`

## Dependencies (Not Modified)
- `ShimmerModifier.kt` -- provides `Modifier.shimmerEffect()`
- `XGMotion.kt` -- provides `XGMotion.Crossfade.IMAGE_FADE_IN`
- `XGColors.kt` -- provides color tokens

## Quality Checks
- [x] No hardcoded colors (all from XGColors tokens)
- [x] No hardcoded animation values (uses XGMotion tokens)
- [x] All dp literals extracted to named private vals
- [x] Trailing commas on all multi-line parameter lists
- [x] No `!!` or `Any` usage
- [x] Three previews wrapped in XGTheme (loading, URL, error)
- [x] KDoc on public composable and private constants
