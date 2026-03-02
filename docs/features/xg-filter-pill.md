# XGFilterPill

**Issue**: [DQ-31] Implement XGFilterPill
**Platforms**: Android + iOS
**Category**: Molecule (Design System)
**Depends on**: XGChip (DQ-18)

## Overview

`XGFilterPill` is a molecule component that extends `XGFilterChip` with filter-specific behavior: a dismiss (X) button when selected, and a horizontally scrollable list variant (`XGFilterPillRow`). Used by Product List and Filter screens.

## Components

### XGFilterPill

A single filter pill with three visual states:

| State | Background | Text | Leading Icon | Trailing Icon |
|-------|-----------|------|-------------|---------------|
| Unselected | `filterPillBackground` | `filterPillText` | none | none |
| Selected | `filterPillBackgroundActive` | `filterPillTextActive` | checkmark | none |
| Selected + Dismiss | `filterPillBackgroundActive` | `filterPillTextActive` | checkmark | X (close) |

The dismiss (X) icon appears only when `isSelected == true` AND the `onDismiss` callback is provided.

### XGFilterPillRow

Horizontally scrollable row of `XGFilterPill` items using `LazyRow` (Android) / `ScrollView` + `HStack` (iOS).

## Token Reference

Source: `shared/design-tokens/components/molecules/xg-filter-pill.json`

| Property | Value | Token |
|----------|-------|-------|
| Height | 36 dp/pt | `tokens.height` |
| Corner Radius | 18 dp/pt | `tokens.cornerRadius` |
| Horizontal Padding | 16 dp/pt | `tokens.horizontalPadding` |
| Gap | 8 dp/pt | `tokens.gap` |
| Font | bodyMedium | `$foundations/typography` |

## File Locations

| Platform | Component | Tests |
|----------|-----------|-------|
| Android | `android/.../component/XGFilterPill.kt` | `android/.../component/XGFilterPillTest.kt` |
| iOS | `ios/.../Component/XGFilterPill.swift` | `ios/.../Component/XGFilterPillTests.swift` |

## Test Coverage

- **Android**: 18 tests (10 behavior + 8 token compliance)
- **iOS**: 24 tests (8 behavior + 11 token + 4 data model + 4 row)
