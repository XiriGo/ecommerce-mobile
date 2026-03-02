# DQ-18 XGChip Token Audit -- iOS Test Handoff

## Test File
`ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGChipTests.swift`

## Tests Added/Updated

### XGFilterChipTests (existing, retained)
- `init_withLabel_initialises` — basic init
- `init_selected_initialises` — selected state init
- `init_defaultIsDeselected` — default deselected
- `init_withLeadingIcon_initialises` — leading icon
- `init_actionClosure_isCaptured` — action closure
- `selectedState_distinctFromDeselected` — state distinction

### XGFilterChipTokenTests (NEW suite)
- `filterChipHeight_is36` — height = 36pt per spec
- `filterChipCornerRadius_is18` — corner radius = 18pt per spec
- `filterChipHorizontalPadding_is16` — XGSpacing.base == 16
- `filterChipGap_is8` — XGSpacing.sm == 8
- `selectedIconSize_is16` — XGSpacing.IconSize.small == 16
- `activeBackground_tokenExists` — filterPillBackgroundActive token exists
- `activeTextColor_tokenExists` — filterPillTextActive token exists
- `inactiveBackground_tokenExists` — filterPillBackground token exists
- `inactiveTextColor_tokenExists` — filterPillText token exists

### XGCategoryChipTests (existing, retained)
- `test_init_withLabel_initialises` — basic init
- `init_withIconUrl_initialises` — URL init
- `init_withoutIconUrl_initialises` — nil URL
- `test_init_actionClosure_isCaptured` — action closure

### XGCategoryChipTokenTests (NEW suite)
- `background_isSurfaceTertiary` — surfaceTertiary token exists
- `textColor_isOnSurface` — onSurface token exists
- `iconSize_isMedium` — XGSpacing.IconSize.medium == 24

## Total Tests: 22
## Coverage: Behavior + token compliance for both variants

## Status
COMPLETE
