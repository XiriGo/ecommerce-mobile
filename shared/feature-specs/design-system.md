# Design System Specification (M0-02)

**Feature ID**: M0-02
**Issue**: #3
**Pipeline ID**: m0/design-system
**Branch**: feature/m0/design-system
**Status**: Specification Complete
**Author**: architect agent
**Date**: 2026-02-20

---

## 1. Overview

The Molt Design System is the shared UI component library for both Android (Jetpack Compose) and iOS (SwiftUI). It provides a single source of truth for visual tokens (colors, typography, spacing) and reusable UI components (`Molt*` wrappers) that all feature screens consume.

**Key principle**: Feature screens never import raw platform components (Material 3, SwiftUI primitives). They only import `Molt*` components from `core/designsystem`. When Figma designs arrive, only files under `core/designsystem/` change. Zero feature-screen edits needed.

### Token Pipeline

```
shared/design-tokens/*.json  -->  core/designsystem/theme/  -->  core/designsystem/component/  -->  feature/*/presentation/
        (source)                    (platform constants)           (Molt* wrappers)                  (consumers)
```

### Dependencies

- **Depends on**: M0-01 App Scaffold (project structure, Gradle/SPM config)
- **Blocks**: All M1+ features (every screen uses Molt* components)

---

## 2. Design Tokens

All token values are defined in `shared/design-tokens/` and must be translated to platform constants.

### 2.1 Colors

**Source**: `shared/design-tokens/colors.json`

#### Light Theme

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#6750A4` | Primary buttons, active states, links |
| `onPrimary` | `#FFFFFF` | Text/icon on primary surfaces |
| `primaryContainer` | `#EADDFF` | Primary container backgrounds |
| `onPrimaryContainer` | `#21005D` | Text/icon on primary containers |
| `secondary` | `#625B71` | Secondary actions, filter chips |
| `onSecondary` | `#FFFFFF` | Text on secondary surfaces |
| `secondaryContainer` | `#E8DEF8` | Selected chip backgrounds |
| `onSecondaryContainer` | `#1D192B` | Text on secondary containers |
| `tertiary` | `#7D5260` | Accent, complementary elements |
| `onTertiary` | `#FFFFFF` | Text on tertiary surfaces |
| `tertiaryContainer` | `#FFD8E4` | Tertiary container backgrounds |
| `onTertiaryContainer` | `#31111D` | Text on tertiary containers |
| `error` | `#B3261E` | Error states, validation errors |
| `onError` | `#FFFFFF` | Text on error surfaces |
| `errorContainer` | `#F9DEDC` | Error container backgrounds |
| `onErrorContainer` | `#410E0B` | Text on error containers |
| `surface` | `#FFFBFE` | Card backgrounds, sheets |
| `onSurface` | `#1C1B1F` | Primary text on surface |
| `surfaceVariant` | `#E7E0EC` | Dividers, borders, subtle backgrounds |
| `onSurfaceVariant` | `#49454F` | Secondary text, icons |
| `outline` | `#79747E` | Borders, text field outlines |
| `outlineVariant` | `#CAC4D0` | Subtle borders, dividers |
| `background` | `#FFFBFE` | Screen background |
| `onBackground` | `#1C1B1F` | Text on background |
| `inverseSurface` | `#313033` | Snackbar background |
| `inverseOnSurface` | `#F4EFF4` | Text on inverse surface |
| `inversePrimary` | `#D0BCFF` | Primary on inverse surface |
| `scrim` | `#000000` | Modal overlay (alpha 0.32) |
| `shadow` | `#000000` | Shadow color |

#### Dark Theme

| Token | Hex |
|-------|-----|
| `primary` | `#D0BCFF` |
| `onPrimary` | `#381E72` |
| `primaryContainer` | `#4F378B` |
| `onPrimaryContainer` | `#EADDFF` |
| `secondary` | `#CCC2DC` |
| `onSecondary` | `#332D41` |
| `secondaryContainer` | `#4A4458` |
| `onSecondaryContainer` | `#E8DEF8` |
| `tertiary` | `#EFB8C8` |
| `onTertiary` | `#492532` |
| `tertiaryContainer` | `#633B48` |
| `onTertiaryContainer` | `#FFD8E4` |
| `error` | `#F2B8B5` |
| `onError` | `#601410` |
| `errorContainer` | `#8C1D18` |
| `onErrorContainer` | `#F9DEDC` |
| `surface` | `#1C1B1F` |
| `onSurface` | `#E6E1E5` |
| `surfaceVariant` | `#49454F` |
| `onSurfaceVariant` | `#CAC4D0` |
| `outline` | `#938F99` |
| `outlineVariant` | `#49454F` |
| `background` | `#1C1B1F` |
| `onBackground` | `#E6E1E5` |
| `inverseSurface` | `#E6E1E5` |
| `inverseOnSurface` | `#313033` |
| `inversePrimary` | `#6750A4` |
| `scrim` | `#000000` |
| `shadow` | `#000000` |

