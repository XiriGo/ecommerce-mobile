# DQ-12: XGSearchBar Token Audit -- Feature Specification

## 1. Overview

This specification describes the audit and upgrade of the `XGSearchBar` atom component
to align with the centralized design token specification at
`shared/design-tokens/components/atoms/xg-search-bar.json`.

### Purpose

- Replace hardcoded / incorrect token references with the correct token mappings
- Ensure cross-platform visual parity (Android and iOS)
- Validate background, border, corner radius, icon size, font, and padding tokens

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Android: Replace Card-based implementation with border-based layout | New component features |
| Android: Fix corner radius from Medium (10dp) to Pill (28dp) | Active search input state |
| Android: Fix background from SurfaceVariant to InputBackground | Search result functionality |
| Android: Add border (borderSubtle, 1dp) | Dark mode token mapping |
| Android: Fix padding to use MD (12dp) horizontal | Text input behavior |
| Android: Add explicit icon size (24dp) | |
| iOS: Fix corner radius from full (999) to pill (28) | |
| Update token JSON if needed | |

### Dependencies

None.

---

## 2. Token Specification

Source: `shared/design-tokens/components/atoms/xg-search-bar.json`

| Token | JSON Reference | Resolved Value | Android Mapping | iOS Mapping |
|-------|---------------|---------------|-----------------|-------------|
| background | `$foundations/colors.light.inputBackground` | #F9FAFB | `XGColors.InputBackground` | `XGColors.inputBackground` |
| borderColor | `$foundations/colors.light.borderSubtle` | #F0F0F0 | `XGColors.OutlineVariant` | `XGColors.outlineVariant` |
| borderWidth | 1 | 1dp/pt | `1.dp` | `1` |
| cornerRadius | `$foundations/spacing.cornerRadius.pill` | 28dp/pt | `XGCornerRadius.Pill` | `XGCornerRadius.pill` |
| iconSize | `$foundations/spacing.layout.iconSize.medium` | 24dp/pt | `24.dp` | `XGSpacing.IconSize.medium` |
| iconColor | `$foundations/colors.light.textSecondary` | #8E8E93 | `XGColors.OnSurfaceVariant` | `XGColors.onSurfaceVariant` |
| placeholderFont | `$foundations/typography.typeScale.bodyLarge` | 16sp/pt Poppins Regular | `XGTypography.bodyLarge` | `XGTypography.bodyLarge` |
| placeholderColor | `$foundations/colors.light.textSecondary` | #8E8E93 | `XGColors.OnSurfaceVariant` | `XGColors.onSurfaceVariant` |
| horizontalPadding | `$foundations/spacing.spacing.md` | 12dp/pt | `XGSpacing.MD` | `XGSpacing.md` |
| verticalPadding | `$foundations/spacing.spacing.md` | 12dp/pt | `XGSpacing.MD` | `XGSpacing.md` |
| leadingIcon | platform-specific | magnifyingglass / Icons.Outlined.Search | `Icons.Outlined.Search` | `magnifyingglass` |

---

## 3. Current State

### 3.1 Android (`XGSearchBar.kt`)

Issues found:
1. Uses `Card` with `SurfaceVariant` background -- should use `InputBackground`
2. Uses `RoundedCornerShape(XGCornerRadius.Medium)` (10dp) -- should be `Pill` (28dp)
3. Uses `CardDefaults.cardElevation(XGElevation.Level1)` -- should have no elevation
4. No border -- should have `OutlineVariant` border at 1dp
5. Uses `XGSpacing.Base` (16dp) horizontal padding -- should be `XGSpacing.MD` (12dp)
6. No explicit icon size -- should be 24dp from `layout.iconSize.medium`
7. Uses `PoppinsFontFamily` override -- unnecessary since `XGTypography.bodyLarge` already uses Poppins

### 3.2 iOS (`XGSearchBar.swift`)

Issues found:
1. Uses `XGCornerRadius.full` (999pt) -- should be `XGCornerRadius.pill` (28pt)

Already compliant:
- Background: `XGColors.inputBackground`
- Border: `XGColors.outlineVariant` with 1pt width
- Padding: `.horizontal, XGSpacing.md` and `.vertical, XGSpacing.md`
- Icon: `magnifyingglass` with `XGSpacing.IconSize.medium`
- Icon color: `XGColors.onSurfaceVariant`
- Placeholder font: `XGTypography.bodyLarge`
- Placeholder color: `XGColors.onSurfaceVariant`

---

## 4. Required Changes

### 4.1 Android (`XGSearchBar.kt`)

1. Remove `Card` wrapper, replace with `Row` + background + border + clip
2. Change background to `XGColors.InputBackground`
3. Change corner radius to `XGCornerRadius.Pill`
4. Remove elevation
5. Add border: `XGColors.OutlineVariant` at `1.dp`
6. Change horizontal padding to `XGSpacing.MD`
7. Add explicit icon size: `size = 24.dp` (from layout.iconSize.medium)
8. Remove `PoppinsFontFamily` override on Text (redundant)
9. Remove unused imports: `CardDefaults`, `Card`, `XGElevation`

### 4.2 iOS (`XGSearchBar.swift`)

1. Change `XGCornerRadius.full` to `XGCornerRadius.pill` (both in clipShape and overlay)

---

## 5. Verification Criteria

- [ ] Android `XGSearchBar` uses `XGColors.InputBackground` for background
- [ ] Android `XGSearchBar` uses `XGCornerRadius.Pill` for corner radius
- [ ] Android `XGSearchBar` has border with `XGColors.OutlineVariant` at 1dp
- [ ] Android `XGSearchBar` has no elevation
- [ ] Android `XGSearchBar` uses `XGSpacing.MD` for horizontal and vertical padding
- [ ] Android `XGSearchBar` icon has explicit 24dp size
- [ ] Android `XGSearchBar` uses `XGTypography.bodyLarge` for placeholder
- [ ] iOS `XGSearchBar` uses `XGCornerRadius.pill` (28pt) instead of `.full` (999pt)
- [ ] Both platforms produce visually identical results
- [ ] No force unwrap (`!!`/`!`) in either implementation
- [ ] Preview composables/views render without errors

---

## 6. File Manifest

| File | Change Type | Platform |
|------|------------|----------|
| `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGSearchBar.kt` | Modify | Android |
| `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGSearchBar.swift` | Modify | iOS |
| `shared/design-tokens/components/atoms/xg-search-bar.json` | No change | Shared |
