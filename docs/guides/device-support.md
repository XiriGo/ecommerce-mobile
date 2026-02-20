# Device Support Guide

**Scope**: Molt Marketplace Mobile Buyer App — Android + iOS
**Last Updated**: 2026-02-20

This guide covers how the Molt Marketplace mobile app handles device variability across screen sizes, orientations, system settings, and platform capabilities. It is an infrastructure reference for developers implementing any feature.

---

## 1. Phone-First Approach

Molt Marketplace is a mobile buyer app. Every interaction — browsing product grids, reading product details, managing a cart, completing checkout — maps naturally to a single-hand phone experience.

**Why phone-first:**

- E-commerce checkout flows are inherently vertical-scrolling sequences (address, payment, confirmation). Horizontal or multi-column layouts add complexity without benefit.
- The primary buyer audience uses phones. Tablet usage in mobile e-commerce is a small fraction of sessions.
- Native phone layouts (full-width lists, bottom sheets, tab bars) feel familiar and reduce friction at checkout.
- Keeping a single column of responsibility per screen reduces layout branching in feature code.

**How to apply it:**

Design each screen for a phone-width canvas first (320dp–390dp / 375pt–390pt). Use `MoltSpacing` constants for all padding and gaps. Let the grid column count adapt to wider screens as a secondary concern — the core information hierarchy never changes.

---

## 2. Portrait-Only Orientation Lock

All screens in the app are locked to portrait orientation. Landscape mode is not supported.

**Rationale:** Product image galleries, price/description sections, and checkout forms are all designed for vertical scrolling. Forcing landscape on any of these creates either excessive whitespace or content truncation. Locking to portrait eliminates the need to maintain two layout variants per screen.

### Android

Add `android:screenOrientation="portrait"` to `MainActivity` in `AndroidManifest.xml`:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.MoltMarketplace.Splash">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>
```

File: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/AndroidManifest.xml`

### iOS

Set `UISupportedInterfaceOrientations` in `Info.plist` to include only `UIInterfaceOrientationPortrait`:

```xml
<!-- ios/MoltMarketplace/Resources/Info.plist -->
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

File: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Resources/Info.plist`

Note: Do not include `UIInterfaceOrientationPortraitUpsideDown`. It is disabled by default on iPhone (iOS 16+) and should stay absent.

---

## 3. Screen Size Adaptation

Although the app is phone-first and portrait-only, layouts must adapt gracefully to the range of phone screen widths — from a compact iPhone SE to a large Android device.

The main adaptation point is the **product grid column count**. All other layouts (detail screens, cart, checkout) use full-width single-column stacks.

### Column Count by Width Class

| Width Class | Android (`WindowWidthSizeClass`) | iOS (`horizontalSizeClass`) | Grid Columns |
|-------------|----------------------------------|------------------------------|--------------|
| Compact | `< 600dp` | `.compact` (phone) | 2 |
| Medium | `600dp – 840dp` | `.regular` (large phone landscape, iPad) | 3 |
| Expanded | `> 840dp` | `.regular` (iPad full-screen) | 4 |

Since the app is locked to portrait, only Compact applies on all current phones. Medium and Expanded are handled defensively for future-proofing or accidental tablet side-loading.

### Android — Adaptive Layout

Use `WindowWidthSizeClass` from the Material 3 adaptive library:

```kotlin
import androidx.compose.material3.adaptive.currentWindowAdaptiveInfo
import androidx.window.core.layout.WindowWidthSizeClass

@Composable
fun productGridColumns(): Int {
    val windowInfo = currentWindowAdaptiveInfo()
    return when (windowInfo.windowSizeClass.windowWidthSizeClass) {
        WindowWidthSizeClass.COMPACT -> 2
        WindowWidthSizeClass.MEDIUM -> 3
        WindowWidthSizeClass.EXPANDED -> 4
        else -> 2
    }
}
```

Dependency required (add to `libs.versions.toml` and `build.gradle.kts`):

```toml
# gradle/libs.versions.toml
[libraries]
androidx-adaptive = { group = "androidx.compose.material3.adaptive", name = "adaptive", version.ref = "adaptiveVersion" }
```

### iOS — Adaptive Layout

Use the `horizontalSizeClass` environment value:

```swift
import SwiftUI

struct ProductGridView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columnCount: Int {
        switch horizontalSizeClass {
        case .compact: return 2
        case .regular: return 3
        default: return 2
        }
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: columnCount),
            spacing: MoltSpacing.productGridSpacing
        ) {
            // product items
        }
    }
}
```

`MoltSpacing.productGridColumns` (value: `2`) is defined in `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltSpacing.swift` as a convenience constant for the default compact case.