#### Semantic Colors (Theme-Independent)

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#4CAF50` | Success states, confirmations |
| `onSuccess` | `#FFFFFF` | Text on success surfaces |
| `warning` | `#FF9800` | Warning states, caution indicators |
| `onWarning` | `#FFFFFF` | Text on warning surfaces |
| `info` | `#2196F3` | Informational states |
| `onInfo` | `#FFFFFF` | Text on info surfaces |
| `priceRegular` | `#1C1B1F` | Regular product price |
| `priceSale` | `#B3261E` | Sale/discounted price |
| `priceOriginal` | `#79747E` | Original price (strikethrough) |
| `ratingStarFilled` | `#FFC107` | Filled rating star |
| `ratingStarEmpty` | `#E0E0E0` | Empty rating star |
| `badgeBackground` | `#B3261E` | Notification badge background |
| `badgeText` | `#FFFFFF` | Badge text |
| `divider` | `#CAC4D0` | Horizontal/vertical dividers |
| `shimmer` | `#E7E0EC` | Shimmer loading placeholder |

### 2.2 Typography

**Source**: `shared/design-tokens/typography.json`

| Style | Size (sp/pt) | Line Height | Letter Spacing | Weight | Usage |
|-------|-------------|-------------|----------------|--------|-------|
| `displayLarge` | 57 | 64 | -0.25 | 400 | Hero banners |
| `displayMedium` | 45 | 52 | 0 | 400 | Large headings |
| `displaySmall` | 36 | 44 | 0 | 400 | Section titles |
| `headlineLarge` | 32 | 40 | 0 | 400 | Screen titles |
| `headlineMedium` | 28 | 36 | 0 | 400 | Section headers |
| `headlineSmall` | 24 | 32 | 0 | 400 | Card titles |
| `titleLarge` | 22 | 28 | 0 | 400 | Top bar title |
| `titleMedium` | 16 | 24 | 0.15 | 500 | Product title, list item title |
| `titleSmall` | 14 | 20 | 0.1 | 500 | Subtitle, metadata label |
| `bodyLarge` | 16 | 24 | 0.5 | 400 | Product description, body text |
| `bodyMedium` | 14 | 20 | 0.25 | 400 | Default body text |
| `bodySmall` | 12 | 16 | 0.4 | 400 | Captions, helper text |
| `labelLarge` | 14 | 20 | 0.1 | 500 | Button text, chip text |
| `labelMedium` | 12 | 16 | 0.5 | 500 | Tab labels, filter labels |
| `labelSmall` | 11 | 16 | 0.5 | 500 | Badge text, timestamp |

**Font families**: Android = system default (Roboto), iOS = SF Pro (system default).

Font weight mapping:
- 400 = `regular` (Android: `FontWeight.Normal`, iOS: `.regular`)
- 500 = `medium` (Android: `FontWeight.Medium`, iOS: `.medium`)
- 600 = `semibold` (Android: `FontWeight.SemiBold`, iOS: `.semibold`)
- 700 = `bold` (Android: `FontWeight.Bold`, iOS: `.bold`)

### 2.3 Spacing

**Source**: `shared/design-tokens/spacing.json`

| Token | Value (dp/pt) | Usage |
|-------|--------------|-------|
| `xxs` | 2 | Minimal gaps (badge offset) |
| `xs` | 4 | Icon-to-text gap, tight padding |
| `sm` | 8 | List item spacing, inline gaps |
| `md` | 12 | Card internal padding |
| `base` | 16 | Screen horizontal padding, section padding |
| `lg` | 24 | Section spacing, large gaps |
| `xl` | 32 | Large section spacing |
| `xxl` | 48 | Extra-large spacing |
| `xxxl` | 64 | Page-level spacing |

### 2.4 Corner Radius

| Token | Value (dp/pt) | Usage |
|-------|--------------|-------|
| `none` | 0 | Square corners |
| `small` | 4 | Chips, small elements |
| `medium` | 8 | Cards, text fields |
| `large` | 12 | Bottom sheets, dialogs |
| `extraLarge` | 16 | Top bar, large containers |
| `full` | 999 | Pills, circular avatars |

### 2.5 Elevation

| Token | Value (dp) | Usage |
|-------|-----------|-------|
| `level0` | 0 | Flat surfaces |
| `level1` | 1 | Cards at rest |
| `level2` | 3 | Cards on hover/press |
| `level3` | 6 | Floating action button |
| `level4` | 8 | Navigation bar |
| `level5` | 12 | Modal sheets |

### 2.6 Layout Constants

