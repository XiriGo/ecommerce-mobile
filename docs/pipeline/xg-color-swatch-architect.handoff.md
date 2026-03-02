# Architect Handoff — XGColorSwatch

## Spec Location
`shared/feature-specs/xg-color-swatch.md`

## Key Decisions
1. Single component per platform (no data/domain layers — pure UI atom)
2. Checkmark contrast via luminance detection (> 0.6 threshold)
3. Selection ring uses brand primary with gap for visual clarity
4. Token-driven: all dimensions from xg-color-swatch.json
5. Minimum touch target ensured (48dp Android / 44pt iOS)

## Files to Create
- Android: `XGColorSwatch.kt` in `core/designsystem/component/`
- iOS: `XGColorSwatch.swift` in `Core/DesignSystem/Component/`
- Color tokens: add `ColorSwatchRing` to XGColors (Android), `colorSwatchRing` to XGColors (iOS)
- Strings: add `common_color_swatch_selected_a11y` to string resources

## Token Summary
- Size: 40
- Corner radius: 20 (full circle)
- Selected ring: #6000FE, 2px stroke, 3px gap
- Border: #E5E7EB, 1px
