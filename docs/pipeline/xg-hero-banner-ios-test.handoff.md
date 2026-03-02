# iOS Test Handoff: DQ-23 XGHeroBanner Upgrade

## Tests Created

### 1. `HeroBannerSkeletonTests.swift` (new file)
- `HeroBannerSkeleton can be instantiated` — instantiation test
- `HeroBannerSkeleton body is a valid View` — disabled (requires SwiftUI runtime)
- Token contract tests for banner height (192pt), corner radius, auto-scroll interval

### 2. `XGMotionTests.swift` (updated)
- `autoScrollInterval is 5.0 seconds` — token contract test
- `autoScrollInterval is positive` — sanity check

## Coverage
- HeroBannerSkeleton: instantiation, token contract verification
- XGMotion.Scroll.autoScrollInterval: value, positivity, reasonable range
