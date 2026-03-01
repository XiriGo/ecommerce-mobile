# Badge Components

## Overview

Badge components are design-system-level atoms used to annotate UI elements with labels, counts, and semantic status indicators. The XiriGo badge family provides three components — `XGBadge`, `XGCountBadge`, and `XGStatusBadge` — all sourced from `shared/design-tokens/components/atoms/xg-badge.json`.

This document reflects DQ-08, the token audit pass that brought Android to full parity with iOS, replaced direct `MaterialTheme.colorScheme` references with `XGColors` tokens, corrected the `XGCountBadge` shape from `CircleShape` to a true capsule, added the `XGBadge` (primary/secondary) composable, and introduced `XGCustomTextStyles.CaptionSemiBold` on Android.

**Status**: Complete
**Phase**: M0 (Foundation) — DQ backfill
**Issue**: DQ-08 (Android + iOS)
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)
**Design token source**: `shared/design-tokens/components/atoms/xg-badge.json`

---

## File Locations

| Platform | File | Layer |
|----------|------|-------|
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGBadge.kt` | Design System / Component |
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGBadgeStatus.kt` | Design System / Component |
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGTypography.kt` | Design System / Theme |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGBadge.swift` | Design System / Component |
| Token file | `shared/design-tokens/components/atoms/xg-badge.json` | Shared |

### Test Files

| Platform | File | Type | Count |
|----------|------|------|-------|
| Android | `android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/component/XGBadgeTokenTest.kt` | JVM unit | 37 |
| Android | `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGBadgeTest.kt` | Compose UI | 19 |
| iOS | `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGBadgeTests.swift` | Swift Testing | 89 (88 pass, 1 skip) |

---

## Architecture

Badge components live exclusively in the design system layer. They have no domain or data layer dependencies.

```
XGBadge / XGCountBadge / XGStatusBadge
    |
    +-- XGBadgeVariant (Primary / Secondary)      [XGBadge only]
    +-- XGBadgeStatus (Success/Warning/Error/Info/Neutral)   [XGStatusBadge only]
    +-- XGColors.*                                 (all color tokens)
    +-- XGCornerRadius.Medium / .Full              (shape)
    +-- XGSpacing.XXS / XS / SM                   (padding)
    +-- XGCustomTextStyles.CaptionSemiBold         (Android XGBadge)
    +-- MaterialTheme.typography.labelSmall        (Android count/status)
    +-- XGTypography.captionSemiBold               (iOS XGBadge)
    +-- XGTypography.labelSmall                    (iOS count/status)
```

---

## Components

### XGBadge

Inline label badge with primary and secondary color variants. Used for product-level labels such as SALE, NEW SEASON, and DAILY DEAL.

#### Android API

```kotlin
enum class XGBadgeVariant(
    val backgroundColor: Color,
    val textColor: Color,
) {
    Primary(
        backgroundColor = XGColors.BadgeBackground,
        textColor = XGColors.BadgeText,
    ),
    Secondary(
        backgroundColor = XGColors.BadgeSecondaryBackground,
        textColor = XGColors.BadgeSecondaryText,
    ),
}

@Composable
fun XGBadge(
    label: String,
    modifier: Modifier = Modifier,
    variant: XGBadgeVariant = XGBadgeVariant.Primary,
)
```

#### iOS API

