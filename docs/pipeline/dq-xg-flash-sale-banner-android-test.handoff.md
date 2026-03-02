# Android Tester Handoff: DQ-25 XGFlashSaleBanner

## Tests Created
- `android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/component/XGFlashSaleBannerTokenTest.kt`

## Coverage
- 11 JVM unit tests verifying:
  - Banner height (133dp) matches token spec
  - Title maxLines (2) matches token spec
  - XGCornerRadius.Medium = 10dp
  - All XGColors tokens (FlashSaleBackground, FlashSaleText, FlashSaleAccentBlue, FlashSaleAccentPink) exist and are non-null
  - Accent colors are distinct from each other
  - Text color differs from background
  - Stripe layout fractions are within valid ranges
