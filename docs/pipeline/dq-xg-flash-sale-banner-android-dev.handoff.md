# Android Dev Handoff: DQ-25 XGFlashSaleBanner

## Changes Made
1. Replaced inline `fontFamily = PoppinsFontFamily, fontSize = BadgeFontSize, fontWeight = FontWeight.Bold` with `style = MaterialTheme.typography.titleSmall` (bodySemiBold token: 14sp SemiBold).
2. Replaced inline `fontFamily = PoppinsFontFamily, fontSize = TitleFontSize, fontWeight = FontWeight.Bold, lineHeight = TitleLineHeight` with `style = MaterialTheme.typography.titleLarge` (title token: 20sp SemiBold, 28sp lineHeight).
3. Added `textAlign = TextAlign.Center` and `maxLines = TITLE_MAX_LINES` to the title Text per the token spec.
4. Removed unused constants: `BadgeFontSize`, `TitleFontSize`, `TitleLineHeight`.
5. Removed unused imports: `PoppinsFontFamily`, `FontWeight`, `sp`.
6. Added `MaterialTheme` and `TextAlign` imports.
7. XGImage shimmer is already inherited — no changes needed (XGImage uses `.shimmerEffect()` in loading slot).
8. Added second preview variant showing the banner with an `imageUrl`.
9. Enhanced KDoc on the composable with `@param` documentation.

## Files Modified
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGFlashSaleBanner.kt`
