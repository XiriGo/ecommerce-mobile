# Architect Handoff: DQ-23 XGHeroBanner Upgrade

## Summary
Spec created at `shared/feature-specs/xg-hero-banner.md`. DQ-23 adds:
1. `HeroBannerSkeleton` on both platforms using skeleton primitives
2. `autoScroll` token in `XGMotion.Scroll` (replacing hardcoded 5000ms/5s)
3. Token file updates for skeleton and auto-scroll references

## Key Decisions
- Skeleton lives in the same file as `XGHeroBanner` (not separate file) since it is tightly coupled
- Auto-scroll interval = 5000ms (matches existing hardcoded value, now tokenized)
- Image shimmer already works via `XGImage` (DQ-07) -- no changes needed
- Gradient overlay already references `XGColors.BrandPrimary` -- verified compliant

## For Android Dev
- Add `AUTO_SCROLL_INTERVAL_MS = 5000L` to `XGMotion.Scroll`
- Add `HeroBannerSkeleton` composable to `XGHeroBanner.kt`
- Replace `AUTO_SCROLL_DELAY_MS` in `HomeScreen.kt` with `XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS`
- Add Preview for skeleton

## For iOS Dev
- Add `autoScrollInterval: TimeInterval = 5.0` to `XGMotion.Scroll`
- Add `HeroBannerSkeleton` view to `XGHeroBanner.swift`
- Replace hardcoded `autoScrollInterval` in `HomeScreenSections.swift` with `XGMotion.Scroll.autoScrollInterval`
- Add Preview for skeleton (NO explicit `return` in #Preview closures)