| Token | Value | Usage |
|-------|-------|-------|
| `screenPaddingHorizontal` | 16 | Horizontal padding for all screens |
| `screenPaddingVertical` | 16 | Vertical padding for screen content |
| `cardPadding` | 12 | Internal padding for cards |
| `listItemSpacing` | 8 | Vertical gap between list items |
| `sectionSpacing` | 24 | Gap between content sections |
| `productGridSpacing` | 8 | Gap between grid items |
| `productGridColumns` | 2 | Default grid column count |
| `minTouchTarget` | 48 (Android) / 44 (iOS) | Minimum tap area |
| `iconSize.small` | 16 | Small icons |
| `iconSize.medium` | 24 | Default icons |
| `iconSize.large` | 32 | Large icons |
| `iconSize.extraLarge` | 48 | Feature icons |
| `avatarSize.small` | 32 | Inline avatars |
| `avatarSize.medium` | 48 | List avatars |
| `avatarSize.large` | 64 | Profile avatars |
| `avatarSize.extraLarge` | 96 | Large profile display |
| `productImageAspectRatio` | 16:9 | Product image containers |
| `bannerAspectRatio` | 21:9 | Hero banner containers |

---

## 3. Component Catalog

### 3.1 MoltButton

**Description**: Standard action button with multiple visual variants and a loading state.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` / `title` | `String` | required | Button label text (localized) |
| `onClick` / `action` | `() -> Unit` / `() -> Void` | required | Tap callback |
| `style` | `MoltButtonStyle` | `.primary` | Visual variant |
| `enabled` | `Boolean` / `Bool` | `true` | Interactive state |
| `loading` | `Boolean` / `Bool` | `false` | Shows spinner, disables interaction |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |
| `leadingIcon` | `ImageVector?` / `String?` | `null` / `nil` | Optional leading icon |
| `fullWidth` | `Boolean` / `Bool` | `true` (primary/secondary), `false` (text) | Stretch to fill width |

#### MoltButtonStyle Enum

| Value | Android Mapping | iOS Mapping | Visual |
|-------|-----------------|-------------|--------|
| `primary` | `Button` (filled) | `.borderedProminent` | Solid primary background, white text |
| `secondary` | `OutlinedButton` | `.bordered` | Outlined, primary text |
| `outlined` | `OutlinedButton` (variant) | `.bordered` + tint | Outlined with custom border color |
| `text` | `TextButton` | `.plain` | No background, primary text |

#### States

- **Default**: Normal appearance
- **Pressed**: Slight opacity change / ripple effect
- **Disabled**: 38% opacity (Material 3 standard), not interactive
- **Loading**: Spinner replaces or precedes text, button disabled

#### Accessibility

- Android: `contentDescription` inherited from `text` parameter. Loading state announces "Loading" via `semantics`.
- iOS: `accessibilityLabel` from `title`. Loading state sets `accessibilityValue` to localized "Loading".

#### Platform-Specific Notes

- Android: Minimum height `MoltSpacing.MinTouchTarget` (48dp). Uses `MaterialTheme.colorScheme` for colors.
- iOS: Minimum height `MoltSpacing.minTouchTarget` (44pt). Uses native `ButtonStyle` conformance.

---

### 3.2 MoltTextField

**Description**: Text input field with label, error message, helper text, and optional icons.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `String` | required | Current text value |
| `onValueChange` | `(String) -> Unit` / `(String) -> Void` | required | Text change callback |
| `label` | `String` | required | Field label (localized) |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |
| `placeholder` | `String?` | `nil` | Placeholder text when empty |
| `errorMessage` | `String?` | `nil` | Error text shown below field (turns border to error color) |
| `helperText` | `String?` | `nil` | Helper text shown below field (hidden when error present) |
| `leadingIcon` | `ImageVector?` / `String?` | `nil` | Icon at start of field |
| `trailingIcon` | `ImageVector?` / `String?` | `nil` | Icon at end of field (e.g., clear, visibility toggle) |
| `onTrailingIconClick` | `(() -> Unit)?` / `(() -> Void)?` | `nil` | Tap callback for trailing icon |
| `enabled` | `Boolean` / `Bool` | `true` | Interactive state |
| `readOnly` | `Boolean` / `Bool` | `false` | Visible but not editable |
| `keyboardType` | `KeyboardType` | `.default` | Keyboard configuration |
| `isPassword` | `Boolean` / `Bool` | `false` | Obscure text, show visibility toggle as trailing icon |
| `singleLine` | `Boolean` / `Bool` | `true` | Restrict to single line |
| `maxLength` | `Int?` | `nil` | Character limit (show counter when set) |

#### States

- **Default**: Outlined border, label above
- **Focused**: Primary-colored border, floating label
- **Error**: Error-colored border, error text below
- **Disabled**: Reduced opacity, not interactive

#### Accessibility

- Android: Label is linked via `OutlinedTextField` built-in semantics. Error announced via `semantics { error(errorMessage) }`.
- iOS: `accessibilityLabel` from `label`. Error announced via `.accessibilityHint`.

#### Platform-Specific Notes

- Android: Wraps `OutlinedTextField`. Corner radius `MoltCornerRadius.medium` (8dp).
- iOS: Custom `TextField` wrapper with `.textFieldStyle(.roundedBorder)` appearance overridden. Uses `@FocusState` for focus management.

---

### 3.3 MoltCard

**Description**: Container component for displaying content cards in different layouts.

#### Variants

##### MoltProductCard

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `imageUrl` | `String?` / `URL?` | required | Product image URL |
| `title` | `String` | required | Product name (max 2 lines) |
| `price` | `String` | required | Formatted current price |
| `originalPrice` | `String?` | `nil` | Original price (for sale items) |
| `vendorName` | `String?` | `nil` | Vendor display name |
| `rating` | `Double?` / `Float?` | `nil` | Average rating (1.0-5.0) |
| `reviewCount` | `Int?` | `nil` | Number of reviews |
| `isWishlisted` | `Boolean` / `Bool` | `false` | Heart icon filled state |
| `onWishlistToggle` | `(() -> Unit)?` | `nil` | Heart icon tap callback |
| `onClick` | `() -> Unit` / `() -> Void` | required | Card tap callback |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

##### MoltInfoCard

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | required | Card title |
| `subtitle` | `String?` | `nil` | Card subtitle |
| `leadingIcon` | `ImageVector?` / `String?` | `nil` | Leading icon |
| `trailingContent` | `@Composable (() -> Unit)?` / `AnyView?` | `nil` | Trailing slot |
| `onClick` | `(() -> Unit)?` | `nil` | Card tap callback (nil = non-tappable) |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### Product Card Layout

```
+--------------------------------------+
| [Image - 16:9 aspect ratio]    [heart] |
+--------------------------------------+
| Product Title (max 2 lines)           |
| Vendor Name                           |
| EUR 29.99  EUR 39.99 (strikethrough)  |
| [stars] 4.5 (123)                     |
+--------------------------------------+
```

#### States

- **Default**: Elevation level1, standard appearance
- **Pressed**: Elevation level2, ripple/highlight effect
- **Loading**: Shimmer placeholder (solid `shimmer` color blocks matching layout)

#### Accessibility

- Android: Card has combined `contentDescription` = "$title, $price, $vendorName, rating $rating out of 5". Wishlist heart is a separate clickable with `contentDescription` = "Add to wishlist" / "Remove from wishlist".
- iOS: Same `accessibilityLabel` composition. Wishlist button uses `accessibilityAddTraits(.isButton)`.

#### Platform-Specific Notes

- Android: Wraps `Card` composable. Padding `MoltSpacing.CardPadding`. Corner radius `MoltCornerRadius.medium`.
- iOS: Wraps content in `VStack` with `.background(RoundedRectangle)`. Shadow from elevation token.

---

### 3.4 MoltChip

**Description**: Compact element for filters, categories, and selections.

#### Variants

##### MoltFilterChip

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | `String` | required | Chip text |
| `selected` | `Boolean` / `Bool` | `false` | Selected state |
| `onClick` | `() -> Unit` / `() -> Void` | required | Toggle callback |
| `leadingIcon` | `ImageVector?` / `String?` | `nil` | Leading icon |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

##### MoltCategoryChip

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | `String` | required | Category name |
| `iconUrl` | `String?` / `URL?` | `nil` | Category icon URL |
| `onClick` | `() -> Unit` / `() -> Void` | required | Tap callback |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### States

- **Default (unselected)**: Outlined with surface variant background
- **Selected**: `secondaryContainer` background, `onSecondaryContainer` text, checkmark icon
- **Disabled**: 38% opacity

#### Accessibility

- Android: `FilterChip` built-in semantics. Selected state announced via `Role.Checkbox`.
- iOS: `accessibilityLabel` = label. `accessibilityAddTraits(selected ? .isSelected : [])`.

#### Platform-Specific Notes

- Android: Wraps `FilterChip` (Material 3). Corner radius `MoltCornerRadius.small`.
- iOS: Custom `Button` with capsule shape. Uses `MoltColors.secondaryContainer` when selected.

---

### 3.5 MoltTopBar

**Description**: Top application bar with navigation and action buttons.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | required | Bar title text |
| `onBackClick` | `(() -> Unit)?` / `(() -> Void)?` | `nil` | Back button callback (nil = no back button) |
| `actions` | `@Composable RowScope.() -> Unit` / `[MoltTopBarAction]` | empty | Action buttons (right side) |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### MoltTopBarAction (iOS convenience)

| Field | Type | Description |
|-------|------|-------------|
| `icon` | `String` | SF Symbol name |
| `accessibilityLabel` | `String` | VoiceOver label |
| `action` | `() -> Void` | Tap callback |
| `badgeCount` | `Int?` | Optional badge overlay |

#### Accessibility

- Android: Back button `contentDescription` = localized "Navigate back". Action icons require explicit `contentDescription`.
- iOS: Back button uses system `navigationBarBackButtonHidden` + custom button with `accessibilityLabel`. Actions use `accessibilityLabel`.

#### Platform-Specific Notes

- Android: Wraps `TopAppBar` (Material 3). `NavigationIcon` slot for back. `actions` slot for action icons.
- iOS: Uses `toolbar` modifier with `.navigationBarTitleDisplayMode(.inline)`. Back button via `navigationBarBackButtonHidden` + custom `ToolbarItem(.navigationBarLeading)`.

---

### 3.6 MoltBottomBar (Android) / MoltTabBar (iOS)

**Description**: Bottom tab navigation bar with tab items and optional badge counts.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `items` | `List<MoltTabItem>` / `[MoltTabItem]` | required | Tab definitions |
| `selectedIndex` | `Int` | required | Currently selected tab index |
| `onTabSelected` | `(Int) -> Unit` / `(Int) -> Void` | required | Tab selection callback |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### MoltTabItem

| Field | Type | Description |
|-------|------|-------------|
| `label` | `String` | Tab label (localized) |
| `icon` | `ImageVector` / `String` | Tab icon (Material Icon / SF Symbol) |
| `selectedIcon` | `ImageVector` / `String` | Filled variant when selected |
| `badgeCount` | `Int?` | Badge count (nil = no badge) |

#### Tab Items (App-Wide)

| Tab | Label Key | Android Icon | iOS SF Symbol | Badge |
|-----|-----------|-------------|---------------|-------|
| Home | `common_tab_home` | `Icons.Outlined.Home` / `Icons.Filled.Home` | `house` / `house.fill` | None |
| Categories | `common_tab_categories` | `Icons.Outlined.Category` / `Icons.Filled.Category` | `square.grid.2x2` / `square.grid.2x2.fill` | None |
| Cart | `common_tab_cart` | `Icons.Outlined.ShoppingCart` / `Icons.Filled.ShoppingCart` | `cart` / `cart.fill` | Cart item count |
| Profile | `common_tab_profile` | `Icons.Outlined.Person` / `Icons.Filled.Person` | `person` / `person.fill` | None |

#### Accessibility

- Android: Each tab has `contentDescription` = label. Badge announces count via semantics.
- iOS: Each tab has `accessibilityLabel` = label. Badge uses `.badge()` modifier (system-handled).

#### Platform-Specific Notes

- Android: Wraps `NavigationBar` + `NavigationBarItem` (Material 3). Badge via `BadgedBox`.
- iOS: Wraps `TabView` with `tabItem` modifiers. Badge via `.badge(count)`.

---

### 3.7 MoltLoadingView

**Description**: Loading state indicators for full-screen and inline contexts.

#### Variants

##### MoltLoadingView (Full Screen)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

Fills the entire available space with a centered progress indicator.

##### MoltLoadingIndicator (Inline)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

Horizontally centered, smaller indicator for list footers and inline loading.

#### Accessibility

- Android: Progress indicator gets `contentDescription` = localized "Loading".
- iOS: Uses system `ProgressView` which has built-in accessibility.

#### Platform-Specific Notes

- Android: `CircularProgressIndicator` (full: default size, inline: 24dp, strokeWidth 2dp).
- iOS: `ProgressView()` (system spinner).

---

### 3.8 MoltErrorView

**Description**: Error state display with message and optional retry action.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `message` | `String` | required | Error description (localized) |
| `onRetry` | `(() -> Unit)?` / `(() -> Void)?` | `nil` | Retry callback (nil = no retry button) |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### Layout

```
        [Error Icon - 48dp/pt]
          (16dp/pt gap)
       Error message text
       (center-aligned, bodyLarge)
          (16dp/pt gap)
       [Retry Button] (if onRetry != nil)
