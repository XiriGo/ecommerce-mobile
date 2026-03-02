# iOS Dev Handoff: DQ-25 XGFlashSaleBanner

## Changes Made
1. Added `XGImage` rendering in the ZStack when `imageUrl` is provided. This inherits shimmer from the XGImage component (DQ-07).
2. Removed unused constants: `badgeFontSize`, `titleFontSize` from `Constants`.
3. Added `titleMaxLines` constant to `Constants` replacing the magic number `2`.
4. Updated doc comment to reference token names instead of hardcoded hex values.
5. Typography tokens were already correct: `XGTypography.bodySemiBold` (badge) and `XGTypography.title` (title).
6. Added preview variant showing the banner with an `imageUrl`.

## Files Modified
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGFlashSaleBanner.swift`
