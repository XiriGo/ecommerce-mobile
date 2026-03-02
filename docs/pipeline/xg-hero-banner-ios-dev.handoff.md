# iOS Dev Handoff: DQ-23 XGHeroBanner Upgrade

## Changes Made

### 1. `XGMotion.swift` -- Added auto-scroll token
- `XGMotion.Scroll.autoScrollInterval: TimeInterval = 5.0`

### 2. `XGHeroBanner.swift` -- Added HeroBannerSkeleton
- New `HeroBannerSkeleton` view using `SkeletonBox` + `SkeletonLine`
- Full-width shimmer background at 192pt
- Overlaid skeleton lines for tag, headline, subtitle
- Accessibility label for loading state
- `#Preview` for skeleton (no explicit return)

### 3. `HomeScreenSections.swift` -- Replaced hardcoded auto-scroll
- `BannerConstants.autoScrollInterval` now references `XGMotion.Scroll.autoScrollInterval`

## Verification
- Gradient overlay already uses `XGColors.brandPrimary` (no change)
- Image shimmer handled by `XGImage` (no change)
- All new code uses design tokens (no hardcoded colors/sizes)
- No explicit `return` in `#Preview` closures
