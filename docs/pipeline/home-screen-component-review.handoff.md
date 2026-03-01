# Review: Home Screen Design System Components -- Cross-Platform

## Status: CHANGES REQUESTED

## Summary

Cross-platform review of all design system components rebuilt for the Home Screen feature.
Token values (font sizes, padding, colors, gradients) are mostly correct and match `shared/design-tokens/components.json`. However, there are several cross-platform behavioral inconsistencies that must be resolved, plus a few token mismatches and design system rule violations.

## Files Reviewed

### Android (15 files)
- `android/.../core/designsystem/component/XGPriceText.kt`
- `android/.../core/designsystem/component/XGPriceSize.kt`
- `android/.../core/designsystem/component/XGCard.kt`
- `android/.../core/designsystem/component/XGRatingBar.kt`
- `android/.../core/designsystem/component/XGHeroBanner.kt`
- `android/.../core/designsystem/component/XGDailyDealCard.kt`
- `android/.../core/designsystem/component/XGFlashSaleBanner.kt`
- `android/.../core/designsystem/component/XGCategoryIcon.kt`
- `android/.../core/designsystem/component/XGSectionHeader.kt`
- `android/.../core/designsystem/component/XGWishlistButton.kt`
- `android/.../core/designsystem/component/XGBadge.kt`
- `android/.../core/designsystem/theme/XGColors.kt`
- `android/.../core/designsystem/theme/XGSpacing.kt`
- `android/.../core/designsystem/theme/XGTypography.kt`
- `android/.../feature/home/presentation/screen/HomeScreen.kt`

### iOS (14 files)
- `ios/.../Core/DesignSystem/Component/XGPriceText.swift`
- `ios/.../Core/DesignSystem/Component/XGCard.swift`
- `ios/.../Core/DesignSystem/Component/XGRatingBar.swift`
- `ios/.../Core/DesignSystem/Component/XGHeroBanner.swift`
- `ios/.../Core/DesignSystem/Component/XGDailyDealCard.swift`
- `ios/.../Core/DesignSystem/Component/XGFlashSaleBanner.swift`
- `ios/.../Core/DesignSystem/Component/XGCategoryIcon.swift`
- `ios/.../Core/DesignSystem/Component/XGSectionHeader.swift`
- `ios/.../Core/DesignSystem/Component/XGWishlistButton.swift`
- `ios/.../Core/DesignSystem/Component/XGBadge.swift`
- `ios/.../Core/DesignSystem/Theme/XGColors.swift`
- `ios/.../Core/DesignSystem/Theme/XGSpacing.swift`
- `ios/.../Core/DesignSystem/Theme/XGTypography.swift`
- `ios/.../Feature/Home/Presentation/Screen/HomeScreenSections.swift`

---

## Issues Found

### Critical