```

#### Accessibility

- Android: Icon has `contentDescription` = null (decorative). Error message is primary. Retry button has `contentDescription` from button text.
- iOS: Icon is decorative (`.accessibilityHidden(true)`). Text and button are accessible.

#### Platform-Specific Notes

- Android: Error icon = `Icons.Outlined.ErrorOutline`. Retry button uses `MoltButton`.
- iOS: Error icon = SF Symbol `exclamationmark.circle`. Retry button uses `MoltButton`.

---

### 3.9 MoltEmptyView

**Description**: Empty state display with illustration, message, and optional action.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `message` | `String` | required | Empty state message (localized) |
| `icon` (Android) | `ImageVector` | `Icons.Outlined.Inbox` | Empty state icon |
| `systemImage` (iOS) | `String` | `"tray"` | SF Symbol name |
| `actionLabel` | `String?` | `nil` | Action button text |
| `onAction` | `(() -> Unit)?` / `(() -> Void)?` | `nil` | Action button callback |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### Layout

```
        [Icon - 64dp/pt, onSurfaceVariant]
              (16dp/pt gap)
         Empty state message
         (center-aligned, bodyLarge, onSurfaceVariant)
              (16dp/pt gap)
         [Action Button] (if actionLabel != nil)
```

#### Accessibility

- Android: Icon `contentDescription` = null (decorative). Message is primary text.
- iOS: Icon `.accessibilityHidden(true)`. Message is primary.

---

### 3.10 MoltImage

**Description**: Async image loader with placeholder and error fallback.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `url` (Android) | `String?` | required | Image URL string |
| `url` (iOS) | `URL?` | required | Image URL |
| `contentDescription` (Android) | `String?` | required | Accessibility description |
| `contentScale` (Android) | `ContentScale` | `ContentScale.Crop` | Image scaling |
| `contentMode` (iOS) | `ContentMode` | `.fill` | Image content mode |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### States

- **Loading**: Shimmer color (`MoltColors.shimmer`) solid fill
- **Success**: Actual image with crossfade animation (250ms)
- **Error**: Same shimmer color as placeholder (or `R.drawable.placeholder` on Android)

#### Accessibility

- Android: `contentDescription` parameter passed to `AsyncImage`.
- iOS: No explicit label needed for decorative images; for meaningful images, wrap with `.accessibilityLabel`.

#### Platform-Specific Notes

- Android: Uses Coil `AsyncImage` with `ImageRequest.Builder.crossfade(true)`. Placeholder and error drawables from resources.
- iOS: Uses NukeUI `LazyImage`. Crossfade via `.transition(.opacity.animation(.easeInOut(duration: 0.25)))`.

---

### 3.11 MoltBadge

**Description**: Small count or status indicator badge, typically overlaid on icons.

#### Variants

##### MoltCountBadge

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `count` | `Int` | required | Badge count |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

Display logic:
- `count == 0`: Hidden (no badge)
- `count 1-99`: Show number
- `count >= 100`: Show "99+"

##### MoltStatusBadge

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `status` | `MoltBadgeStatus` | required | Status type |
| `label` | `String` | required | Status text (localized) |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### MoltBadgeStatus Enum

| Value | Background | Text Color | Usage |
|-------|-----------|------------|-------|
| `success` | `MoltColors.success` | `MoltColors.onSuccess` | Order delivered, in stock |
| `warning` | `MoltColors.warning` | `MoltColors.onWarning` | Low stock, pending |
| `error` | `MoltColors.error` | `MoltColors.onError` | Out of stock, cancelled |
| `info` | `MoltColors.info` | `MoltColors.onInfo` | Processing, info |
| `neutral` | `MoltColors.surfaceVariant` | `MoltColors.onSurfaceVariant` | Default status |

#### Accessibility

- Android: Count badge uses `semantics { contentDescription = "$count notifications" }`. Status badge uses label as `contentDescription`.
- iOS: Count badge uses `.accessibilityLabel("\(count) notifications")`. Status badge uses `label` as `accessibilityLabel`.

#### Platform-Specific Notes

- Android: Count badge wraps in `BadgedBox` (Material 3). Status badge is custom `Surface` with rounded corners.
- iOS: Count badge is `Text` in red circle. Status badge uses capsule-shaped background.

---

### 3.12 MoltRatingBar

**Description**: Read-only star rating display showing a value between 1 and 5.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `rating` | `Float` / `Double` | required | Rating value (0.0 to 5.0) |
| `maxRating` | `Int` | `5` | Maximum number of stars |
| `starSize` | `Dp` / `CGFloat` | `16` (dp/pt) | Individual star size |
| `showValue` | `Boolean` / `Bool` | `false` | Show numeric value next to stars |
| `reviewCount` | `Int?` | `nil` | Show "(N)" review count after value |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### Layout

```
[star][star][star][star][star] 4.5 (123)
 filled filled filled half  empty
