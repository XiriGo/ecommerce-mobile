# XGSocialLoginButton

## Overview

A social authentication button molecule for the Login screen. Renders a provider icon
and localized label inside an outlined surface button. Supports Google and Apple
providers with brand-accurate colors, loading state, and disabled state.

## Token Reference

`shared/design-tokens/components/molecules/xg-social-login-button.json`

## API

### Android

```kotlin
@Composable
fun XGSocialLoginButton(
    provider: SocialLoginProvider,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    loading: Boolean = false,
    enabled: Boolean = true,
)
```

### iOS

```swift
struct XGSocialLoginButton: View {
    init(
        provider: SocialLoginProvider,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void,
    )
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| provider | `SocialLoginProvider` | required | `.google` or `.apple` |
| onClick / action | `() -> Unit` / `() -> Void` | required | Tap callback |
| loading | `Boolean` / `Bool` | `false` | Shows spinner, disables interaction |
| enabled | `Boolean` / `Bool` | `true` | Reduces opacity to 0.38 when false |

## Provider Enum

| Variant | Icon | Icon Technique |
|---------|------|---------------|
| Google | Multi-color "G" | Canvas arcs (Android) / Shape overlays (iOS) |
| Apple | Black Apple logo | Canvas path (Android) / SF Symbol (iOS) |

## Design Tokens

| Property | Token | Value |
|----------|-------|-------|
| Height | `buttonSize.social.height` | 44dp/pt |
| Corner radius | `cornerRadius.medium` | 10dp/pt |
| Background | `light.surface` | #FFFFFF |
| Border | `light.borderDefault` | #E5E7EB, 1px |
| Text color | `light.textPrimary` | #333333 |
| Typography | `bodyMedium` (labelLarge) | 14sp/pt Medium |

## Social Auth Colors

| Token | Hex |
|-------|-----|
| `socialAuth.googleBlue` | #4285F4 |
| `socialAuth.googleGreen` | #34A853 |
| `socialAuth.googleYellow` | #FBBC05 |
| `socialAuth.googleRed` | #EA4335 |
| `socialAuth.appleBlack` | #000000 |

## Usage

### Side-by-Side Layout (Login Screen)

**Android:**
```kotlin
Row(
    modifier = Modifier.fillMaxWidth(),
    horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
) {
    XGSocialLoginButton(
        provider = SocialLoginProvider.Google,
        onClick = { viewModel.onGoogleLogin() },
        modifier = Modifier.weight(1f),
    )
    XGSocialLoginButton(
        provider = SocialLoginProvider.Apple,
        onClick = { viewModel.onAppleLogin() },
        modifier = Modifier.weight(1f),
    )
}
```

**iOS:**
```swift
HStack(spacing: XGSpacing.sm) {
    XGSocialLoginButton(provider: .google) { viewModel.onGoogleLogin() }
    XGSocialLoginButton(provider: .apple) { viewModel.onAppleLogin() }
}
```

## Files

| Platform | File |
|----------|------|
| Android | `core/designsystem/component/XGSocialLoginButton.kt` |
| iOS | `Core/DesignSystem/Component/XGSocialLoginButton.swift` |
| Android tests | `test/.../component/XGSocialLoginButtonTokenTest.kt` |
| iOS tests | `XiriGoEcommerceTests/.../Component/XGSocialLoginButtonTests.swift` |

## Related

- Login Screen (M1-01)
- XGDivider (DQ-19) -- "or continue with" divider above social buttons
- XGButton -- primary login button above divider
