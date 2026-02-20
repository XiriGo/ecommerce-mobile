# M0-02: Design System

## Overview

The Molt Design System is the shared UI component library for the Molt Marketplace mobile app on both Android (Jetpack Compose) and iOS (SwiftUI). It provides a single source of truth for visual design tokens (colors, typography, spacing, corner radius, elevation) and 14 reusable `Molt*` wrapper components that all feature screens consume.

**Status**: Complete
**Phase**: M0 (Foundation)
**Issue**: #3
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)
**Blocks**: All M1+ features (every screen uses Molt* components)

### Key Principle

Feature screens never import raw platform components (Material 3 primitives or SwiftUI primitives). They import only `Molt*` components from `core/designsystem`. When Figma designs arrive, only files under `core/designsystem/` change — zero feature-screen edits are needed.

---

## Token Pipeline

```
shared/design-tokens/*.json
         |
         v
core/designsystem/theme/        <- Platform constants (MoltColors, MoltTypography, MoltSpacing, ...)
         |
         v
core/designsystem/component/    <- Molt* wrappers (MoltButton, MoltCard, ...)
         |
         v
feature/*/presentation/         <- Feature screens (consume Molt* only)
```

---

## Design Tokens

Token source files live in `shared/design-tokens/` as JSON. Platform theme files translate them to typed constants.

### Colors

Two full color schemes (light and dark) plus a set of theme-independent semantic colors.

**Light / Dark scheme tokens** (28 roles each): `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`, `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer`, `error`, `onError`, `errorContainer`, `onErrorContainer`, `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`, `outline`, `outlineVariant`, `background`, `onBackground`, `inverseSurface`, `inverseOnSurface`, `inversePrimary`, `scrim`.

**Semantic colors** (theme-independent, 15 tokens): `success`, `onSuccess`, `warning`, `onWarning`, `info`, `onInfo`, `priceRegular`, `priceSale`, `priceOriginal`, `ratingStarFilled`, `ratingStarEmpty`, `badgeBackground`, `badgeText`, `divider`, `shimmer`.

### Typography

15 text styles mapped from `shared/design-tokens/typography.json`:

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `displayLarge` | 57sp/pt | 400 | Hero banners |
| `displayMedium` | 45sp/pt | 400 | Large headings |
| `displaySmall` | 36sp/pt | 400 | Section titles |
| `headlineLarge` | 32sp/pt | 400 | Screen titles |
| `headlineMedium` | 28sp/pt | 400 | Section headers |
| `headlineSmall` | 24sp/pt | 400 | Card titles |
| `titleLarge` | 22sp/pt | 400 | Top bar title |
| `titleMedium` | 16sp/pt | 500 | Product title, list item title |
| `titleSmall` | 14sp/pt | 500 | Subtitle, metadata label |
| `bodyLarge` | 16sp/pt | 400 | Product description |
| `bodyMedium` | 14sp/pt | 400 | Default body text |
| `bodySmall` | 12sp/pt | 400 | Captions, helper text |
| `labelLarge` | 14sp/pt | 500 | Button text, chip text |
| `labelMedium` | 12sp/pt | 500 | Tab labels, filter labels |
| `labelSmall` | 11sp/pt | 500 | Badge text, timestamp |

Font families: Roboto (Android system default), SF Pro (iOS system default).

### Spacing

9 base spacing tokens (2dp–64dp: `xxs`, `xs`, `sm`, `md`, `base`, `lg`, `xl`, `xxl`, `xxxl`) plus layout constants: `screenPaddingHorizontal` (16), `screenPaddingVertical` (16), `cardPadding` (12), `listItemSpacing` (8), `sectionSpacing` (24), `productGridSpacing` (8), `productGridColumns` (2), `minTouchTarget` (48dp Android / 44pt iOS).

Icon sizes: `small` (16), `medium` (24), `large` (32), `extraLarge` (48).
Avatar sizes: `small` (32), `medium` (48), `large` (64), `extraLarge` (96).

### Corner Radius

6 tokens: `none` (0), `small` (4), `medium` (8), `large` (12), `extraLarge` (16), `full` (999/capsule).

### Elevation

