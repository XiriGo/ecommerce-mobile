# Architect Handoff — DQ-33 Brand Audit

## Spec Location
`shared/feature-specs/dq-xg-brand-audit.md`

## Summary
Audit of XGBrandGradient, XGBrandPattern, XGLogoMark across both platforms.
Core change: replace inline hex color literals with XGColors token references.

## Key Decisions
1. Reuse existing XGColors constants where hex values match (BrandPrimaryLight, BrandPrimary, BrandPrimaryDark)
2. Add 4 new gradient-specific constants for intermediate overlay stops
3. Add brand pattern opacity constant to XGColors
4. Logo mark already uses correct defaults; just add token-source comments

## Files Impacted
- XGColors.kt / XGColors.swift (add constants)
- XGBrandGradient.kt / XGBrandGradient.swift (refactor to tokens)
- XGBrandPattern.kt / XGBrandPattern.swift (refactor opacity)
- XGLogoMark.kt / XGLogoMark.swift (documentation only)

## Risk Assessment
Low risk — all changes are cosmetic refactors. No behavioral changes.
Gradient visual output should be pixel-identical before and after.
