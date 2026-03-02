# XGDivider

## Overview

XGDivider is a design-system-level atom component that provides a token-driven horizontal divider for both Android and iOS. It wraps the platform-native divider component and enforces design token defaults so that feature screens never reference raw `Divider()` or `HorizontalDivider()` directly.

The component family includes two members:

- **XGDivider** -- plain horizontal line (default variant)
- **XGLabeledDivider** -- line-label-line pattern (withLabel variant, e.g. "OR CONTINUE WITH" on the Login screen)

**Status**: Complete
**Phase**: Phase 2B -- New Atom Components (DQ backfill)
**Issue**: DQ-19 (#63)
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)
**Design token source**: `shared/design-tokens/components/atoms/xg-divider.json`

---

## File Locations

| Platform | File | Layer |
|----------|------|-------|
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGDivider.kt` | Design System / Component |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGDivider.swift` | Design System / Component |
| Token file | `shared/design-tokens/components/atoms/xg-divider.json` | Shared |

### Test Files

| Platform | File | Type | Count |
|----------|------|------|-------|
| Android | `android/app/src/test/.../component/XGDividerTokenTest.kt` | JVM unit | 8 |
| Android | `android/app/src/androidTest/.../component/XGDividerTest.kt` | Compose UI | 12 |
| iOS | `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGDividerTests.swift` | Swift Testing | 19 |

---

## Architecture

XGDivider components live exclusively in the design system layer. They have no domain or data layer dependencies.

```
XGDivider / XGLabeledDivider
    |
    +-- XGColors.Divider / XGColors.divider          (line color: #E5E7EB)
    +-- XGColors.TextTertiary / XGColors.textTertiary (label color: #9CA3AF)
    +-- MaterialTheme.typography.labelMedium          (Android label text)
    +-- XGTypography.captionMedium                    (iOS label text)
```

---

## Token Mapping

### Default Variant

| Token | JSON Source | Android | iOS |
|-------|-----------|---------|-----|
| `color` | `$foundations/colors.light.divider` | `XGColors.Divider` | `XGColors.divider` |
| `thickness` | `1` | `1.dp` | `1` (CGFloat) |

### WithLabel Variant

| Token | JSON Source | Android | iOS |
|-------|-----------|---------|-----|
| `color` | `$foundations/colors.light.divider` | `XGColors.Divider` | `XGColors.divider` |
| `thickness` | `1` | `1.dp` | `1` (CGFloat) |
| `labelFont` | `$foundations/typography.typeScale.captionMedium` | `labelMedium` (12sp Medium) | `XGTypography.captionMedium` (12pt) |
| `labelColor` | `$foundations/colors.light.textTertiary` | `XGColors.TextTertiary` | `XGColors.textTertiary` |
| `labelHorizontalPadding` | `16` | `16.dp` | `16` (CGFloat) |

---

## API

### Android

```kotlin
@Composable
fun XGDivider(
    modifier: Modifier = Modifier,
    color: Color = XGColors.Divider,
    thickness: Dp = 1.dp,
)

@Composable
fun XGLabeledDivider(
    label: String,
    modifier: Modifier = Modifier,
    color: Color = XGColors.Divider,
    thickness: Dp = 1.dp,
)
```

### iOS

```swift
struct XGDivider: View {
    var color: Color = XGColors.divider
    var thickness: CGFloat = 1
}

struct XGLabeledDivider: View {
    let label: String
    var color: Color = XGColors.divider
    var thickness: CGFloat = 1
}
```

---

## Migration Notes

The following raw divider usages were replaced as part of this work:

| File | Before | After |
|------|--------|-------|
| `ProfileScreen.kt` | `HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)` | `XGDivider()` |

No raw `Divider()` usage was found on iOS.

---

## Previews

Both platforms include preview annotations:

- **Android**: `@Preview XGDividerPreview`, `@Preview XGLabeledDividerPreview`
- **iOS**: `#Preview("XGDivider")`, `#Preview("XGLabeledDivider")`
