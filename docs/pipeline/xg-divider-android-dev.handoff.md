# XGDivider -- Android Dev Handoff

## Summary

Implemented XGDivider and XGLabeledDivider composables for Android.

## Files Created / Modified

| File | Action |
|------|--------|
| `android/.../core/designsystem/component/XGDivider.kt` | Created |
| `android/.../feature/profile/presentation/screen/ProfileScreen.kt` | Modified |

## Implementation Details

- `XGDivider`: Wraps `HorizontalDivider` with token defaults (color = `XGColors.Divider`, thickness = 1.dp)
- `XGLabeledDivider`: Row layout with line-label-line pattern, captionMedium typography
- Replaced raw `HorizontalDivider` in `ProfileScreen.kt` with `XGDivider`
- Removed unused `HorizontalDivider` import from `ProfileScreen.kt`
- Both composables have `@Preview` annotations
- All values sourced from design tokens -- no hardcoded colors/dimensions