6 levels (0dp–12dp): `level0` (flat), `level1` (cards at rest), `level2` (cards pressed), `level3` (FAB), `level4` (navigation bar), `level5` (modal sheets).

---

## Component Catalog

All 14 components are implemented on both platforms.

| # | Component | Description | Android File | iOS File |
|---|-----------|-------------|-------------|---------|
| 1 | `MoltButton` | Action button with 4 style variants and loading state | `MoltButton.kt` | `MoltButton.swift` |
| 2 | `MoltTextField` | Text input with label, error, helper text, icons, password mode | `MoltTextField.kt` | `MoltTextField.swift` |
| 3 | `MoltCard` | `MoltProductCard` + `MoltInfoCard` container variants | `MoltCard.kt` | `MoltCard.swift` |
| 4 | `MoltChip` | `MoltFilterChip` + `MoltCategoryChip` for filters and categories | `MoltChip.kt` | `MoltChip.swift` |
| 5 | `MoltTopBar` | Top navigation bar with back button and action slots | `MoltTopBar.kt` | `MoltTopBar.swift` |
| 6 | `MoltBottomBar` / `MoltTabBar` | Bottom tab navigation with badge counts | `MoltBottomBar.kt` | `MoltTabBar.swift` |
| 7 | `MoltLoadingView` | Full-screen spinner + inline `MoltLoadingIndicator` | `MoltLoadingView.kt` | `MoltLoadingView.swift` |
| 8 | `MoltErrorView` | Error icon + message + optional retry button | `MoltErrorView.kt` | `MoltErrorView.swift` |
| 9 | `MoltEmptyView` | Empty state icon + message + optional action button | `MoltEmptyView.kt` | `MoltEmptyView.swift` |
| 10 | `MoltImage` | Async image with shimmer placeholder and crossfade | `MoltImage.kt` | `MoltImage.swift` |
| 11 | `MoltBadge` | `MoltCountBadge` (0/1–99/99+) + `MoltStatusBadge` (5 statuses) | `MoltBadge.kt` | `MoltBadge.swift` |
| 12 | `MoltRatingBar` | Read-only star rating with half-star precision | `MoltRatingBar.kt` | `MoltRatingBar.swift` |
| 13 | `MoltPriceText` | Currency display with sale strikethrough, 3 size variants | `MoltPriceText.kt` | `MoltPriceText.swift` |
| 14 | `MoltQuantityStepper` | Increment/decrement control with min/max bounds | `MoltQuantityStepper.kt` | `MoltQuantityStepper.swift` |

### MoltButton Variants

| Variant | Android | iOS | Visual |
|---------|---------|-----|--------|
| `primary` | Filled `Button` | `.primary` | Solid primary background, white text |
| `secondary` | `OutlinedButton` | `.secondary` | Secondary container background |
| `outlined` | `OutlinedButton` (custom) | `.outlined` | Outlined border, primary text |
| `text` | `TextButton` | `.text` | No background, primary text |

iOS note: The enum is named `MoltButtonVariant` (not `MoltButtonStyle`) to avoid conflict with the SwiftUI `ButtonStyle` protocol.

### MoltTabItem Fields

| Field | Type | Description |
|-------|------|-------------|
| `label` | `String` | Localized tab label |
| `icon` | `ImageVector` / `String` | Unselected icon |
| `selectedIcon` | `ImageVector` / `String` | Selected (filled) icon |
| `badgeCount` | `Int?` | Optional badge overlay count |

App-wide tabs: **Home**, **Categories**, **Cart** (with cart item count badge), **Profile**.

### MoltBadgeStatus Values

`success`, `warning`, `error`, `info`, `neutral` — each maps to a semantic color pair from `MoltColors`.

---

## Usage Examples

### Android — Feature Screen Import Pattern

```kotlin
import com.molt.marketplace.core.designsystem.component.MoltButton
import com.molt.marketplace.core.designsystem.component.MoltButtonStyle
import com.molt.marketplace.core.designsystem.component.MoltProductCard
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
fun ProductDetailScreen(onAddToCart: () -> Unit) {
    MoltTheme {
        MoltButton(
            text = stringResource(R.string.product_add_to_cart),
            onClick = onAddToCart,
            style = MoltButtonStyle.Primary,
        )
    }
}
```

