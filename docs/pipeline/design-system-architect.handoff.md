# Design System Architect Handoff

**Feature**: Design System (M0-02, Issue #3)
**Pipeline ID**: m0/design-system
**Agent**: architect
**Date**: 2026-02-20
**Status**: Specification Complete

---

## Summary

Designed a comprehensive, platform-agnostic specification for the Molt Design System covering:

- **6 theme files** (Colors, Typography, Spacing, CornerRadius, Elevation, Theme wrapper)
- **14 component files** (MoltButton, MoltTextField, MoltCard, MoltChip, MoltTopBar, MoltBottomBar/TabBar, MoltLoadingView, MoltErrorView, MoltEmptyView, MoltImage, MoltBadge, MoltRatingBar, MoltPriceText, MoltQuantityStepper)
- **18 localization keys** for component-level strings (en, mt, tr)
- **Full API contracts** for each component: parameters, types, defaults, states, accessibility, platform notes

---

## Artifacts Produced

| File | Description |
|------|-------------|
| `shared/feature-specs/design-system.md` | Complete feature specification |

---

## File Listing for Android Dev

**Root**: `android/app/src/main/java/com/molt/marketplace/core/designsystem/`

### Theme Files (create first)

1. `theme/MoltColors.kt` -- All color tokens from `shared/design-tokens/colors.json`. Includes `MoltColors` object with light/dark/semantic colors, plus `MoltLightColorScheme` and `MoltDarkColorScheme` using `lightColorScheme()` / `darkColorScheme()`.
2. `theme/MoltTypography.kt` -- Typography from `shared/design-tokens/typography.json`. Maps to Material 3 `Typography` object.
3. `theme/MoltSpacing.kt` -- Spacing constants from `shared/design-tokens/spacing.json`. `object MoltSpacing` with `Dp` values.
4. `theme/MoltCornerRadius.kt` -- Corner radius tokens. `object MoltCornerRadius` with `Dp` values + `RoundedCornerShape` helpers.
5. `theme/MoltElevation.kt` -- Elevation tokens. `object MoltElevation` with `Dp` values.
6. `theme/MoltTheme.kt` -- `@Composable fun MoltTheme(darkTheme, content)` wrapper applying `MaterialTheme`.

### Component Files (create after theme)

7. `component/MoltButton.kt` -- `MoltButton` composable + `MoltButtonStyle` enum (primary, secondary, outlined, text). Loading state with spinner.
8. `component/MoltTextField.kt` -- `MoltTextField` composable wrapping `OutlinedTextField`. Label, error, helper, icons, password mode.
9. `component/MoltCard.kt` -- `MoltProductCard` + `MoltInfoCard` composables. Product card with image, title, price, rating, wishlist.
10. `component/MoltChip.kt` -- `MoltFilterChip` + `MoltCategoryChip` composables.
11. `component/MoltTopBar.kt` -- `MoltTopBar` wrapping `TopAppBar`. Back button + action slots.
12. `component/MoltBottomBar.kt` -- `MoltBottomBar` wrapping `NavigationBar`. `MoltTabItem` data class.
13. `component/MoltLoadingView.kt` -- `MoltLoadingView` (full screen) + `MoltLoadingIndicator` (inline).
14. `component/MoltErrorView.kt` -- Error icon + message + optional retry `MoltButton`.
15. `component/MoltEmptyView.kt` -- Icon + message + optional action button.
16. `component/MoltImage.kt` -- Coil `AsyncImage` wrapper with placeholder/error/crossfade.
17. `component/MoltBadge.kt` -- `MoltCountBadge` + `MoltStatusBadge` + `MoltBadgeStatus` enum.
18. `component/MoltRatingBar.kt` -- Star rating display (filled, half, empty stars).
19. `component/MoltPriceText.kt` -- Price display with sale strikethrough + `MoltPriceSize` enum.
20. `component/MoltQuantityStepper.kt` -- Minus/Plus buttons with count display.

### String Resources

Add localization keys from spec Section 5 to:
- `android/app/src/main/res/values/strings.xml` (en)
- `android/app/src/main/res/values-mt/strings.xml` (mt)
- `android/app/src/main/res/values-tr/strings.xml` (tr)

---

## File Listing for iOS Dev

**Root**: `ios/MoltMarketplace/Core/DesignSystem/`

### Theme Files (create first)

1. `Theme/MoltColors.swift` -- `enum MoltColors` with static color constants + `Color(hex:)` extension. Light/dark handled via SwiftUI adaptive colors or manual.
2. `Theme/MoltTypography.swift` -- `enum MoltTypography` mapping token sizes to `Font` values.
3. `Theme/MoltSpacing.swift` -- `enum MoltSpacing` with `CGFloat` static constants.
4. `Theme/MoltCornerRadius.swift` -- `enum MoltCornerRadius` with `CGFloat` static constants.
5. `Theme/MoltElevation.swift` -- `enum MoltElevation` with shadow helpers.
6. `Theme/MoltTheme.swift` -- `ViewModifier` applying color/typography to SwiftUI environment.

### Component Files (create after theme)

7. `Component/MoltButton.swift` -- `MoltButton` view + `MoltButtonStyle` enum. Loading state with `ProgressView`.
8. `Component/MoltTextField.swift` -- `MoltTextField` view with label, error, helper, icons, password mode, `@FocusState`.
9. `Component/MoltCard.swift` -- `MoltProductCard` + `MoltInfoCard` views.
10. `Component/MoltChip.swift` -- `MoltFilterChip` + `MoltCategoryChip` views.
11. `Component/MoltTopBar.swift` -- `MoltTopBar` view using toolbar modifiers.
12. `Component/MoltTabBar.swift` -- `MoltTabBar` view wrapping `TabView` + `MoltTabItem` struct.
13. `Component/MoltLoadingView.swift` -- `MoltLoadingView` + `MoltLoadingIndicator` views.
14. `Component/MoltErrorView.swift` -- Error icon + message + optional retry `MoltButton`.
15. `Component/MoltEmptyView.swift` -- SF Symbol icon + message + optional action button.
16. `Component/MoltImage.swift` -- NukeUI `LazyImage` wrapper with shimmer placeholder.
17. `Component/MoltBadge.swift` -- `MoltCountBadge` + `MoltStatusBadge` + `MoltBadgeStatus` enum.
18. `Component/MoltRatingBar.swift` -- Star rating with SF Symbols (`star.fill`, `star.leadinghalf.filled`, `star`).
19. `Component/MoltPriceText.swift` -- Price display with strikethrough + `MoltPriceSize` enum.
20. `Component/MoltQuantityStepper.swift` -- Minus/Plus buttons with count display.

### String Resources

Add localization keys from spec Section 5 to:
- `ios/MoltMarketplace/Resources/Localizable.xcstrings` (String Catalog with en, mt, tr)

---

## Key Decisions

1. **Separate CornerRadius and Elevation files**: Rather than bundling corner radius and elevation into `MoltSpacing`, they get their own files (`MoltCornerRadius`, `MoltElevation`) for clarity and to match the token JSON structure.

2. **MoltProductCard and MoltInfoCard in same file**: Both are card variants that share styling logic. One file `MoltCard.kt/swift` contains both.

3. **MoltFilterChip and MoltCategoryChip in same file**: Same rationale. `MoltChip.kt/swift` exports both variants.

4. **MoltBottomBar (Android) vs MoltTabBar (iOS)**: Different names to match platform conventions. Same `MoltTabItem` data structure shared conceptually.

5. **No interactive MoltRatingBar**: Read-only for now. Interactive star input (for writing reviews, M3-07) can be added as `MoltRatingInput` later without changing the read-only API.

6. **Price formatting**: The component receives pre-formatted price strings. Formatting responsibility stays in the ViewModel/UseCase layer, not in the design system. The component only handles display (color, size, strikethrough).

7. **MoltImage uses platform-native loading**: Coil (Android) and NukeUI (iOS) as specified in CLAUDE.md dependencies. No custom image caching -- rely on library defaults.

8. **Half-star support in MoltRatingBar**: Ratings display half-star precision (e.g., 3.5 shows 3 filled + 1 half + 1 empty). This matches typical e-commerce UX expectations.

9. **No custom font**: Using system fonts (Roboto on Android, SF Pro on iOS) as specified in typography.json. When a custom brand font arrives with Figma, only `MoltTypography` changes.

10. **Localization for 3 languages**: English (default), Maltese, Turkish. Component strings are minimal (mostly accessibility labels and common actions like "Retry").

---

## Risks and Notes

1. **Shimmer animation**: The spec defines `shimmer` color for loading placeholders. Full shimmer animation (gradient sweep) is a nice-to-have but not required for M0. Solid color placeholder is acceptable initially.

2. **Dark theme semantic colors**: Semantic colors (success, warning, priceRegular, etc.) are defined as theme-independent in the token JSON. Devs should consider whether these need dark-mode variants. For M0, using the same values in both themes is acceptable since they have sufficient contrast.

3. **MoltImage placeholder drawable**: Android needs `R.drawable.placeholder` created as a vector drawable. iOS uses the `shimmer` color as placeholder. Ensure the placeholder asset is created during implementation.

4. **Half-star rendering on Android**: The `Canvas`-based approach for half stars needs careful implementation. Consider using `Icon` with clip modifier as an alternative.

5. **iOS Dynamic Type**: All text in components should use `.font(.system(size:))` through `MoltTypography` constants. Ensure these scale with Dynamic Type by using `@ScaledMetric` or system text styles where possible.

6. **Performance**: Card components (especially `MoltProductCard` in grid) must be lightweight. Avoid nesting too many layout layers. Test scrolling at 60fps with a grid of 50+ products.

7. **Dependency on NukeUI (iOS)**: Ensure SPM package `NukeUI` is added in `ios/Package.swift` before `MoltImage.swift` implementation.

8. **Dependency on Coil (Android)**: Ensure Coil Compose dependency is in `android/app/build.gradle.kts` before `MoltImage.kt` implementation.

---

## Verification Checklist (for next agents)

Before starting implementation, verify:

- [ ] `shared/design-tokens/colors.json` exists and matches spec Section 2.1
- [ ] `shared/design-tokens/typography.json` exists and matches spec Section 2.2
- [ ] `shared/design-tokens/spacing.json` exists and matches spec Section 2.3
- [ ] Android project compiles (`./gradlew assembleDebug`)
- [ ] iOS project compiles (Xcode build)
- [ ] Coil dependency present in Android Gradle
- [ ] NukeUI dependency present in iOS SPM

---

**Handoff Complete -- Ready for Android Dev and iOS Dev**
