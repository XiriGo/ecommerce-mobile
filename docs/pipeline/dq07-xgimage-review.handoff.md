# Review: DQ-07 XGImage Upgrade (Shimmer + Motion Tokens + Error Fallback)

## Status: CHANGES REQUESTED

## Summary

The XGImage upgrade correctly migrates both platforms from static loading placeholders to animated shimmer effects, adds branded error fallback states, and replaces hardcoded crossfade durations with XGMotion tokens. However, a critical cross-platform color mismatch in iOS `XGColors.surfaceVariant` means the error fallback is visually identical to the loading state on iOS, and both platforms differ in null-URL behavior. Two critical and three warning issues must be resolved before merge.

## Files Reviewed

### Android
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGImage.kt`
- `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGImageTest.kt`
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/ShimmerModifier.kt` (dependency, not modified)
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGMotion.kt` (dependency, not modified)
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGColors.kt` (dependency, not modified)

### iOS
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGImage.swift`
- `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGImageTests.swift`
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/ShimmerModifier.swift` (dependency, not modified)
- `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGMotion.swift` (dependency, not modified)
- `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGColors.swift` (dependency, root cause of C-01)

### Design Tokens
- `shared/design-tokens/foundations/colors.json`
- `shared/design-tokens/foundations/motion.json`
- `shared/design-tokens/foundations/spacing.json`
- `shared/design-tokens/components/atoms/xg-image.json`

## Issues Found

### Critical

- **[C-01]** `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGColors.swift:33` — iOS `surfaceVariant` is `#F1F5F9` (maps to `light.surfaceTertiary`) but the design token `light.surfaceSecondary` is `#F9FAFB`, which is what Android uses (`XGColors.SurfaceVariant = Color(0xFFF9FAFB)`). This causes two problems:
  1. **Cross-platform inconsistency**: Error fallback background is `#F1F5F9` on iOS but `#F9FAFB` on Android.
  2. **Indistinguishable states on iOS**: Loading state uses `XGColors.shimmer` (`#F1F5F9`) and error state uses `XGColors.surfaceVariant` (`#F1F5F9`) -- they are the same hex value, making loading and error visually identical on iOS. The entire purpose of DQ-07 (distinct loading vs error) is defeated on iOS.
  - Fix: Change `XGColors.surfaceVariant` from `Color(hex: "#F1F5F9")` to `Color(hex: "#F9FAFB")` to match `light.surfaceSecondary` in `colors.json` and align with Android.
  - Assign: **ios-dev**
  - Note: This is a pre-existing bug in `XGColors.swift` (not introduced by DQ-07), but it directly undermines DQ-07's error fallback feature and must be fixed in this PR.

- **[C-02]** `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGImage.swift:60-65` vs `android/.../XGImage.kt:86-98` — **Cross-platform behavioral inconsistency for null URL**. When `url` is nil/null:
  - **Android**: Renders shimmer background + centered `Icons.Outlined.Image` icon (lines 86-98).
  - **iOS**: `AsyncImage(url: nil)` enters `.empty` phase, which renders `loadingView` -- shimmer only, NO icon (lines 60-65).
  The user sees different UI on each platform for the same null-URL state. Since the Android behavior (shimmer + icon) visually communicates "no image available" more clearly than shimmer alone, both platforms should align.
  - Fix: Either (a) add the photo icon to iOS `loadingView` to match Android's null-URL branch, or (b) remove the icon from Android's null-URL branch and treat null URL as a pure loading indicator on both platforms. Option (a) is recommended for consistency with the existing Android behavior.
  - Assign: **ios-dev** (if option a) or **android-dev** (if option b)

### Warning

- **[W-01]** `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGImage.kt:86-98` — The null-URL branch on Android does not set accessibility semantics for the loading/shimmer state. iOS correctly uses `.accessibilityHidden(true)` on `loadingView` (line 64). The Android null-URL Box should be marked with `Modifier.semantics { }` to clear or hide the loading placeholder from screen readers, similar to how the `loading` slot (line 58-65) naturally has no content description.
  - Fix: Add `Modifier.clearAndSetSemantics { }` to the outer Box in the null-URL branch (line 86), or ensure the shimmer placeholder is not announced by TalkBack.
  - Assign: **android-dev**

- **[W-02]** `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGImage.swift:73` — Uses `.font(.system(size: XGSpacing.IconSize.large))` for the error icon. Per FAANG rules (`docs/standards/faang-rules.md` line 81): "never use Font.system(...)". While this is for a system SF Symbol icon (not body text), it still uses raw `.system(size:)` instead of a design system typography token. The icon size (27pt) correctly references `XGSpacing.IconSize.large`, which is the appropriate token, but the font API usage is technically non-compliant.
  - Fix: Since this is an SF Symbol rendered via `Image(systemName:)`, the `.font(.system(size:))` usage is the standard SwiftUI pattern for icon sizing and is acceptable in `core/designsystem/` components. Mark as acknowledged exception. No code change required unless a dedicated `XGTypography.iconSize` token is added.
  - Assign: N/A (acknowledged)

- **[W-03]** `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGImageTests.swift:134-153` — The `errorIconOpacity` tests do not actually test the private property on `XGImage`. They create local variables set to `0.5` and assert against themselves (`let errorIconOpacity = 0.5; #expect(errorIconOpacity == 0.5)`). These tests will always pass regardless of what the actual `XGImage.errorIconOpacity` value is. They provide false confidence.
  - Fix: Either (a) make `errorIconOpacity` internal (not private) and test it directly, or (b) remove these "tests" since they don't verify anything, or (c) test via ViewInspector if the opacity is actually applied. At minimum, add a comment acknowledging this is a documentation-only assertion.
  - Assign: **ios-test**

### Info

