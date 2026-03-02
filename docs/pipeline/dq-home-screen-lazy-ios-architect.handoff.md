# Architect Handoff — DQ-35: Refactor iOS HomeScreen to LazyVStack/LazyHStack

## Scope

iOS-only. Presentation layer only. Two files change.

## Changes Required

1. **HomeScreen.swift**: Replace `VStack` with `LazyVStack` inside `ScrollView` in `successContent`
2. **HomeScreenSections.swift**: Replace `HStack` with `LazyHStack` in `categoriesSection` and `popularProductsSection`

## What NOT to Change

- Domain models, use cases, repository
- ViewModel, state, events
- New arrivals grid (already uses `LazyVGrid`)
- Daily deal section (single item, no list)
- Flash sale section (single item, no list)
- Hero banner carousel (`TabView` -- not a list)

## Spec

See `shared/feature-specs/dq-home-screen-lazy-ios.md`
