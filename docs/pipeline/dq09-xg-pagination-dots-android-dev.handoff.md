# DQ-09 Android Dev Handoff — XGPaginationDots Motion Token Upgrade

## Status: COMPLETE

## Changes Made

### `XGPaginationDots.kt`
1. **Removed** `import androidx.compose.animation.core.tween` (no longer needed)
2. **Added** `import com.xirigo.ecommerce.core.designsystem.theme.XGMotion`
3. **Removed** `private const val ANIMATION_DURATION_MS = 300` (hardcoded duration)
4. **Replaced** `animationSpec = tween(durationMillis = ANIMATION_DURATION_MS)` with `animationSpec = XGMotion.Easing.springSpec()`

### `xg-pagination-dots.json`
- Updated `"animation"` field from `"spring(response: 0.3, dampingFraction: 0.7)"` to `"$foundations/motion.easing.spring"`

## Verification
- Android animation now uses `XGMotion.Easing.springSpec()` which provides `spring(dampingRatio = 0.7f, stiffness = Spring.StiffnessMedium)`
- Matches iOS behavior which uses `XGMotion.Easing.spring` = `.spring(response: 0.35, dampingFraction: 0.7)`
- All size tokens unchanged (18dp active, 6dp inactive, 6dp height, 3dp cornerRadius, 4dp gap)
- All color tokens unchanged (`XGColors.PaginationDotsActive`, `XGColors.PaginationDotsInactive`)

## Files Modified
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGPaginationDots.kt`
- `shared/design-tokens/components/atoms/xg-pagination-dots.json`

## Next: Android Tester
