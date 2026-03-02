# XGDivider -- iOS Dev Handoff

## Summary

Implemented XGDivider and XGLabeledDivider views for iOS.

## Files Created

| File | Action |
|------|--------|
| `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGDivider.swift` | Created |

## Implementation Details

- `XGDivider`: Uses `Rectangle()` with fill color and frame height, matching token spec
- `XGLabeledDivider`: HStack with two `XGDivider` instances flanking a `Text` label
- Label uses `XGTypography.captionMedium` (Poppins Medium 12pt) and `XGColors.textTertiary`
- Divider is `accessibilityHidden(true)` as it's decorative
- Both views have `#Preview` macros
- All values sourced from design tokens -- no hardcoded colors/dimensions
- No raw `Divider()` usage found on iOS to replace
