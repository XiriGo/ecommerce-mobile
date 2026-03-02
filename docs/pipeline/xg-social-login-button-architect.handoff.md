# Architect Handoff -- XGSocialLoginButton

## Status: COMPLETE

## Spec Location
`shared/feature-specs/xg-social-login-button.md`

## Key Decisions
1. Only Google + Apple providers (Facebook not in design tokens or login screen spec)
2. Flexible width with `weight(1f)` / `.frame(maxWidth: .infinity)` for equal sizing
3. Height fixed at 44dp/pt per token spec
4. Corner radius: medium (10dp/pt)
5. Loading state replaces icon with spinner, disables interaction
6. Social auth colors from `foundations/colors.json > socialAuth`
7. Google icon: multi-color "G" via Canvas/custom drawing
8. Apple icon: SF Symbol on iOS, vector drawable on Android

## Token Sources
- Component: `components/molecules/xg-social-login-button.json`
- Colors: `foundations/colors.json > socialAuth`
- Spacing: `foundations/spacing.json > buttonSize.social`
- Typography: `foundations/typography.json > bodyMedium`

## Files to Create
- Android: `XGSocialLoginButton.kt` in `core/designsystem/component/`
- iOS: `XGSocialLoginButton.swift` in `Core/DesignSystem/Component/`
- String resources for localized button text
