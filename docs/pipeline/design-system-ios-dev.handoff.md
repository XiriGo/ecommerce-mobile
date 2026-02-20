# Design System - iOS Dev Handoff

**Feature**: Design System (M0-02)
**Agent**: ios-dev
**Platform**: iOS
**Branch**: feature/m0/design-system
**Date**: 2026-02-20

## Summary

Implemented the complete Molt Design System for iOS, consisting of 6 theme files and 14 component files under `ios/MoltMarketplace/Core/DesignSystem/`.

## Files Created / Modified

### Theme (6 files)

| File | Status | Description |
|------|--------|-------------|
| `Theme/MoltColors.swift` | Modified | Added missing `shadow`, `onWarning`, `info`, `onInfo` semantic colors |
| `Theme/MoltTypography.swift` | Existing | No changes needed |
| `Theme/MoltSpacing.swift` | Modified | Added `IconSize` and `AvatarSize` nested enums |
| `Theme/MoltCornerRadius.swift` | Modified | Moved from MoltTheme.swift to dedicated file, removed duplicate |
| `Theme/MoltElevation.swift` | Created | Elevation levels with `ShadowStyle` struct, `moltElevation()` modifier |
| `Theme/MoltTheme.swift` | Modified | Cleaned up, removed duplicate MoltCornerRadius, simplified |

### Components (14 files)

| File | Description |
|------|-------------|
| `Component/MoltButton.swift` | Primary/Secondary/Outlined/Text variants, loading state, leading icon |
| `Component/MoltTextField.swift` | Label, placeholder, error, helper, password toggle, max length counter |
| `Component/MoltCard.swift` | `MoltProductCard` (image, title, price, rating, wishlist) + `MoltInfoCard` (generic with trailing content) |
| `Component/MoltChip.swift` | `MoltFilterChip` (selected/unselected with checkmark) + `MoltCategoryChip` |
| `Component/MoltTopBar.swift` | Back button, title, action buttons with badge support |
| `Component/MoltTabBar.swift` | `MoltTabBar` with `MoltTabItem`, selected/unselected icons, badge count |
| `Component/MoltLoadingView.swift` | Full-screen `MoltLoadingView` + inline `MoltLoadingIndicator` |
| `Component/MoltErrorView.swift` | Error icon, message, optional retry button |
| `Component/MoltEmptyView.swift` | Custom SF Symbol, message, optional action button |
| `Component/MoltImage.swift` | AsyncImage wrapper with shimmer placeholder and error fallback |
| `Component/MoltBadge.swift` | `MoltCountBadge` (0/1-99/99+), `MoltStatusBadge` with `MoltBadgeStatus` enum |
| `Component/MoltRatingBar.swift` | 1-5 stars, half-star support, optional value text and review count |
| `Component/MoltPriceText.swift` | Currency display, sale price with strikethrough, small/medium/large sizes |
| `Component/MoltQuantityStepper.swift` | +/- buttons, min/max bounds, adjustable action for VoiceOver |

### Localization

| File | Description |
|------|-------------|
| `Resources/Localizable.xcstrings` | Added 22 design system string keys in English, Maltese, and Turkish |

## Architecture Decisions

1. **No NukeUI dependency yet**: Used SwiftUI's built-in `AsyncImage` for `MoltImage`. When NukeUI is added via SPM, this can be swapped to `LazyImage` with zero API changes.
2. **`MoltButtonVariant` naming**: Used `MoltButtonVariant` enum to avoid conflict with SwiftUI's `ButtonStyle` protocol. Custom `ButtonStyle` conformance is internal via `MoltButtonStyleModifier`.
3. **`MoltInfoCard` generic trailing content**: Uses `@ViewBuilder` generic pattern for type-safe trailing content, with `EmptyView` convenience init.
4. **Accessibility**: All interactive elements have `accessibilityLabel`. `MoltQuantityStepper` uses `accessibilityAdjustableAction` for native VoiceOver stepper behavior. Decorative icons use `accessibilityHidden(true)`.
5. **No force unwraps**: All optionals handled with `if let`, `guard let`, or nil coalescing.

## Acceptance Criteria Status

- [x] All 14 components implemented
- [x] Every component has `#Preview` blocks
- [x] No raw SwiftUI primitives in public API
- [x] All strings use `String(localized:)` keys
- [x] All interactive elements >= 44pt touch target (MoltSpacing.minTouchTarget)
- [x] All colors from MoltColors, spacing from MoltSpacing
- [x] No force unwrap (`!`)
- [x] No `Any` type usage
- [x] All types immutable (struct/enum)
- [x] Localization: English, Maltese, Turkish

## Notes for Tester

- Previews should render correctly in Xcode 16+ canvas.
- MoltImage placeholder uses shimmer color with photo icon overlay.
- MoltRatingBar uses SF Symbols `star.fill`, `star.leadinghalf.filled`, `star`.
- MoltQuantityStepper bounds check: minus disabled at min, plus disabled at max.
- MoltCountBadge: hidden at 0, shows "99+" at >= 100.
- Password toggle in MoltTextField swaps between `SecureField` and `TextField`.

## Next Steps

- iOS Tester: Verify component rendering, accessibility, and localization
- Reviewer: Check code quality and cross-platform consistency with Android implementation
