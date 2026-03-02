# M0-02: Design System

## Overview

The XiriGo Design System is the shared UI component library for the XiriGo Ecommerce mobile app on both Android (Jetpack Compose) and iOS (SwiftUI). It provides a single source of truth for visual design tokens (colors, typography, spacing, corner radius, elevation, motion) and 35 reusable `XG*` wrapper components that all feature screens consume.

**Status**: Complete (updated after DQ backfill)
**Phase**: M0 (Foundation) + DQ (Design Quality Backfill)
**Issue**: #3 (M0-02), DQ-01 through DQ-40
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
core/designsystem/theme/        <- Platform constants (XGColors, XGTypography, XGSpacing, XGMotion, ...)
         |
         v
core/designsystem/component/    <- XG* wrappers (XGButton, XGCard, ShimmerModifier, Skeleton, ...)
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

### Motion (XGMotion) -- Added in DQ-01/DQ-02

Centralized animation, transition, shimmer, scroll, and performance tokens. Source: `shared/design-tokens/foundations/motion.json`.

**Duration** (5 tokens):

| Token | Android | iOS | Value | Usage |
|-------|---------|-----|-------|-------|
| `instant` | `XGMotion.Duration.INSTANT` | `XGMotion.Duration.instant` | 100ms / 0.1s | Micro-interactions (button press, toggle, checkbox) |
| `fast` | `XGMotion.Duration.FAST` | `XGMotion.Duration.fast` | 200ms / 0.2s | Content switch, crossfade, chip toggle |
| `normal` | `XGMotion.Duration.NORMAL` | `XGMotion.Duration.normal` | 300ms / 0.3s | Standard transitions, image fade-in |
| `slow` | `XGMotion.Duration.SLOW` | `XGMotion.Duration.slow` | 450ms / 0.45s | Modal entrance/exit, bottom sheet slide |
| `pageTransition` | `XGMotion.Duration.PAGE_TRANSITION` | `XGMotion.Duration.pageTransition` | 350ms / 0.35s | Screen-to-screen navigation |

**Easing** (4 tokens):

| Token | Android | iOS | Usage |
|-------|---------|-----|-------|
| `standard` | `FastOutSlowInEasing` / `EaseInOut` | `.easeInOut` | General-purpose symmetric animation |
| `decelerate` | `LinearOutSlowInEasing` / `EaseOut` | `.easeOut` | Elements entering the viewport |
| `accelerate` | `FastOutLinearInEasing` / `EaseIn` | `.easeIn` | Elements leaving the viewport |
| `spring` | `spring(dampingRatio=0.7, stiffness=Medium)` | `.spring(response: 0.35, dampingFraction: 0.7)` | Interactive gestures, pagination dots, wishlist bounce |

**Shimmer** (4 tokens):

| Token | Value | Description |
|-------|-------|-------------|
| `gradientColors` | `[#E0E0E0, #F5F5F5, #E0E0E0]` | Three-color linear gradient |
| `angleDegrees` | 20 | Subtle diagonal sweep angle |
| `durationMs` | 1200ms | One full sweep cycle |
| `repeatMode` | restart | No reverse, continuous loop |

**Crossfade** (2 tokens):

| Token | Value | Usage |
|-------|-------|-------|
| `imageFadeIn` | 300ms | Image crossfade after loading |
| `contentSwitch` | 200ms | Loading-to-content state transition |

**Scroll** (4 tokens):

| Token | Value | Usage |
|-------|-------|-------|
| `prefetchDistance` | 5 items | Pagination prefetch threshold |
| `scrollRestorationEnabled` | true | Preserve scroll position on navigation |
| `autoScrollIntervalMs` | 5000ms | Hero banner carousel auto-scroll |
| `flingDecayFriction` | platform default | Scroll deceleration |

**Entrance Animation** (4 tokens):

