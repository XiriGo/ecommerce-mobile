# iOS Tester Handoff: DQ-25 XGFlashSaleBanner

## Tests Created
- `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGFlashSaleBannerTests.swift`

## Coverage
- 6 initialisation tests (all parameter combinations, edge cases)
- 10 token contract tests (height, maxLines, cornerRadius, colors, typography, spacing, shimmer)
- 5 stripe layout tests (fraction values, non-overlap verification)
- 3 body tests (disabled: require SwiftUI runtime)
- Total: 24 tests

## Registration
- File added to `project.pbxproj` (4 entries: PBXBuildFile, PBXFileReference, group ref, Sources build phase)
