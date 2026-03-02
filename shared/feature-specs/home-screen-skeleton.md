# DQ-36: HomeScreen Skeleton — Feature Specification

## Overview

Create a full-screen skeleton layout for HomeScreen loading state using existing skeleton
primitives (`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`) and `ProductCardSkeleton`.
This replaces the generic `XGLoadingView()` placeholder with a content-aware skeleton that
mirrors the real HomeScreen layout (search bar, hero banner, categories, products, etc.).

### User Stories

- As a **user**, I want to see a skeleton that matches the home screen layout while content loads
  so I understand what to expect and the app feels responsive.
- As a **developer**, I want a reusable `HomeScreenSkeleton` component so I can show a
  high-fidelity loading state during initial load and pull-to-refresh.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| `HomeScreenSkeleton` composable (Android) | Changes to skeleton primitives |
| `HomeScreenSkeleton` view (iOS) | Changes to `ProductCardSkeleton` |
| Integration into HomeScreen loading state | Backend API changes |
| Preview for both platforms | Dark mode skeleton colors |
| Accessibility annotations | Pull-to-refresh skeleton (uses same component) |

## 1. Architecture

`HomeScreenSkeleton` lives in the **feature home presentation layer**, not in the design system.
It composes design system atoms (`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`) and
molecules (`ProductCardSkeleton`) into a screen-specific layout.

### File Locations

| Platform | Path |
|----------|------|
| Android | `feature/home/presentation/component/HomeScreenSkeleton.kt` |
| iOS | `Feature/Home/Presentation/Component/HomeScreenSkeleton.swift` |

### Dependency Graph

```
HomeScreenSkeleton
    |
    +-- SkeletonBox (hero banner placeholder)
    +-- SkeletonLine (section header, search bar placeholders)
    +-- SkeletonCircle (category icon placeholders)
    +-- ProductCardSkeleton (product grid placeholders)
    +-- XGSpacing.* (layout spacing tokens)
    +-- XGCornerRadius.* (corner radius tokens)
```

## 2. Layout Specification

The skeleton mirrors the home screen sections defined in `home-screen.json`:

### Section 1: Search Bar Skeleton
- Full-width `SkeletonBox` with `cornerRadius: pill (28)`, height 43dp (search bar height)
- Horizontal padding: `XGSpacing.ScreenPaddingHorizontal` (20)

### Section 2: Hero Banner Skeleton
- Full-width `SkeletonBox`, height 210dp (banner carousel height)
- Corner radius: `XGCornerRadius.Medium` (10)
- Horizontal padding: `XGSpacing.ScreenPaddingHorizontal` (20)

### Section 3: Categories Skeleton
- Section header: `SkeletonLine` width ~120dp (section title width)
- Horizontal row of 4-5 category placeholders:
  - Each: `SkeletonCircle` size 56dp + `SkeletonLine` width 48dp below
  - Spacing: `XGSpacing.Base` (16)
- Horizontal padding: `XGSpacing.ScreenPaddingHorizontal` (20)

### Section 4: Popular Products Skeleton
- Section header: `SkeletonLine` width ~140dp
- Horizontal row of 3 `ProductCardSkeleton`, each width 160dp
- Spacing: `XGSpacing.ProductGridSpacing` (10)
- Horizontal padding: `XGSpacing.ScreenPaddingHorizontal` (20)

### Section 5: New Arrivals Skeleton
- Section header: `SkeletonLine` width ~120dp
- 2-column grid of 4 `ProductCardSkeleton` (2 rows x 2 columns)
- Column/row spacing: `XGSpacing.ProductGridSpacing` (10)
- Horizontal padding: `XGSpacing.ScreenPaddingHorizontal` (20)

### Section Spacing
- Between sections: `XGSpacing.SectionSpacing` (24)

## 3. Integration

Replace `XGLoadingView()` in HomeScreen loading state with `HomeScreenSkeleton()`:

### Android (HomeScreen.kt)
```kotlin
is HomeUiState.Loading -> {
    HomeScreenSkeleton(modifier = modifier)
}
```

### iOS (HomeScreen.swift)
```swift
case .loading:
    HomeScreenSkeleton()
```

## 4. Accessibility

- `HomeScreenSkeleton` is wrapped with a single accessibility label: "Loading content"
  (reuses existing `skeleton_loading_placeholder` localized string)
- Individual skeleton shapes remain decorative (hidden from accessibility tree)

## 5. Preview

Both platforms must include `@Preview` / `#Preview` for `HomeScreenSkeleton`.

## 6. Verification Criteria

| # | Criterion |
|---|-----------|
| 1 | HomeScreenSkeleton renders search bar, hero banner, categories, products skeletons |
| 2 | Layout matches real HomeScreen section order and spacing |
| 3 | Shimmer animation plays on all skeleton shapes |
| 4 | HomeScreen loading state uses HomeScreenSkeleton instead of generic XGLoadingView |
| 5 | Smooth crossfade transition from skeleton to real content |
| 6 | Preview available on both platforms |
| 7 | No hardcoded colors/dimensions — all from design tokens |
| 8 | Accessibility: single "Loading content" label on container |
