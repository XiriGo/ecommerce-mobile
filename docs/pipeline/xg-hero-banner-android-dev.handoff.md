# Android Dev Handoff: DQ-23 XGHeroBanner Upgrade

## Changes Made

### 1. `XGMotion.kt` -- Added auto-scroll token
- `XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS = 5000L`

### 2. `XGHeroBanner.kt` -- Added HeroBannerSkeleton
- New `HeroBannerSkeleton` composable using `SkeletonBox` + `SkeletonLine`
- Full-width shimmer background at 192dp
- Overlaid skeleton lines for tag, headline, subtitle
- Preview composable `HeroBannerSkeletonPreview`

### 3. `HomeScreen.kt` -- Replaced hardcoded auto-scroll
- Removed `private const val AUTO_SCROLL_DELAY_MS = 5000L`
- Uses `XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS` instead

## Verification
- Gradient overlay already uses `XGColors.BrandPrimary` (no change)
- Image shimmer handled by `XGImage` (no change)
- All new code uses design tokens (no hardcoded colors/sizes)
