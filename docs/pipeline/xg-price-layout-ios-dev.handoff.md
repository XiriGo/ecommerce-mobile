# iOS Dev Handoff: XGPriceLayout (DQ-38)

## Summary

Extracted `XGPriceLayout` enum from `XGPriceText.swift` into its own file
`XGPriceLayout.swift` for platform parity with Android.

## Changes Made

### New File
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGPriceLayout.swift`
  - Contains `XGPriceLayout` enum with `.inline` and `.stacked` cases
  - Doc comments match Android implementation

### Modified Files
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGPriceText.swift`
  - Removed inline `XGPriceLayout` enum definition (was lines 83-91)
  - No other changes; enum is resolved from same module
- `ios/XiriGoEcommerce.xcodeproj/project.pbxproj`
  - Added 4 entries for `XGPriceLayout.swift` (PBXBuildFile, PBXFileReference, PBXGroup, Sources build phase)

## Verification

- `XGPriceText` still compiles and works with the extracted enum
- All existing previews remain functional
- No breaking changes to public API

## Next Agent

iOS Tester -> add XGPriceLayout-specific tests
