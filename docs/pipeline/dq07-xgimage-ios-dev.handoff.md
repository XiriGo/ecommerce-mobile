# DQ-07 XGImage Shimmer + State Separation (iOS) - Dev Handoff

## Status: COMPLETE

## What was implemented

### Modified file
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGImage.swift`

### Summary
Upgraded XGImage to separate loading and error states with distinct visual treatments:

1. **Loading state (`.empty`)**: Animated shimmer placeholder using `.shimmerEffect()` with NO icon overlay. Provides visual feedback that content is actively loading.
2. **Error state (`.failure`)**: Static branded fallback with `XGColors.surfaceVariant` background and a centered photo icon at `errorIconOpacity` (0.5). No shimmer animation.
3. **Success state**: Unchanged -- fades in with `XGMotion.Crossfade.imageFadeIn` (0.3s) easeInOut transition.

### Changes from previous implementation
- **Before**: Both `.failure` and `.empty` showed the same `placeholderView` (static shimmer color + photo icon).
- **After**: Two separate views:
  - `loadingView` -- shimmer-animated rectangle, no icon, `accessibilityHidden(true)`
  - `errorFallbackView` -- static `surfaceVariant` rectangle with photo icon overlay
- **Magic number extraction**: `0.5` opacity extracted to `private static let errorIconOpacity: Double = 0.5`
- **Preview constants**: Extracted `200`/`150` to `PreviewConstants.width`/`PreviewConstants.height`
- **New preview**: Added "XGImage Error" preview with broken URL to show error fallback
- **Renamed preview**: "XGImage Placeholder" renamed to "XGImage Loading" for clarity

### Design tokens used (no hardcoded values)
- `XGColors.shimmer` -- `Color(hex: "#F1F5F9")` loading state fill
- `XGColors.surfaceVariant` -- `Color(hex: "#F1F5F9")` error state fill
- `XGColors.onSurfaceVariant` -- `Color(hex: "#8E8E93")` error icon color
- `XGSpacing.IconSize.large` -- 27pt error icon size
- `XGCornerRadius.medium` -- 10pt preview clip shape
- `XGMotion.Crossfade.imageFadeIn` -- 0.3s fade-in transition

### Dependencies used (not modified)
- `ShimmerModifier.swift` -- `.shimmerEffect()` extension
- `XGMotion.swift` -- `XGMotion.Crossfade.imageFadeIn`
- `XGColors.swift` -- all color tokens
- `XGSpacing.swift` -- `XGSpacing.IconSize.large`

### API (unchanged)
```swift
XGImage(url: someURL)
XGImage(url: someURL, contentMode: .fit)
XGImage(url: someURL, accessibilityLabel: "Product photo")
```

### Previews (3 total)
1. **XGImage Loading** -- nil URL showing animated shimmer (loading state)
2. **XGImage with URL** -- nil URL with accessibility label
3. **XGImage Error** -- broken URL showing static error fallback with icon

### Android parity
Android `XGImage.kt` uses Coil's built-in `placeholder`/`error` painters with `XGColors.Shimmer`. The iOS implementation provides the same behavioral distinction:
- Loading: shimmer animation (Android: Coil crossfade placeholder)
- Error: branded fallback (Android: Coil error painter)
- The iOS version adds `.shimmerEffect()` animation which Android currently handles via Coil's crossfade

## Checklist
- [x] Uses `XGColors.shimmer` token (no hardcoded colors)
- [x] Uses `XGColors.surfaceVariant` token for error state
- [x] Uses `XGColors.onSurfaceVariant` token for error icon
- [x] Uses `XGSpacing.IconSize.large` token (no hardcoded sizes)
- [x] Uses `XGMotion.Crossfade.imageFadeIn` token (no hardcoded durations)
- [x] `.shimmerEffect()` applied to loading state
- [x] `.accessibilityHidden(true)` on loading view
- [x] `.accessibilityHidden(true)` on error icon
- [x] Magic number extracted: `errorIconOpacity = 0.5`
- [x] `PreviewConstants` enum for preview dimensions
- [x] `#Preview` macro used (not PreviewProvider)
- [x] `.xgTheme()` applied to all previews
- [x] Error state preview added
- [x] No force unwrap (`!`)
- [x] No hardcoded `Color(hex:)` in component
- [x] MARK section headers throughout
- [x] Trailing commas on multi-line parameters

## Files changed
1. `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGImage.swift` (MODIFIED)
