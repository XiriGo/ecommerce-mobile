# XGDivider -- Architect Handoff

## Summary

Designed platform-agnostic spec for DQ-19 XGDivider atom component.

## Key Decisions

1. **Two composables/views per platform**: `XGDivider` (plain) and `XGLabeledDivider` (with label).
   Separating them keeps each composable focused and avoids optional-parameter complexity.

2. **Color default**: `XGColors.Divider` / `XGColors.divider` mapped from `semantic.divider` (`#E5E7EB`).
   This matches `$foundations/colors.light.divider` from the token spec.

3. **Typography**: Label uses `captionMedium` (12sp/pt Poppins Medium) which maps to
   `MaterialTheme.typography.labelMedium` on Android and `XGTypography.captionMedium` on iOS.

4. **ProfileScreen migration**: The only raw `HorizontalDivider` usage is in `ProfileScreen.kt`.
   No raw `Divider()` usage found on iOS.

## Files Created

- `shared/feature-specs/xg-divider.md`

## Next Steps

- Android Dev: Create `XGDivider.kt`, update `ProfileScreen.kt`
- iOS Dev: Create `XGDivider.swift`