| Token | Value | Usage |
|-------|-------|-------|
| `staggerDelayMs` | 50ms | Delay between consecutive list items |
| `maxStaggerItems` | 8 | Maximum items to stagger (first page only) |
| `fadeFromOpacity` / `fadeToOpacity` | 0 / 1 | Opacity range for entrance fade |
| `slideOffsetY` | 20dp/pt | Vertical slide offset for entrance |

**Performance Budgets** (5 tokens):

| Token | Value | Description |
|-------|-------|-------------|
| `frameTimeMs` | 16ms | Maximum frame time (60fps) |
| `startupColdMs` | 2000ms | Cold startup to first content |
| `screenTransitionMs` | 300ms | Maximum screen transition duration |
| `listScrollFps` | 60 | Required scroll FPS |
| `firstContentfulPaintMs` | 1000ms | First contentful paint budget |

---

## Component Catalog

All 35 components (atoms, molecules, brand, infrastructure) are implemented on both platforms.

### Atoms (17 components)

| # | Component | Description | Token File | DQ Issue |
|---|-----------|-------------|-----------|----------|
| 1 | `XGButton` | Action button with 4 style variants (primary, secondary, outlined, text) and loading state | `xg-button.json` | -- |
| 2 | `XGTextField` | Text input with label, error, helper text, icons, password mode | `xg-text-field.json` | -- |
| 3 | `XGCard` | `XGProductCard` + `XGInfoCard` container variants | -- | DQ-22 |
| 4 | `XGChip` | `XGFilterChip` + `XGCategoryChip` for filters and categories | `xg-chip.json` | DQ-18 |
| 5 | `XGBadge` | `XGCountBadge` (0/1-99/99+) + `XGStatusBadge` (5 statuses) + `XGBadgeVariant` (Primary/Secondary) | `xg-badge.json` | DQ-08 |
| 6 | `XGImage` | Async image with shimmer placeholder, crossfade, and branded error fallback | `xg-image.json` | DQ-07 |
| 7 | `XGRatingBar` | Read-only star rating with half-star precision | `xg-rating-bar.json` | -- |
| 8 | `XGPriceText` | Currency display with sale strikethrough, 3 size variants + `XGPriceLayout` (inline/stacked) | `xg-price-text.json` | DQ-38 |
| 9 | `XGQuantityStepper` | Increment/decrement control with min/max bounds | `xg-quantity-stepper.json` | -- |
| 10 | `XGSearchBar` | Search input with icon, pill-shaped corners (28dp/pt), outline border | `xg-search-bar.json` | DQ-12 |
| 11 | `XGSectionHeader` | Title + subtitle + "See All" action link | `xg-section-header.json` | DQ-13 |
| 12 | `XGPaginationDots` | Animated pagination indicator with pill active dot and spring animation | `xg-pagination-dots.json` | DQ-09 |
| 13 | `XGWishlistButton` | Heart toggle with animated color transition and scale bounce | `xg-wishlist-button.json` | DQ-15 |
| 14 | `XGCategoryIcon` | Colored tile for category display (79dp) | `xg-category-icon.json` | -- |
| 15 | `XGDivider` | `XGDivider` (line) + `XGLabeledDivider` ("OR CONTINUE WITH" pattern) | `xg-divider.json` | DQ-19 |
| 16 | `XGColorSwatch` | Circular color swatch with selection ring and adaptive checkmark | `xg-color-swatch.json` | DQ-20 |
| 17 | `XGRangeSlider` | Dual-thumb range slider for price filter (continuous + stepped modes) | `xg-range-slider.json` | DQ-21 |

### Molecules (7 components)

