# DQ-09 Architect Handoff — XGPaginationDots Motion Token Upgrade

## Status: COMPLETE

## Summary

Designed spec for upgrading `XGPaginationDots` atom component to use `XGMotion` tokens.

## Key Findings

1. **Android** uses hardcoded `tween(300ms)` — must be replaced with `XGMotion.Easing.springSpec()`
2. **iOS** already uses `XGMotion.Easing.spring` — no changes needed
3. **Token JSON** has hardcoded spring params — should reference `$foundations/motion.easing.spring`
4. All size/color tokens are already compliant on both platforms

## Changes Required

### Android (1 file)
- `XGPaginationDots.kt`: Replace `tween` animation with `XGMotion.Easing.springSpec()`

### Shared (1 file)
- `xg-pagination-dots.json`: Update animation reference to use foundation token

### iOS (0 files)
- Already compliant

## Spec Location
`shared/feature-specs/xg-pagination-dots.md`

## Next: Android Dev + iOS Dev (parallel)
