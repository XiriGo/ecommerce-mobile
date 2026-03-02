# DQ-16 XGQuantityStepper Token Audit — Review Handoff

## Summary

Audited `XGQuantityStepper` on both Android and iOS against the token spec at
`shared/design-tokens/components/atoms/xg-quantity-stepper.json`.

## Token Mapping

| Token | Spec Value | Android Before | Android After | iOS Before | iOS After |
|-------|-----------|---------------|--------------|-----------|----------|
| buttonSize | minTouchTarget (48) | XGSpacing.MinTouchTarget | XGSpacing.MinTouchTarget | XGSpacing.minTouchTarget | XGSpacing.minTouchTarget |
| buttonBackground | surfaceTertiary (#F1F5F9) | none | XGColors.SurfaceTertiary | XGColors.surfaceVariant | XGColors.surfaceTertiary |
| buttonCornerRadius | cornerRadius.medium (10) | none | XGCornerRadius.Medium | XGCornerRadius.medium | XGCornerRadius.medium |
| iconSize | iconSize.medium (24) | default | StepperConstants.ICON_SIZE | XGSpacing.IconSize.medium | XGSpacing.IconSize.medium |
| iconColor | textPrimary (#333333) | default Material | XGColors.OnSurface | XGColors.onSurface | XGColors.onSurface |
| disabledIconColor | textSecondary (#8E8E93) | default Material | XGColors.OnSurfaceVariant | XGColors.onSurfaceVariant | XGColors.onSurfaceVariant |
| disabledOpacity | 0.38 | none | StepperConstants.DISABLED_OPACITY | hardcoded 0.38 | StepperConstants.disabledOpacity |
| quantityFont | titleMedium (16pt Medium) | MaterialTheme.typography.titleMedium | MaterialTheme.typography.titleMedium | XGTypography.titleMedium | XGTypography.titleMedium |
| quantityMinWidth | spacing.xl (24) | none | XGSpacing.XL | XGSpacing.xl | XGSpacing.xl |
| spacing | spacing.md (12) | XGSpacing.SM (8dp) | XGSpacing.MD (12dp) | XGSpacing.md | XGSpacing.md |

## Theme Additions

- Added `XGColors.SurfaceTertiary` = `Color(0xFFF1F5F9)` to Android `XGColors.kt`
- Added `XGColors.surfaceTertiary` = `Color(hex: "#F1F5F9")` to iOS `XGColors.swift`

## Files Changed

### Android
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGQuantityStepper.kt`
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGColors.kt`

### iOS
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGQuantityStepper.swift`
- `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGColors.swift`

### Shared
- `CHANGELOG.md`

## Quality Checks

- Android: `compileDebugKotlin` PASS
- Android: `ktlintCheck` PASS
- Android: `detekt` PASS
- Existing tests on both platforms remain valid (no logic changes)

## Spec Compliance

All tokens from `xg-quantity-stepper.json` are now mapped to named design system constants.
Zero hardcoded values remain in the component implementations.
