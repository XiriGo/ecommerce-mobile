# Home Screen iOS Test Handoff

## Feature: M1-04 Home Screen
## Platform: iOS
## Agent: ios-tester
## Date: 2026-02-28

## Summary

Added comprehensive unit tests for the Home Screen feature. Fixed 4 bugs discovered in the iOS dev's implementation during testing. All 828 unit tests pass.

## Test Files Created

### Test Infrastructure (`ios/XiriGoEcommerceTests/Feature/Home/`)

| File | Location | Tests |
|------|----------|-------|
| `FakeHomeRepository.swift` | `Fakes/` | Fake implementation of `HomeRepository` for tests |
| `FakeHomeRepositoryTests.swift` | `Repository/` | 15 tests verifying fake behavior |
| `GetHomeBannersUseCaseTests.swift` | `UseCase/` | 6 tests |
| `GetHomeCategoriesUseCaseTests.swift` | `UseCase/` | 6 tests |
| `GetPopularProductsUseCaseTests.swift` | `UseCase/` | 6 tests |
| `GetDailyDealUseCaseTests.swift` | `UseCase/` | 6 tests |
| `GetNewArrivalsUseCaseTests.swift` | `UseCase/` | 6 tests |
| `GetFlashSaleUseCaseTests.swift` | `UseCase/` | 7 tests |
| `HomeViewModelTests.swift` | `ViewModel/` | 34 tests |

**Total new Home tests: 92 tests across 8 suites**
**Overall test suite: 828 tests, all passing**

## Test Coverage

### HomeViewModelTests (34 tests)
- Initial state: `uiState == .loading`, `currentBannerPage == 0`, `isRefreshing == false`
- `loadHomeData()`: success transitions (banners, categories, popularProducts, dailyDeal, newArrivals, flashSale, wishedProductIds), error transitions (network, server errors)
- `refresh()`: reloads data, preserves `wishedProductIds`, sets `isRefreshing = false`
- `onEvent(.refresh)`: triggers data reload
- `onEvent(.wishlistToggled)`: add/remove/toggle, handles loading/error states gracefully
- `onEvent(.retryTapped)`: retries load after error
- Navigation events (bannerTapped, categoryTapped, productTapped, etc.): do not mutate uiState
- `currentBannerPage` mutation

### Use Case Tests (6-7 each, × 6 use cases)
Each use case tested for:
- Success path: returns configured data from fake
- Empty/nil path: handles empty returns correctly
- Error propagation: network and server errors pass through
- Delegation: call count verification

### FakeHomeRepository Tests (15 tests)
- Default state (empty/nil returns per method)
- Configurable return values
- Error propagation for all 6 methods
- Call count tracking starts at 0 and increments correctly
- Test isolation (separate instances are independent)

## Bugs Fixed

### Bug 1: project.pbxproj parse error
**File**: `ios/XiriGoEcommerce.xcodeproj/project.pbxproj`
**Issue**: `Container+Home.swift` file reference had unquoted `+` in path: `path = Container+Home.swift;`. OpenStep plist parser treats `+` as a special character unless quoted.
**Fix**: Added quotes: `name = "Container+Home.swift"; path = "Container+Home.swift";`

### Bug 2: `private` access level blocks extension access
**File**: `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreen.swift`
**Issue**: `router` and `viewModel` were declared `private`, but `HomeScreenSections.swift` (an extension on `HomeScreen`) needed access to them.
**Fix**: Changed `private var router` and `@State private var viewModel` to internal (`var router` and `@State var viewModel`).

### Bug 3: Return type mismatch for `bannerTimer`
**File**: `ios/XiriGoEcommerce/Feature/Home/Presentation/Screen/HomeScreenSections.swift`
**Issue**: `bannerTimer` was declared as returning `Timer.TimerPublisher` but `Timer.publish(...).autoconnect()` returns `Publishers.Autoconnect<Timer.TimerPublisher>`.
**Fix**: Changed return type to `Publishers.Autoconnect<Timer.TimerPublisher>` and added `import Combine`.

### Bug 4: Missing constant `titleMaxLines`
**File**: `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGDailyDealCard.swift`
**Issue**: `Constants.titleMaxLines` was referenced in `leftContent` but never defined in the `Constants` enum.
**Fix**: Added `static let titleMaxLines = 2` to the `Constants` enum.

### Bug 5: `refresh()` did not preserve `wishedProductIds`
**File**: `ios/XiriGoEcommerce/Feature/Home/Presentation/ViewModel/HomeViewModel.swift`
**Issue**: The iOS dev handoff documented that `refresh()` preserves `wishedProductIds`, but the implementation called `loadHomeData()` which always set `wishedProductIds: []`.
**Fix**: Updated `refresh()` to capture existing `wishedProductIds` before reload and restore them after success.

## Project File Changes

Added to `ios/XiriGoEcommerce.xcodeproj/project.pbxproj`:
- 10 new PBXBuildFile entries (9 test files + FakeHomeRepository)
- 10 new PBXFileReference entries
- 5 new PBXGroup entries (Home, Fakes, Repository, UseCase, ViewModel)
- Home group added to Feature group's children in XiriGoEcommerceTests
- All 10 files added to XiriGoEcommerceTests Sources build phase

## Test Results

```
✔ Test run with 828 tests in 81 suites passed after 4.974 seconds.
** TEST SUCCEEDED **
```

## Notes for Reviewer

- `FakeHomeRepository` in the test target is a distinct fake from `FakeHomeRepository` in the main app (data layer). The test fake adds call counts and configurable error injection.
- The `refresh preserves wishedProductIds` behavior was specified in the dev handoff but not implemented — this was fixed as a bug.
- The project file bug (Bug 1) existed before the test files were added; the iOS dev committed a broken pbxproj. This fix is included in the test commit.
