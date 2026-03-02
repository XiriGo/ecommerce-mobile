# DQ-13 XGSectionHeader Audit - Architect Handoff

**Agent**: architect
**Date**: 2026-03-02
**Status**: Complete

## Summary

Platform-agnostic spec for auditing `XGSectionHeader` against `shared/design-tokens/components/atoms/xg-section-header.json`.

## Output

- Spec file: `shared/feature-specs/xg-section-header.md`

## Key Findings

### Android (6 issues)
1. Title uses inline font constants instead of `XGTypography.titleMedium`
2. Subtitle uses `FontWeight.Normal` — spec requires Medium (`XGTypography.labelLarge`)
3. Arrow icon size is 16dp — spec says 12dp
4. "See All" text uses inline font constants — should use `XGTypography.labelLarge`
5. No explicit subtitle spacing — spec requires `XGSpacing.XXS` (2dp)
6. Redundant private constants can be removed

### iOS (1 issue)
1. Unused `Constants.titleFontSize` and `Constants.seeAllFontSize` dead code
2. All token references are already spec-aligned

## Next Steps

- Android Dev: Apply token fixes
- iOS Dev: Remove dead code
- Both: Write token contract tests