```

#### Star Fill Logic

For each star position `i` (1-based):
- If `rating >= i`: filled star (`ratingStarFilled`)
- If `rating >= i - 0.5`: half-filled star (clip mask)
- Else: empty star (`ratingStarEmpty`)

#### Accessibility

- Android: `contentDescription` = localized "Rating: $rating out of $maxRating" + optional "(N reviews)".
- iOS: `accessibilityLabel` = same composition.

#### Platform-Specific Notes

- Android: Custom composable with `Canvas` or `Icon` per star. Uses `MoltColors.RatingStarFilled` / `MoltColors.RatingStarEmpty`.
- iOS: `HStack` of `Image(systemName: "star.fill")` / `Image(systemName: "star.leadinghalf.filled")` / `Image(systemName: "star")`.

---

### 3.13 MoltPriceText

**Description**: Formatted price display with currency symbol, sale price, and strikethrough for original price.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `price` | `String` | required | Formatted current price (e.g., "29.99") |
| `originalPrice` | `String?` | `nil` | Original price before discount |
| `currencySymbol` | `String` | `"EUR"` | Currency symbol/code |
| `size` | `MoltPriceSize` | `.medium` | Text size variant |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### MoltPriceSize Enum

| Value | Price Style | Original Price Style |
|-------|------------|---------------------|
| `small` | `bodySmall` | `labelSmall` |
| `medium` | `titleMedium` | `bodySmall` |
| `large` | `headlineSmall` | `bodyMedium` |

#### Layout

When `originalPrice != nil` (sale):
```
EUR 29.99  EUR 39.99
(priceSale)  (priceOriginal, strikethrough)
```

When `originalPrice == nil` (regular):
```
EUR 29.99
(priceRegular)
```

#### Formatting Rules

- Currency format: "EUR XX.XX" (euro symbol before amount, dot decimal separator)
- Use locale-aware `NumberFormat` (Android) / `NumberFormatter` (iOS) for display
- Always show 2 decimal places

#### Accessibility

- Android: Combined `contentDescription` = "Price: EUR 29.99" or "Sale price: EUR 29.99, was EUR 39.99".
- iOS: `accessibilityLabel` = same composition.

#### Platform-Specific Notes

- Android: `Row` with two `Text` composables. Original price uses `TextDecoration.LineThrough`.
- iOS: `HStack` with two `Text` views. Original price uses `.strikethrough()`.

---

### 3.14 MoltQuantityStepper

**Description**: Increment/decrement control for item quantities.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `quantity` | `Int` | required | Current quantity value |
| `onQuantityChange` | `(Int) -> Unit` / `(Int) -> Void` | required | Quantity change callback |
| `minQuantity` | `Int` | `1` | Minimum allowed value |
| `maxQuantity` | `Int` | `99` | Maximum allowed value |
| `modifier` (Android) | `Modifier` | `Modifier` | Compose modifier chain |

#### Layout

```
[ - ]  3  [ + ]
```

- Minus button disabled when `quantity <= minQuantity`
- Plus button disabled when `quantity >= maxQuantity`
- Count displayed with `titleMedium` style

#### Accessibility

- Android: Minus button `contentDescription` = localized "Decrease quantity". Plus button = "Increase quantity". Quantity text = "Quantity: $quantity".
- iOS: Same labels. Consider `accessibilityAdjustableAction` for combined stepper control.

#### Platform-Specific Notes

- Android: `Row` with two `IconButton` composables and center `Text`. Min touch target 48dp for each button.
- iOS: `HStack` with two `Button` views and center `Text`. Min touch target 44pt.

---

## 4. File Structure

### 4.1 Android

**Root**: `android/app/src/main/java/com/molt/marketplace/core/designsystem/`

```
core/designsystem/
  theme/
    MoltColors.kt          -- Color object (light, dark, semantic) from colors.json
    MoltTypography.kt      -- Typography object from typography.json
    MoltSpacing.kt         -- Spacing object from spacing.json
    MoltCornerRadius.kt    -- Corner radius object from spacing.json
    MoltElevation.kt       -- Elevation object from spacing.json
    MoltTheme.kt           -- @Composable MoltTheme wrapper (applies colorScheme + typography)
  component/
    MoltButton.kt          -- MoltButton + MoltButtonStyle enum
    MoltTextField.kt       -- MoltTextField
    MoltCard.kt            -- MoltProductCard + MoltInfoCard
    MoltChip.kt            -- MoltFilterChip + MoltCategoryChip
    MoltTopBar.kt          -- MoltTopBar
    MoltBottomBar.kt       -- MoltBottomBar + MoltTabItem
    MoltLoadingView.kt     -- MoltLoadingView + MoltLoadingIndicator
    MoltErrorView.kt       -- MoltErrorView
    MoltEmptyView.kt       -- MoltEmptyView
    MoltImage.kt           -- MoltImage
    MoltBadge.kt           -- MoltCountBadge + MoltStatusBadge + MoltBadgeStatus enum
    MoltRatingBar.kt       -- MoltRatingBar
    MoltPriceText.kt       -- MoltPriceText + MoltPriceSize enum
    MoltQuantityStepper.kt -- MoltQuantityStepper
