# Architect Handoff — XGFilterPill (DQ-31)

## Spec Location
`shared/feature-specs/xg-filter-pill.md`

## Summary
XGFilterPill is a molecule component wrapping XGFilterChip with:
1. Dismiss (X) trailing icon when selected and onDismiss callback provided
2. XGFilterPillRow — horizontal scrollable list variant

## Key Decisions
- Wraps XGFilterChip (not duplicates) to maintain token compliance from DQ-18
- Dismiss icon uses system close/xmark icon, sized at iconSize.small (16dp/pt)
- XGFilterPillRow uses LazyRow (Android) / ScrollView+HStack (iOS)
- Gap between pills: XGSpacing.sm (8dp/pt) from token `gap`
- Data model: XGFilterPillItem(label, isSelected)

## Token Source
`shared/design-tokens/components/molecules/xg-filter-pill.json`

## Dependencies
- XGFilterChip (DQ-18) -- DONE
- XGColors filterPill tokens -- DONE
- XGSpacing tokens -- DONE

## Next Steps
- Android Dev: Create XGFilterPill.kt
- iOS Dev: Create XGFilterPill.swift