---

## 4. Safe Area and Notch Handling

The app renders edge-to-edge on both platforms. Screen content must never be obscured by notches, Dynamic Island, rounded corners, the status bar, navigation bar, or home indicator.

### Android

`MainActivity` calls `enableEdgeToEdge()` on startup, which makes the app draw behind the status bar and navigation bar:

```kotlin
// android/app/src/main/java/com/molt/marketplace/MainActivity.kt
override fun onCreate(savedInstanceState: Bundle?) {
    installSplashScreen()
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()  // <-- enables edge-to-edge rendering
    setContent { MoltTheme { /* ... */ } }
}
```

File: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/MainActivity.kt`

Apply insets to Compose layouts using `Modifier.windowInsetsPadding()` or the convenience variants:

```kotlin
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.systemBars
import androidx.compose.foundation.layout.windowInsetsPadding

// Full-screen scaffold
Scaffold(
    modifier = Modifier.windowInsetsPadding(WindowInsets.systemBars)
) { paddingValues ->
    // content with correct padding
}

// Or use padding values from Scaffold directly
Scaffold { innerPadding ->
    LazyColumn(contentPadding = innerPadding) { /* ... */ }
}
```

Key inset types:

| Inset | Use Case |
|-------|----------|
| `WindowInsets.statusBars` | Top-of-screen content (custom top bars) |
| `WindowInsets.navigationBars` | Bottom-of-screen content (bottom sheets, FABs) |
| `WindowInsets.systemBars` | Both (most common — use in root Scaffold) |
| `WindowInsets.ime` | Keyboard avoidance for forms and text inputs |

### iOS

SwiftUI handles safe areas automatically. Views do not extend into unsafe areas unless explicitly opted in with `.ignoresSafeArea()`.

For content that must extend behind the navigation bar or tab bar (e.g., hero images):

```swift
// Extend image behind navigation bar, keep text in safe area
ScrollView {
    VStack {
        MoltImage(url: product.thumbnailURL)
            .frame(height: 300)
            .ignoresSafeArea(edges: .top)  // image bleeds behind navigation bar

        VStack(alignment: .leading, spacing: MoltSpacing.base) {
            Text(product.title)
            // ... safe area applies here automatically
        }
        .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
    }
}
```

Use `.safeAreaInset(edge:)` to add persistent content above the home indicator (e.g., an "Add to Cart" sticky button):

```swift
.safeAreaInset(edge: .bottom) {
    MoltButton("Add to Cart") { viewModel.addToCart() }
        .padding(MoltSpacing.base)
        .background(.regularMaterial)
}
```

---

## 5. Dynamic Type and Font Scaling

Both platforms must support user-configured font scaling. Text must remain readable and layouts must not break at large or extra-large text sizes.

### Android

Use `sp` (scale-independent pixels) for all text sizes. `MoltTypography.kt` defines all text styles using `sp` units, so `MaterialTheme.typography.*` already scales correctly.

Never hardcode `dp` for text sizes in feature screens. Always use a typography style from `MoltTheme`:

```kotlin
// Correct
Text(product.title, style = MaterialTheme.typography.titleMedium)

// Wrong — does not scale with user font size
Text(product.title, fontSize = 16.dp)
```

Test with the system Accessibility settings: set **Font size** to **Largest** (200% scale) and verify all text remains readable without clipping.

Useful modifier for wrapping text gracefully at large sizes:

```kotlin
Text(
    text = product.title,
    style = MaterialTheme.typography.bodyLarge,
    maxLines = 3,
    overflow = TextOverflow.Ellipsis,
)
```

### iOS

SwiftUI text elements respect Dynamic Type automatically when using system fonts or the `Font` styles from `MoltTypography.swift`.

Apply the `.dynamicTypeSize` modifier to limit scaling for UI-critical elements where layout would break at extreme sizes:

```swift
// Allow scaling up to xxxLarge only
Text(product.title)
    .font(MoltTypography.titleMedium)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
```

Test Dynamic Type in the iOS Simulator: **Settings > Accessibility > Display & Text Size > Larger Text**, or use the Xcode Accessibility Inspector to preview all type sizes without re-running the app.

### Design System Reference

Typography tokens are defined in:

- Android: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTypography.kt`
- iOS: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltTypography.swift`

Feature screens must never hardcode font sizes or weights. Use the design system tokens exclusively.

---

## 6. Dark Mode

Both platforms support system dark mode. No feature-level configuration is required — `MoltTheme` handles the switch automatically.

### Android

`MoltTheme` reads `isSystemInDarkTheme()` and applies either `MoltLightColorScheme` or `MoltDarkColorScheme`:

```kotlin
// android/.../core/designsystem/theme/MoltTheme.kt
@Composable
fun MoltTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) MoltDarkColorScheme else MoltLightColorScheme
    MaterialTheme(colorScheme = colorScheme, typography = MoltTypography, content = content)
}
```

File: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTheme.kt`

