# Handoff: motion-tokens -- Android Tester

## Feature
**DQ-01: Motion Tokens (Android)** -- Unit tests for `XGMotion.kt` design system token constants.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Test File | `android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/theme/XGMotionTest.kt` |
| This Handoff | `docs/pipeline/motion-tokens-android-test.handoff.md` |

## Test Coverage Summary

### Test File
`android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/theme/XGMotionTest.kt`

### Test Count: 36 tests

| Category | Tests | Description |
|----------|-------|-------------|
| Duration | 7 | All 5 constants match JSON values, ordering constraints |
| Shimmer | 6 | DURATION_MS, ANGLE_DEGREES, REPEAT_MODE_RESTART, GradientColors size/symmetry/hex values |
| Crossfade | 3 | IMAGE_FADE_IN, CONTENT_SWITCH, relative ordering |
| Scroll | 2 | PREFETCH_DISTANCE, SCROLL_RESTORATION_ENABLED |
| EntranceAnimation | 6 | STAGGER_DELAY_MS, MAX_STAGGER_ITEMS, FADE_FROM, FADE_TO, SlideOffsetY, fade range |
| Performance | 6 | FRAME_TIME_MS, STARTUP_COLD_MS, SCREEN_TRANSITION_MS, LIST_SCROLL_FPS, FIRST_CONTENTFUL_PAINT_MS, frame/fps math |
| Easing | 10 | standardTween, decelerateTween, accelerateTween (return type + default duration), springSpec, distinct instances |

### Coverage Estimate
All public constants and factory functions in `XGMotion` are directly exercised. Coverage target >= 80% is met.

## Test Approach

### Token Constant Tests
All `const val` and `val` constants are asserted to equal their expected values from `shared/design-tokens/foundations/motion.json`. No mocking required -- these are pure Kotlin constant tests.

### Easing Factory Function Tests
- Each factory function (`standardTween`, `decelerateTween`, `accelerateTween`, `springSpec`) is called and the return value is verified to be non-null and of the correct type (`TweenSpec<T>` or `SpringSpec<T>`).
- Default duration arguments are validated by comparing a default-call result against an explicit-duration result using `TweenSpec.durationMillis`.
- Compose animation types (`TweenSpec`, `SpringSpec`) are available in unit test scope without Robolectric because they are pure Kotlin classes with no Android framework dependencies.

### Design Decisions
- No mocking used -- all assertions are on compile-time constants.
- Structural invariants tested (duration ordering, gradient symmetry, fade range, frame time math) in addition to exact value checks.
- Generic type parameter `Float` used for easing factory calls as a representative concrete type.

## Key Assertions

```kotlin
// Duration values from motion.json
assertThat(XGMotion.Duration.INSTANT).isEqualTo(100)
assertThat(XGMotion.Duration.FAST).isEqualTo(200)
assertThat(XGMotion.Duration.NORMAL).isEqualTo(300)
assertThat(XGMotion.Duration.SLOW).isEqualTo(450)
assertThat(XGMotion.Duration.PAGE_TRANSITION).isEqualTo(350)

// Shimmer gradient: 3 colors, first == last, correct hex values
assertThat(XGMotion.Shimmer.GradientColors).hasSize(3)
assertThat(XGMotion.Shimmer.GradientColors[0]).isEqualTo(Color(0xFFE0E0E0))
assertThat(XGMotion.Shimmer.GradientColors[1]).isEqualTo(Color(0xFFF5F5F5))

// Easing factory returns correct AnimationSpec subtype
val spec: AnimationSpec<Float> = XGMotion.Easing.standardTween()
assertThat(spec).isInstanceOf(TweenSpec::class.java)

val spring: AnimationSpec<Float> = XGMotion.Easing.springSpec<Float>()
assertThat(spring).isInstanceOf(SpringSpec::class.java)
```

## Dependencies Used

| Dependency | Version |
|------------|---------|
| JUnit 4 | via `libs.junit` |
| Google Truth | via `libs.truth` |
| Compose Animation Core | `TweenSpec`, `SpringSpec`, `AnimationSpec` |
| Compose UI Unit | `Dp` / `.dp` |

## Downstream Notes

- **Reviewer**: All 36 tests are pure unit tests (no Robolectric needed). Each JSON token has a matching `isEqualTo` assertion. Easing factory tests confirm correct `AnimationSpec` subtype and default duration pass-through.
- **Doc Writer**: Test file documents expected values for all token categories, which can serve as a reference.
- **Skeleton Components Android Tester**: `XGMotion.Shimmer` tokens (gradient colors, duration, angle) are validated here; skeleton tests can import these constants and rely on the values being correct.