1. **[iOS XGPriceText.swift:121-123] Price color logic differs from Android -- breaks visual consistency**
   iOS conditionally uses `XGColors.priceRegular` (#333333) when `originalPrice` is nil, while Android always uses the style-specific color (`PriceSale` = #6000FE for default/small, `BrandSecondary` = #94D63A for deal). This means a product with no sale shows purple price on Android and dark gray on iOS.
   - Fix: Align iOS with Android behavior -- always use `style.color` regardless of `hasSale`. The `priceRegular` fallback color should only apply when explicitly requested (e.g., a future `.regular` style variant), not as a conditional override.
   - Assign: ios-dev

2. **[iOS XGDailyDealCard.swift:69] Strikethrough font size mismatch: 14pt vs spec 15.18pt**
   `Constants.strikethroughFontSize` is `14` on iOS. The spec in `components.json > XGPriceText.strikethrough.fontSize` is `15.18`. Android XGDailyDealCard.kt uses the correct `15.18.sp` (line 51).
   - Fix: Change `static let strikethroughFontSize: CGFloat = 14` to `static let strikethroughFontSize: CGFloat = 15.18`
   - Assign: ios-dev

3. **[Cross-platform XGFlashSaleBanner] Title font size inconsistency: Android 24sp vs iOS 20pt**
   Android XGFlashSaleBanner.kt line 85: `fontSize = 24.sp`. iOS XGFlashSaleBanner.swift line 43: `Constants.titleFontSize = 20`. The flash sale card has no explicit font spec in `components.json` so both platforms should use the same size.
   - Fix: Align both platforms on one value. The flash sale is a large promotional banner so 24sp/pt (matching Android and `typeScale.headline`) is the better choice. Update iOS `titleFontSize` to `24`.
   - Assign: ios-dev

4. **[Cross-platform XGFlashSaleBanner] Badge font size inconsistency: iOS 14pt vs Android has no separate badge**
   iOS has a separate badge text at `Constants.badgeFontSize = 14`, while Android only shows the title text with no badge split. The iOS implementation renders both a "Flash Sale" badge text and a subtitle, while Android renders a single title.
   - Fix: Align the structure. If the banner shows a badge + subtitle, both platforms should. If it shows a single title, both platforms should. Recommend making both consistent with iOS structure (badge 14pt + title 20-24pt) since it matches the design intent, but use 12pt semiBold for the badge to match `components.json > XGBadge.secondary`.
   - Assign: android-dev, ios-dev

5. **[Android HomeScreen.kt:167-186] Raw MaterialTheme usage in feature screen**
   The `SearchBarSection` composable uses `MaterialTheme.colorScheme.surfaceVariant`, `MaterialTheme.colorScheme.onSurfaceVariant`, and `MaterialTheme.typography.bodyLarge` directly, violating the design system rule: "Feature screens use XG* design system components exclusively / No raw MaterialTheme".
   - Fix: Replace `MaterialTheme.colorScheme.surfaceVariant` with `XGColors.SurfaceVariant`, `MaterialTheme.colorScheme.onSurfaceVariant` with `XGColors.OnSurfaceVariant`, and `MaterialTheme.typography.bodyLarge` with a `TextStyle` using `PoppinsFontFamily` at 16.sp.
   - Assign: android-dev

### Warning

6. **[Cross-platform XGProductCard] showValue inconsistency in XGRatingBar usage**
   Android XGCard.kt line 162: `showValue = false` (does not show numeric rating value). iOS XGCard.swift line 135: `showValue: true` (shows numeric rating value). Both should match.
   - Fix: Decide on one behavior and align. The SVG designs for product cards do not show the numeric rating value (only stars + review count), so `showValue = false` is likely correct. Update iOS XGCard.swift to pass `showValue: false`.
   - Assign: ios-dev

7. **[iOS XGRatingBar.swift:38,46] Review count text uses system font instead of Poppins**
   The review count and rating value Text views use `.font(.system(size: Constants.reviewCountFontSize))` while Android uses `PoppinsFontFamily`. The typography spec says all UI text uses Poppins. Note: the star icons correctly use `.system()` since they are SF Symbols, but the text labels should use Poppins.
   - Fix: Change to `.font(.custom("Poppins-Regular", size: Constants.reviewCountFontSize))` for both the rating value and review count text.
   - Assign: ios-dev

8. **[iOS XGCard.swift:175] Delivery badge text uses system font instead of Poppins**
   `deliveryBadge` uses `.font(.system(size: Constants.deliveryFontSize))` instead of Poppins. Android uses `PoppinsFontFamily` at the same size.
   - Fix: Change to `.font(.custom("Poppins-Regular", size: Constants.deliveryFontSize))`
   - Assign: ios-dev

9. **[iOS XGDailyDealCard.swift:92-100] Gradient uses XGColors.textDark instead of direct hex**
   The daily deal background gradient uses `XGColors.textDark` which maps to `#111827` -- this is correct color-wise, but the spec gradient is explicitly `#111827 -> #6000FE`. Using a named semantic token (`textDark`) for a gradient stop makes the intent less clear. On Android, the gradient uses direct Color literals (`Color(0xFF111827)` and `Color(0xFF6000FE)`).
   - Fix: Consider adding `XGColors.dailyDealGradientStart` and `XGColors.dailyDealGradientEnd` named tokens for clarity, or at minimum add a code comment documenting that `textDark` is used here because it maps to `#111827` which matches `gradients.json > dailyDealCard`.
   - Assign: ios-dev (low priority)

10. **[iOS XGTypography.swift] Typography values don't match design tokens**
    The iOS `XGTypography` enum uses system font defaults (e.g., `displayLarge = Font.system(size: 57)`, `titleLarge = Font.system(size: 22)`) which are Material 3 defaults, not the XiriGo design token values. The Android `XGTypography` correctly maps to the design tokens (e.g., `displayLarge = 28sp bold`, `titleLarge = 20sp semiBold`). Since the iOS components all use inline `.custom("Poppins-...", size:)` this doesn't currently cause visual bugs, but the shared `XGTypography` enum is wrong as a reference.
    - Fix: Update iOS `XGTypography` to match the design token values, using Poppins custom font references instead of `.system()` defaults.
    - Assign: ios-dev

11. **[iOS HomeScreenSections.swift:44] Search bar uses `.ultraThinMaterial` background**
    The iOS search bar uses `.background(.ultraThinMaterial)` and `RoundedRectangle(cornerRadius: XGCornerRadius.full)` (999pt). The Android search bar uses `surfaceVariant` color and `RoundedCornerShape(XGCornerRadius.Medium)` (10dp). The component spec (`components.json > XGTextField.search`) specifies `background: "$light.surface"` and `cornerRadius: 10`. Neither platform fully matches the spec, and they differ from each other.
    - Fix: Both should use `XGColors.surface` / `XGColors.Surface` as background and `XGCornerRadius.medium` / `XGCornerRadius.Medium` (10dp/10pt) as corner radius per spec.
    - Assign: android-dev, ios-dev

12. **[iOS XGCard.swift:165] Add-to-cart button uses `XGColors.brandSecondary` instead of `XGColors.addToCart`**
    The add-to-cart button background is `.background(XGColors.brandSecondary)`. While both map to the same hex (#94D63A), the semantic name `addToCart` from `colors.json > semantic.addToCart` should be used for intent clarity, matching Android which uses `XGColors.AddToCart`.
    - Fix: Change `.background(XGColors.brandSecondary)` to `.background(XGColors.addToCart)`.
    - Assign: ios-dev

### Info

13. **[iOS XGHeroBanner.swift:88] Fallback gradient uses brandPrimary + tertiary instead of XGBrandGradient**
    When `imageUrl` is nil, the iOS implementation creates an inline `LinearGradient(colors: [XGColors.brandPrimary, XGColors.tertiary])`, while Android calls `XGBrandGradient(modifier)` which uses the full multi-layer radial gradient from `gradients.json > brandHeader`. This is an acceptable simplification since the overlay gradient will cover most of it, but the visual fidelity is slightly lower on iOS.

14. **[Both platforms] Previews are present and wrapped in XGTheme (Android) or use #Preview (iOS)**
    All components have appropriate preview functions. Android previews are consistently wrapped in `XGTheme {}`. iOS previews use `#Preview` blocks. This matches the project standard.

15. **[Both platforms] Accessibility labels present on all interactive elements**
    XGWishlistButton, XGProductCard, XGHeroBanner, XGDailyDealCard, XGFlashSaleBanner, XGSectionHeader, XGRatingBar, and XGCategoryIcon all have appropriate accessibility labels/descriptions on both platforms.

16. **[Both platforms] No "Featured" header on hero banner section, no "See All" on Popular Products, no welcome header**
    Verified correct. Android: HeroBannerSection has no section header, PopularProductsSection has XGSectionHeader without onSeeAllClick. iOS: heroBannerCarousel has no header, popularProductsSection has XGSectionHeader without onSeeAllAction. No welcome header exists on either platform.

---

## Spec Compliance Summary

### XGPriceText
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Default currency font | 22.78 | 22.78sp | 22.78pt | PASS |
| Default integer font | 27.33 | 27.33sp | 27.33pt | PASS |
| Default decimal font | 18.98 | 18.98sp | 18.98pt | PASS |
| Small currency font | 14 | 14sp | 14pt | PASS |
| Small integer font | 18 | 18sp | 18pt | PASS |
| Small decimal font | 14 | 14sp | 14pt | PASS |
| Font family | Source Sans 3 Black | SourceSans3FontFamily Black | SourceSans3-Black | PASS |
| Default color | $semantic.priceDiscount (#6000FE) | PriceSale (#6000FE) | priceSale (#6000FE) / priceRegular (conditional) | FAIL (iOS) |
| Strikethrough font | 15.18 Poppins Medium | 15.18sp Poppins Medium | 15.18pt Poppins-Medium | PASS |
| Strikethrough color | #8E8E93 | PriceStrikethrough (#8E8E93) | priceStrikethrough (#8E8E93) | PASS |

### XGCard (Product)
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Corner radius | 10 | 10dp | medium (10pt) | PASS |
| Border width | 1 | 1dp | 1pt | PASS |
| Border color | $light.borderSubtle (#F0F0F0) | OutlineVariant | outlineVariant | PASS |
| Padding | 8 | 8dp | 8pt | PASS |
| Image aspect ratio | 1:1 | aspectRatio(1f) | aspectRatio(1.0) | PASS |
| Title font size | 12 semiBold | 12sp SemiBold | 12pt Poppins-SemiBold | PASS |
| Title max lines | 2 | 2 | 2 | PASS |
| Elevation | 0 | 0dp | N/A (border-based) | PASS |

### XGStarRating (XGRatingBar)
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Star size | 12 | 12dp | 12pt | PASS |
| Star gap | 2 | 2dp | 2pt | PASS |
| Count | 5 | 5 | 5 | PASS |
| Review count font | 12 | 12sp Poppins | 12pt .system | WARN (iOS font) |
| Review count spacing | 4 | 4dp | 4pt | PASS |
| Active color | #6000FE | RatingStarFilled (#6000FE) | ratingStarFilled (#6000FE) | PASS |
| Inactive color | #8E8E93 | RatingStarEmpty (#8E8E93) | ratingStarEmpty (#8E8E93) | PASS |

### XGHeroBanner
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Height | 192 | 192dp | 192pt | PASS |
| Corner radius | 10 | 10dp | medium (10pt) | PASS |
| Tag font | 12 semiBold | 12sp SemiBold | 12pt Poppins-SemiBold | PASS |
| Headline font | 24 semiBold | 24sp SemiBold | 24pt Poppins-SemiBold | PASS |
| Subtitle font | 14 | 14sp | 14pt Poppins-Regular | PASS |
| Badge padding H | 10 | 10dp | 10pt | PASS |
| Badge padding V | 4 | 4dp | 4pt | PASS |
| Gradient overlay | 0.90 opacity LTR | 0xE6 (90%) -> 0x00 | 0.90 -> 0 | PASS |

### XGDailyDealCard
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Height | 163 | 163dp | 163pt | PASS |
| Gradient | #111827 -> #6000FE | Correct | Correct (via textDark + brandPrimary) | PASS |
| Badge text | "DAILY DEAL" | localized string | localized string | PASS |
| Badge bg | $brand.secondary (#94D63A) | BadgeSecondaryBackground | brandSecondary | PASS |
| Title font | 20 semiBold | 20sp SemiBold | 20pt Poppins-SemiBold | PASS |
| Price style | deal (Source Sans 3 Black, #94D63A) | Deal | .deal | PASS |
| Strikethrough | 15.18 | 15.18sp | 14pt | FAIL (iOS) |
| Corner radius | 10 | 10dp | medium (10pt) | PASS |
| Padding | 16 | 16dp | 16pt | PASS |

### XGFlashSaleBanner
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Height | 133 | 133dp | 133pt | PASS |
| Background | #FFD814 | FlashSaleBackground | flashSaleBackground | PASS |
| Left stripe | #9EBDF4 | FlashSaleAccentBlue | flashSaleAccentBlue | PASS |
| Right stripe | #F60186 | FlashSaleAccentPink | flashSaleAccentPink | PASS |
| Text color | #1D1D1B | FlashSaleText | flashSaleText | PASS |
| Font | Poppins-Bold | PoppinsFontFamily Bold | Poppins-Bold | PASS |
| Title font size | N/A (not spec'd) | 24sp | 20pt | WARN (cross-platform) |

### XGCategoryIcon
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Tile size | 79 | 79dp | 79pt | PASS |
| Corner radius | 10 | 10dp | medium (10pt) | PASS |
| Icon size | 40 | 40dp | 40pt | PASS |
| Label font | 12 medium | 12sp Medium Poppins | 12pt Poppins-Medium | PASS |
| Label spacing | 6 | 6dp | 6pt | PASS |

### XGSectionHeader
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Title font | 18 semiBold | 18sp SemiBold Poppins | 18pt Poppins-SemiBold | PASS |
| See All font | 14 medium | 14sp Medium Poppins | 14pt Poppins-Medium | PASS |
| See All color | brand primary | BrandPrimary (#6000FE) | brandPrimary (#6000FE) | PASS |

### XGWishlistButton
| Spec Property | Expected | Android | iOS | Status |
|---|---|---|---|---|
| Size | 32 | 32dp | 32pt | PASS |
| Icon size | 16 | 16dp | 16pt | PASS |
| Corner radius | 16 (circle) | 16dp RoundedCorner | Circle | PASS |
| Background | $light.surface (#FFFFFF) | Surface (#FFFFFF) | surface (#FFFFFF) | PASS |
| Active icon color | #6000FE | BrandPrimary | brandPrimary | PASS |
| Inactive icon color | #8E8E93 | OnSurfaceVariant | onSurfaceVariant | PASS |
| Elevation | 2 | 2dp shadow | level2 | PASS |

### HomeScreen Layout Verification
| Check | Android | iOS | Status |
|---|---|---|---|
| No "Featured" header on hero | Correct | Correct | PASS |
| No "See All" on Popular Products | Correct | Correct | PASS |
| No welcome header | Correct | Correct | PASS |
| "See All" on New Arrivals | Present | Present | PASS |
| Hero banner auto-scroll | 5s delay | 5s timer | PASS |
| Pagination dots below hero | Present | Present | PASS |
| Pull-to-refresh | PullToRefreshBox | .refreshable | PASS |
| Loading/Error/Success states | All present | All present | PASS |

---

## Metrics
- Android files reviewed: 15
- iOS files reviewed: 14
- Critical issues: 5
- Warning issues: 7
- Info issues: 4

---

## Action Required

Critical issues 1-5 and Warning issues 6-8, 11 must be resolved before merge. These affect visual consistency between platforms and violate the project's design system rules. Issues 9-10, 12 are lower priority and can be addressed in a follow-up.

### Assignments
- **ios-dev**: Issues 1, 2, 3 (partial), 4 (partial), 6, 7, 8, 9, 10, 11 (partial), 12
- **android-dev**: Issues 4 (partial), 5, 11 (partial)