```

**Total files**: 6 theme + 14 component = **20 Kotlin files**

### 4.2 iOS

**Root**: `ios/MoltMarketplace/Core/DesignSystem/`

```
Core/DesignSystem/
  Theme/
    MoltColors.swift       -- MoltColors enum (light, dark, semantic) + Color(hex:) extension
    MoltTypography.swift   -- MoltTypography enum from typography.json
    MoltSpacing.swift      -- MoltSpacing enum from spacing.json
    MoltCornerRadius.swift -- MoltCornerRadius enum from spacing.json
    MoltElevation.swift    -- MoltElevation enum (shadow helpers)
    MoltTheme.swift        -- MoltTheme ViewModifier (applies color + typography environment)
  Component/
    MoltButton.swift       -- MoltButton view + MoltButtonStyle enum
    MoltTextField.swift    -- MoltTextField view
    MoltCard.swift         -- MoltProductCard + MoltInfoCard views
    MoltChip.swift         -- MoltFilterChip + MoltCategoryChip views
    MoltTopBar.swift       -- MoltTopBar view
    MoltTabBar.swift       -- MoltTabBar view + MoltTabItem struct
    MoltLoadingView.swift  -- MoltLoadingView + MoltLoadingIndicator views
    MoltErrorView.swift    -- MoltErrorView
    MoltEmptyView.swift    -- MoltEmptyView
    MoltImage.swift        -- MoltImage view (NukeUI)
    MoltBadge.swift        -- MoltCountBadge + MoltStatusBadge + MoltBadgeStatus enum
    MoltRatingBar.swift    -- MoltRatingBar view
    MoltPriceText.swift    -- MoltPriceText view + MoltPriceSize enum
    MoltQuantityStepper.swift -- MoltQuantityStepper view
