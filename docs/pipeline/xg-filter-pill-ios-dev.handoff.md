# iOS Dev Handoff — XGFilterPill (DQ-31)

## Files Created
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGFilterPill.swift`
- `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` (added `common_filter_pill_dismiss_a11y`)

## Components
1. **XGFilterPillItem** — Equatable, Sendable struct (`label: String`, `isSelected: Bool`)
2. **XGFilterPill** — Single pill view with optional dismiss (X) button
3. **XGFilterPillRow** — Horizontal `ScrollView` + `HStack` of `XGFilterPill` items

## Token Compliance
- Height: 36pt (`FilterPillTokens.height`)
- Corner radius: 18pt (`FilterPillTokens.cornerRadius`)
- Horizontal padding: `XGSpacing.base` (16pt)
- Gap: `XGSpacing.sm` (8pt)
- Icon size: `XGSpacing.IconSize.small` (16pt)
- Active bg: `XGColors.filterPillBackgroundActive`
- Active text: `XGColors.filterPillTextActive`
- Inactive bg: `XGColors.filterPillBackground`
- Inactive text: `XGColors.filterPillText`
- Border: `XGColors.outline` (unselected only)

## Previews
- Unselected, Selected, Selected+Dismiss, Row with mixed states
