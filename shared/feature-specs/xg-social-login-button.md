# XGSocialLoginButton -- Component Specification

## Overview

A social authentication button molecule for the login screen. Supports Google
and Apple providers with brand-accurate icon + text layout. Used on the Login
Screen (M1-01) below the "or" divider.

## Token Reference

`shared/design-tokens/components/molecules/xg-social-login-button.json`

## Provider Variants

| Provider | Background | Border | Text Color | Icon |
|----------|-----------|--------|-----------|------|
| Google | `surface` (#FFFFFF) | `borderDefault` (#E5E7EB), 1px | `textPrimary` (#333333) | Multi-color Google "G" logo |
| Apple | `surface` (#FFFFFF) | `borderDefault` (#E5E7EB), 1px | `textPrimary` (#333333) | Black Apple logo |

## Dimensions

- **Height**: 44dp/pt (from `buttonSize.social.height`)
- **Width**: Flexible -- use `weight(1f)` (Android) / `flexible()` (iOS) so
  buttons share available width equally when placed side by side
- **Corner Radius**: `cornerRadius.medium` (10dp/pt)
- **Icon Size**: 20dp/pt
- **Icon-to-Text Spacing**: `XGSpacing.SM` (8dp/pt)
- **Typography**: `bodyMedium` (14pt Medium / Poppins-Medium)

## States

### Normal
- Surface background, 1px border, provider icon + text

### Loading
- Replace icon with a `CircularProgressIndicator` / `ProgressView`
- Spinner tint: `textPrimary`
- Button disabled during loading (click blocked)
- Accessibility: announce loading state

### Disabled
- Opacity reduced to 0.38
- Click blocked
- No visual change to colors (just opacity)

## Social Auth Colors (from colors.json)

```json
"socialAuth": {
  "googleBlue": "#4285F4",
  "googleGreen": "#34A853",
  "googleYellow": "#FBBC05",
  "googleRed": "#EA4335",
  "appleBlack": "#000000",
  "appleWhite": "#FFFFFF"
}
```

## Icon Rendering

### Google
- Multi-color "G" logo rendered as a composable/view drawing four colored arcs
- Colors: googleBlue, googleGreen, googleYellow, googleRed from socialAuth tokens
- Alternative: SF Symbol not available; use custom Canvas drawing or vector asset

### Apple
- Apple logo from SF Symbols (`apple.logo` on iOS)
- On Android: use a vector drawable or Canvas-drawn Apple logo
- Color: `socialAuth.appleBlack` (#000000)

## Text Content (Localized)

| Key | English Value |
|-----|--------------|
| `auth_social_continue_google` | "Google" |
| `auth_social_continue_apple` | "Apple" |
| `common_loading_message` | "Loading..." (existing) |

## Accessibility

- **Android**: `contentDescription` = provider name + state
- **iOS**: `accessibilityLabel` = provider name, `accessibilityValue` = loading state
- Minimum touch target: 48dp/44pt (already met by 44dp height + parent padding)

## Layout Usage (Login Screen)

```
Row(horizontalArrangement = spacedBy(XGSpacing.SM)) {
  XGSocialLoginButton(provider = .google, onClick = ..., modifier = Modifier.weight(1f))
  XGSocialLoginButton(provider = .apple, onClick = ..., modifier = Modifier.weight(1f))
}
```

## Platform Implementation

### Android
- File: `core/designsystem/component/XGSocialLoginButton.kt`
- Enum: `SocialLoginProvider` with `Google`, `Apple` variants
- Composable: `@Composable fun XGSocialLoginButton(...)`
- Previews: All provider variants, loading, disabled

### iOS
- File: `Core/DesignSystem/Component/XGSocialLoginButton.swift`
- Enum: `SocialLoginProvider` with `google`, `apple` cases
- Struct: `XGSocialLoginButton: View`
- Previews: All provider variants, loading, disabled

## Handoff Notes

- The Facebook provider from the issue description is NOT in the design tokens
  (only Google and Apple appear in the login screen spec and token file).
  Implement Google + Apple only. Facebook can be added later if needed.
- Both buttons should be placed side-by-side in a horizontal row with equal weight.
