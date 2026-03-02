# DQ-18 XGChip Token Audit -- Android Test Handoff

## Test File
`android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGChipTest.kt`

## Tests Added/Updated

### XGFilterChip Behavior Tests (existing, retained)
- `xgFilterChip_unselected_displaysLabel` — verifies label renders
- `xgFilterChip_selected_displaysLabel` — verifies selected chip renders label
- `xgFilterChip_click_firesCallback` — verifies onClick fires
- `xgFilterChip_selected_hasSelectedState` — verifies selected semantic state
- `xgFilterChip_toggling_callsCallbackEachTime` — verifies multiple clicks

### XGFilterChip Token Compliance Tests (NEW)
- `xgFilterChip_token_filterChipHeight_is36` — height = 36dp per spec
- `xgFilterChip_token_cornerRadius_is18` — corner radius = 18dp per spec
- `xgFilterChip_token_activeBackground_isFilterPillBackgroundActive` — active bg token exists
- `xgFilterChip_token_activeText_isFilterPillTextActive` — active text token exists
- `xgFilterChip_token_inactiveBackground_isFilterPillBackground` — inactive bg token exists
- `xgFilterChip_token_inactiveText_isFilterPillText` — inactive text token exists

### XGCategoryChip Tests (existing + NEW token tests)
- `xgCategoryChip_displaysLabel` — verifies label renders
- `xgCategoryChip_click_firesCallback` — verifies onClick fires
- `xgCategoryChip_token_background_isSurfaceTertiary` — surfaceTertiary token exists (NEW)
- `xgCategoryChip_token_textColor_isOnSurface` — onSurface token exists (NEW)

## Total Tests: 15
## Coverage: Behavior + token compliance for both variants

## Status
COMPLETE