### iOS — Feature Screen Import Pattern

```swift
import SwiftUI

struct ProductDetailView: View {
    var onAddToCart: () -> Void

    var body: some View {
        MoltButton(
            String(localized: "product_add_to_cart"),
            variant: .primary,
            action: onAddToCart
        )
    }
}
```

### Using MoltTheme Wrapper

**Android** — Apply at app root in `MainActivity`:
```kotlin
MoltTheme(darkTheme = isSystemInDarkTheme()) {
    // All content here inherits MoltColors and MoltTypography via MaterialTheme
}
```

**iOS** — Apply as a `ViewModifier` at app entry:
```swift
ContentView()
    .moltTheme()
```

---

## Theme Customization (Figma Update Process)

When Figma designs arrive, follow this process:

1. Update `shared/design-tokens/*.json` with new color, typography, and spacing values from Figma
2. Update theme files on each platform:
   - Android: `MoltColors.kt`, `MoltTypography.kt`, `MoltSpacing.kt`, `MoltCornerRadius.kt`, `MoltElevation.kt`
   - iOS: `MoltColors.swift`, `MoltTypography.swift`, `MoltSpacing.swift`, `MoltCornerRadius.swift`, `MoltElevation.swift`
3. Update component visual implementation if shapes or paddings change (e.g., `MoltButton.kt/.swift`)
4. **Do not change** any feature screen code — the `Molt*` component API contracts (parameters, callbacks, types) are stable

---

## Localization

All user-facing strings in design system components use localization keys. 17 keys are defined across 3 languages (English, Maltese, Turkish).

Key examples:

| Key | English | Usage |
|-----|---------|-------|
| `common_navigate_back` | Navigate back | MoltTopBar back button |
| `common_loading_message` | Loading... | MoltButton loading, MoltLoadingView |
| `common_retry_button` | Retry | MoltErrorView retry |
| `common_decrease_quantity` | Decrease quantity | MoltQuantityStepper minus |
| `common_increase_quantity` | Increase quantity | MoltQuantityStepper plus |
| `common_add_to_wishlist` | Add to wishlist | MoltProductCard heart |
| `common_tab_home` | Home | MoltBottomBar/MoltTabBar |
| `common_tab_cart` | Cart | MoltBottomBar/MoltTabBar |

Android string files: `res/values/strings.xml`, `res/values-mt/strings.xml`, `res/values-tr/strings.xml`
iOS string file: `Resources/Localizable.xcstrings` (String Catalog format)

---

## File Structure

### Android

**Root**: `android/app/src/main/java/com/molt/marketplace/core/designsystem/`

```
core/designsystem/
  theme/
    MoltColors.kt           # Color tokens (light/dark/semantic), MoltLightColorScheme, MoltDarkColorScheme
    MoltTypography.kt       # Typography object (15 text styles)
    MoltSpacing.kt          # Spacing constants (dp values)
    MoltCornerRadius.kt     # Corner radius constants + RoundedCornerShape helpers
    MoltElevation.kt        # Elevation constants (dp values)
    MoltTheme.kt            # @Composable MoltTheme wrapper
  component/
    MoltButton.kt           # MoltButton + MoltButtonStyle enum (4 variants)
    MoltTextField.kt        # MoltTextField (label, error, helper, password)
    MoltCard.kt             # MoltProductCard + MoltInfoCard
    MoltChip.kt             # MoltFilterChip + MoltCategoryChip
    MoltTopBar.kt           # MoltTopBar
    MoltBottomBar.kt        # MoltBottomBar + MoltTabItem
    MoltLoadingView.kt      # MoltLoadingView + MoltLoadingIndicator
    MoltErrorView.kt        # MoltErrorView
    MoltEmptyView.kt        # MoltEmptyView
    MoltImage.kt            # MoltImage (Coil AsyncImage wrapper)
    MoltBadge.kt            # MoltCountBadge + MoltStatusBadge + MoltBadgeStatus enum
    MoltRatingBar.kt        # MoltRatingBar (half-star support)
    MoltPriceText.kt        # MoltPriceText + MoltPriceSize enum
    MoltQuantityStepper.kt  # MoltQuantityStepper
```