```swift
enum XGBadgeVariant {
    case primary
    case secondary
}

struct XGBadge: View {
    init(
        label: String,
        variant: XGBadgeVariant = .primary,
    )
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | `String` | required | The text to display inside the badge |
| `variant` | `XGBadgeVariant` | `.primary` / `Primary` | Color scheme — primary (brand purple) or secondary (brand green) |

**Visual behavior**: Clips to `RoundedCornerShape(XGCornerRadius.Medium)` / `RoundedRectangle(cornerRadius: XGCornerRadius.medium)` (10dp/pt). Applies `CaptionSemiBold` text style (12sp/pt, SemiBold, Poppins). Horizontal padding 10dp/pt, vertical padding 4dp/pt.

---

### XGCountBadge

Capsule-shaped count badge used on the cart tab and notification icons. Displays a number, capping at "99+" for counts of 100 or more. Renders nothing when `count` is zero or negative.

#### Android API

```kotlin
@Composable
fun XGCountBadge(
    count: Int,
    modifier: Modifier = Modifier,
)
```

#### iOS API

```swift
struct XGCountBadge: View {
    init(count: Int)
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `count` | `Int` | required | The number to display. Zero or negative: renders nothing. |

**Display logic**:

| Count | Displayed text |
|-------|---------------|
| <= 0 | (not rendered) |
| 1 – 99 | The count as a string (e.g. "5") |
| >= 100 | "99+" |

**Visual behavior**: Clips to `RoundedCornerShape(XGCornerRadius.Full)` / `Capsule()` (pill shape). Background `XGColors.BadgeBackground` (#6000FE), text `XGColors.BadgeText` (#FFFFFF). Horizontal padding `XGSpacing.XS` (4dp/pt), vertical padding `XGSpacing.XXS` (2dp/pt). Font: `MaterialTheme.typography.labelSmall` (Android, 10sp Normal) / `XGTypography.labelSmall` (iOS, 11pt Medium).

**Note**: Android uses `MaterialTheme.typography.labelSmall` which maps to `XGTypography.labelSmall` (10sp Normal — the micro scale). The token spec declares `labelSmall (11pt Medium)`. The iOS implementation uses `XGTypography.labelSmall` at 11pt Medium. This size discrepancy is a known deviation flagged for design review.

---

### XGStatusBadge

Pill-shaped badge with five semantic status variants. Used on product cards and order screens to indicate availability, order state, and other contextual statuses.

#### Android API

```kotlin
enum class XGBadgeStatus {
    Success, Warning, Error, Info, Neutral,
}

@Composable
fun XGStatusBadge(
    status: XGBadgeStatus,
    label: String,
    modifier: Modifier = Modifier,
)
```

#### iOS API

```swift
enum XGBadgeStatus {
    case success, warning, error, info, neutral
}

struct XGStatusBadge: View {
    init(status: XGBadgeStatus, label: String)
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `status` | `XGBadgeStatus` | required | Determines background and text colors |
| `label` | `String` | required | The text to display. Empty string is allowed and renders an empty pill. |

**Visual behavior**: Clips to `RoundedCornerShape(XGCornerRadius.Full)` / `Capsule()`. Horizontal padding `XGSpacing.SM` (8dp/pt), vertical padding `XGSpacing.XS` (4dp/pt). Font: `MaterialTheme.typography.labelSmall` (Android) / `XGTypography.labelSmall` (iOS).

---

## Design Tokens

### Color Tokens

| Token | Android | iOS | Value | Used By |
|-------|---------|-----|-------|---------|
| Badge primary background | `XGColors.BadgeBackground` | `XGColors.badgeBackground` | #6000FE | `XGBadge` (primary), `XGCountBadge` |
| Badge primary text | `XGColors.BadgeText` | `XGColors.badgeText` | #FFFFFF | `XGBadge` (primary), `XGCountBadge` |
| Badge secondary background | `XGColors.BadgeSecondaryBackground` | `XGColors.badgeSecondaryBackground` | #94D63A | `XGBadge` (secondary) |
| Badge secondary text | `XGColors.BadgeSecondaryText` | `XGColors.badgeSecondaryText` | #6000FE | `XGBadge` (secondary) |
| Success background | `XGColors.Success` | `XGColors.success` | #22C55E | `XGStatusBadge` (.success) |
| On success text | `XGColors.OnSuccess` | `XGColors.onSuccess` | #FFFFFF | `XGStatusBadge` (.success) |
| Warning background | `XGColors.Warning` | `XGColors.warning` | #FACC15 | `XGStatusBadge` (.warning) |
| On warning text | `XGColors.OnWarning` | `XGColors.onWarning` | #1D1D1B | `XGStatusBadge` (.warning) |
| Error background | `XGColors.Error` | `XGColors.error` | #EF4444 | `XGStatusBadge` (.error) |
| On error text | `XGColors.OnError` | `XGColors.onError` | #FFFFFF | `XGStatusBadge` (.error) |
| Info background | `XGColors.Info` | `XGColors.info` | #3B82F6 | `XGStatusBadge` (.info) |
| On info text | `XGColors.OnInfo` | `XGColors.onInfo` | #FFFFFF | `XGStatusBadge` (.info) |
| Neutral background | `XGColors.SurfaceVariant` | `XGColors.surfaceVariant` | #F9FAFB | `XGStatusBadge` (.neutral) |
| On neutral text | `XGColors.OnSurfaceVariant` | `XGColors.onSurfaceVariant` | #8E8E93 | `XGStatusBadge` (.neutral) |

### Shape Tokens

| Component | Android | iOS | Value |
|-----------|---------|-----|-------|
| `XGBadge` corner radius | `XGCornerRadius.Medium` | `XGCornerRadius.medium` | 10dp / 10pt |
| `XGCountBadge` shape | `RoundedCornerShape(XGCornerRadius.Full)` | `Capsule()` | Pill |
| `XGStatusBadge` shape | `RoundedCornerShape(XGCornerRadius.Full)` | `Capsule()` | Pill |

### Padding Tokens

| Component | Direction | Android | iOS | Value |
|-----------|-----------|---------|-----|-------|
| `XGBadge` | Horizontal | `BadgeConstants.HorizontalPadding` | `Constants.horizontalPadding` | 10dp / 10pt |
| `XGBadge` | Vertical | `BadgeConstants.VerticalPadding` | `Constants.verticalPadding` | 4dp / 4pt |
| `XGCountBadge` | Horizontal | `XGSpacing.XS` | `XGSpacing.xs` | 4dp / 4pt |
| `XGCountBadge` | Vertical | `XGSpacing.XXS` | `XGSpacing.xxs` | 2dp / 2pt |
| `XGStatusBadge` | Horizontal | `XGSpacing.SM` | `XGSpacing.sm` | 8dp / 8pt |
| `XGStatusBadge` | Vertical | `XGSpacing.XS` | `XGSpacing.xs` | 4dp / 4pt |

### Typography Tokens

| Component | Android | iOS | Value |
|-----------|---------|-----|-------|
| `XGBadge` | `XGCustomTextStyles.CaptionSemiBold` | `XGTypography.captionSemiBold` | 12sp / 12pt, SemiBold, Poppins |
| `XGCountBadge` | `MaterialTheme.typography.labelSmall` | `XGTypography.labelSmall` | 10sp Normal (Android) / 11pt Medium (iOS) |
| `XGStatusBadge` | `MaterialTheme.typography.labelSmall` | `XGTypography.labelSmall` | 10sp Normal (Android) / 11pt Medium (iOS) |

---

## Status Color Reference

| Status | Background | Text | Example usage |
|--------|-----------|------|---------------|
| `.success` / `Success` | #22C55E | #FFFFFF | "In Stock" |
| `.warning` / `Warning` | #FACC15 | #1D1D1B | "Low Stock" |
| `.error` / `Error` | #EF4444 | #FFFFFF | "Out of Stock" |
| `.info` / `Info` | #3B82F6 | #FFFFFF | "Processing" |
| `.neutral` / `Neutral` | #F9FAFB | #8E8E93 | "Draft", "Archived" |

---

## Usage Examples

### XGBadge on a product card

**Android**:

```kotlin
XGBadge(label = "SALE", variant = XGBadgeVariant.Primary)
XGBadge(label = "NEW SEASON", variant = XGBadgeVariant.Secondary)
XGBadge(label = "DAILY DEAL", variant = XGBadgeVariant.Secondary)
```

**iOS**:

```swift
XGBadge(label: "SALE", variant: .primary)
XGBadge(label: "NEW SEASON", variant: .secondary)
XGBadge(label: "DAILY DEAL", variant: .secondary)
```

### XGCountBadge on the cart tab icon

**Android**:

```kotlin
XGCountBadge(count = cartItemCount)
// count = 0   → renders nothing
// count = 5   → shows "5"
// count = 150 → shows "99+"
```

**iOS**:

```swift
XGCountBadge(count: cartItemCount)
// count = 0   → renders nothing
// count = 5   → shows "5"
// count = 150 → shows "99+"
```

### XGStatusBadge on a product availability indicator

**Android**:

```kotlin
XGStatusBadge(status = XGBadgeStatus.Success, label = "In Stock")
XGStatusBadge(status = XGBadgeStatus.Warning, label = "Low Stock")
XGStatusBadge(status = XGBadgeStatus.Error, label = "Out of Stock")
XGStatusBadge(status = XGBadgeStatus.Info, label = "Processing")
XGStatusBadge(status = XGBadgeStatus.Neutral, label = "Draft")
```

**iOS**:

```swift
XGStatusBadge(status: .success, label: "In Stock")
XGStatusBadge(status: .warning, label: "Low Stock")
XGStatusBadge(status: .error, label: "Out of Stock")
XGStatusBadge(status: .info, label: "Processing")
XGStatusBadge(status: .neutral, label: "Draft")
```

---

## Accessibility

| Component | Android | iOS |
|-----------|---------|-----|
| `XGBadge` | No explicit `contentDescription` (text node is inherently accessible) | `.accessibilityLabel(label)` |
| `XGCountBadge` | `semantics { contentDescription = stringResource(R.string.common_notifications_count, count) }` | `String(localized: "common_notifications_count \(count)")` |
| `XGStatusBadge` | No explicit `contentDescription` (text node is inherently accessible) | `.accessibilityLabel(label)` |

`XGCountBadge` provides a localized notification count description via `common_notifications_count`. This string key must be localized in all supported languages (EN, MT, TR).

---

## Previews

### Android

| Preview function | Content |
|-----------------|---------|
| `XGBadgePrimaryPreview` | Single "SALE" badge (primary) |
| `XGBadgeSecondaryPreview` | "NEW SEASON" + "DAILY DEAL" badges (secondary), stacked |
| `XGCountBadgePreview` | count = 5 |
| `XGCountBadgeOverflowPreview` | count = 150 (displays "99+") |
| `XGStatusBadgeSuccessPreview` | "In Stock" (success) |
| `XGStatusBadgeErrorPreview` | "Out of Stock" (error) |
| `XGStatusBadgeWarningPreview` | "Low Stock" (warning) |

All Android previews use `@Preview(showBackground = true)` wrapped in `XGTheme { }`.

### iOS

| Preview name | Content |
|-------------|---------|
| `XGBadge` | "NEW SEASON" (secondary) + "DAILY DEAL" (secondary) + "SALE" (primary) |
| `XGCountBadge` | count = 3, 99, 150, 0 in a row |
| `XGStatusBadge` | All 5 statuses stacked (In Stock, Low Stock, Out of Stock, Processing, Draft) |

All iOS previews use the `#Preview` macro with `.xgTheme()`.

---

## Tests

### Android

**Total: 56 tests across 2 files**

#### XGBadgeTokenTest.kt — JVM unit tests (37 tests)

Runs without an Android device or emulator.

| Region | Tests | What is verified |
|--------|-------|-----------------|
| `XGBadgeStatus` enum | 7 | All 5 values present, exact count is 5, `valueOf` resolves each name |
| `XGColors` badge tokens | 6 | `BadgeBackground` (#6000FE), `BadgeText` (#FFFFFF), `BadgeSecondaryBackground` (#94D63A), `BadgeSecondaryText` (#6000FE), primary/secondary distinctness |
| `XGColors` status semantic colors | 9 | Success (#22C55E), OnSuccess, Warning (#FACC15), OnWarning (#1D1D1B), Error (#EF4444), Info (#3B82F6), OnInfo, SurfaceVariant (#F9FAFB), OnSurfaceVariant (#8E8E93) |
| `XGColors` status distinctness | 1 | All 5 status background colors are distinct |
| `XGCornerRadius` | 2 | `Full` = 999dp, `Full` >= 100f for pill shape |
| `XGSpacing` | 5 | `XXS` = 2dp, `XS` = 4dp, `SM` = 8dp, padding hierarchy assertions |
| `XGTypography` labelSmall | 4 | `fontSize` = 10sp, `fontWeight` = Normal, `lineHeight` = 14sp, smaller than `labelMedium` |

#### XGBadgeTest.kt — Compose UI tests (19 tests)

Requires an Android device or emulator.

| Area | Tests |
|------|-------|
| `XGCountBadge` zero/negative → not rendered | 2 |
| `XGCountBadge` count 1, 5, 99 → displays correctly | 3 |
| `XGCountBadge` count 100, 150, 999 → displays "99+" | 3 |
| `XGCountBadge` modifier forwarding | 1 |
| `XGCountBadge` two instances render independently | 1 |
| `XGStatusBadge` all 5 statuses display label | 5 |
| `XGStatusBadge` modifier forwarding | 1 |
| `XGStatusBadge` two instances render independently | 1 |
| `XGStatusBadge` all 5 statuses render without crash | 1 |
| `XGStatusBadge` empty label renders without crash | 1 |

**Run unit tests**:

```bash
./gradlew :app:test --tests "*.XGBadgeTokenTest"
```

**Run UI tests**:

```bash
./gradlew :app:connectedAndroidTest --tests "*.XGBadgeTest"
```

### iOS

**Total: 89 tests across 11 suites (88 passing, 1 skipped)**

File: `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGBadgeTests.swift`
Framework: Swift Testing (`@Test`, `@Suite`, `#expect`)

| Suite | Tests | What is verified |
|-------|-------|-----------------|
| `XGBadgeVariantTests` | 6 | backgroundColor + textColor for primary/secondary; cross-variant distinctness |
| `XGBadgeInitTests` | 7 | Label storage, default variant = primary, explicit variants, body (skipped) |
| `XGBadgeTokenContractTests` | 8 | horizontalPadding=10, verticalPadding=4, cornerRadius=10, font=captionSemiBold |
| `XGBadgeColorTokenContractTests` | 9 | Hex values: badgeBackground=#6000FE, badgeText=white, badgeSecondaryBackground=#94D63A, badgeSecondaryText=#6000FE |
| `XGBadgeStatusTextColorTests` | 7 | textColor for all 5 statuses |
| `XGBadgeStatusColorContractTests` | 10 | Hex values for all status colors cross-referenced against colors.json |
| `XGCountBadgeTests` | 16 | Count values 0/1/50/99/100/150/999, displayText logic, hasItems boundary, body (skipped) |
| `XGCountBadgeTokenContractTests` | 6 | xs=4, xxs=2, labelSmall=11pt Poppins-Medium, badgeBackground color |
| `XGBadgeStatusTests` | 7 | Background colors for all 5 statuses |
| `XGStatusBadgeTests` | 7 | Init for all 5 statuses + empty label + body (skipped) |
| `XGStatusBadgeTokenContractTests` | 4 | sm=8 horizontal, xs=4 vertical, labelSmall font |

The 1 skipped test requires the SwiftUI runtime — it is covered at the UI test layer per project standards.

**Run tests**:

```bash
xcodebuild test \
  -project ios/XiriGoEcommerce.xcodeproj \
  -scheme XiriGoEcommerce \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:XiriGoEcommerceTests/XGBadgeVariantTests \
  -only-testing:XiriGoEcommerceTests/XGBadgeInitTests \
  -only-testing:XiriGoEcommerceTests/XGBadgeTokenContractTests \
  -only-testing:XiriGoEcommerceTests/XGBadgeColorTokenContractTests \
  -only-testing:XiriGoEcommerceTests/XGBadgeStatusTextColorTests \
  -only-testing:XiriGoEcommerceTests/XGBadgeStatusColorContractTests \
  -only-testing:XiriGoEcommerceTests/XGCountBadgeTests \
  -only-testing:XiriGoEcommerceTests/XGCountBadgeTokenContractTests \
  -only-testing:XiriGoEcommerceTests/XGBadgeStatusTests \
  -only-testing:XiriGoEcommerceTests/XGStatusBadgeTests \
  -only-testing:XiriGoEcommerceTests/XGStatusBadgeTokenContractTests
```

---

## Cross-Platform Parity

| Aspect | Android | iOS |
|--------|---------|-----|
| `XGBadge` type | `@Composable` function | `struct` conforming to `View` |
| `XGBadgeVariant` cases | `Primary`, `Secondary` | `.primary`, `.secondary` |
| `XGBadge` corner shape | `RoundedCornerShape(XGCornerRadius.Medium)` | `RoundedRectangle(cornerRadius: XGCornerRadius.medium)` |
| `XGBadge` padding | `BadgeConstants` (10h / 4v) | `Constants` (10h / 4v) |
| `XGBadge` font | `XGCustomTextStyles.CaptionSemiBold` (12sp SemiBold) | `XGTypography.captionSemiBold` (12pt SemiBold) |
| `XGCountBadge` shape | `RoundedCornerShape(XGCornerRadius.Full)` | `Capsule()` |
| `XGCountBadge` padding | `XGSpacing.XS` / `XGSpacing.XXS` | `XGSpacing.xs` / `XGSpacing.xxs` |
| `XGCountBadge` font | `MaterialTheme.typography.labelSmall` (10sp Normal) | `XGTypography.labelSmall` (11pt Medium) |
| `XGCountBadge` max display | "99+" at count >= 100 | "99+" at count >= 100 |
| `XGCountBadge` zero | Returns early (not rendered) | `if hasItems` guard (not rendered) |
| `XGStatusBadge` shape | `RoundedCornerShape(XGCornerRadius.Full)` | `Capsule()` |
| `XGStatusBadge` padding | `XGSpacing.SM` / `XGSpacing.XS` | `XGSpacing.sm` / `XGSpacing.xs` |
| `XGStatusBadge` font | `MaterialTheme.typography.labelSmall` | `XGTypography.labelSmall` |
| `XGBadgeStatus` cases | `Success`, `Warning`, `Error`, `Info`, `Neutral` | `.success`, `.warning`, `.error`, `.info`, `.neutral` |
| Color tokens | All via `XGColors.*` | All via `XGColors.*` |
| Preview macro | `@Preview` | `#Preview` |

### Known Divergence

`XGCountBadge` and `XGStatusBadge` font: Android `MaterialTheme.typography.labelSmall` maps to the micro scale (10sp, Normal weight). iOS `XGTypography.labelSmall` is 11pt, Medium weight. The token spec declares "labelSmall (11pt Medium)". This is a documented deviation; the Android value follows the existing `XGTypography` mapping. A design review may align the two platforms in a future DQ pass.

---

## DQ-08 Audit Summary

Changes made during the DQ-08 token audit:

### Android (XGBadge.kt + XGTypography.kt)

- Added `XGBadgeVariant` enum with `Primary` and `Secondary` entries
- Added `XGBadge` composable (label, variant) — new component matching iOS
- Fixed `XGStatusBadge`: replaced `MaterialTheme.colorScheme.surfaceVariant`, `MaterialTheme.colorScheme.onError`, `MaterialTheme.colorScheme.onSurfaceVariant` with `XGColors.SurfaceVariant`, `XGColors.OnError`, `XGColors.OnSurfaceVariant`
- Fixed `XGCountBadge` shape: changed `CircleShape` to `RoundedCornerShape(XGCornerRadius.Full)` (capsule/pill)
- Added `XGCustomTextStyles.CaptionSemiBold` to `XGTypography.kt` (12sp, SemiBold, Poppins)
- Added 7 Android preview functions

### iOS (XGBadge.swift)

- Removed unused `Constants.fontSize` dead code (the body references `XGTypography.captionSemiBold` directly)
- All other token references were already aligned with the spec — no functional changes

---

## Related Documentation

- [Design System](./design-system.md) — Full design system component registry
- [Motion Tokens](./motion-tokens.md) — `XGMotion` token reference
- [Shimmer Modifier](./shimmer-modifier.md) — `shimmerEffect()` modifier
- [Skeleton Components](./skeleton-components.md) — Loading placeholder primitives
