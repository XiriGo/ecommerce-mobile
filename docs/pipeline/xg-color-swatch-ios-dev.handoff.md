# iOS Dev Handoff — XGColorSwatch

## Files Created
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGColorSwatch.swift`
- Updated `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` (added a11y string)

## Implementation Details
- Pure design system atom — no data/domain layers needed
- Circular swatch with `swatchSize` = 40pt from token
- Selection ring uses `XGColors.primary` with 2pt stroke and 3pt gap
- Always-visible border using `XGColors.outline` at 1pt
- Checkmark adapts via luminance detection (> 0.6 = dark check, <= 0.6 = white check)
- Animated selection ring via `.animation(XGMotion.Easing.standard, value: isSelected)`
- Accessibility: `accessibilityLabel` with color name, `.isSelected` trait
- Private `Color.luminance` extension for contrast detection
- Three preview variants: unselected, selected-dark, selected-light

## Token Mapping
| Token | Code Constant |
|-------|---------------|
| size: 40 | `Constants.swatchSize = 40` |
| selectedRingWidth: 2 | `Constants.selectedRingWidth = 2` |
| selectedRingGap: 3 | `Constants.selectedRingGap = 3` |
| whiteBorderWidth: 1 | `Constants.whiteBorderWidth = 1` |
| selectedRingColor: brand.primary | `XGColors.primary` |
| whiteBorderColor: light.borderDefault | `XGColors.outline` |
