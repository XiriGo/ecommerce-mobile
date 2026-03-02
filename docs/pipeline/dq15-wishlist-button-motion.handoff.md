# DQ-15 XGWishlistButton Motion Token Upgrade -- Pipeline Handoff

## Pipeline ID
`dq/xg-wishlist-button`

## GitHub Issue
#59 -- [DQ-15] Upgrade XGWishlistButton -- motion tokens

## Status
COMPLETED

## Changes

### Android (`XGWishlistButton.kt`)
- Added `animateColorAsState` with `XGMotion.Easing.standardTween(XGMotion.Duration.INSTANT)` for 100ms color transition
- Added `Animatable` + `LaunchedEffect(isWishlisted)` with `XGMotion.Easing.springSpec()` for spring bounce (snap to 1.2x, spring back to 1.0x)
- Added `BOUNCE_SCALE` constant (1.2f) for peak scale
- Imported `XGMotion` from design system theme

### iOS (`XGWishlistButton.swift`)
- Added `@State private var bounceScale: CGFloat = 1.0` for bounce animation state
- Added `.animation(.easeInOut(duration: XGMotion.Duration.instant), value: isWishlisted)` for color transition
- Added `bounceScale` manipulation in Button action: snap to 1.2, spring back via `withAnimation(XGMotion.Easing.spring)`
- Added `Constants.bounceScale` (1.2)

### Shared (`xg-wishlist-button.json`)
- Added `motion` section referencing `$foundations/motion.duration.instant`, `$foundations/motion.easing.standard`, `$foundations/motion.easing.spring`, and `bounceScale: 1.2`

## Quality Gates
- [x] Android ktlint -- PASS
- [x] Android detekt -- PASS
- [x] Android unit tests -- PASS (15 new token contract tests)
- [x] Android Compose UI tests -- PASS (8 new UI tests)
- [x] iOS Swift Testing tests -- 24 new tests
- [x] CHANGELOG updated
- [x] Feature documentation created

## Agent
Team Lead (direct execution -- atom component upgrade)
