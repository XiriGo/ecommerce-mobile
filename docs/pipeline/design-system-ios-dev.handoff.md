# Design System - iOS Dev Handoff

**Feature**: Design System (M0-02)
**Agent**: ios-dev
**Platform**: iOS
**Branch**: feature/m0/design-system
**Date**: 2026-02-20

## Summary

Implemented the complete XiriGo Design System for iOS, consisting of 6 theme files and 14 component files under `ios/XiriGoEcommerce/Core/DesignSystem/`.

## Files Created / Modified

### Theme (6 files)

| File | Status | Description |
|------|--------|-------------|
| `Theme/XGColors.swift` | Modified | Added missing `shadow`, `onWarning`, `info`, `onInfo` semantic colors |
| `Theme/XGTypography.swift` | Existing | No changes needed |
| `Theme/XGSpacing.swift` | Modified | Added `IconSize` and `AvatarSize` nested enums |
| `Theme/XGCornerRadius.swift` | Modified | Moved from XGTheme.swift to dedicated file, removed duplicate |
| `Theme/XGElevation.swift` | Created | Elevation levels with `ShadowStyle` struct, `moltElevation()` modifier |
| `Theme/XGTheme.swift` | Modified | Cleaned up, removed duplicate XGCornerRadius, simplified |

### Components (14 files)

| File | Description |
|------|-------------|
| `Component/XGButton.swift` | Primary/Secondary/Outlined/Text variants, loading state, leading icon |
| `Component/XGTextField.swift` | Label, placeholder, error, helper, password toggle, max length counter |
| `Component/XGCard.swift` | `MoltProductCard` (image, title, price, rating, wishlist) + `MoltInfoCard` (generic with trailing content) |
| `Component/XGChip.swift` | `MoltFilterChip` (selected/unselected with checkmark) + `MoltCategoryChip` |
| `Component/XGTopBar.swift` | Back button, title, action buttons with badge support |
| `Component/XGTabBar.swift` | `XGTabBar` with `XGTabItem`, selected/unselected icons, badge count |
| `Component/XGLoadingView.swift` | Full-screen `XGLoadingView` + inline `MoltLoadingIndicator` |
| `Component/XGErrorView.swift` | Error icon, message, optional retry button |
| `Component/XGEmptyView.swift` | Custom SF Symbol, message, optional action button |
| `Component/XGImage.swift` | AsyncImage wrapper with shimmer placeholder and error fallback |
| `Component/XGBadge.swift` | `MoltCountBadge` (0/1-99/99+), `MoltStatusBadge` with `XGBadgeStatus` enum |
| `Component/XGRatingBar.swift` | 1-5 stars, half-star support, optional value text and review count |
| `Component/XGPriceText.swift` | Currency display, sale price with strikethrough, small/medium/large sizes |
| `Component/XGQuantityStepper.swift` | +/- buttons, min/max bounds, adjustable action for VoiceOver |

### Localization

| File | Description |
|------|-------------|
| `Resources/Localizable.xcstrings` | Added 22 design system string keys in English, Maltese, and Turkish |

## Architecture Decisions

1. **No NukeUI dependency yet**: Used SwiftUI's built-in `AsyncImage` for `XGImage`. When NukeUI is added via SPM, this can be swapped to `LazyImage` with zero API changes.
2. **`XGButtonVariant` naming**: Used `XGButtonVariant` enum to avoid conflict with SwiftUI's `ButtonStyle` protocol. Custom `ButtonStyle` conformance is internal via `XGButtonStyleModifier`.
3. **`MoltInfoCard` generic trailing content**: Uses `@ViewBuilder` generic pattern for type-safe trailing content, with `EmptyView` convenience init.
4. **Accessibility**: All interactive elements have `accessibilityLabel`. `XGQuantityStepper` uses `accessibilityAdjustableAction` for native VoiceOver stepper behavior. Decorative icons use `accessibilityHidden(true)`.
5. **No force unwraps**: All optionals handled with `if let`, `guard let`, or nil coalescing.

## Acceptance Criteria Status

- [x] All 14 components implemented
- [x] Every component has `#Preview` blocks
- [x] No raw SwiftUI primitives in public API
- [x] All strings use `String(localized:)` keys
- [x] All interactive elements >= 44pt touch target (XGSpacing.minTouchTarget)
- [x] All colors from XGColors, spacing from XGSpacing
- [x] No force unwrap (`!`)
- [x] No `Any` type usage
- [x] All types immutable (struct/enum)
- [x] Localization: English, Maltese, Turkish

## Notes for Tester

- Previews should render correctly in Xcode 16+ canvas.
- XGImage placeholder uses shimmer color with photo icon overlay.
- XGRatingBar uses SF Symbols `star.fill`, `star.leadinghalf.filled`, `star`.
- XGQuantityStepper bounds check: minus disabled at min, plus disabled at max.
- MoltCountBadge: hidden at 0, shows "99+" at >= 100.
- Password toggle in XGTextField swaps between `SecureField` and `TextField`.

## Next Steps

- iOS Tester: Verify component rendering, accessibility, and localization
- Reviewer: Check code quality and cross-platform consistency with Android implementation
