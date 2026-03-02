# Android Test Handoff: DQ-23 XGHeroBanner Upgrade

## Tests Created

### 1. `HeroBannerSkeletonTest.kt` (androidTest — instrumented)
- `heroBannerSkeleton_isDisplayed` — renders without crash
- `heroBannerSkeleton_withCustomModifier_isDisplayed` — modifier forwarding
- `heroBannerSkeleton_rendersWithinXGSkeleton` — works as placeholder in XGSkeleton wrapper
- `heroBannerSkeleton_hidesWhenXGSkeletonNotVisible` — crossfade hides skeleton when loaded

### 2. `XGMotionTest.kt` (unit test — updated)
- `Scroll AUTO_SCROLL_INTERVAL_MS should be 5000` — token contract test
- `Scroll AUTO_SCROLL_INTERVAL_MS should be positive` — sanity check

## Coverage
- HeroBannerSkeleton: rendering, modifier forwarding, XGSkeleton integration
- XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS: token value contract