Feature screens use `MaterialTheme.colorScheme.*` — they never reference `MoltColors.*` directly. Only `core/designsystem/` files reference color constants.

### iOS

`MoltThemeModifier` passes the current `colorScheme` environment value through with `.preferredColorScheme()`. SwiftUI propagates the active color scheme to all child views automatically:

```swift
// ios/.../Core/DesignSystem/Theme/MoltTheme.swift
struct MoltThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    func body(content: Content) -> some View {
        content.preferredColorScheme(colorScheme)
    }
}
```

File: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltTheme.swift`

Use `.foregroundStyle(.primary)` and semantic color roles (`.background`, `.secondarySystemBackground`, etc.) rather than referencing `MoltColors` constants directly in feature screens.

### Testing Dark Mode

- **Android**: Toggle **Settings > Display > Dark theme** or use the Quick Settings tile. In Compose Preview, add `uiMode = UI_MODE_NIGHT_YES` to `@Preview`.
- **iOS**: Toggle **Settings > Display & Brightness > Dark** or use the Environment Overrides panel in Xcode at runtime.

Verify all `Molt*` components (buttons, cards, text fields, loading states, error states) display correctly in both schemes before shipping any screen.

---

## 7. Status Bar and Navigation Bar

### Android

`enableEdgeToEdge()` in `MainActivity` configures a transparent status bar and navigation bar. The system enforces icon color contrast automatically based on the background color beneath the bars.

```kotlin
// android/.../MainActivity.kt
enableEdgeToEdge()  // transparent bars, system handles icon tint
```

For screens that require an explicitly light or dark status bar (e.g., a screen with a dark hero image behind the status bar), use the `SystemBarStyle` overload:

```kotlin
enableEdgeToEdge(
    statusBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
    navigationBarStyle = SystemBarStyle.light(
        android.graphics.Color.TRANSPARENT,
        android.graphics.Color.TRANSPARENT,
    ),
)
```

Gesture navigation (Android 10+) requires the navigation bar to remain transparent — `enableEdgeToEdge()` handles this by default. Do not set a solid color on the navigation bar.

### iOS

SwiftUI manages status bar style automatically based on the content color scheme. No explicit configuration is needed in most cases.

Override the status bar appearance per-view when needed:

```swift
// Force light status bar content on a dark hero image
.preferredColorScheme(.dark)

// Or use the toolbar modifier for navigation bar appearance
.toolbarBackground(.hidden, for: .navigationBar)
```

The home indicator on Face ID devices is handled automatically by SwiftUI. Do not place interactive content within 34pt of the bottom edge without applying `.safeAreaInset(edge: .bottom)`.

---

## 8. Minimum Supported Screen Size

All layouts must work on the smallest supported screens without horizontal scrolling.

| Platform | Minimum Device | Logical Width |
|----------|----------------|---------------|
| Android | Any device with minSdk 26 (Android 8.0) | 320dp |
| iOS | iPhone SE 3rd generation | 375pt |

### Rules for Minimum-Width Layouts

- All horizontal padding from `MoltSpacing.screenPaddingHorizontal` (16dp / 16pt). This leaves 288dp / 343pt for content on minimum-width devices — sufficient for a 2-column grid or a full-width single-column list.
- Never use fixed-width containers wider than the minimum content width. Use `.fillMaxWidth()` (Android) or `.frame(maxWidth: .infinity)` (iOS) for all content blocks.
- Avoid `Row` / `HStack` with multiple fixed-width children unless you have verified they fit on 320dp.
- Horizontal `ScrollView` is acceptable only for explicitly scrollable content (e.g., image carousels, filter chips). Never as a workaround for a layout that doesn't fit.

### Android Smallest Width

The `smallestWidth` qualifier in `build.gradle.kts` can restrict installation to devices that meet a width threshold. The project does not enforce this currently, but all layouts are tested at 320dp.

```kotlin
// android/app/build.gradle.kts (informational, not currently set)
defaultConfig {
    // Uncomment to enforce minimum screen width
    // addManifestPlaceholders(mapOf("smallestScreenWidthDp" to "320"))
}
```

### iOS Device Testing Matrix

| Device | Logical Width | Notes |
|--------|---------------|-------|
| iPhone SE 3rd gen | 375pt | Minimum target |
| iPhone 14 / 15 | 390pt | Most common |
| iPhone 14 Plus / 15 Plus | 430pt | Large phone |
| iPhone 14 Pro Max | 430pt | Large phone |

Test new screens on iPhone SE 3rd gen simulator before marking a feature complete.

---

## 9. Accessibility Touch Targets

All interactive elements must meet platform-standard minimum touch target sizes.

| Platform | Minimum Size | Standard |
|----------|-------------|----------|
| Android | 48dp x 48dp | Material 3 |
| iOS | 44pt x 44pt | Apple HIG |

### Design System Constants

Touch target minimums are encoded in the design system:

- **Android**: `MoltSpacing.MinTouchTarget = 48.dp`
  File: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltSpacing.kt`

