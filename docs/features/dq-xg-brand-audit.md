# DQ-33: Brand Component Token Audit

## Overview

Audit and refactor of `XGBrandGradient`, `XGBrandPattern`, and `XGLogoMark` on
both Android and iOS to ensure all visual values are sourced from centralized
design-token constants rather than inline hex literals.

## Components Audited

| Component | Android File | iOS File |
|-----------|-------------|----------|
| XGBrandGradient | `XGBrandGradient.kt` | `XGBrandGradient.swift` |
| XGBrandPattern | `XGBrandPattern.kt` | `XGBrandPattern.swift` |
| XGLogoMark | `XGLogoMark.kt` | `XGLogoMark.swift` |

## Token Migration Summary

### New Tokens Added

| Token (Android) | Token (iOS) | Value | Source |
|----------------|-------------|-------|--------|
| `XGColors.BrandGradientMid` | `XGColors.brandGradientMid` | `#6900FE` | `gradients.json > brandHeader.layers[0]` |
| `XGColors.BrandOverlayMid1` | `XGColors.brandOverlayMid1` | `#5D00FB` | `gradients.json > brandHeader.layers[1]` |
| `XGColors.BrandOverlayMid2` | `XGColors.brandOverlayMid2` | `#5800F4` | `gradients.json > brandHeader.layers[1]` |
| `XGColors.BrandOverlayMid3` | `XGColors.brandOverlayMid3` | `#4F00E9` | `gradients.json > brandHeader.layers[1]` |
| `XGColors.BrandOverlayMid4` | `XGColors.brandOverlayMid4` | `#4200DA` | `gradients.json > brandHeader.layers[1]` |
| `XGColors.BRAND_PATTERN_OPACITY` | `XGColors.brandPatternOpacity` | `0.06` | `gradients.json > splashPatternOverlay` |

### Existing Tokens Reused

| Token | Value | Usage |
|-------|-------|-------|
| `BrandPrimaryLight` / `brandPrimaryLight` | `#9000FE` | Base gradient edge stops |
| `BrandPrimary` / `brandPrimary` | `#6000FE` | Overlay start (transparent) |
| `BrandPrimaryDark` / `brandPrimaryDark` | `#3C00D2` | Overlay end (opaque) |

### Logo Mark

- Default size (120) extracted to named constant with token-source comment
- No visual change; asset name and content mode already matched spec

## Test Coverage

### Android (JUnit 4 + Truth)
- `XGBrandGradientTokenTest` — 10 tests covering all gradient color tokens
- `XGBrandPatternTokenTest` — 4 tests covering opacity token value and range
- `XGLogoMarkTokenTest` — 3 tests covering default size token

### iOS (Swift Testing)
- `XGBrandGradientTests` — 11 tests (4 init + 7 token existence)
- `XGBrandPatternTests` — 6 tests (2 init + 4 token value)
- `XGLogoMarkTests` — 6 tests (5 init + 1 token)

## Visual Impact

None. All changes are cosmetic refactors that replace inline hex values with
references to the same values stored in the token layer. The rendered output
is pixel-identical before and after.
