# Feature Spec: DQ-25 — Upgrade XGFlashSaleBanner

## Summary

Upgrade `XGFlashSaleBanner` on both platforms to:
1. Leverage `XGImage` shimmer for image loading (inherited from DQ-07).
2. Use **token-driven dimensions** from `xg-flash-sale-banner.json`.
3. Replace any hardcoded typography with `XGTypography` tokens.
4. Ensure gradient overlay stripes use `XGColors` tokens (already the case).

## Token Reference

**File**: `shared/design-tokens/components/molecules/xg-flash-sale-banner.json`

| Token | Value | Notes |
|-------|-------|-------|
| `height` | 133 | Banner height in dp/pt |
| `cornerRadius` | `$foundations/spacing.cornerRadius.medium` | Maps to `XGCornerRadius.Medium` / `XGCornerRadius.medium` |
| `background` | `$foundations/colors.flashSale.background` | Maps to `XGColors.FlashSaleBackground` / `XGColors.flashSaleBackground` |
| `textColor` | `$foundations/colors.flashSale.text` | Maps to `XGColors.FlashSaleText` / `XGColors.flashSaleText` |
| `badgeLabel.font` | `$foundations/typography.typeScale.bodySemiBold` | Maps to `XGTypography.bodySemiBold` |
| `title.font` | `$foundations/typography.typeScale.title` | Maps to `XGTypography.title` |
| `title.maxLines` | 2 | |
| `title.textAlignment` | center | |
| `accentStripeLeft.color` | `$foundations/colors.flashSale.accentBlue` | Maps to `XGColors.FlashSaleAccentBlue` / `XGColors.flashSaleAccentBlue` |
| `accentStripeRight.color` | `$foundations/colors.flashSale.accentPink` | Maps to `XGColors.FlashSaleAccentPink` / `XGColors.flashSaleAccentPink` |

## Changes Required

### Android (`XGFlashSaleBanner.kt`)

1. **Remove hardcoded font references**: Replace inline `fontFamily = PoppinsFontFamily, fontSize = BadgeFontSize, fontWeight = FontWeight.Bold` with `style = XGTypography.bodySemiBold` for the badge and `style = XGTypography.title` for the title.
2. **Remove unused font size constants**: `BadgeFontSize`, `TitleFontSize`, `TitleLineHeight` become unnecessary once `XGTypography` tokens are used.
3. **XGImage already provides shimmer**: The `XGImage` composable from DQ-07 includes `.shimmerEffect()` in its loading slot. No additional shimmer code needed — just ensure `XGImage` is used (already the case).
4. **Add maxLines + textAlign to title**: Align with token spec `maxLines = 2, textAlign = TextAlign.Center`.
5. **Remove `import PoppinsFontFamily`** if no longer needed after switching to `XGTypography`.

### iOS (`XGFlashSaleBanner.swift`)

1. **XGImage shimmer inherited**: iOS `XGImage` already uses `.shimmerEffect()` in its loading state. The banner currently does NOT use `XGImage` for the background image — if `imageUrl` is provided, it should render via `XGImage` to get shimmer automatically.
2. **Typography tokens**: Already using `XGTypography.bodySemiBold` and `XGTypography.title` — verify these are correct.
3. **Ensure `imageUrl` is rendered via `XGImage`**: Add an `XGImage` layer in the ZStack when `imageUrl` is non-nil, behind the stripes and text.

### Cross-Platform Consistency

- Both platforms use the same token values.
- Both get shimmer via `XGImage` (no manual shimmer code in the banner).
- Banner height = 133, cornerRadius = medium, same stripe geometry.

## Out of Scope

- No new API integration (banner content comes from feature-level code).
- No new localization keys (existing `home_flash_sale_badge` key is reused).
- No domain/data layer changes.