```

**Total files**: 6 theme + 14 component = **20 Swift files**

---

## 5. Localization Keys

All user-facing strings in design system components must use localization keys.

### String Keys

| Key | English (en) | Maltese (mt) | Turkish (tr) |
|-----|-------------|-------------|-------------|
| `common_loading` | Loading... | Tagħbija... | Yukleniyor... |
| `common_retry_button` | Retry | Erga' pprova | Tekrar dene |
| `common_error_icon_description` | Error | Zball | Hata |
| `common_navigate_back` | Navigate back | Mur lura | Geri git |
| `common_decrease_quantity` | Decrease quantity | Naqqas il-kwantita | Miktari azalt |
| `common_increase_quantity` | Increase quantity | Żid il-kwantita | Miktari artir |
| `common_quantity_value` | Quantity: %d | Kwantita: %d | Miktar: %d |
| `common_rating_description` | Rating: %.1f out of %d | Klassifika: %.1f minn %d | Puan: %d uzerinden %.1f |
| `common_reviews_count` | (%d reviews) | (%d reviżjonijiet) | (%d degerlendirme) |
| `common_price_label` | Price: %s | Prezz: %s | Fiyat: %s |
| `common_sale_price_label` | Sale price: %1$s, was %2$s | Prezz tal-bejgh: %1$s, kien %2$s | Indirimli fiyat: %1$s, eskisi %2$s |
| `common_add_to_wishlist` | Add to wishlist | Żid mal-wishlist | Favorilere ekle |
| `common_remove_from_wishlist` | Remove from wishlist | Neħħi mill-wishlist | Favorilerden kaldir |
| `common_notifications_count` | %d notifications | %d notifiki | %d bildirim |
| `common_tab_home` | Home | Dar | Ana sayfa |
| `common_tab_categories` | Categories | Kategoriji | Kategoriler |
| `common_tab_cart` | Cart | Karrettun | Sepet |
| `common_tab_profile` | Profile | Profil | Profil |

---

## 6. Preview Requirements

Every component file must include at least one preview demonstrating:
1. Default state
2. Key variant (if applicable)
3. Edge case (long text, loading, error, etc.)

### Android Preview Pattern

```kotlin
@Preview(showBackground = true)
@Composable
private fun MoltButtonPrimaryPreview() {
    MoltTheme {
        MoltButton(text = "Add to Cart", onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltButtonLoadingPreview() {
    MoltTheme {
        MoltButton(text = "Loading", onClick = {}, loading = true)
    }
}
```

### iOS Preview Pattern

```swift
#Preview("MoltButton Primary") {
    MoltButton("Add to Cart") { }
}

#Preview("MoltButton Loading") {
    MoltButton("Loading", isLoading: true) { }
}
```

---

## 7. Acceptance Criteria

### Theme

- [ ] All color tokens from `colors.json` mapped to platform constants
- [ ] Light and dark color schemes implemented and switchable
- [ ] All typography styles from `typography.json` mapped to platform text styles
- [ ] All spacing tokens from `spacing.json` mapped to platform dimension constants
- [ ] Corner radius and elevation tokens mapped
- [ ] `MoltTheme` wrapper applies color scheme + typography to content tree

### Components

- [ ] All 14 components implemented on both platforms
- [ ] Each component has a `modifier` (Android) parameter as first optional parameter
- [ ] No raw Material 3 or SwiftUI primitives exposed in public API (all wrapped)
- [ ] All components support the states listed in their spec
- [ ] All strings use localization keys (no hardcoded user-facing text)
- [ ] All interactive elements meet minimum touch target (48dp Android / 44pt iOS)

### Accessibility

- [ ] All interactive elements have `contentDescription` (Android) / `accessibilityLabel` (iOS)
- [ ] Loading states announce "Loading" to screen readers
- [ ] Error states announce error message
- [ ] Color contrast ratio >= 4.5:1 for text on all backgrounds
- [ ] Dynamic Type support on iOS (text scales with system setting)

### Previews

- [ ] Every component file has at least one `@Preview` / `#Preview`
- [ ] Previews wrapped in `MoltTheme`
- [ ] Both light and dark previews for theme-dependent components

### Quality

- [ ] Android: ktlint + detekt pass with zero warnings
- [ ] iOS: SwiftLint + SwiftFormat pass with zero warnings
- [ ] No `Any` type usage
- [ ] No force unwrap (`!!` or `!`)
- [ ] All types are immutable (data class / struct)
- [ ] No hardcoded colors, dimensions, or strings in component code
- [ ] 60fps scroll performance (no jank from complex component rendering)

---

## 8. Design Transition Notes

This spec uses Material 3 defaults and system fonts. When Figma designs arrive:

1. **Update** `shared/design-tokens/*.json` with new values
2. **Update** theme files (`MoltColors`, `MoltTypography`, `MoltSpacing`) to read new tokens
3. **Update** component files to match new visual specs (padding, shapes, shadows)
4. **Do NOT change** any feature screen code -- the `Molt*` API contracts stay stable

The component API (parameters, callbacks, types) defined in this spec is the stable contract. Visual implementation behind these APIs is what changes when Figma arrives.

---

**Specification Complete**
**Next**: Android Dev + iOS Dev implement in parallel based on this spec.