| # | Component | Description | Token File | DQ Issue |
|---|-----------|-------------|-----------|----------|
| 18 | `XGTopBar` | Top navigation bar with back button, action slots, Surface/Transparent variants | `xg-top-bar.json` | DQ-29 |
| 19 | `XGBottomBar` / `XGTabBar` | Bottom tab navigation with badge counts, animated icon tint transition | `xg-bottom-bar.json` | DQ-30 |
| 20 | `XGLoadingView` | Skeleton-aware loading with optional skeleton slot, crossfade transition | `xg-loading-view.json` | DQ-26 |
| 21 | `XGErrorView` | Error icon + message + retry, with crossfade transition overload | `xg-error-view.json` | DQ-27 |
| 22 | `XGEmptyView` | Empty state icon + message + outlined CTA button | `xg-empty-view.json` | DQ-28 |
| 23 | `XGFilterPill` | Filter pill with selected/unselected state + `XGFilterPillRow` scrollable list | `xg-filter-pill.json` | DQ-31 |
| 24 | `XGSocialLoginButton` | Google/Apple social auth button with brand icons and loading state | `xg-social-login-button.json` | DQ-32 |

### Screen-Level Components (4 components)

| # | Component | Description | Token File | DQ Issue |
|---|-----------|-------------|-----------|----------|
| 25 | `XGHeroBanner` | 192dp gradient hero card + `HeroBannerSkeleton` | `xg-hero-banner.json` | DQ-23 |
| 26 | `XGDailyDealCard` | Countdown card (163dp) with motion token timers | `xg-daily-deal-card.json` | DQ-24 |
| 27 | `XGFlashSaleBanner` | Yellow banner (133dp) with Canvas diagonal accent stripes + shimmer | `xg-flash-sale-banner.json` | DQ-25 |
| 28 | `XGProductCard` | Product card with skeleton variant, `reserveSpace` for uniform grid height | `xg-product-card.json` | DQ-22 |

### Brand Components (3 components)

| # | Component | Description | Token File | DQ Issue |
|---|-----------|-------------|-----------|----------|
| 29 | `XGBrandGradient` | Radial brand gradient background (2-layer composition) | `xg-brand-gradient.json` | DQ-33 |
| 30 | `XGBrandPattern` | Tiled X-motif pattern overlay at 6% opacity | `xg-brand-pattern.json` | DQ-33 |
| 31 | `XGLogoMark` | Two-chevron logo mark (green + white), scalable | `xg-logo-mark.json` | DQ-33 |

### Infrastructure Components (4 components)

| # | Component | Description | Token File | DQ Issue |
|---|-----------|-------------|-----------|----------|
| 32 | `ShimmerModifier` | Animated gradient sweep modifier for loading placeholders | (motion.json) | DQ-03/DQ-04 |
| 33 | `SkeletonBox` | Rectangular shimmer placeholder with configurable dimensions | `xg-skeleton.json` | DQ-05/DQ-06 |
| 34 | `SkeletonLine` | Text-line shimmer placeholder (fixed small corner radius) | `xg-skeleton.json` | DQ-05/DQ-06 |
| 35 | `SkeletonCircle` | Circular shimmer placeholder | `xg-skeleton.json` | DQ-05/DQ-06 |

### Skeleton Screen Variants

These composites are built from skeleton primitives and used in `UiState.Loading`:

| Skeleton | Description | DQ Issue |
|----------|-------------|----------|
| `ProductCardSkeleton` | Mirrors `XGProductCard` layout with shimmer boxes/lines | DQ-22 |
| `HeroBannerSkeleton` | Full-width shimmer with overlaid tag/headline/subtitle lines | DQ-23 |
| `HomeScreenSkeleton` | Full home screen skeleton (default slot in `XGLoadingView`) | DQ-26/DQ-34/DQ-35 |

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

