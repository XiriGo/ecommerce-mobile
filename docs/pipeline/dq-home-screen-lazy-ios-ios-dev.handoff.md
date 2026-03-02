# iOS Dev Handoff — DQ-35: Refactor iOS HomeScreen to LazyVStack/LazyHStack

## Changes Made

### HomeScreen.swift
- Replaced `VStack(spacing: XGSpacing.sectionSpacing)` with `LazyVStack(spacing: XGSpacing.sectionSpacing)` inside `ScrollView` in `successContent`
- Only visible sections are now composed by SwiftUI

### HomeScreenSections.swift
- Replaced `HStack(spacing: XGSpacing.base)` with `LazyHStack(spacing: XGSpacing.base)` in `categoriesSection`
- Replaced `HStack(spacing: XGSpacing.productGridSpacing)` with `LazyHStack(spacing: XGSpacing.productGridSpacing)` in `popularProductsSection`
- Only visible category/product items are now rendered in horizontal lists

## What Was NOT Changed

- `heroBannerCarousel`: Uses `TabView`, not a list — no lazy equivalent needed
- `dailyDealSection`: Single item, not a list
- `newArrivalsSection`: Already uses `LazyVGrid` — already lazy
- `flashSaleSection`: Single item, not a list
- ViewModel, state, events, domain layer: Zero changes
- Pull-to-refresh: `.refreshable {}` works identically with `LazyVStack`

## Files Modified

1. `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreen.swift`
2. `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreenSections.swift`
