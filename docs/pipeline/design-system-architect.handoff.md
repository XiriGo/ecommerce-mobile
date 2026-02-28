# Design System Architect Handoff

**Feature**: Design System (M0-02, Issue #3)
**Pipeline ID**: m0/design-system
**Agent**: architect
**Date**: 2026-02-20
**Status**: Specification Complete

---

## Summary

Designed a comprehensive, platform-agnostic specification for the XiriGo Design System covering:

- **6 theme files** (Colors, Typography, Spacing, CornerRadius, Elevation, Theme wrapper)
- **14 component files** (XGButton, XGTextField, XGCard, XGChip, XGTopBar, XGBottomBar/TabBar, XGLoadingView, XGErrorView, XGEmptyView, XGImage, XGBadge, XGRatingBar, XGPriceText, XGQuantityStepper)
- **18 localization keys** for component-level strings (en, mt, tr)
- **Full API contracts** for each component: parameters, types, defaults, states, accessibility, platform notes

---

## Artifacts Produced

| File | Description |
|------|-------------|
| `shared/feature-specs/design-system.md` | Complete feature specification |

---

## File Listing for Android Dev

**Root**: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/`

### Theme Files (create first)

1. `theme/XGColors.kt` -- All color tokens from `shared/design-tokens/colors.json`. Includes `XGColors` object with light/dark/semantic colors, plus `MoltLightColorScheme` and `MoltDarkColorScheme` using `lightColorScheme()` / `darkColorScheme()`.
2. `theme/XGTypography.kt` -- Typography from `shared/design-tokens/typography.json`. Maps to Material 3 `Typography` object.
3. `theme/XGSpacing.kt` -- Spacing constants from `shared/design-tokens/spacing.json`. `object XGSpacing` with `Dp` values.
4. `theme/XGCornerRadius.kt` -- Corner radius tokens. `object XGCornerRadius` with `Dp` values + `RoundedCornerShape` helpers.
5. `theme/XGElevation.kt` -- Elevation tokens. `object XGElevation` with `Dp` values.
6. `theme/XGTheme.kt` -- `@Composable fun XGTheme(darkTheme, content)` wrapper applying `MaterialTheme`.

### Component Files (create after theme)

7. `component/XGButton.kt` -- `XGButton` composable + `XGButtonStyle` enum (primary, secondary, outlined, text). Loading state with spinner.
8. `component/XGTextField.kt` -- `XGTextField` composable wrapping `OutlinedTextField`. Label, error, helper, icons, password mode.
9. `component/XGCard.kt` -- `MoltProductCard` + `MoltInfoCard` composables. Product card with image, title, price, rating, wishlist.
10. `component/XGChip.kt` -- `MoltFilterChip` + `MoltCategoryChip` composables.
11. `component/XGTopBar.kt` -- `XGTopBar` wrapping `TopAppBar`. Back button + action slots.
12. `component/XGBottomBar.kt` -- `XGBottomBar` wrapping `NavigationBar`. `XGTabItem` data class.
13. `component/XGLoadingView.kt` -- `XGLoadingView` (full screen) + `MoltLoadingIndicator` (inline).
14. `component/XGErrorView.kt` -- Error icon + message + optional retry `XGButton`.
15. `component/XGEmptyView.kt` -- Icon + message + optional action button.
16. `component/XGImage.kt` -- Coil `AsyncImage` wrapper with placeholder/error/crossfade.
17. `component/XGBadge.kt` -- `MoltCountBadge` + `MoltStatusBadge` + `XGBadgeStatus` enum.
18. `component/XGRatingBar.kt` -- Star rating display (filled, half, empty stars).
19. `component/XGPriceText.kt` -- Price display with sale strikethrough + `XGPriceSize` enum.
20. `component/XGQuantityStepper.kt` -- Minus/Plus buttons with count display.

### String Resources

Add localization keys from spec Section 5 to:
- `android/app/src/main/res/values/strings.xml` (en)
- `android/app/src/main/res/values-mt/strings.xml` (mt)
- `android/app/src/main/res/values-tr/strings.xml` (tr)

---

## File Listing for iOS Dev

**Root**: `ios/XiriGoEcommerce/Core/DesignSystem/`

### Theme Files (create first)

1. `Theme/XGColors.swift` -- `enum XGColors` with static color constants + `Color(hex:)` extension. Light/dark handled via SwiftUI adaptive colors or manual.
2. `Theme/XGTypography.swift` -- `enum XGTypography` mapping token sizes to `Font` values.
3. `Theme/XGSpacing.swift` -- `enum XGSpacing` with `CGFloat` static constants.
4. `Theme/XGCornerRadius.swift` -- `enum XGCornerRadius` with `CGFloat` static constants.
5. `Theme/XGElevation.swift` -- `enum XGElevation` with shadow helpers.
6. `Theme/XGTheme.swift` -- `ViewModifier` applying color/typography to SwiftUI environment.

### Component Files (create after theme)

7. `Component/XGButton.swift` -- `XGButton` view + `XGButtonStyle` enum. Loading state with `ProgressView`.
8. `Component/XGTextField.swift` -- `XGTextField` view with label, error, helper, icons, password mode, `@FocusState`.
9. `Component/XGCard.swift` -- `MoltProductCard` + `MoltInfoCard` views.
10. `Component/XGChip.swift` -- `MoltFilterChip` + `MoltCategoryChip` views.
11. `Component/XGTopBar.swift` -- `XGTopBar` view using toolbar modifiers.
12. `Component/XGTabBar.swift` -- `XGTabBar` view wrapping `TabView` + `XGTabItem` struct.
13. `Component/XGLoadingView.swift` -- `XGLoadingView` + `MoltLoadingIndicator` views.
14. `Component/XGErrorView.swift` -- Error icon + message + optional retry `XGButton`.
15. `Component/XGEmptyView.swift` -- SF Symbol icon + message + optional action button.
16. `Component/XGImage.swift` -- NukeUI `LazyImage` wrapper with shimmer placeholder.
17. `Component/XGBadge.swift` -- `MoltCountBadge` + `MoltStatusBadge` + `XGBadgeStatus` enum.
18. `Component/XGRatingBar.swift` -- Star rating with SF Symbols (`star.fill`, `star.leadinghalf.filled`, `star`).
19. `Component/XGPriceText.swift` -- Price display with strikethrough + `XGPriceSize` enum.
20. `Component/XGQuantityStepper.swift` -- Minus/Plus buttons with count display.

### String Resources

Add localization keys from spec Section 5 to:
- `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` (String Catalog with en, mt, tr)

---

## Key Decisions

1. **Separate CornerRadius and Elevation files**: Rather than bundling corner radius and elevation into `XGSpacing`, they get their own files (`XGCornerRadius`, `XGElevation`) for clarity and to match the token JSON structure.

2. **MoltProductCard and MoltInfoCard in same file**: Both are card variants that share styling logic. One file `XGCard.kt/swift` contains both.

3. **MoltFilterChip and MoltCategoryChip in same file**: Same rationale. `XGChip.kt/swift` exports both variants.

4. **XGBottomBar (Android) vs XGTabBar (iOS)**: Different names to match platform conventions. Same `XGTabItem` data structure shared conceptually.

5. **No interactive XGRatingBar**: Read-only for now. Interactive star input (for writing reviews, M3-07) can be added as `MoltRatingInput` later without changing the read-only API.

6. **Price formatting**: The component receives pre-formatted price strings. Formatting responsibility stays in the ViewModel/UseCase layer, not in the design system. The component only handles display (color, size, strikethrough).

7. **XGImage uses platform-native loading**: Coil (Android) and NukeUI (iOS) as specified in CLAUDE.md dependencies. No custom image caching -- rely on library defaults.

8. **Half-star support in XGRatingBar**: Ratings display half-star precision (e.g., 3.5 shows 3 filled + 1 half + 1 empty). This matches typical e-commerce UX expectations.

9. **No custom font**: Using system fonts (Roboto on Android, SF Pro on iOS) as specified in typography.json. When a custom brand font arrives with Figma, only `XGTypography` changes.

10. **Localization for 3 languages**: English (default), Maltese, Turkish. Component strings are minimal (mostly accessibility labels and common actions like "Retry").

---

## Risks and Notes

1. **Shimmer animation**: The spec defines `shimmer` color for loading placeholders. Full shimmer animation (gradient sweep) is a nice-to-have but not required for M0. Solid color placeholder is acceptable initially.

2. **Dark theme semantic colors**: Semantic colors (success, warning, priceRegular, etc.) are defined as theme-independent in the token JSON. Devs should consider whether these need dark-mode variants. For M0, using the same values in both themes is acceptable since they have sufficient contrast.

3. **XGImage placeholder drawable**: Android needs `R.drawable.placeholder` created as a vector drawable. iOS uses the `shimmer` color as placeholder. Ensure the placeholder asset is created during implementation.

4. **Half-star rendering on Android**: The `Canvas`-based approach for half stars needs careful implementation. Consider using `Icon` with clip modifier as an alternative.

5. **iOS Dynamic Type**: All text in components should use `.font(.system(size:))` through `XGTypography` constants. Ensure these scale with Dynamic Type by using `@ScaledMetric` or system text styles where possible.

6. **Performance**: Card components (especially `MoltProductCard` in grid) must be lightweight. Avoid nesting too many layout layers. Test scrolling at 60fps with a grid of 50+ products.

7. **Dependency on NukeUI (iOS)**: Ensure SPM package `NukeUI` is added in `ios/Package.swift` before `XGImage.swift` implementation.

8. **Dependency on Coil (Android)**: Ensure Coil Compose dependency is in `android/app/build.gradle.kts` before `XGImage.kt` implementation.

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
