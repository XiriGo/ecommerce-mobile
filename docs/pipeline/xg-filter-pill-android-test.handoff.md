# Android Test Handoff — XGFilterPill (DQ-31)

## Test File
`android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGFilterPillTest.kt`

## Coverage Summary
- 18 test cases total
- **Behavior tests (10)**: unselected display, selected display, click callback, selected state, dismiss icon visibility (3 cases), dismiss callback fire, data class equality/inequality
- **Token compliance tests (8)**: height 36dp, corner radius 18dp, gap 8dp, content padding 16dp, active/inactive background/text token existence

## Framework
JUnit4 + Compose UI Test + Truth assertions
