# Architect Handoff: DQ-25 XGFlashSaleBanner

## Spec Location
`shared/feature-specs/dq-xg-flash-sale-banner.md`

## Key Decisions
1. This is a refactor/upgrade of an existing component — no new files needed.
2. Android needs typography migration from inline font props to XGTypography tokens.
3. iOS needs XGImage integration for the imageUrl parameter to inherit shimmer.
4. Both platforms already use correct color and cornerRadius tokens.

## Files to Modify
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGFlashSaleBanner.kt`
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGFlashSaleBanner.swift`

## Token Mapping
See spec for full token table.
