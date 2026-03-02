# Architect Handoff — DQ-24 XGDailyDealCard Upgrade

## Status: COMPLETE

## Spec Location
`shared/feature-specs/xg-daily-deal-card.md`

## Key Decisions
1. This is a REFACTOR/UPGRADE of an existing component, not a new component
2. Both countdown timer patterns (LaunchedEffect on Android, TimelineView on iOS) are already correct
3. XGImage shimmer is inherited automatically from DQ-07 — no card-level shimmer work needed
4. Main changes: audit token compliance, fix product image sizing to use fixed 100dp/100pt instead of weight
5. Ensure all constants map to design token JSON values

## Files to Modify
- Android: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGDailyDealCard.kt`
- iOS: `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGDailyDealCard.swift`

## Token Source
`shared/design-tokens/components/molecules/xg-daily-deal-card.json`