1. Update `shared/design-tokens/*.json` with new color, typography, spacing, and motion values from Figma
2. Update theme files on each platform:
   - Android: `XGColors.kt`, `XGTypography.kt`, `XGSpacing.kt`, `XGCornerRadius.kt`, `XGElevation.kt`, `XGMotion.kt`
   - iOS: `XGColors.swift`, `XGTypography.swift`, `XGSpacing.swift`, `XGCornerRadius.swift`, `XGElevation.swift`, `XGMotion.swift`
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
    XGColors.kt           # Color tokens (light/dark/semantic + social/brand/filter tokens)
    XGTypography.kt       # Typography object (15 text styles)
    XGSpacing.kt          # Spacing constants (dp values)
    XGCornerRadius.kt     # Corner radius constants + RoundedCornerShape helpers
    XGElevation.kt        # Elevation constants (dp values)
    XGMotion.kt           # Motion tokens (duration, easing, shimmer, crossfade, scroll, perf)
    XGTheme.kt            # @Composable XGTheme wrapper
  component/
    ShimmerModifier.kt    # Modifier.shimmerEffect(enabled) — animated gradient sweep
    Skeleton.kt           # SkeletonBox, SkeletonLine, SkeletonCircle, XGSkeleton crossfade
    XGBadge.kt            # XGBadge + XGCountBadge + XGStatusBadge + XGBadgeStatus + XGBadgeVariant
    XGBadgeStatus.kt      # XGBadgeStatus enum
    XGBottomBar.kt        # XGBottomBar + XGTabItem (custom Row-based, animated icon tint)
    XGBrandGradient.kt    # XGBrandGradient (radial gradient background)
    XGBrandPattern.kt     # XGBrandPattern (tiled X-motif overlay)
    XGButton.kt           # XGButton + XGButtonStyle enum (4 variants)
    XGButtonStyle.kt      # XGButtonStyle enum
    XGCard.kt             # XGProductCard + XGInfoCard + ProductCardSkeleton
    XGCategoryIcon.kt     # XGCategoryIcon (79dp colored tile)
    XGChip.kt             # XGFilterChip + XGCategoryChip (token-audited)
    XGColorSwatch.kt      # XGColorSwatch (circular swatch with selection ring)
    XGDailyDealCard.kt    # XGDailyDealCard (countdown card with motion tokens)
    XGDivider.kt          # XGDivider + XGLabeledDivider
    XGEmptyView.kt        # XGEmptyView (outlined CTA button)
    XGErrorView.kt        # XGErrorView + crossfade overload
    XGFilterPill.kt       # XGFilterPill + XGFilterPillRow
    XGFlashSaleBanner.kt  # XGFlashSaleBanner (diagonal stripes + shimmer)
    XGHeroBanner.kt       # XGHeroBanner + HeroBannerSkeleton
    XGImage.kt            # XGImage (Coil, shimmer + crossfade + fallback)
    XGLoadingView.kt      # XGLoadingView + XGLoadingIndicator (skeleton-aware)
    XGLogoMark.kt         # XGLogoMark (two-chevron logo)
    XGPaginationDots.kt   # XGPaginationDots (spring-animated)
    XGPriceLayout.kt      # XGPriceLayout enum (inline/stacked)
    XGPriceSize.kt        # XGPriceSize enum
    XGPriceText.kt        # XGPriceText (currency display + sale strikethrough)
    XGQuantityStepper.kt  # XGQuantityStepper
    XGRangeSlider.kt      # XGRangeSlider (dual-thumb, Canvas-based)
    XGRatingBar.kt        # XGRatingBar (half-star support)
    XGSearchBar.kt        # XGSearchBar (pill-shaped, outline border)
    XGSectionHeader.kt    # XGSectionHeader (title + subtitle + see-all)
    XGSocialLoginButton.kt # XGSocialLoginButton (Google/Apple brand icons)
    XGTabItem.kt          # XGTabItem data class
    XGTextField.kt        # XGTextField (label, error, helper, password)
    XGTopBar.kt           # XGTopBar + XGTopBarVariant (Surface/Transparent)
    XGWishlistButton.kt   # XGWishlistButton (animated color + scale bounce)
