# Feature Spec: XGPriceLayout (DQ-38)

## Overview

Port the `XGPriceLayout` enum from Android to iOS design system for platform parity.
On Android, `XGPriceLayout` lives in its own file (`XGPriceLayout.kt`). On iOS, it is
currently inlined inside `XGPriceText.swift`. This task extracts it to a standalone file
to match the Android pattern and follow the "one component per file" rule.

## Scope

- **Platform**: iOS only
- **Phase**: DQ (Design Quality)
- **Issue**: #82

## Enum Definition

```
XGPriceLayout
  .inline   — Sale price + strikethrough side-by-side (HStack). Default for standard/grid cards.
  .stacked  — Strikethrough above, sale price below (VStack). Used for featured/horizontal-scroll cards.
```

## Token Source

`shared/design-tokens/components/atoms/xg-price-text.json` -> `enums.XGPriceLayout`

## Android Reference

File: `android/.../core/designsystem/component/XGPriceLayout.kt`

```kotlin
enum class XGPriceLayout {
    Inline,
    Stacked,
}
```

## iOS Changes

### 1. New File: `XGPriceLayout.swift`

- Path: `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGPriceLayout.swift`
- Extract `XGPriceLayout` enum from `XGPriceText.swift` into this file
- Keep identical doc comments and case names

### 2. Update: `XGPriceText.swift`

- Remove the `// MARK: - XGPriceLayout` section (lines 83-91)
- No other changes needed; Swift resolves the type from the same module

### 3. Update: `project.pbxproj`

- Add `XGPriceLayout.swift` to the Xcode project (4 entries per file)

### 4. Tests

- Add `XGPriceLayoutTests` suite to `XGPriceTextTests.swift`
- Verify both cases exist
- Verify XGPriceText initialises with each layout

## Acceptance Criteria

- [x] XGPriceLayout exists in iOS design system as its own file
- [x] XGPriceText on iOS supports both layouts (already done)
- [x] Behavior matches Android (inline=HStack, stacked=VStack)
- [x] Tests cover the enum
- [x] File registered in project.pbxproj
