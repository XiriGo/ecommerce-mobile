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

### Completed Features
- **app-onboarding (M4-05)**: FakeOnboardingRepository, CheckOnboarding/CompleteOnboardingUseCase tests, OnboardingViewModelTest (18 tests), SplashScreenTest, OnboardingScreenTest, XGPaginationDotsTest
