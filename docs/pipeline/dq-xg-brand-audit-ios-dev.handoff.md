# iOS Dev Handoff — DQ-33 Brand Audit

## Changes Made

### XGColors.swift
- Added `brandGradientMid` (#6900FE) — brandHeader base gradient midpoint
- Added `brandOverlayMid1` (#5D00FB) — dark overlay intermediate stop 1
- Added `brandOverlayMid2` (#5800F4) — dark overlay intermediate stop 2
- Added `brandOverlayMid3` (#4F00E9) — dark overlay intermediate stop 3
- Added `brandOverlayMid4` (#4200DA) — dark overlay intermediate stop 4
- Added `brandPatternOpacity` (0.06) — splash pattern overlay opacity

### XGBrandGradient.swift
- Replaced all `Color(hex: "#...")` literals with `XGColors.*` token references
- Base gradient: uses `brandPrimaryLight` and `brandGradientMid`
- Dark overlay: uses `brandPrimary`, `brandOverlayMid1-4`, `brandPrimaryDark` with `.opacity()`

### XGBrandPattern.swift
- Replaced hardcoded `patternOpacity = 0.06` with `XGColors.brandPatternOpacity`
- Preview backgrounds now use `XGColors.brandPrimary` instead of `Color(hex: "#6000FE")`

### XGLogoMark.swift
- Extracted `defaultSize: CGFloat = 120` as private static constant with token doc reference
- Preview backgrounds now use `XGColors.brandPrimary` instead of `Color(hex: "#6000FE")`
- No functional change

## Verification
- SwiftLint + SwiftFormat passed
- No behavioral changes (pixel-identical output)
