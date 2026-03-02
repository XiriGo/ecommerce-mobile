# Android Dev Handoff — DQ-33 Brand Audit

## Changes Made

### XGColors.kt
- Added `BrandGradientMid` (#6900FE) — brandHeader base gradient midpoint
- Added `BrandOverlayMid1` (#5D00FB) — dark overlay intermediate stop 1
- Added `BrandOverlayMid2` (#5800F4) — dark overlay intermediate stop 2
- Added `BrandOverlayMid3` (#4F00E9) — dark overlay intermediate stop 3
- Added `BrandOverlayMid4` (#4200DA) — dark overlay intermediate stop 4
- Added `BRAND_PATTERN_OPACITY` (0.06f) — splash pattern overlay opacity

### XGBrandGradient.kt
- Replaced all `Color(0xFF...)` literals with `XGColors.*` token references
- Base gradient: uses `BrandPrimaryLight` and `BrandGradientMid`
- Dark overlay: uses `BrandPrimary`, `BrandOverlayMid1-4`, `BrandPrimaryDark` with `.copy(alpha=)`
- Removed `import Color` (no longer directly used)

### XGBrandPattern.kt
- Replaced hardcoded `PATTERN_OPACITY = 0.06f` with `XGColors.BRAND_PATTERN_OPACITY`
- Added `import XGColors`

### XGLogoMark.kt
- Extracted `DEFAULT_LOGO_SIZE = 120.dp` as named constant with token doc reference
- No functional change

## Verification
- ktlint check passed
- No behavioral changes (pixel-identical output)