```

Total: 7 theme files + 37 component files = **44 Kotlin files**

**String resources**:
- `android/app/src/main/res/values/strings.xml` — English
- `android/app/src/main/res/values-mt/strings.xml` — Maltese
- `android/app/src/main/res/values-tr/strings.xml` — Turkish

**Image loading**: Coil 3 (`AsyncImage`). Shimmer via `shimmerEffect()` modifier. Branded fallback on error.

### iOS

**Root**: `ios/XiriGoEcommerce/Core/DesignSystem/`

```
Core/DesignSystem/
  Theme/
    XGColors.swift        # Color constants (light/dark adaptive, semantic + social/brand/filter)
    XGTypography.swift    # Font constants (15 text styles)
    XGSpacing.swift       # Spacing constants + IconSize + AvatarSize nested enums
    XGCornerRadius.swift  # Corner radius constants
    XGElevation.swift     # Elevation levels + ShadowStyle struct + xgElevation() modifier
    XGMotion.swift        # Motion tokens (Duration, Easing, Shimmer, Crossfade, Scroll, Perf)
    XGTheme.swift         # ViewModifier applying theme to environment
  Component/
    ShimmerModifier.swift     # View.shimmerEffect(active) — animated gradient sweep
    Skeleton.swift            # SkeletonBox, SkeletonLine, SkeletonCircle, .skeleton() modifier
    ProductCardSkeleton.swift # ProductCardSkeleton (mirrors XGProductCard layout)
    XGBadge.swift             # XGCountBadge + XGStatusBadge + XGBadgeStatus enum
    XGBrandGradient.swift     # XGBrandGradient (radial gradient background)
    XGBrandPattern.swift      # XGBrandPattern (tiled X-motif overlay)
    XGButton.swift            # XGButton + XGButtonVariant enum (4 variants)
    XGCard.swift              # XGProductCard + XGInfoCard
    XGCategoryIcon.swift      # XGCategoryIcon (79pt colored tile)
    XGChip.swift              # XGFilterChip + XGCategoryChip (token-audited)
    XGColorSwatch.swift       # XGColorSwatch (circular swatch with selection ring)
    XGDailyDealCard.swift     # XGDailyDealCard (countdown card, TimelineView)
    XGDivider.swift           # XGDivider + XGLabeledDivider
    XGEmptyView.swift         # XGEmptyView (outlined CTA button)
    XGErrorView.swift         # XGErrorView + crossfade overload
    XGFilterPill.swift        # XGFilterPill + XGFilterPillRow
    XGFlashSaleBanner.swift   # XGFlashSaleBanner (diagonal stripes + shimmer)
    XGHeroBanner.swift        # XGHeroBanner + HeroBannerSkeleton
    XGImage.swift             # XGImage (AsyncImage, shimmer + crossfade + fallback)
    XGLoadingView.swift       # XGLoadingView + XGLoadingIndicator (skeleton-aware)
    XGLogoMark.swift          # XGLogoMark (two-chevron logo)
    XGPaginationDots.swift    # XGPaginationDots (spring-animated)
    XGPriceLayout.swift       # XGPriceLayout enum (inline/stacked)
    XGPriceText.swift         # XGPriceText (currency display + sale strikethrough)
    XGQuantityStepper.swift   # XGQuantityStepper (accessibilityAdjustableAction)
    XGRangeSlider.swift       # XGRangeSlider (dual-thumb, GeometryReader-based)
    XGRatingBar.swift         # XGRatingBar (SF Symbols, half-star)
    XGSearchBar.swift         # XGSearchBar (pill-shaped, outline border)
    XGSectionHeader.swift     # XGSectionHeader (title + subtitle + see-all)
    XGSocialLoginButton.swift # XGSocialLoginButton (Google/Apple brand icons)
    XGTabBar.swift            # XGTabBar + XGTabItem struct (animated icon tint)
    XGTextField.swift         # XGTextField (label, error, password toggle, maxLength)
    XGTopBar.swift            # XGTopBar + XGTopBarVariant (Surface/Transparent)
    XGWishlistButton.swift    # XGWishlistButton (animated color + scale bounce)