Total: 6 theme files + 14 component files = **20 Kotlin files**

**String resources**:
- `android/app/src/main/res/values/strings.xml` — English (17 design system keys)
- `android/app/src/main/res/values-mt/strings.xml` — Maltese
- `android/app/src/main/res/values-tr/strings.xml` — Turkish

**Image loading**: Coil 3 (`AsyncImage`). Placeholder uses `ColorPainter(MoltColors.Shimmer)`.

### iOS

**Root**: `ios/MoltMarketplace/Core/DesignSystem/`

```
Core/DesignSystem/
  Theme/
    MoltColors.swift        # Color constants (light/dark adaptive, semantic) + Color(hex:) extension
    MoltTypography.swift    # Font constants (15 text styles)
    MoltSpacing.swift       # Spacing constants + IconSize + AvatarSize nested enums
    MoltCornerRadius.swift  # Corner radius constants
    MoltElevation.swift     # Elevation levels + ShadowStyle struct + moltElevation() modifier
    MoltTheme.swift         # ViewModifier applying theme to environment
  Component/
    MoltButton.swift        # MoltButton view + MoltButtonVariant enum (4 variants)
    MoltTextField.swift     # MoltTextField view (label, error, password toggle, maxLength)
    MoltCard.swift          # MoltProductCard + MoltInfoCard views
    MoltChip.swift          # MoltFilterChip + MoltCategoryChip views
    MoltTopBar.swift        # MoltTopBar view (toolbar modifiers)
    MoltTabBar.swift        # MoltTabBar view + MoltTabItem struct
    MoltLoadingView.swift   # MoltLoadingView + MoltLoadingIndicator views
    MoltErrorView.swift     # MoltErrorView
    MoltEmptyView.swift     # MoltEmptyView
    MoltImage.swift         # MoltImage (AsyncImage wrapper with shimmer placeholder)
    MoltBadge.swift         # MoltCountBadge + MoltStatusBadge + MoltBadgeStatus enum
    MoltRatingBar.swift     # MoltRatingBar (SF Symbols: star.fill, star.leadinghalf.filled, star)
    MoltPriceText.swift     # MoltPriceText + MoltPriceSize enum
    MoltQuantityStepper.swift # MoltQuantityStepper (accessibilityAdjustableAction)
```

Total: 6 theme files + 14 component files = **20 Swift files**

**String resources**: `ios/MoltMarketplace/Resources/Localizable.xcstrings` (22 design system keys)

**Image loading**: SwiftUI `AsyncImage` (NukeUI `LazyImage` can be swapped in later with zero API changes when SPM dependency is added).

---

## Architecture Compliance

Both platforms enforce these rules in every component file:

- All colors referenced from `MoltColors` — no hardcoded hex values
- All spacing referenced from `MoltSpacing` — no magic number dp/pt values
- All corner radii from `MoltCornerRadius`; elevations from `MoltElevation`
- All user-facing strings via `stringResource(R.string.xxx)` (Android) / `String(localized:)` (iOS)
- No `Any` type usage
- No force unwrap (`!!` Kotlin / `!` Swift)
- All types are immutable (`data class` / `struct`)
- Every composable/view has `modifier: Modifier = Modifier` (Android) as first optional parameter
- Every component file has `@Preview` / `#Preview` blocks wrapped in `MoltTheme`
- All interactive elements meet minimum touch target: 48dp (Android) / 44pt (iOS)
- All interactive elements have `contentDescription` (Android) / `accessibilityLabel` (iOS)

---

## Testing

### Android

**Test framework**: JUnit 4 + Truth + Compose UI Test (`createComposeRule`)

**Unit tests** (2 new files in `android/app/src/test/`):
- `theme/MoltCornerRadiusTest.kt` — all corner radius values, ordering, boundary checks
- `theme/MoltElevationTest.kt` — all elevation levels, ascending order, Level0 = zero

