# Android Dev Handoff — XGEmptyView Token Audit (DQ-28)

## Status: COMPLETE

## Changes Made

### `XGEmptyView.kt`
- Changed CTA button style from `XGButtonStyle.Primary` to `XGButtonStyle.Outlined`
  to match token spec (`$atoms/xg-button (outlined variant)`)

## Token Compliance

| Property | Token | Implementation | Status |
|----------|-------|---------------|--------|
| Icon size | XXXL (48dp) | `Modifier.size(XGSpacing.XXXL)` | OK |
| Icon color | textSecondary | `MaterialTheme.colorScheme.onSurfaceVariant` | OK |
| Default icon | Inbox | `Icons.Outlined.Inbox` | OK |
| Message font | bodyLarge | `MaterialTheme.typography.bodyLarge` | OK |
| Message color | textSecondary | `MaterialTheme.colorScheme.onSurfaceVariant` | OK |
| Spacing | base (16dp) | `XGSpacing.Base` | OK |
| CTA button | outlined | `XGButtonStyle.Outlined` | FIXED |

## Files Modified
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGEmptyView.kt`
