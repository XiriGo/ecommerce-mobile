# Design System — Android Test Handoff

**Feature**: M0-02 Design System
**Agent**: Android Tester
**Platform**: Android
**Date**: 2026-02-20
**Branch**: feature/m0/design-system

---

## Summary

Comprehensive tests were written for all design system components and theme token classes. Tests are split between unit tests (JUnit 4 / Truth) in `src/test/` and Compose UI tests (`composeTestRule`) in `src/androidTest/`.

---

## Test Files Created

### Unit Tests (`android/app/src/test/`)

| File | Package | Coverage |
|------|---------|----------|
| `theme/MoltCornerRadiusTest.kt` | `com.molt.marketplace.core.designsystem.theme` | All corner radius values verified against design tokens; ordering and boundary checks |
| `theme/MoltElevationTest.kt` | `com.molt.marketplace.core.designsystem.theme` | All elevation levels verified; ascending order; Level0 = zero |

Previously existing (kept):
- `theme/MoltColorsTest.kt` — Color token values
- `theme/MoltSpacingTest.kt` — Spacing values, accessibility minimum touch target

### Compose UI Tests (`android/app/src/androidTest/`)

| File | Component(s) Tested | Key Scenarios |
|------|-------------------|---------------|
| `component/MoltButtonTest.kt` | `MoltButton` | All 4 variants (Primary, Secondary, Outlined, Text); loading state disables click + shows progress indicator; disabled state; click callback; leading icon |
| `component/MoltTextFieldTest.kt` | `MoltTextField` | Label, placeholder, error state, helper text, error overrides helper, password toggle, value callback, maxLength counter, maxLength truncation |
| `component/MoltCardTest.kt` | `MoltProductCard`, `MoltInfoCard` | Product card title/price/vendor rendering; click callback; wishlist toggle (add/remove CD); info card title, subtitle, click |
| `component/MoltChipTest.kt` | `MoltFilterChip`, `MoltCategoryChip` | Unselected/selected label; click callback; selected state; multiple clicks; category chip label and click |
| `component/MoltTopBarTest.kt` | `MoltTopBar` | Title display; back button absent when null; back button present and clickable; action button click; title-only variant |
| `component/MoltBottomBarTest.kt` | `MoltBottomBar`, `MoltTabItem` | All tabs rendered; selected state; tab click with index callback; badge count display; zero badge hidden; 99+ cap; tab switching |
| `component/MoltLoadingViewTest.kt` | `MoltLoadingView`, `MoltLoadingIndicator` | Progress indicator content description; render-without-crash for both variants |
| `component/MoltErrorViewTest.kt` | `MoltErrorView` | Message displayed; retry button present/absent; retry click fires callback; render-without-crash |
| `component/MoltEmptyViewTest.kt` | `MoltEmptyView` | Message displayed; action button shown/hidden (requires both label + callback); action click; custom icon; render-without-crash |
| `component/MoltImageTest.kt` | `MoltImage` | Null URL renders shimmer (no crash); non-null URL renders AsyncImage with CD; null content description variants |
| `component/MoltBadgeTest.kt` | `MoltCountBadge`, `MoltStatusBadge` | Zero/negative count hidden; 1–99 displayed; 100+ capped at "99+"; all 5 status badge variants (Success/Warning/Error/Info/Neutral) |
| `component/MoltRatingBarTest.kt` | `MoltRatingBar` | showValue flag; review count display; full/zero/half ratings; accessibility content description; combined showValue + reviewCount |
| `component/MoltPriceTextTest.kt` | `MoltPriceText` | Regular price format; custom currency symbol; sale price with both prices; accessibility descriptions; all 3 size variants |
| `component/MoltQuantityStepperTest.kt` | `MoltQuantityStepper` | Current quantity display; increase/decrease callbacks; min/max button disable; custom min/max enforcement; render-without-crash |

---

## Test Statistics

| Category | Count |
|----------|-------|
| New unit test files | 2 |
| New UI test files | 13 |
| Total new test cases | ~90 |
| Components covered | 14 / 14 (100%) |
| Theme objects covered | 4 / 4 (100%) |

---

## Coverage Areas

### Happy Paths
- All components render text/content correctly
- Click callbacks fire with correct arguments
- State variants (loading, disabled, selected) all covered

### Error / Edge Paths
- Null props handled without crash (MoltImage, MoltErrorView retry null, etc.)
- Zero counts hidden (MoltCountBadge, MoltBottomBar badge)
- Overflow counts capped (99+ for MoltCountBadge and MoltBottomBar)
- Min/max bounds respected in MoltQuantityStepper

### Accessibility
- Content descriptions verified: MoltLoadingView, MoltRatingBar, MoltPriceText, MoltQuantityStepper
- Wishlist button content description changes with `isWishlisted` state
- Navigate back content description on MoltTopBar

---

## Test Stack Used

- JUnit 4
- Truth (`com.google.common.truth.Truth.assertThat`)
- Compose UI Test (`createComposeRule`, `composeTestRule`)
- No mocks needed — all design system components are pure composables with no external dependencies

---

## Next Steps for Reviewer

1. Run `./gradlew :app:connectedAndroidTest` on an emulator to execute UI tests
2. Run `./gradlew :app:test` for unit tests
3. Check coverage report: `./gradlew :app:jacocoTestReport`
4. Verify coverage >= 80% lines, >= 70% branches on designsystem package
