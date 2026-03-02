# Android Dev Handoff — XGColorSwatch

## Files Created
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGColorSwatch.kt`
- Updated `android/app/src/main/res/values/strings.xml` (added a11y strings)

## Implementation Details
- Pure design system atom — no data/domain layers needed
- Circular swatch with `SwatchSize` = 40dp from token
- Selection ring uses `XGColors.Primary` with 2dp stroke and 3dp gap
- Always-visible border using `XGColors.Outline` at 1dp
- Checkmark adapts via luminance detection (> 0.6 = dark check, <= 0.6 = white check)
- Animated selection ring via `animateFloatAsState` + `animateColorAsState` with `XGMotion.Easing.standardTween`
- Accessibility: `contentDescription` with color name, `Role.RadioButton`, `selected` semantics
- Three preview variants: unselected, selected-dark, selected-light

## Token Mapping
| Token | Code Constant |
|-------|---------------|
| size: 40 | `SwatchSize = 40.dp` |
| selectedRingWidth: 2 | `SelectedRingWidth = 2.dp` |
| selectedRingGap: 3 | `SelectedRingGap = 3.dp` |
| whiteBorderWidth: 1 | `WhiteBorderWidth = 1.dp` |
| selectedRingColor: brand.primary | `XGColors.Primary` |
| whiteBorderColor: light.borderDefault | `XGColors.Outline` |