```

Total: 7 theme files + 35 component files = **42 Swift files**

**String resources**: `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` (String Catalog, 3 languages)

**Image loading**: SwiftUI `AsyncImage`. Shimmer via `.shimmerEffect()` modifier. Branded fallback on error.

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

---

## Shimmer and Skeleton Usage Guide

### When to Use Shimmer

The `shimmerEffect()` modifier applies an animated gradient sweep to any view as a loading placeholder. Use it:

- On `SkeletonBox`, `SkeletonLine`, `SkeletonCircle` primitives (applied automatically)
- On `XGImage` during the loading phase (built-in)
- On any custom placeholder shape during async data loading

**Android**: `Modifier.shimmerEffect(enabled: Boolean = true)`
**iOS**: `View.shimmerEffect(active: Bool = true)`

All parameters (gradient colors, angle, duration) come from `XGMotion.Shimmer` tokens. Pass `enabled = false` / `active = false` to disable without removing the modifier.

### When to Use Skeleton Screens

Every screen with async data MUST show a layout-matching skeleton during `UiState.Loading`. The skeleton replaces the old centered spinner pattern.

**Skeleton Primitives**:

| Primitive | Shape | Corner Radius | Usage |
|-----------|-------|--------------|-------|
| `SkeletonBox` | Rectangle | `XGCornerRadius.medium` (configurable) | Image placeholders, card backgrounds |
| `SkeletonLine` | Rectangle | `XGCornerRadius.small` (fixed) | Text line placeholders |
| `SkeletonCircle` | Circle | N/A | Avatar, icon placeholders |

**Content-Wrapping Crossfade**:

- **Android**: `XGSkeleton(visible, placeholder) { content }` -- crossfades between skeleton and real content using `XGMotion.Crossfade.CONTENT_SWITCH` (200ms)
- **iOS**: `.skeleton(visible:, placeholder:)` modifier -- uses `.transition(.opacity)` with `XGMotion.Crossfade.contentSwitch` (0.2s)

**Pre-built Skeleton Screens**:

- `ProductCardSkeleton` -- Use in product grids during loading
- `HeroBannerSkeleton` -- Use in hero carousel during loading
- `XGLoadingView` default skeleton -- Full-screen default skeleton (box + lines) when no custom slot is provided

### Design Rules

1. Skeleton shapes MUST match the final content layout
2. All skeleton rectangles use animated shimmer (never static gray)
3. Skeleton corner radius matches the component's corner radius token
4. Grid skeletons show the same number of columns as the real grid
5. Pull-to-refresh does NOT show skeleton when data already exists (uses inline indicator)

---

## DQ Backfill Summary

The Design Quality (DQ) backfill consisted of 40 issues that upgraded the design system from its M0 foundation state to production quality. Key improvements:

| Category | Issues | Description |
|----------|--------|-------------|
| Motion Tokens | DQ-01, DQ-02 | Added `XGMotion` token namespace (Duration, Easing, Shimmer, Crossfade, Scroll, Perf) |
| Shimmer | DQ-03, DQ-04 | Added `shimmerEffect()` modifier on both platforms |
| Skeletons | DQ-05, DQ-06 | Added `SkeletonBox/Line/Circle` primitives + content crossfade |
| Image Pipeline | DQ-07 | Upgraded `XGImage` with shimmer, crossfade, branded fallback |
| Component Audits | DQ-08 to DQ-15, DQ-18, DQ-22 to DQ-30, DQ-33 | Token compliance audit for all existing components |
| New Components | DQ-19 to DQ-21, DQ-31, DQ-32 | Added XGDivider, XGColorSwatch, XGRangeSlider, XGFilterPill, XGSocialLoginButton |
| Lazy Rendering | DQ-34, DQ-35 | Replaced eager rendering with LazyColumn/LazyVStack on HomeScreen |
| Platform Parity | DQ-36, DQ-37, DQ-38 | iOS-specific lazy home screen, XGPriceLayout port |
| Tests | DQ-39 | Added shimmer + skeleton unit tests |
| Documentation | DQ-40 | This update |

---

**Last Updated**: 2026-03-02
**Agent**: pipeline (DQ-40)
**Status**: Complete
