# Android Dev Handoff -- XGSocialLoginButton

## Status: COMPLETE

## Files Created/Modified

### New Files
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGSocialLoginButton.kt`

### Modified Files
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGColors.kt` -- added social auth colors
- `android/app/src/main/res/values/strings.xml` -- added social login string resources

## Implementation Details

### Component: `XGSocialLoginButton`
- Outlined button with surface background, 1px border
- Height: 44dp (from `buttonSize.social.height`)
- Corner radius: `XGCornerRadius.Medium` (10dp)
- Typography: `XGTypography.labelLarge` (14sp Medium = bodyMedium token)

### Enum: `SocialLoginProvider`
- `Google` -- multi-color "G" icon via Canvas
- `Apple` -- simplified Apple logo via Canvas

### States
- Normal: Icon + text, enabled
- Loading: CircularProgressIndicator replaces icon, button disabled
- Disabled: 0.38 alpha opacity, interaction blocked

### Icons
- Google: Canvas-drawn multi-color "G" using `XGColors.SocialGoogle*` tokens
- Apple: Canvas-drawn simplified Apple logo using `XGColors.SocialAppleBlack`

### Colors Added to XGColors
- `SocialGoogleBlue` (#4285F4)
- `SocialGoogleGreen` (#34A853)
- `SocialGoogleYellow` (#FBBC05)
- `SocialGoogleRed` (#EA4335)
- `SocialAppleBlack` (#000000)

### String Resources Added
- `auth_social_continue_google` = "Google"
- `auth_social_continue_apple` = "Apple"

### Previews (5 total)
1. Google variant
2. Apple variant
3. Row layout (both side by side with weight)
4. Loading state (both)
5. Disabled state (both)
