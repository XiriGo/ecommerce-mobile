# DQ-17 XGTextField Token Audit — Review Handoff

## Summary

Audited `XGTextField` on both Android (Kotlin/Compose) and iOS (Swift/SwiftUI) against the
token specification at `shared/design-tokens/components/atoms/xg-text-field.json`.

## Changes Made

### Android (`XGTextField.kt`)

| Property | Before | After | Token Reference |
|----------|--------|-------|-----------------|
| Field height | None (Material default) | `heightIn(min = 52.dp)` | `inputSize.default.height = 52` |
| Container/background color | Material default | `XGColors.InputBackground` | `colors.light.inputBackground` |
| Border color (unfocused) | Material default | `XGColors.InputBorder` | `colors.light.inputBorder` |
| Border color (focused) | Material default | `XGColors.Primary` | `colors.brand.primary` |
| Border color (error) | Material default | `XGColors.Error` | `colors.semantic.error` |
| Border color (disabled) | Material default | `XGColors.InputBorder` | `colors.light.inputBorder` |
| Label color (unfocused) | Material default | `XGColors.InputPlaceholder` | `colors.light.inputPlaceholder` |
| Label color (focused) | Material default | `XGColors.Primary` | `colors.brand.primary` |
| Label color (error) | Material default | `XGColors.Error` | `colors.semantic.error` |
| Placeholder color | Material default | `XGColors.InputPlaceholder` | `colors.light.inputPlaceholder` |
| Text color | Material default | `XGColors.OnSurface` | `colors.light.textPrimary` |
| Text style | Implicit | Explicit `MaterialTheme.typography.bodyLarge` | `typeScale.bodyLarge` |
| Label style | Implicit | Explicit `MaterialTheme.typography.bodySmall` | `typeScale.bodySmall` (12pt Regular) |
| Placeholder style | Implicit | Explicit `MaterialTheme.typography.bodyLarge` | `typeScale.bodyLarge` |
| Supporting text colors | `MaterialTheme.colorScheme.error/onSurfaceVariant` | `XGColors.Error/OnSurfaceVariant` | Direct token usage |
| Disabled opacity | None | `0.38f` via `XGTextFieldTokens.DISABLED_OPACITY` | Material convention |
| Corner radius | `XGCornerRadius.Medium` (already correct) | Same | `cornerRadius.medium = 10` |

### iOS (`XGTextField.swift`)

| Property | Before | After | Token Reference |
|----------|--------|-------|-----------------|
| Field height | Implicit from padding | `frame(minHeight: 52)` | `inputSize.default.height = 52` |
| Background color | None (transparent) | `XGColors.inputBackground` | `colors.light.inputBackground` |
| Border color (unfocused) | `XGColors.outline` | `XGColors.inputBorder` | `colors.light.inputBorder` |
| Border width (unfocused) | Hardcoded `1` | `XGTextFieldTokens.borderWidth` | `default.borderWidth = 1` |
| Border width (focused) | Hardcoded `2` | `XGTextFieldTokens.focusBorderWidth` | `default.focusBorderWidth = 2` |
| Label color (unfocused) | `XGColors.onSurfaceVariant` | `XGColors.inputLabel` | `colors.light.inputLabel` |
| Text color | System default | `XGColors.onSurface` | `colors.light.textPrimary` |
| Disabled opacity | Hardcoded `0.38` | `XGTextFieldTokens.disabledOpacity` | Named constant |
| Background clip | Stroke only | `clipShape` + `overlay` stroke | Proper background rendering |

### Both Platforms

- Added `XGTextFieldTokens` private constants object with documented token references
- Added disabled-state preview variant
- All font references explicit (bodySmall for labels, bodyLarge for input text)
- All color references use `XGColors.*` tokens directly (no Material theme indirection)
- Corner radius unchanged (`XGCornerRadius.Medium = 10`)
- Horizontal padding uses `XGSpacing.MD = 12` (matches token `horizontalPadding`)

## Token Compliance

All properties specified in `xg-text-field.json` are now token-driven:
- [x] Field height from tokens (52dp/pt)
- [x] Corner radius from tokens (XGCornerRadius.medium = 10)
- [x] Label/placeholder/input fonts from tokens (bodySmall / bodyLarge)
- [x] Border colors (default, focused, error, disabled) from tokens
- [x] Disabled opacity as named constant (0.38)
- [x] Background color from tokens (inputBackground)
- [x] Text color from tokens (onSurface / textPrimary)

## Files Modified

- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGTextField.kt`
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGTextField.swift`
- `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGTextFieldTests.swift`

## Verification

- Android: `compileDebugKotlin` -- PASS
- Android: `ktlintCheck` -- PASS
- Android: `detekt` -- PASS
- Android: `test` -- PASS
