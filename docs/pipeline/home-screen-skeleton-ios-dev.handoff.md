# iOS Dev Handoff: HomeScreenSkeleton (DQ-36)

## Files Created
- `ios/XiriGoEcommerce/Feature/Home/Presentation/Component/HomeScreenSkeleton.swift`

## Files Modified
- `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreen.swift`
  - Replaced `XGLoadingView()` with `HomeScreenSkeleton()` in `.loading` case
- `ios/XiriGoEcommerce.xcodeproj/project.pbxproj`
  - Added new Component group under Home/Presentation
  - Registered HomeScreenSkeleton.swift (PBXBuildFile, PBXFileReference, group, Sources)

## Implementation Notes
- Constants in private `HomeScreenSkeletonConstants` enum (SwiftLint compliant)
- Uses `ScrollView` with `VStack` for vertical layout (matches real HomeScreen)
- Uses `ScrollView(.horizontal)` with `HStack` for categories and popular products
- Uses `LazyVGrid` for 2-column new arrivals grid
- SkeletonBox for search bar uses `cornerRadius: XGCornerRadius.pill` (28)
- Accessibility: `.accessibilityLabel` on root ScrollView
- `#Preview` macro used (not deprecated PreviewProvider)
- No `return` in preview closures (ViewBuilder compliance)
