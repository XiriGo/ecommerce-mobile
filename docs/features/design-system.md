# M0-02: Design System

## Overview

The XiriGo Design System is the shared UI component library for the XiriGo Ecommerce mobile app on both Android (Jetpack Compose) and iOS (SwiftUI). It provides a single source of truth for visual design tokens (colors, typography, spacing, corner radius, elevation) and 14 reusable `XG*` wrapper components that all feature screens consume.

**Status**: Complete
**Phase**: M0 (Foundation)
**Issue**: #3
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)
**Blocks**: All M1+ features (every screen uses XG* components)

### Key Principle

Feature screens never import raw platform components (Material 3 primitives or SwiftUI primitives). They import only `XG*` components from `core/designsystem`. When Figma designs arrive, only files under `core/designsystem/` change — zero feature-screen edits are needed.

---

## Token Pipeline

```
shared/design-tokens/*.json
         |
         v
core/designsystem/theme/        <- Platform constants (XGColors, XGTypography, XGSpacing, ...)
         |
         v
core/designsystem/component/    <- XG* wrappers (XGButton, XGCard, ...)
         |
         v
feature/*/presentation/         <- Feature screens (consume XG* only)
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
| 1 | `XGButton` | Action button with 4 style variants and loading state | `XGButton.kt` | `XGButton.swift` |
| 2 | `XGTextField` | Text input with label, error, helper text, icons, password mode | `XGTextField.kt` | `XGTextField.swift` |
| 3 | `XGCard` | `XGProductCard` + `XGInfoCard` container variants | `XGCard.kt` | `XGCard.swift` |
| 4 | `XGChip` | `XGFilterChip` + `XGCategoryChip` for filters and categories | `XGChip.kt` | `XGChip.swift` |
| 5 | `XGTopBar` | Top navigation bar with back button and action slots | `XGTopBar.kt` | `XGTopBar.swift` |
| 6 | `XGBottomBar` / `XGTabBar` | Bottom tab navigation with badge counts | `XGBottomBar.kt` | `XGTabBar.swift` |
| 7 | `XGLoadingView` | Full-screen spinner + inline `XGLoadingIndicator` | `XGLoadingView.kt` | `XGLoadingView.swift` |
| 8 | `XGErrorView` | Error icon + message + optional retry button | `XGErrorView.kt` | `XGErrorView.swift` |
| 9 | `XGEmptyView` | Empty state icon + message + optional action button | `XGEmptyView.kt` | `XGEmptyView.swift` |
| 10 | `XGImage` | Async image with shimmer placeholder and crossfade | `XGImage.kt` | `XGImage.swift` |
| 11 | `XGBadge` | `XGCountBadge` (0/1–99/99+) + `XGStatusBadge` (5 statuses) | `XGBadge.kt` | `XGBadge.swift` |
| 12 | `XGRatingBar` | Read-only star rating with half-star precision | `XGRatingBar.kt` | `XGRatingBar.swift` |
| 13 | `XGPriceText` | Currency display with sale strikethrough, 3 size variants | `XGPriceText.kt` | `XGPriceText.swift` |
| 14 | `XGQuantityStepper` | Increment/decrement control with min/max bounds | `XGQuantityStepper.kt` | `XGQuantityStepper.swift` |

### XGButton Variants

| Variant | Android | iOS | Visual |
|---------|---------|-----|--------|
| `primary` | Filled `Button` | `.primary` | Solid primary background, white text |
| `secondary` | `OutlinedButton` | `.secondary` | Secondary container background |
| `outlined` | `OutlinedButton` (custom) | `.outlined` | Outlined border, primary text |
| `text` | `TextButton` | `.text` | No background, primary text |

iOS note: The enum is named `XGButtonVariant` (not `XGButtonStyle`) to avoid conflict with the SwiftUI `ButtonStyle` protocol.

### XGTabItem Fields

| Field | Type | Description |
|-------|------|-------------|
| `label` | `String` | Localized tab label |
| `icon` | `ImageVector` / `String` | Unselected icon |
| `selectedIcon` | `ImageVector` / `String` | Selected (filled) icon |
| `badgeCount` | `Int?` | Optional badge overlay count |

App-wide tabs: **Home**, **Categories**, **Cart** (with cart item count badge), **Profile**.

### XGBadgeStatus Values

`success`, `warning`, `error`, `info`, `neutral` — each maps to a semantic color pair from `XGColors`.

---

## Usage Examples

### Android — Feature Screen Import Pattern

```kotlin
import com.xirigo.ecommerce.core.designsystem.component.XGButton
import com.xirigo.ecommerce.core.designsystem.component.XGButtonStyle
import com.xirigo.ecommerce.core.designsystem.component.XGProductCard
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun ProductDetailScreen(onAddToCart: () -> Unit) {
    XGTheme {
        XGButton(
            text = stringResource(R.string.product_add_to_cart),
            onClick = onAddToCart,
            style = XGButtonStyle.Primary,
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
        XGButton(
            String(localized: "product_add_to_cart"),
            variant: .primary,
            action: onAddToCart
        )
    }
}
```

### Using XGTheme Wrapper

**Android** — Apply at app root in `MainActivity`:
```kotlin
XGTheme(darkTheme = isSystemInDarkTheme()) {
    // All content here inherits XGColors and XGTypography via MaterialTheme
}
```

**iOS** — Apply as a `ViewModifier` at app entry:
```swift
ContentView()
    .xgTheme()
```

---

## Theme Customization (Figma Update Process)

When Figma designs arrive, follow this process:

1. Update `shared/design-tokens/*.json` with new color, typography, and spacing values from Figma
2. Update theme files on each platform:
   - Android: `XGColors.kt`, `XGTypography.kt`, `XGSpacing.kt`, `XGCornerRadius.kt`, `XGElevation.kt`
   - iOS: `XGColors.swift`, `XGTypography.swift`, `XGSpacing.swift`, `XGCornerRadius.swift`, `XGElevation.swift`
3. Update component visual implementation if shapes or paddings change (e.g., `XGButton.kt/.swift`)
4. **Do not change** any feature screen code — the `XG*` component API contracts (parameters, callbacks, types) are stable

---

## Localization

All user-facing strings in design system components use localization keys. 17 keys are defined across 3 languages (English, Maltese, Turkish).

Key examples:

| Key | English | Usage |
|-----|---------|-------|
| `common_navigate_back` | Navigate back | XGTopBar back button |
| `common_loading_message` | Loading... | XGButton loading, XGLoadingView |
| `common_retry_button` | Retry | XGErrorView retry |
| `common_decrease_quantity` | Decrease quantity | XGQuantityStepper minus |
| `common_increase_quantity` | Increase quantity | XGQuantityStepper plus |
| `common_add_to_wishlist` | Add to wishlist | XGProductCard heart |
| `common_tab_home` | Home | XGBottomBar/XGTabBar |
| `common_tab_cart` | Cart | XGBottomBar/XGTabBar |

Android string files: `res/values/strings.xml`, `res/values-mt/strings.xml`, `res/values-tr/strings.xml`
iOS string file: `Resources/Localizable.xcstrings` (String Catalog format)

---

## File Structure

### Android

**Root**: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/`

```
core/designsystem/
  theme/
    XGColors.kt           # Color tokens (light/dark/semantic), XGLightColorScheme, XGDarkColorScheme
    XGTypography.kt       # Typography object (15 text styles)
    XGSpacing.kt          # Spacing constants (dp values)
    XGCornerRadius.kt     # Corner radius constants + RoundedCornerShape helpers
    XGElevation.kt        # Elevation constants (dp values)
    XGTheme.kt            # @Composable XGTheme wrapper
  component/
    XGButton.kt           # XGButton + XGButtonStyle enum (4 variants)
    XGTextField.kt        # XGTextField (label, error, helper, password)
    XGCard.kt             # XGProductCard + XGInfoCard
    XGChip.kt             # XGFilterChip + XGCategoryChip
    XGTopBar.kt           # XGTopBar
    XGBottomBar.kt        # XGBottomBar + XGTabItem
    XGLoadingView.kt      # XGLoadingView + XGLoadingIndicator
    XGErrorView.kt        # XGErrorView
    XGEmptyView.kt        # XGEmptyView
    XGImage.kt            # XGImage (Coil AsyncImage wrapper)
    XGBadge.kt            # XGCountBadge + XGStatusBadge + XGBadgeStatus enum
    XGRatingBar.kt        # XGRatingBar (half-star support)
    XGPriceText.kt        # XGPriceText + XGPriceSize enum
    XGQuantityStepper.kt  # XGQuantityStepper
```

Total: 6 theme files + 14 component files = **20 Kotlin files**

**String resources**:
- `android/app/src/main/res/values/strings.xml` — English (17 design system keys)
- `android/app/src/main/res/values-mt/strings.xml` — Maltese
- `android/app/src/main/res/values-tr/strings.xml` — Turkish

**Image loading**: Coil 3 (`AsyncImage`). Placeholder uses `ColorPainter(XGColors.Shimmer)`.

### iOS

**Root**: `ios/XiriGoEcommerce/Core/DesignSystem/`

```
Core/DesignSystem/
  Theme/
    XGColors.swift        # Color constants (light/dark adaptive, semantic) + Color(hex:) extension
    XGTypography.swift    # Font constants (15 text styles)
    XGSpacing.swift       # Spacing constants + IconSize + AvatarSize nested enums
    XGCornerRadius.swift  # Corner radius constants
    XGElevation.swift     # Elevation levels + ShadowStyle struct + xgElevation() modifier
    XGTheme.swift         # ViewModifier applying theme to environment
  Component/
    XGButton.swift        # XGButton view + XGButtonVariant enum (4 variants)
    XGTextField.swift     # XGTextField view (label, error, password toggle, maxLength)
    XGCard.swift          # XGProductCard + XGInfoCard views
    XGChip.swift          # XGFilterChip + XGCategoryChip views
    XGTopBar.swift        # XGTopBar view (toolbar modifiers)
    XGTabBar.swift        # XGTabBar view + XGTabItem struct
    XGLoadingView.swift   # XGLoadingView + XGLoadingIndicator views
    XGErrorView.swift     # XGErrorView
    XGEmptyView.swift     # XGEmptyView
    XGImage.swift         # XGImage (AsyncImage wrapper with shimmer placeholder)
    XGBadge.swift         # XGCountBadge + XGStatusBadge + XGBadgeStatus enum
    XGRatingBar.swift     # XGRatingBar (SF Symbols: star.fill, star.leadinghalf.filled, star)
    XGPriceText.swift     # XGPriceText + XGPriceSize enum
    XGQuantityStepper.swift # XGQuantityStepper (accessibilityAdjustableAction)
```

Total: 6 theme files + 14 component files = **20 Swift files**

**String resources**: `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` (22 design system keys)

**Image loading**: SwiftUI `AsyncImage` (NukeUI `LazyImage` can be swapped in later with zero API changes when SPM dependency is added).

---

## Architecture Compliance

Both platforms enforce these rules in every component file:

- All colors referenced from `XGColors` — no hardcoded hex values
- All spacing referenced from `XGSpacing` — no magic number dp/pt values
- All corner radii from `XGCornerRadius`; elevations from `XGElevation`
- All user-facing strings via `stringResource(R.string.xxx)` (Android) / `String(localized:)` (iOS)
- No `Any` type usage
- No force unwrap (`!!` Kotlin / `!` Swift)
- All types are immutable (`data class` / `struct`)
- Every composable/view has `modifier: Modifier = Modifier` (Android) as first optional parameter
- Every component file has `@Preview` / `#Preview` blocks wrapped in `XGTheme`
- All interactive elements meet minimum touch target: 48dp (Android) / 44pt (iOS)
- All interactive elements have `contentDescription` (Android) / `accessibilityLabel` (iOS)

---

## Testing

### Android

**Test framework**: JUnit 4 + Truth + Compose UI Test (`createComposeRule`)

**Unit tests** (2 new files in `android/app/src/test/`):
- `theme/XGCornerRadiusTest.kt` — all corner radius values, ordering, boundary checks
- `theme/XGElevationTest.kt` — all elevation levels, ascending order, Level0 = zero

**Compose UI tests** (13 files in `android/app/src/androidTest/component/`):
`XGButtonTest.kt`, `XGTextFieldTest.kt`, `XGCardTest.kt`, `XGChipTest.kt`, `XGTopBarTest.kt`, `XGBottomBarTest.kt`, `XGLoadingViewTest.kt`, `XGErrorViewTest.kt`, `XGEmptyViewTest.kt`, `XGImageTest.kt`, `XGBadgeTest.kt`, `XGRatingBarTest.kt`, `XGPriceTextTest.kt`, `XGQuantityStepperTest.kt`

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

**Theme tests** (2 new files in `XiriGoEcommerceTests/Core/DesignSystem/Theme/`):
- `XGCornerRadiusTests.swift` — 7 tests (all 6 values, ascending order)
- `XGElevationTests.swift` — 11 tests (all levels, radius, y-offset, opacity)

**Component tests** (14 new files in `XiriGoEcommerceTests/Core/DesignSystem/Component/`):
`XGButtonTests.swift` (11), `XGTextFieldTests.swift` (11), `XGCardTests.swift` (13), `XGChipTests.swift` (10), `XGTopBarTests.swift` (11), `XGTabBarTests.swift` (10), `XGLoadingViewTests.swift` (5), `XGErrorViewTests.swift` (9), `XGEmptyViewTests.swift` (11), `XGImageTests.swift` (8), `XGBadgeTests.swift` (19), `XGRatingBarTests.swift` (12), `XGPriceTextTests.swift` (13), `XGQuantityStepperTests.swift` (18)

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

- **Image loading**: Coil 3 `AsyncImage`. Placeholder uses `ColorPainter(XGColors.Shimmer)` (no drawable resource needed).
- **Half-star rating**: Uses `Icons.AutoMirrored.Filled.StarHalf` for RTL support.
- **Composable complexity**: UI composables with many optional parameters suppress detekt complexity warnings per-function with `@Suppress` annotations.
- **Dependency**: Coil 3.1.0 required in `android/app/build.gradle.kts`.

### iOS

- **Image loading**: SwiftUI `AsyncImage` (not NukeUI) for M0. When `NukeUI` SPM package is added, `XGImage.swift` can swap to `LazyImage` with zero API changes.
- **Button enum naming**: `XGButtonVariant` (not `XGButtonStyle`) to avoid protocol name conflict with SwiftUI's `ButtonStyle`.
- **Stepper accessibility**: `XGQuantityStepper` uses `accessibilityAdjustableAction` for native VoiceOver stepper behavior.
- **Password toggle**: Swaps between `SecureField` and `TextField` using `@FocusState`.
- **Swift 6 concurrency**: Test closures use no-op `{}` for init verification to satisfy `@Sendable` constraint.

---

## Documentation References

- **Architect Spec**: `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/shared/feature-specs/design-system.md`
- **Design Tokens**: `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/shared/design-tokens/`
- **CLAUDE.md Standards**: `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/CLAUDE.md`
- **Android Standards**: `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/docs/standards/android.md`
- **iOS Standards**: `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/docs/standards/ios.md`

---

**Last Updated**: 2026-02-20
**Agent**: doc-writer
**Status**: Complete
