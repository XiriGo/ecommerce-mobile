# DQ-33: Brand Component Token Audit

## Summary

Audit and refactor `XGBrandGradient`, `XGBrandPattern`, and `XGLogoMark` on both
Android and iOS so every visual value (colors, gradient stops, opacity, dimensions)
is sourced from design-token constants instead of inline hex literals.

## Token Sources

| Component | Token File | Foundation Reference |
|-----------|-----------|---------------------|
| XGBrandGradient | `components/brand/xg-brand-gradient.json` | `foundations/gradients.json > brandHeader` |
| XGBrandPattern | `components/brand/xg-brand-pattern.json` | `foundations/gradients.json > splashPatternOverlay` |
| XGLogoMark | `components/brand/xg-logo-mark.json` | N/A (self-contained) |

## Audit Findings

### XGBrandGradient

**Current state (both platforms):** Gradient stop colors are hardcoded inline:
- `#9000FE` = `brand.primaryLight` = `XGColors.BrandPrimaryLight` / `XGColors.brandPrimaryLight`
- `#6900FE` = midpoint between primary and primaryLight (not in XGColors yet)
- `#6000FE` = `brand.primary` = `XGColors.BrandPrimary` / `XGColors.brandPrimary`
- `#5D00FB`, `#5800F4`, `#4F00E9`, `#4200DA` = intermediate overlay stops (not in XGColors)
- `#3C00D2` = `brand.primaryDark` = `XGColors.BrandPrimaryDark` / `XGColors.brandPrimaryDark`

**Action:** Since the gradient stops include intermediate colors that are specific to the
brand gradient (not general-purpose brand tokens), add dedicated gradient-stop constants
to both `XGColors.kt` and `XGColors.swift`. Reference these from the component files.

**New token constants needed:**

| Constant Name (Android) | Constant Name (iOS) | Value | Source |
|-------------------------|---------------------|-------|--------|
| `BrandGradientEdge` | `brandGradientEdge` | `#9000FE` | gradients.brandHeader.layers[0].stops[0,3] |
| `BrandGradientMid` | `brandGradientMid` | `#6900FE` | gradients.brandHeader.layers[0].stops[1,2] |
| `BrandOverlayStart` | `brandOverlayStart` | `#6000FE` | gradients.brandHeader.layers[1].stops[0] |
| `BrandOverlayMid1` | `brandOverlayMid1` | `#5D00FB` | gradients.brandHeader.layers[1].stops[1] |
| `BrandOverlayMid2` | `brandOverlayMid2` | `#5800F4` | gradients.brandHeader.layers[1].stops[2] |
| `BrandOverlayMid3` | `brandOverlayMid3` | `#4F00E9` | gradients.brandHeader.layers[1].stops[3] |
| `BrandOverlayMid4` | `brandOverlayMid4` | `#4200DA` | gradients.brandHeader.layers[1].stops[4] |
| `BrandOverlayEnd` | `brandOverlayEnd` | `#3C00D2` | gradients.brandHeader.layers[1].stops[5] |

Note: `BrandGradientEdge` maps to existing `BrandPrimaryLight` and `BrandOverlayEnd`
maps to existing `BrandPrimaryDark`. We can reuse those instead of adding duplicates.
`BrandOverlayStart` maps to existing `BrandPrimary`. So only 4 new constants are truly needed.

**Final mapping:**

| Stop | Android Token | iOS Token |
|------|--------------|-----------|
| Base edge (#9000FE) | `XGColors.BrandPrimaryLight` | `XGColors.brandPrimaryLight` |
| Base mid (#6900FE) | NEW `XGColors.BrandGradientMid` | NEW `XGColors.brandGradientMid` |
| Overlay start (#6000FE) | `XGColors.BrandPrimary` | `XGColors.brandPrimary` |
| Overlay #5D00FB | NEW `XGColors.BrandOverlayMid1` | NEW `XGColors.brandOverlayMid1` |
| Overlay #5800F4 | NEW `XGColors.BrandOverlayMid2` | NEW `XGColors.brandOverlayMid2` |
| Overlay #4F00E9 | NEW `XGColors.BrandOverlayMid3` | NEW `XGColors.brandOverlayMid3` |
| Overlay #4200DA | NEW `XGColors.BrandOverlayMid4` | NEW `XGColors.brandOverlayMid4` |
| Overlay end (#3C00D2) | `XGColors.BrandPrimaryDark` | `XGColors.brandPrimaryDark` |

### XGBrandPattern

**Current state:** `patternOpacity` is hardcoded as `0.06` on both platforms.
This matches `gradients.json > splashPatternOverlay.patternOpacity = 0.06`.

**Action:** Extract to a named constant in the token layer:
- Android: `XGColors.BrandPatternOpacity = 0.06f` (Float constant in XGColors)
- iOS: `XGColors.brandPatternOpacity = 0.06` (static let in XGColors)

Also verify `patternColor` is white (`#FFFFFF`) per token spec (currently not
explicitly set in code but implicit via the white PNG asset).

### XGLogoMark

**Current state:** Default size is `120.dp` / `120` on both platforms.
This matches `xg-logo-mark.json > tokens.defaultSize = 120`.

**Action:** Extract to a named constant:
- Android: `private const val DEFAULT_LOGO_SIZE = 120` (local constant with comment referencing token)
- iOS: constant already implicit in init default parameter. Add a comment referencing the token source.

The logo asset name `SplashLogo` / `splash_logo` matches the token `asset: "SplashLogo"`.
Content mode `fit` is correctly applied. No changes needed for asset or content mode.

### Preview Background Colors

Both iOS files use `Color(hex: "#6000FE")` in previews. These should use
`XGColors.brandPrimary` instead.

## Files to Modify

### Android
1. `android/.../theme/XGColors.kt` — add 4 new gradient token constants + opacity constant
2. `android/.../component/XGBrandGradient.kt` — replace hardcoded colors with XGColors refs
3. `android/.../component/XGBrandPattern.kt` — replace opacity with XGColors constant
4. `android/.../component/XGLogoMark.kt` — add token reference comment

### iOS
1. `ios/.../Theme/XGColors.swift` — add 4 new gradient token constants + opacity constant
2. `ios/.../Component/XGBrandGradient.swift` — replace hardcoded colors with XGColors refs
3. `ios/.../Component/XGBrandPattern.swift` — replace opacity with XGColors constant
4. `ios/.../Component/XGLogoMark.swift` — add token reference comment, use XGColors in previews

## Test Requirements

- Verify components instantiate without crashes (existing tests)
- Verify token constants exist and have expected values
- Verify opacity, size defaults match token spec
