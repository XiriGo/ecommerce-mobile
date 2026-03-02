# DQ-15: XGWishlistButton Motion Token Upgrade

## Summary

Upgraded the `XGWishlistButton` component on both Android and iOS to use `XGMotion` tokens for toggle animation, replacing the previously static (non-animated) heart icon toggle.

## Token References

| Property | Token | Value |
|----------|-------|-------|
| Color transition duration | `XGMotion.Duration.INSTANT` / `XGMotion.Duration.instant` | 100ms / 0.1s |
| Color transition easing | `XGMotion.Easing.standardTween` / `.easeInOut` | FastOutSlowIn |
| Scale bounce | `XGMotion.Easing.springSpec()` / `XGMotion.Easing.spring` | dampingRatio=0.7, stiffness=Medium / response=0.35, dampingFraction=0.7 |
| Bounce peak scale | Component constant | 1.2x |

## Behavior

1. **On toggle tap**: Icon color transitions from inactive (OnSurfaceVariant) to active (BrandPrimary) or vice versa, using a 100ms ease-in-out animation.
2. **Scale bounce**: The button snaps to 1.2x scale then springs back to 1.0x using a physics-based spring with moderate bounce (dampingRatio=0.7).
3. **Cross-platform consistency**: Both platforms produce the same visual behavior -- 100ms color fade + spring bounce.

## Files Changed

### Android
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGWishlistButton.kt`
- `android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/component/XGWishlistButtonTokenTest.kt` (new)
- `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGWishlistButtonTest.kt` (new)

### iOS
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGWishlistButton.swift`
- `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGWishlistButtonTests.swift` (new)

### Shared
- `shared/design-tokens/components/atoms/xg-wishlist-button.json` (added motion section)

## Test Coverage

| Platform | Test Type | Count |
|----------|-----------|-------|
| Android | JUnit unit (token contract) | 15 |
| Android | Compose UI | 8 |
| iOS | Swift Testing | 24 |

## Dependencies

- DQ-01: XGMotion Android (merged)
- DQ-02: XGMotion iOS (merged)
