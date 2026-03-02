# DQ-29 XGTopBar — Android Dev Handoff

## Summary
Upgraded XGTopBar Android implementation to use design tokens directly.

## Changes Made
- Added `XGTopBarVariant` enum with `Surface` and `Transparent` cases
- Replaced `TopAppBar` with custom `Row` layout for full token control
- Title: `XGTypography.titleLarge` (was `MaterialTheme.typography.titleLarge`)
- Colors: `XGColors.Surface`/`XGColors.OnSurface` via variant (was `MaterialTheme.colorScheme.*`)
- Height: explicit `56.dp` from token spec (was default TopAppBar height)
- Icon size: explicit `24.dp` via `Modifier.size()` (was Material default)
- Horizontal padding: `XGSpacing.Base` (16dp)
- Action icon color now matches variant content color (was `onSurfaceVariant`)
- Added transparent variant preview

## Files Changed
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGTopBar.kt`