- **[I-01]** `shared/design-tokens/components/atoms/xg-image.json:16` — The component spec lists `"fadeAnimation": "easeInOut(duration: 0.25)"` (250ms) but `motion.json` defines `crossfade.imageFadeIn: 300`. Both platforms correctly use the motion.json value (300ms). The component spec should be updated to reference the motion token instead of hardcoding the duration.
  - Fix: Update xg-image.json `fadeAnimation` to `"$foundations/motion.crossfade.imageFadeIn"`.

- **[I-02]** `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGImage.swift:97` — The "XGImage with URL" preview actually passes `url: nil`, so it shows the same thing as the "XGImage Loading" preview. This is misleading -- the preview name suggests it shows an image loaded from a URL.
  - Fix: Use a valid URL string or rename the preview to "XGImage with Label" to accurately describe what it demonstrates.

- **[I-03]** Android test file uses `composeTestRule` instrumented tests (androidTest) which is appropriate for UI verification. iOS tests use Swift Testing `@Test` macro with unit-level assertions. Both test suites are well-structured with good token contract verification. Android has 16 tests, iOS has 33 tests across 6 suites -- adequate coverage for a design system atom component.

## Design Token Verification Results

### Colors (XGImage-relevant tokens)
| Token | JSON Value | Android | iOS | Status |
|-------|-----------|---------|-----|--------|
| `semantic.shimmer` | `#F1F5F9` | `XGColors.Shimmer = 0xFFF1F5F9` | `XGColors.shimmer = "#F1F5F9"` | MATCH |
| `light.surfaceSecondary` | `#F9FAFB` | `XGColors.SurfaceVariant = 0xFFF9FAFB` | `XGColors.surfaceVariant = "#F1F5F9"` | **MISMATCH (C-01)** |
| `light.textSecondary` | `#8E8E93` | `XGColors.OnSurfaceVariant = 0xFF8E8E93` | `XGColors.onSurfaceVariant = "#8E8E93"` | MATCH |

### Motion Tokens (XGImage-relevant)
| Token | JSON Value | Android | iOS | Status |
|-------|-----------|---------|-----|--------|
| `crossfade.imageFadeIn` | `300` ms | `XGMotion.Crossfade.IMAGE_FADE_IN = 300` | `XGMotion.Crossfade.imageFadeIn = 0.3` | MATCH |
| `shimmer.durationMs` | `1200` ms | `XGMotion.Shimmer.DURATION_MS = 1200` | `XGMotion.Shimmer.duration = 1.2` | MATCH |
| `shimmer.angleDegrees` | `20` | `XGMotion.Shimmer.ANGLE_DEGREES = 20` | `XGMotion.Shimmer.angleDegrees = 20` | MATCH |
| `shimmer.gradientColors` | `["#E0E0E0","#F5F5F5","#E0E0E0"]` | `[0xFFE0E0E0, 0xFFF5F5F5, 0xFFE0E0E0]` | `["#E0E0E0","#F5F5F5","#E0E0E0"]` | MATCH |

### Spacing Tokens
| Token | JSON Value | Android | iOS | Status |
|-------|-----------|---------|-----|--------|
| `layout.iconSize.large` | `27` | `PlaceholderIconSize = 27.dp` | `XGSpacing.IconSize.large = 27` | MATCH |

### Hardcoded Visual Value Scan
- `Color(hex:` in XGImage.swift: **0 instances** (clean)
- `Color(0xFF` in XGImage.kt: **0 instances** (clean)
- `.system(size:` in XGImage.swift: **1 instance** (line 73, for SF Symbol sizing -- see W-02)
- Hardcoded dp/pt literals in component bodies: **0 instances** (clean -- all extracted to named constants)

## Checklist Results

| Check | Android | iOS | Notes |
|-------|---------|-----|-------|
| Shimmer on loading state | PASS | PASS | Both use `.shimmerEffect()` |
| Branded error fallback distinct from loading | PASS | **FAIL** | iOS uses same color (#F1F5F9) for both (C-01) |
| XGMotion tokens used (no hardcoded values) | PASS | PASS | Both reference `XGMotion.Crossfade.imageFadeIn` |
| No force unwrap / no Any type | PASS | PASS | Clean |
| Accessibility (loading hidden, error hidden) | **PARTIAL** | PASS | Android null-URL branch missing accessibility (W-01) |
| Cross-platform consistency | **FAIL** | **FAIL** | Color mismatch (C-01), null-URL behavior mismatch (C-02) |
| Test coverage adequate | PASS | **PARTIAL** | iOS errorIconOpacity tests are no-ops (W-03) |
| Error preview added | PASS | PASS | Both platforms have error preview |
| No hardcoded colors in component | PASS | PASS | All use XGColors tokens |
| Previews wrapped in theme | PASS | PASS | XGTheme / .xgTheme() applied |

## Metrics

- Android source files reviewed: 2 (XGImage.kt, XGImageTest.kt) + 3 dependencies
- iOS source files reviewed: 2 (XGImage.swift, XGImageTests.swift) + 3 dependencies
- Design token files verified: 4 (colors.json, motion.json, spacing.json, xg-image.json)
- Critical issues: 2
- Warning issues: 3
- Info issues: 3

## Required Actions Before Re-review

1. **ios-dev**: Fix `XGColors.surfaceVariant` from `#F1F5F9` to `#F9FAFB` (C-01)
2. **ios-dev** or **android-dev**: Align null-URL behavior across platforms (C-02)
3. **android-dev**: Add accessibility semantics to null-URL branch (W-01) -- can be done in follow-up
4. **ios-test**: Fix or remove no-op errorIconOpacity tests (W-03) -- can be done in follow-up

Items W-01, W-03 can be deferred to a follow-up PR if C-01 and C-02 are resolved.