- **iOS**: `MoltSpacing.minTouchTarget = 44` (CGFloat, in points)
  File: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltSpacing.swift`

### Android Implementation

`MoltButton` enforces the minimum via `Modifier.heightIn(min = MoltSpacing.MinTouchTarget)`. For custom interactive elements, apply the same modifier:

```kotlin
import com.molt.marketplace.core.designsystem.theme.MoltSpacing

// Icon button with minimum touch target
Box(
    modifier = Modifier
        .size(MoltSpacing.MinTouchTarget)  // 48dp x 48dp clickable area
        .clickable { onFavoriteClick() },
    contentAlignment = Alignment.Center
) {
    Icon(Icons.Outlined.FavoriteBorder, contentDescription = stringResource(R.string.common_add_to_wishlist))
}
```

Use `Modifier.minimumInteractiveComponentSize()` (Compose 1.5+) as an alternative that applies the 48dp minimum automatically:

```kotlin
Icon(
    imageVector = Icons.Outlined.FavoriteBorder,
    contentDescription = stringResource(R.string.common_add_to_wishlist),
    modifier = Modifier
        .minimumInteractiveComponentSize()
        .clickable { onFavoriteClick() }
)
```

### iOS Implementation

SwiftUI `Button` automatically applies a 44pt minimum touch area via its tap target extension. For custom gesture-based interactions, add explicit frame sizing:

```swift
Image(systemName: "heart")
    .frame(width: MoltSpacing.minTouchTarget, height: MoltSpacing.minTouchTarget)
    .contentShape(Rectangle())  // makes the entire frame tappable
    .onTapGesture { viewModel.toggleWishlist() }
```

`MoltButton` enforces `.frame(minHeight: MoltSpacing.minTouchTarget)` internally. Do not override this in feature code.

### Verification

- **Android**: Run the **Accessibility Scanner** app on a debug build. Any element flagged as having a small touch target must be fixed before merge.
- **iOS**: Use **Xcode Accessibility Inspector** (Xcode menu: Xcode > Open Developer Tool > Accessibility Inspector). Enable **Audit** to detect small touch targets.

---

## Summary Reference Table

| Topic | Android | iOS |
|-------|---------|-----|
| Orientation lock | `android:screenOrientation="portrait"` in `AndroidManifest.xml` | `UISupportedInterfaceOrientations` = portrait in `Info.plist` |
| Edge-to-edge | `enableEdgeToEdge()` in `MainActivity` | Automatic in SwiftUI |
| Safe area padding | `Modifier.windowInsetsPadding(WindowInsets.systemBars)` | `.safeAreaInset()`, automatic |
| Screen size class | `WindowWidthSizeClass` (Compact / Medium / Expanded) | `horizontalSizeClass` (.compact / .regular) |
| Dark mode | `isSystemInDarkTheme()` in `MoltTheme` | `@Environment(\.colorScheme)` in `MoltThemeModifier` |
| Font scaling | `sp` units via `MoltTypography` | Dynamic Type via `MoltTypography` |
| Min touch target | `MoltSpacing.MinTouchTarget` = 48dp | `MoltSpacing.minTouchTarget` = 44pt |
| Min screen width | 320dp (smallestWidth) | 375pt (iPhone SE 3rd gen) |
| Grid columns (compact) | 2 | 2 |
| Grid columns (medium) | 3 | 3 |
| Grid columns (expanded) | 4 | 4 |

---

## Related Files

| File | Purpose |
|------|---------|
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/AndroidManifest.xml` | Orientation lock, permissions |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/MainActivity.kt` | `enableEdgeToEdge()` call |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTheme.kt` | Dark mode, color scheme |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltSpacing.kt` | `MinTouchTarget`, grid spacing |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTypography.kt` | Font scale tokens |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Resources/Info.plist` | Orientation lock |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/MoltMarketplaceApp.swift` | App entry point |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltTheme.swift` | Dark mode, color scheme |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltSpacing.swift` | `minTouchTarget`, grid columns |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltTypography.swift` | Font scale tokens |
