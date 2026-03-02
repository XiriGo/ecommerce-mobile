# Architect Handoff: XGPriceLayout (DQ-38)

## Summary

Platform-agnostic spec for extracting `XGPriceLayout` enum to its own iOS file.
This is an iOS-only change for platform parity with Android.

## Spec Location

`shared/feature-specs/xg-price-layout.md`

## Key Decisions

1. Extract enum to `XGPriceLayout.swift` (matches Android `XGPriceLayout.kt`)
2. No API changes -- enum already exists inline in `XGPriceText.swift`
3. No new design tokens needed -- uses existing `xg-price-text.json`

## Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGPriceLayout.swift` |
| MODIFY | `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGPriceText.swift` |
| MODIFY | `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGPriceTextTests.swift` |
| MODIFY | `ios/XiriGoEcommerce.xcodeproj/project.pbxproj` |

## Next Agent

iOS Dev -> implement the extraction
