# DQ-18 XGChip Token Audit -- Architect Handoff

## Spec Location
`shared/feature-specs/xg-chip.md`

## Summary
Platform-agnostic specification for upgrading XGFilterChip and XGCategoryChip
to use explicit design tokens from `xg-chip.json`. Both variants (filter and
category) need height, radius, padding, colors, font, and icon size from tokens.

## Key Decisions
1. Filter variant uses `RoundedCornerShape(18.dp)` / `RoundedRectangle(cornerRadius: 18)`
   instead of generic Capsule, since token specifies exact 18dp radius
2. New filterPill color tokens added to both `XGColors.kt` and `XGColors.swift`
3. Android switches from Material 3 `FilterChip` defaults to explicit token overrides
4. iOS switches from semantic color aliases to dedicated filterPill tokens
5. Category variant background changes from surfaceVariant to surfaceTertiary

## Files to Modify
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGColors.kt`
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGChip.kt`
- `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGColors.swift`
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGChip.swift`

## Status
COMPLETE
