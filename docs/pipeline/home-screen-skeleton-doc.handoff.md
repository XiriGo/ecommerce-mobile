# Doc Handoff: HomeScreenSkeleton (DQ-36)

## Feature Documentation
- Feature spec: `shared/feature-specs/home-screen-skeleton.md`
- Architect handoff: `docs/pipeline/home-screen-skeleton-architect.handoff.md`
- Android dev handoff: `docs/pipeline/home-screen-skeleton-android-dev.handoff.md`
- iOS dev handoff: `docs/pipeline/home-screen-skeleton-ios-dev.handoff.md`
- Review handoff: `docs/pipeline/home-screen-skeleton-review.handoff.md`

## File Manifest

### New Files
| Platform | File | Description |
|----------|------|-------------|
| Shared | `shared/feature-specs/home-screen-skeleton.md` | Feature specification |
| Android | `feature/home/presentation/component/HomeScreenSkeleton.kt` | Skeleton composable |
| iOS | `Feature/Home/Presentation/Component/HomeScreenSkeleton.swift` | Skeleton view |

### Modified Files
| Platform | File | Change |
|----------|------|--------|
| Android | `feature/home/presentation/screen/HomeScreen.kt` | Loading state: XGLoadingView -> HomeScreenSkeleton |
| iOS | `Feature/Home/Presentation/Screen/HomeScreen.swift` | Loading state: XGLoadingView() -> HomeScreenSkeleton() |
| iOS | `XiriGoEcommerce.xcodeproj/project.pbxproj` | Added Component group + file registration |
