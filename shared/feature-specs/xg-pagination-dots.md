# DQ-09: XGPaginationDots Motion Token Upgrade -- Feature Specification

## 1. Overview

This specification describes the upgrade of the `XGPaginationDots` atom component to use
centralized `XGMotion` tokens for all animation behavior, replacing any remaining hardcoded
animation values.

### Purpose

- Replace the hardcoded `tween(300ms)` animation on Android with `XGMotion.Easing.springSpec()`
- Verify iOS already uses `XGMotion.Easing.spring` (no code change expected)
- Update the component token JSON to reference the foundation motion token
- Ensure cross-platform animation parity (both use spring-based animation)

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Android: Replace `tween` with `XGMotion.Easing.springSpec()` | Size token changes (already correct) |
| iOS: Verify compliance | Color token changes (already correct) |
| Update `xg-pagination-dots.json` animation reference | New component features |
| Verify existing tests still pass | Additional test coverage beyond regression |

### Dependencies

- **DQ-01** (XGMotion Android) -- MERGED
- **DQ-02** (XGMotion iOS) -- MERGED

---

## 2. Current State

### 2.1 Android (`XGPaginationDots.kt`)

The Android component uses a hardcoded `tween` animation:

```kotlin
private const val ANIMATION_DURATION_MS = 300

val animatedWidth by animateDpAsState(
    targetValue = if (isActive) ActiveDotWidth else InactiveDotWidth,
    animationSpec = tween(durationMillis = ANIMATION_DURATION_MS),
    label = "dotWidth$index",
)
```

**Issue**: Uses `tween(300ms)` instead of `XGMotion.Easing.springSpec()`. The token file
specifies a spring animation, and the iOS implementation already uses the spring token.

### 2.2 iOS (`XGPaginationDots.swift`)

The iOS component already uses the motion token:

```swift
.animation(XGMotion.Easing.spring, value: currentPage)
```

**Status**: Compliant. No changes needed.

### 2.3 Token File (`xg-pagination-dots.json`)

Current animation field:
```json
"animation": "spring(response: 0.3, dampingFraction: 0.7)"
```

**Issue**: Hardcoded spring parameters instead of referencing `$foundations/motion.easing.spring`.

---

## 3. Required Changes

### 3.1 Android (`XGPaginationDots.kt`)

1. Add import for `XGMotion`:
   ```kotlin
   import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
   ```

2. Remove unused imports:
   - `import androidx.compose.animation.core.tween`

3. Remove hardcoded constant:
   - Delete `private const val ANIMATION_DURATION_MS = 300`

4. Replace animation spec:
   ```kotlin
   // Before:
   animationSpec = tween(durationMillis = ANIMATION_DURATION_MS),

   // After:
   animationSpec = XGMotion.Easing.springSpec(),
   ```

### 3.2 iOS (`XGPaginationDots.swift`)

No changes required. Already compliant.

### 3.3 Token File (`xg-pagination-dots.json`)

Update the animation field to reference the foundation token:
```json
"animation": "$foundations/motion.easing.spring"
```

---

## 4. Size Token Verification

All size tokens match between the JSON spec and both platform implementations:

| Token | JSON Value | Android | iOS |
|-------|-----------|---------|-----|
| `activeWidth` | 18 | `18.dp` | `18` (CGFloat) |
| `inactiveWidth` | 6 | `6.dp` | `6` (CGFloat) |
| `height` | 6 | `6.dp` | `6` (CGFloat) |
| `cornerRadius` | 3 | `3.dp` | `3` (CGFloat) |
| `gap` | 4 | `4.dp` | `4` (CGFloat) |

---

## 5. Verification Criteria

- [ ] Android `XGPaginationDots` uses `XGMotion.Easing.springSpec()` for dot width animation
- [ ] Android has no remaining hardcoded `tween` or `ANIMATION_DURATION_MS` references
- [ ] iOS `XGPaginationDots` uses `XGMotion.Easing.spring` (unchanged, already compliant)
- [ ] `xg-pagination-dots.json` animation field references `$foundations/motion.easing.spring`
- [ ] All existing tests pass on both platforms
- [ ] Both platforms produce visually identical spring animation behavior
- [ ] No force unwrap (`!!`/`!`) in either implementation
- [ ] Preview composables/views render without errors

---

## 6. File Manifest

| File | Change Type | Platform |
|------|------------|----------|
| `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGPaginationDots.kt` | Modify | Android |
| `shared/design-tokens/components/atoms/xg-pagination-dots.json` | Modify | Shared |
| `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGPaginationDots.swift` | No change | iOS |
