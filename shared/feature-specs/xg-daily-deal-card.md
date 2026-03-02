# XGDailyDealCard — Upgrade Specification (DQ-24)

## Summary

Upgrade the existing `XGDailyDealCard` design-system component on both Android and iOS to:

1. Use proper countdown timer patterns (`LaunchedEffect` + `delay` on Android, `TimelineView` on iOS)
2. Inherit image shimmer from the upgraded `XGImage` (DQ-07) — no manual shimmer needed
3. Ensure all dimensions are token-driven from `xg-daily-deal-card.json`
4. Align both platforms to consistent behavior

## Current State

Both platforms already have a working `XGDailyDealCard`:
- **Android**: `core/designsystem/component/XGDailyDealCard.kt` — uses `LaunchedEffect` + `delay(1000L)` for countdown
- **iOS**: `Core/DesignSystem/Component/XGDailyDealCard.swift` — uses `TimelineView(.periodic(from:by:))` for countdown

Both use `XGImage` which already has shimmer via `.shimmerEffect()` modifier (DQ-07 completed).

## Token Reference

Source: `shared/design-tokens/components/molecules/xg-daily-deal-card.json`

| Token | Value | Maps To |
|-------|-------|---------|
| height | 163 | `Constants.CardHeight` / `Constants.cardHeight` |
| cornerRadius | `$foundations/spacing.cornerRadius.medium` | `XGCornerRadius.Medium` / `XGCornerRadius.medium` |
| background | `$foundations/gradients.dailyDealCard` | `DailyDealGradient` / `backgroundGradient` |
| padding | 16 | `Constants.CardPadding` / `Constants.cardPadding` |
| badge.style | `$atoms/xg-badge.secondary` | Secondary badge styling |
| title.font | `$foundations/typography.typeScale.title` | `XGTypography.title` |
| title.color | `$foundations/colors.light.textOnDark` | `XGColors.TextOnDark` / `XGColors.textOnDark` |
| title.maxLines | 2 | `maxLines = 2` / `lineLimit(2)` |
| countdown.format | HH:MM:SS | `formatCountdown()` / `formattedCountdown()` |
| countdown.font | system monospaced 12pt | Monospaced system font, 12sp/pt |
| countdown.tickInterval | 1 second | `delay(1000L)` / `TimelineView(.periodic(by: 1))` |
| countdown.expiredText | localized key | `home_daily_deal_ended` |
| price.style | deal | `XGPriceSize.Deal` / `.deal` |
| strikethrough.fontSize | 15.18 | Named constant |
| productImage.size | 100 | Named constant |
| productImage.cornerRadius | medium | `XGCornerRadius.Medium` / `XGCornerRadius.medium` |

## Changes Required

### Android

1. **Audit token compliance**: Ensure all named constants map to design tokens. Current code already extracts constants — verify they match the JSON spec.
2. **Countdown timer**: Current `LaunchedEffect` + `delay` pattern is correct per `component-quality.md` Section 9. Keep it.
3. **Image shimmer**: `XGImage` already applies shimmer internally (DQ-07). No changes needed on the card.
4. **Product image sizing**: Current code uses `Modifier.weight(0.6f).aspectRatio(1f)`. The token specifies `size: 100`. Use a fixed `100.dp` size instead of weight-based sizing for pixel-perfect match.
5. **Ensure no hardcoded values**: All spacing via `XGSpacing`, all corners via `XGCornerRadius`, all colors via `XGColors`.

### iOS

1. **Audit token compliance**: Same as Android.
2. **Countdown timer**: Current `TimelineView(.periodic)` pattern is correct. Keep it.
3. **Image shimmer**: `XGImage` already applies shimmer internally. No changes needed.
4. **Product image sizing**: Current code uses `Constants.imageSize = 100`. Correct. Verify it is used as both width and height.
5. **Ensure no hardcoded values**.

### Both Platforms

- Verify `formatCountdown` / `formattedCountdown` produces `HH:MM:SS` format
- Verify expired text uses localized string `home_daily_deal_ended`
- Verify badge uses secondary styling
- Verify accessibility labels are present and meaningful

## Layout Specification

```
HStack: [
  VStack(alignment: .leading, spacing: SM) {
    Badge("DAILY DEAL", style: secondary)
    Title(maxLines: 2, font: title, color: textOnDark)
    Countdown(format: HH:MM:SS, font: monospaced 12, color: textOnDark)
    HStack(spacing: SM) {
      XGPriceText(style: deal)
      StrikethroughPrice(font: 15.18, color: priceStrikethrough)
    }
  }
  Spacer
  XGImage(size: 100x100, cornerRadius: medium)
]
```

Container: `fillMaxWidth`, height: 163, cornerRadius: medium, gradient background, padding: 16

## Test Plan

### Unit Tests (both platforms)
- `formatCountdown` returns correct HH:MM:SS for various intervals
- `formatCountdown` returns expired text when remaining <= 0
- Countdown hours/minutes/seconds calculation is correct
- Edge cases: exactly 0, negative values, very large values

### UI Tests
- Card renders with all subcomponents visible
- Preview compiles and renders without crashes

## Dependencies

- DQ-07 (XGImage upgrade) — DONE
- XGPriceText — EXISTS
- XGBadge atoms — EXISTS
