# iOS Dev Handoff -- XGSocialLoginButton

## Status: COMPLETE

## Files Created/Modified

### New Files
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGSocialLoginButton.swift`

### Modified Files
- `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGColors.swift` -- added social auth colors
- `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` -- added social login strings

## Implementation Details

### Component: `XGSocialLoginButton`
- Custom `ButtonStyle` with surface background, 1px border
- Height: 44pt (from `buttonSize.social.height`)
- Corner radius: `XGCornerRadius.medium` (10pt)
- Typography: `XGTypography.labelLarge` (14pt Medium)
- Width: flexible via `frame(maxWidth: .infinity)`

### Enum: `SocialLoginProvider`
- `.google` -- multi-color "G" icon via Canvas
- `.apple` -- SF Symbol `apple.logo`

### States
- Normal: Icon + text, enabled
- Loading: ProgressView replaces icon, button disabled
- Disabled: 0.38 opacity, interaction blocked

### Icons
- Google: Canvas-drawn multi-color "G" using `XGColors.socialGoogle*` tokens
- Apple: SF Symbol `apple.logo` using `XGColors.socialAppleBlack`

### Colors Added to XGColors
- `socialGoogleBlue` (#4285F4)
- `socialGoogleGreen` (#34A853)
- `socialGoogleYellow` (#FBBC05)
- `socialGoogleRed` (#EA4335)
- `socialAppleBlack` (#000000)

### Localized Strings Added
- `auth_social_continue_google` = "Google" (en, mt, tr)
- `auth_social_continue_apple` = "Apple" (en, mt, tr)

### Previews (5 total)
1. Google variant
2. Apple variant
3. Row layout (both side by side)
4. Loading state (both)
5. Disabled state (both)
