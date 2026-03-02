# iOS Test Handoff — XGFilterPill (DQ-31)

## Test File
`ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGFilterPillTests.swift`

## Coverage Summary
- 24 test cases total across 4 suites
- **XGFilterPillTests (8)**: init with label, selected state, deselected default, with/without onDismiss, action closure capture, distinct states, nil dismiss
- **XGFilterPillTokenTests (11)**: height 36pt, corner radius 18pt, horizontal padding 16pt, gap 8pt, icon size 16pt, active/inactive background/text color token matching, distinct active/inactive comparisons
- **XGFilterPillItemTests (4)**: init properties, equality, inequality by selection, inequality by label
- **XGFilterPillRowTests (4)**: init with items, with dismiss, without dismiss, empty items

## Framework
Swift Testing (`import Testing`)
