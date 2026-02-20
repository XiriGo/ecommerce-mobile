# Handoff: design-system -- Architect

## Feature
**M0-02: Design System Components** -- 14 reusable `Molt*` wrapper components for the buyer app.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/design-system.md` |
| This Handoff | `docs/pipeline/design-system-architect.handoff.md` |

## Summary of Spec

The design-system spec defines 14 reusable UI components that wrap platform-native controls
(Material 3 on Android, SwiftUI on iOS) behind a stable `Molt*` interface. Feature screens
import these components exclusively -- never raw platform components.

### Components (14 total)

| # | Component | Android File | iOS File | Key Features |
|---|-----------|-------------|----------|-------------|
| 1 | MoltButton | MoltButton.kt | MoltButton.swift | Primary/Secondary/Text variants, loading spinner |
| 2 | MoltCard | MoltCard.kt | MoltCard.swift | ProductCard + InfoCard variants |
| 3 | MoltTextField | MoltTextField.kt | MoltTextField.swift | Label, error, icons, secure mode |
| 4 | MoltTopBar | MoltTopBar.kt | MoltTopBar.swift | Back button, title, action icons |
| 5 | MoltBottomBar/TabBar | MoltBottomBar.kt | MoltTabBar.swift | 4 tabs with badge support |
| 6 | MoltLoadingView | MoltLoadingView.kt | MoltLoadingView.swift | Full-screen + inline variants |
| 7 | MoltErrorView | MoltErrorView.kt | MoltErrorView.swift | Icon, message, optional retry |
| 8 | MoltEmptyView | MoltEmptyView.kt | MoltEmptyView.swift | Icon, message |
| 9 | MoltImage | MoltImage.kt | MoltImage.swift | Coil/Nuke wrapper, placeholder, crossfade |
| 10 | MoltBadge | MoltBadge.kt | MoltBadge.swift | CountBadge + StatusBadge |
| 11 | MoltSearchBar | MoltSearchBar.kt | MoltSearchBar.swift | Pill-shaped, search/clear icons |
| 12 | MoltDivider | MoltDivider.kt | MoltDivider.swift | Thin separator line |
| 13 | MoltPriceText | MoltPriceText.kt | MoltPriceText.swift | Locale-aware EUR format, sale strikethrough |
| 14 | MoltRatingBar | MoltRatingBar.kt | MoltRatingBar.swift | Star display with half-star support |

### New String Keys (6)

| Key | English |
|-----|---------|
| `nav_tab_home` | Home |
| `nav_tab_categories` | Categories |
| `nav_tab_cart` | Cart |
| `nav_tab_profile` | Profile |
| `common_back_button` | Back |
| `common_empty_message` | Nothing here yet |

All keys include Maltese (mt) and Turkish (tr) translations.

### File Counts

| Category | Android | iOS |
|----------|---------|-----|
| Component files | 14 | 14 |
| Test files | 14 | 14 |
| String files modified | 3 | 1 |
| **Total new files** | **28** | **28** |

## Key Decisions

1. **No API calls**: Components are pure UI. No data/domain layer involvement.
2. **Price in cents (Long/Int)**: All price props accept amounts in cents to avoid floating-point issues. Formatting is internal to `MoltPriceText`.
3. **EUR single currency**: Default currency code is `"EUR"` throughout.
4. **Half-star support**: `MoltRatingBar` rounds 0.25-0.74 fractional to half star.
5. **Badge overflow at 99+**: `MoltCountBadge` caps display at "99+" for counts > 99.
6. **Pill-shaped search bar**: `MoltSearchBar` uses `MoltCornerRadius.full` (999).
7. **No interactive rating**: `MoltRatingBar` is display-only (read-only). Interactive rating pickers are feature-specific (M3-07).
8. **Platform-specific naming**: Android `MoltBottomBar` vs iOS `MoltTabBar` to align with platform conventions.
9. **Component dependency order**: `MoltCard` depends on `MoltImage`, `MoltPriceText`, `MoltRatingBar`. Devs should build leaf components first.

## Downstream Dependencies

| Downstream Agent | What They Need From This Spec |
|-----------------|-------------------------------|
| Android Dev | Section 3 (all component specs with Android types), Section 10.1 (file manifest), Section 12 (impl notes) |
| iOS Dev | Section 3 (all component specs with iOS types), Section 10.2 (file manifest), Section 12 (impl notes) |
| Android Tester | Section 10.4 (test file manifest), Section 6 (component states), Section 7 (error scenarios) |
| iOS Tester | Section 10.5 (test file manifest), Section 6 (component states), Section 7 (error scenarios) |

## Verification

Downstream developers should verify their implementation against the build verification criteria in spec section 11.

## Notes for Next Features

- **M0-03 (Network Layer)**: Does not depend on design system components.
- **M0-04 (Navigation)**: Uses `MoltBottomBar`/`MoltTabBar` for tab bar, `MoltTopBar` for screen headers.
- **M1-01 (Login)**: Uses `MoltTextField`, `MoltButton`, `MoltLoadingView`, `MoltErrorView`, `MoltTopBar`.
- **M1-04 (Home)**: Uses `MoltSearchBar`, `MoltCard` (ProductCard), `MoltLoadingView`, `MoltErrorView`.
- **M1-06 (Product List)**: Uses `MoltCard` (ProductCard), `MoltLoadingView`, `MoltErrorView`, `MoltEmptyView`, `MoltSearchBar`.
- **M1-07 (Product Detail)**: Uses `MoltImage`, `MoltPriceText`, `MoltRatingBar`, `MoltButton`, `MoltTopBar`, `MoltDivider`.