**Compose UI tests** (13 files in `android/app/src/androidTest/component/`):
`MoltButtonTest.kt`, `MoltTextFieldTest.kt`, `MoltCardTest.kt`, `MoltChipTest.kt`, `MoltTopBarTest.kt`, `MoltBottomBarTest.kt`, `MoltLoadingViewTest.kt`, `MoltErrorViewTest.kt`, `MoltEmptyViewTest.kt`, `MoltImageTest.kt`, `MoltBadgeTest.kt`, `MoltRatingBarTest.kt`, `MoltPriceTextTest.kt`, `MoltQuantityStepperTest.kt`

| Metric | Value |
|--------|-------|
| New test files | 15 (2 unit + 13 UI) |
| Total new test cases | ~90 |
| Components covered | 14 / 14 (100%) |
| Theme objects covered | 4 / 4 (100%) |

Run UI tests: `./gradlew :app:connectedAndroidTest`
Run unit tests: `./gradlew :app:test`

### iOS

**Test framework**: Swift Testing (`@Test` macro)

**Theme tests** (2 new files in `MoltMarketplaceTests/Core/DesignSystem/Theme/`):
- `MoltCornerRadiusTests.swift` — 7 tests (all 6 values, ascending order)
- `MoltElevationTests.swift` — 11 tests (all levels, radius, y-offset, opacity)

**Component tests** (14 new files in `MoltMarketplaceTests/Core/DesignSystem/Component/`):
`MoltButtonTests.swift` (11), `MoltTextFieldTests.swift` (11), `MoltCardTests.swift` (13), `MoltChipTests.swift` (10), `MoltTopBarTests.swift` (11), `MoltTabBarTests.swift` (10), `MoltLoadingViewTests.swift` (5), `MoltErrorViewTests.swift` (9), `MoltEmptyViewTests.swift` (11), `MoltImageTests.swift` (8), `MoltBadgeTests.swift` (19), `MoltRatingBarTests.swift` (12), `MoltPriceTextTests.swift` (13), `MoltQuantityStepperTests.swift` (18)

| Metric | Value |
|--------|-------|
| New test files | 16 (2 theme + 14 component) |
| Total new test cases | ~175 |
| Components covered | 14 / 14 (100%) |

Note: Tests exercise public API contracts and logic helpers. No ViewInspector snapshot tests — architecture tests (`ArchitectureTests.swift`) continue to pass.

### Combined Test Summary

| Platform | New Test Files | New Test Cases | Components Covered |
|----------|--------------|---------------|-------------------|
| Android | 15 | ~90 | 14 / 14 |
| iOS | 16 | ~175 | 14 / 14 |
| **Total** | **31** | **~265** | **14 / 14** |

---

## Platform-Specific Implementation Notes

### Android

- **Image loading**: Coil 3 `AsyncImage`. Placeholder uses `ColorPainter(MoltColors.Shimmer)` (no drawable resource needed).
- **Half-star rating**: Uses `Icons.AutoMirrored.Filled.StarHalf` for RTL support.
- **Composable complexity**: UI composables with many optional parameters suppress detekt complexity warnings per-function with `@Suppress` annotations.
- **Dependency**: Coil 3.1.0 required in `android/app/build.gradle.kts`.

### iOS

- **Image loading**: SwiftUI `AsyncImage` (not NukeUI) for M0. When `NukeUI` SPM package is added, `MoltImage.swift` can swap to `LazyImage` with zero API changes.
- **Button enum naming**: `MoltButtonVariant` (not `MoltButtonStyle`) to avoid protocol name conflict with SwiftUI's `ButtonStyle`.
- **Stepper accessibility**: `MoltQuantityStepper` uses `accessibilityAdjustableAction` for native VoiceOver stepper behavior.
- **Password toggle**: Swaps between `SecureField` and `TextField` using `@FocusState`.
- **Swift 6 concurrency**: Test closures use no-op `{}` for init verification to satisfy `@Sendable` constraint.

---

## Documentation References

- **Architect Spec**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/shared/feature-specs/design-system.md`
- **Design Tokens**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/shared/design-tokens/`
- **CLAUDE.md Standards**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/CLAUDE.md`
- **Android Standards**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/docs/standards/android.md`
- **iOS Standards**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/docs/standards/ios.md`

---

**Last Updated**: 2026-02-20
**Agent**: doc-writer
**Status**: Complete
