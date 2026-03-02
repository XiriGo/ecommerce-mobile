# Android Dev Handoff — XGFilterPill (DQ-31)

## Files Created
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGFilterPill.kt`
- `android/app/src/main/res/values/strings.xml` (added `common_filter_pill_dismiss_a11y`)
- `android/app/src/main/res/values-mt/strings.xml` (added `common_filter_pill_dismiss_a11y`)
- `android/app/src/main/res/values-tr/strings.xml` (added `common_filter_pill_dismiss_a11y`)

## Components
1. **XGFilterPillItem** — Immutable data class (`label: String`, `isSelected: Boolean`)
2. **XGFilterPill** — Single pill composable wrapping `FilterChip` with dismiss support
3. **XGFilterPillRow** — `LazyRow` of `XGFilterPill` items with index-based callbacks

## Token Compliance
- Height: 36dp (`FilterPillHeight`)
- Corner radius: 18dp (`FilterPillCornerRadius`)
- Icon size: 16dp (`IconSize`)
- Gap: `XGSpacing.SM` (8dp)
- Content padding: `XGSpacing.Base` (16dp)
- Active bg: `XGColors.FilterPillBackgroundActive`
- Active text: `XGColors.FilterPillTextActive`
- Inactive bg: `XGColors.FilterPillBackground`
- Inactive text: `XGColors.FilterPillText`
- Border: `XGColors.Outline` (unselected only)

## Previews
- Unselected, Selected, Selected+Dismiss, Row with mixed states
