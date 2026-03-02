# DQ-19: XGDivider -- Feature Specification

## 1. Overview

This specification defines the `XGDivider` atom component for both Android and iOS platforms.
XGDivider wraps the platform-native divider to enforce design-system tokens and provides an
optional "with label" variant used on the Login screen ("OR CONTINUE WITH" pattern).

### Purpose

- Provide a token-driven divider component so feature screens never use raw `Divider()` /
  `HorizontalDivider()` directly
- Support two variants: **default** (plain horizontal line) and **withLabel** (line-label-line)
- Replace any existing raw divider usage in the codebase

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| `XGDivider` component on Android | Vertical divider variant |
| `XGDivider` component on iOS | Dark mode token updates (already mapped) |
| Default variant (plain hairline) | Feature screen redesigns |
| WithLabel variant ("OR CONTINUE WITH") | |
| Replace raw `HorizontalDivider` in `ProfileScreen.kt` | |
| Preview composables / SwiftUI previews | |

### Dependencies

- None (standalone atom component)

---

## 2. Token Reference

Source: `shared/design-tokens/components/atoms/xg-divider.json`

### 2.1 Default Variant

| Token | Value | Resolved |
|-------|-------|----------|
| `color` | `$foundations/colors.light.divider` | `#E5E7EB` |
| `thickness` | `1` | 1 dp / 1 pt |

### 2.2 WithLabel Variant

| Token | Value | Resolved |
|-------|-------|----------|
| `color` | `$foundations/colors.light.divider` | `#E5E7EB` |
| `thickness` | `1` | 1 dp / 1 pt |
| `labelFontSize` | `12` | 12 sp / 12 pt |
| `labelFont` | `$foundations/typography.typeScale.captionMedium` | Poppins Medium 12 |
| `labelColor` | `$foundations/colors.light.textTertiary` | `#9CA3AF` |
| `labelHorizontalPadding` | `16` | 16 dp / 16 pt |

---

## 3. API Design

### 3.1 Android

```kotlin
// Default divider
@Composable
fun XGDivider(
    modifier: Modifier = Modifier,
    color: Color = XGColors.Divider,
    thickness: Dp = DividerConstants.DefaultThickness,
)

// Divider with centered label
@Composable
fun XGLabeledDivider(
    label: String,
    modifier: Modifier = Modifier,
    color: Color = XGColors.Divider,
    thickness: Dp = DividerConstants.DefaultThickness,
)
```

- `XGDivider`: Wraps `HorizontalDivider` from Material 3 with token defaults.
- `XGLabeledDivider`: Row of [line - label - line] pattern.
  Label uses `MaterialTheme.typography.labelMedium` (maps to captionMedium 12sp Medium).
  Label color: `XGColors.TextTertiary`.
  Label horizontal padding: 16.dp.

### 3.2 iOS

```swift
struct XGDivider: View {
    var color: Color = XGColors.divider
    var thickness: CGFloat = Constants.defaultThickness
}

struct XGLabeledDivider: View {
    let label: String
    var color: Color = XGColors.divider
    var thickness: CGFloat = Constants.defaultThickness
}
```

- `XGDivider`: A `Rectangle` with height = thickness and foreground color = divider token.
- `XGLabeledDivider`: HStack of [line - label - line] pattern.
  Label uses `XGTypography.captionMedium` (Poppins Medium 12pt).
  Label color: `XGColors.textTertiary`.
  Label horizontal padding: 16pt.

---

## 4. Implementation Details

### 4.1 Android (`XGDivider.kt`)

File: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGDivider.kt`

1. Create `XGDivider` composable wrapping `HorizontalDivider`.
2. Create `XGLabeledDivider` composable using `Row` + two `HorizontalDivider`s + `Text`.
3. Use `DividerConstants` private object for token values.
4. Add `@Preview` for both variants.
5. No `@file:Suppress` needed (two public composables share a file, names are distinct).

### 4.2 iOS (`XGDivider.swift`)

File: `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGDivider.swift`

1. Create `XGDivider` View using `Rectangle()` with frame height and foreground color.
2. Create `XGLabeledDivider` View using HStack with two `XGDivider`s and `Text`.
3. Use `Constants` private enum for token values.
4. Add `#Preview` for both variants.

### 4.3 Replace Raw Divider Usage

In `ProfileScreen.kt`, replace:
```kotlin
HorizontalDivider(
    modifier = Modifier.padding(horizontal = XGSpacing.Base),
    color = MaterialTheme.colorScheme.outlineVariant,
)
```
With:
```kotlin
XGDivider(
    modifier = Modifier.padding(horizontal = XGSpacing.Base),
)
```

Remove the `import androidx.compose.material3.HorizontalDivider` import.

---

## 5. Verification Criteria

- [ ] `XGDivider` exists on Android at `core/designsystem/component/XGDivider.kt`
- [ ] `XGDivider` exists on iOS at `Core/DesignSystem/Component/XGDivider.swift`
- [ ] Default variant uses `XGColors.Divider` / `XGColors.divider` (`#E5E7EB`)
- [ ] Default thickness is 1 dp / 1 pt
- [ ] `XGLabeledDivider` renders line-label-line pattern
- [ ] Label uses captionMedium typography (12sp/pt Medium)
- [ ] Label color is `XGColors.TextTertiary` / `XGColors.textTertiary` (`#9CA3AF`)
- [ ] Label horizontal padding is 16 dp / 16 pt
- [ ] `@Preview` / `#Preview` exists for both variants on both platforms
- [ ] Raw `HorizontalDivider` in `ProfileScreen.kt` replaced with `XGDivider`
- [ ] No raw `Divider()` / `HorizontalDivider()` usage anywhere else in the codebase
- [ ] No force unwrap (`!!` / `!`) in either implementation
- [ ] No hardcoded colors or dimensions -- all from tokens

---

## 6. File Manifest

| File | Change Type | Platform |
|------|------------|----------|
| `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGDivider.kt` | Create | Android |
| `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGDivider.swift` | Create | iOS |
| `android/app/src/main/java/com/xirigo/ecommerce/feature/profile/presentation/screen/ProfileScreen.kt` | Modify | Android |
