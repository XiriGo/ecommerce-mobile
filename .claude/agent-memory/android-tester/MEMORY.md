# Android Tester Agent Memory

## Project: XiriGo Ecommerce Mobile (Android)

### Test Stack
- **Unit tests**: JUnit 4 + Truth + Turbine (Flow) — `src/test/`
- **UI tests**: Compose Test (`createComposeRule`) — `src/androidTest/`
- **Fakes**: `FakeXxxRepository` in test source set (not mocks)
- **ViewModel coroutines**: `MainDispatcherRule` (TestWatcher + StandardTestDispatcher)

### Key Patterns

#### FakeRepository
```kotlin
class FakeOnboardingRepository : OnboardingRepository {
    private var hasSeen: Boolean = false
    var setOnboardingSeenCallCount: Int = 0
    fun setHasSeen(value: Boolean) { hasSeen = value }
    override suspend fun hasSeenOnboarding(): Boolean = hasSeen
    override suspend fun setOnboardingSeen() { hasSeen = true; setOnboardingSeenCallCount++ }
}
```

#### ViewModel Test with MainDispatcherRule
```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class MyViewModelTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule()
    // ...
    fun test() = runTest { advanceUntilIdle(); assertThat(vm.uiState.value)... }
}
```

#### Turbine Flow test pattern
```kotlin
viewModel.uiState.test {
    assertThat(awaitItem()).isEqualTo(SomeState.Loading)
    advanceUntilIdle()
    assertThat(awaitItem()).isEqualTo(SomeState.ShowContent)
    cancelAndIgnoreRemainingEvents()
}
```

#### AnimatedVisibility assertions
- When `visible=false` and animation completes → use `assertDoesNotExist()`
- Always call `composeTestRule.waitForIdle()` before asserting absence

#### Private composable workaround
When a screen has private `Content` composables, create a `TestXxxContent` in the androidTest
package that mirrors the implementation — allows composition tests without Hilt.

### Test Locations
- Unit: `android/app/src/test/java/com/xirigo/ecommerce/feature/<name>/`
- UI: `android/app/src/androidTest/java/com/xirigo/ecommerce/feature/<name>/`
- Shared fakes: `src/test/java/com/xirigo/ecommerce/feature/<name>/repository/Fake<Name>Repository.kt`
- `MainDispatcherRule.kt` can live in feature viewmodel package (move to testutil if reused)

### FakeRepository pattern for multi-method interfaces
When an interface has many suspend methods that all can fail, use a single `var shouldThrow: IOException?`
that all methods check. Individual data fields are `var` for per-test customization.
Also supports `null` return for optional fields (dailyDeal, flashSale).

### Coil / Image Component Testing
- Do NOT mock Coil or network for UI tests — verify composable node presence only
- `SubcomposeAsyncImage` retains `contentDescription` on its root semantic node during loading, error, and success states → use `assertIsDisplayed()` on the content description node
- Broken URLs trigger the error slot but the root semantic node with `contentDescription` still asserts displayed
- Null URL branch renders a plain `Box` with NO `contentDescription` semantic node → use `assertDoesNotExist()` on content description, and `testTag` to assert the box renders
- `private val` constants (PlaceholderIconSize, PreviewImageSize) inside composable files cannot be referenced from test code — test them indirectly by rendering the component at those sizes

### Completed Features
- **app-onboarding (M4-05)**: FakeOnboardingRepository, CheckOnboarding/CompleteOnboardingUseCase tests, OnboardingViewModelTest (18 tests), SplashScreenTest, OnboardingScreenTest, XGPaginationDotsTest
- **home-screen (M1-04)**: FakeHomeRepository (test), FakeHomeRepositoryTest (19), 6x UseCase tests (6 each = 36), HomeViewModelTest (30 tests). Total: 65 tests. No UI tests (deferred — needs emulator for PullToRefreshBox + HorizontalPager).
- **skeleton-components (DQ-05)**: 27 Compose UI tests in SkeletonTest.kt — SkeletonBox (5), SkeletonLine (4), SkeletonCircle (3), XGSkeleton visibility+transitions (6), accessibility (2), token contracts (4), composite layout (1), content correctness (1).
- **XGImage (DQ-07)**: 18 androidTest tests in XGImageTest.kt — null URL branch (4), valid URL branch (5), XGMotion.Crossfade token contract (3), XGColors token contract (4), multiple instances (2).
