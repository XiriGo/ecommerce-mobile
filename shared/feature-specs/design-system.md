# M0-02: Design System Components -- Feature Specification

## Overview

The Design System Components feature implements 14 reusable `Molt*` wrapper components that all
feature screens use instead of raw Material 3 (Android) or SwiftUI (iOS) components. These
wrappers create an abstraction layer between the design system and feature code so that when
Figma designs arrive, only the files under `core/designsystem/component/` change -- zero edits
to feature screens.

The theme shell (`MoltColors`, `MoltSpacing`, `MoltTypography`, `MoltTheme`) already exists
from M0-01. This task fills the `component/` directory with concrete, production-ready UI
building blocks.

### User Stories

- As a **feature developer**, I want pre-built `MoltButton`, `MoltCard`, `MoltTextField`, and
  other components so that I can build screens without touching raw platform components.
- As a **feature developer**, I want `MoltLoadingView`, `MoltErrorView`, and `MoltEmptyView`
  components so that I can handle all screen states consistently.
- As a **feature developer**, I want `MoltPriceText` and `MoltRatingBar` so that I can display
  prices and ratings in a consistent, locale-aware format.
- As a **feature developer**, I want `MoltImage` so that I can load remote images with
  placeholder, crossfade, and error handling without configuring Coil/Nuke directly.
- As a **feature developer**, I want `MoltTopBar` and `MoltBottomBar`/`MoltTabBar` so that
  navigation chrome is consistent across all screens.
- As a **feature developer**, I want `MoltSearchBar` so that I can add search input to screens
  with the standard search UX.
- As a **designer**, I want all visual tokens (colors, spacing, radii, typography) consumed
  through the design system layer so that a future Figma-driven redesign only touches component
  files.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| 14 `Molt*` wrapper components (see list below) | Theme files (already exist from M0-01) |
| Component-level states (loading, disabled, error) | Screen-level state management |
| `@Preview` / `#Preview` for every component | Feature screens that consume these components |
| New localized string keys for component labels | Navigation wiring (M0-04) |
| Accessibility labels and minimum touch targets | Network layer (M0-03) |
| Unit/snapshot tests for each component | Business logic or API calls |

### Dependencies on Other Features

| Feature | What This Needs |
|---------|-----------------|
| M0-01 App Scaffold | Theme shell (`MoltColors`, `MoltSpacing`, `MoltTypography`, `MoltTheme`), project structure, string resource files, placeholder assets (`placeholder.xml`, `Placeholder.imageset`) |

### Features That Depend on This

All features from M0-04 onward: Navigation (M0-04), Auth (M1-01 through M1-03), Home (M1-04),
Categories (M1-05), Product List (M1-06), Product Detail (M1-07), Search (M1-08), Cart (M2-01),
Wishlist (M2-02), Checkout (M2-04 through M2-07), Orders (M3-01, M3-02), Profile (M3-03),
Settings (M3-06), and all M4 features.

---

## 1. API Mapping

Not applicable. Design system components are pure UI building blocks with no API calls. All data
is passed in as props from feature-level ViewModels. Components do not import any network or
repository layer code.

---

## 2. Data Models

Not applicable. Components accept primitive types and simple data classes/structs as props.
They do not define DTOs or domain models. The types used by components (e.g., `Long` for price
in cents, `Float` for rating) are standard platform types.

Where a component needs a structured prop (e.g., `MoltBottomBar` tab items), a simple data
class/struct is defined alongside the component file. These are UI-only models, not domain models.

---

## 3. Component Specifications

### 3.1 MoltButton

**Purpose**: Primary interactive button used across all screens for actions.

**Variants**:

| Variant | Android Wraps | iOS Style |
|---------|--------------|-----------|
| `Primary` | `Button` (filled) | `.borderedProminent` |
| `Secondary` | `OutlinedButton` | `.bordered` |
| `Text` | `TextButton` | `.plain` |

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `text` / `title` | `String` | `String` | Yes | -- | Button label |
| `onClick` / `action` | `() -> Unit` | `() -> Void` | Yes | -- | Tap callback |
| `style` | `MoltButtonStyle` enum | `MoltButtonStyle` enum | No | `Primary` | Visual variant |
| `enabled` | `Boolean` | `Bool` | No | `true` | Interaction enabled |
| `loading` | `Boolean` | `Bool` | No | `false` | Shows inline spinner, disables tap |
| `modifier` | `Modifier` | -- | No | `Modifier` | Android layout modifier |

**MoltButtonStyle Enum**: `Primary`, `Secondary`, `Text`

**Behavior**:
- When `loading = true`: shows a small `CircularProgressIndicator` (Android, 18dp, 2dp stroke)
  or `ProgressView` (iOS) to the left of the text. Button is disabled during loading.
- Minimum height: `MoltSpacing.MinTouchTarget` (48dp Android) / `MoltSpacing.minTouchTarget`
  (44pt iOS).
- Primary variant fills full available width (`fillMaxWidth` / `maxWidth: .infinity`). Text
  variant does not expand.
- Uses `MaterialTheme.colorScheme` colors (Android) / `MoltColors` (iOS). Never hardcodes.

**Text-Based Wireframe**:

```
Primary (normal):
+----------------------------------------+
|           [ Button Text ]              |  height >= 48dp/44pt
+----------------------------------------+

Primary (loading):
+----------------------------------------+
|        [o] [ Button Text ]             |  o = spinner
+----------------------------------------+

Secondary (normal):
+========================================+
|           [ Button Text ]              |  outlined border
+========================================+

Text (normal):
          [ Button Text ]                   no background, no border

Disabled (any variant):
+----------------------------------------+
|           [ Button Text ]              |  40% opacity
+----------------------------------------+
```

---

### 3.2 MoltCard

**Purpose**: Card container for displaying product information or general info content.

**Variants**: `ProductCard`, `InfoCard`

#### ProductCard

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `imageUrl` | `String?` | `URL?` | No | `null` / `nil` | Product thumbnail URL |
| `title` | `String` | `String` | Yes | -- | Product name (max 2 lines, ellipsis) |
| `price` | `Long` | `Int` | Yes | -- | Price in cents (EUR) |
| `originalPrice` | `Long?` | `Int?` | No | `null` / `nil` | Original price before discount |
| `vendorName` | `String` | `String` | Yes | -- | Vendor display name |
| `rating` | `Float?` | `Double?` | No | `null` / `nil` | Average rating 0.0-5.0 |
| `onClick` | `() -> Unit` | `() -> Void` | Yes | -- | Card tap callback |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Text-Based Wireframe -- ProductCard**:

```
+----------------------------+
|                            |
|      [ Product Image ]     |  16:9 aspect ratio via MoltImage
|        (MoltImage)         |
|                            |
+----------------------------+
| Product Title Text That    |  titleSmall, max 2 lines
| May Wrap to Two Lines...   |
| Vendor Name                |  bodySmall, onSurfaceVariant
| EUR 29.99  EUR 39.99       |  MoltPriceText (sale + strikethrough)
| **** (4.2)                 |  MoltRatingBar + count (optional)
+----------------------------+

Padding: MoltSpacing.CardPadding (12dp/pt) inside text area
Corner radius: MoltCornerRadius.medium (8dp/pt)
Elevation: level1 (Android) / shadow (iOS)
```

#### InfoCard

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `title` | `String` | `String` | Yes | -- | Card title |
| `subtitle` | `String?` | `String?` | No | `null` / `nil` | Secondary text |
| `trailingContent` | `@Composable (() -> Unit)?` | `AnyView?` / `@ViewBuilder` | No | `null` / `nil` | Trailing composable/view |
| `onClick` | `(() -> Unit)?` | `(() -> Void)?` | No | `null` / `nil` | Tap callback (null = not clickable) |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Text-Based Wireframe -- InfoCard**:

```
+------------------------------------------+
|  Title Text              [ Trailing ]    |  titleMedium
|  Subtitle text (optional)                |  bodyMedium, onSurfaceVariant
+------------------------------------------+

Padding: MoltSpacing.CardPadding (12dp/pt)
Corner radius: MoltCornerRadius.medium (8dp/pt)
Surface color background
Optional clickable ripple
```

---

### 3.3 MoltTextField

**Purpose**: Text input field with label, placeholder, error message, and icon support.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `value` | `String` | `String` (Binding) | Yes | -- | Current text value |
| `onValueChange` | `(String) -> Unit` | `Binding<String>` | Yes | -- | Text change callback |
| `label` | `String` | `String` | Yes | -- | Field label (above field) |
| `placeholder` | `String` | `String` | No | `""` | Placeholder text |
| `errorMessage` | `String?` | `String?` | No | `null` / `nil` | Error text (shows in red below field) |
| `leadingIcon` | `ImageVector?` | `String?` (SF Symbol) | No | `null` / `nil` | Leading icon |
| `trailingIcon` | `ImageVector?` | `String?` (SF Symbol) | No | `null` / `nil` | Trailing icon |
| `trailingIconClick` | `(() -> Unit)?` | `(() -> Void)?` | No | `null` / `nil` | Trailing icon tap (e.g., clear, toggle visibility) |
| `keyboardType` | `KeyboardType` | `UIKeyboardType` | No | `Text` / `.default` | Keyboard type |
| `isSecure` | `Boolean` | `Bool` | No | `false` | Masks input (password field) |
| `enabled` | `Boolean` | `Bool` | No | `true` | Field enabled |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Android**: Wraps `OutlinedTextField` with `isError` state and `supportingText` for error.
**iOS**: Wraps `TextField` (or `SecureField` when `isSecure = true`) with `LabeledContent`-like
layout.

**Behavior**:
- When `errorMessage` is non-null: border turns `error` color, error text appears below field
  in `bodySmall` style with `error` color.
- When `isSecure = true`: renders a password field. On Android, wraps `OutlinedTextField` with
  `visualTransformation = PasswordVisualTransformation()`. On iOS, uses `SecureField`.
- `trailingIcon` with `trailingIconClick` supports toggling password visibility (eye icon).
- Label is always visible above the field (not as floating label).

**Text-Based Wireframe**:

```
Normal:
  Email
  +--------------------------------------+
  | [icon]  placeholder text       [icon]|
  +--------------------------------------+

Error:
  Email
  +--------------------------------------+  <- red border
  | [icon]  user@example         [icon]  |
  +--------------------------------------+
  Invalid email format                      <- bodySmall, error color

Secure:
  Password
  +--------------------------------------+
  | [lock]  ************           [eye] |
  +--------------------------------------+
```

---

### 3.4 MoltTopBar

**Purpose**: Top navigation bar with title, optional back button, and optional action icons.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `title` | `String` | `String` | Yes | -- | Bar title |
| `onBackClick` | `(() -> Unit)?` | `(() -> Void)?` | No | `null` / `nil` | Back button callback. When non-null, shows back arrow. |
| `actions` | `List<MoltTopBarAction>` | `[MoltTopBarAction]` | No | `emptyList()` / `[]` | Trailing action icons |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**MoltTopBarAction**:

| Field | Android Type | iOS Type | Description |
|-------|-------------|----------|-------------|
| `icon` | `ImageVector` | `String` (SF Symbol name) | Icon resource |
| `contentDescription` | `String` | `String` | Accessibility label |
| `onClick` | `() -> Unit` | `() -> Void` | Action callback |

**Android**: Wraps `TopAppBar` (Material 3 `MediumTopAppBar` or `TopAppBar`).
**iOS**: Custom `HStack` inside `.toolbar` or standalone `HStack` with back button, title, and
actions. Uses `titleMedium` / `.headline` for title.

**Behavior**:
- When `onBackClick` is non-null: shows a back arrow icon (`Icons.AutoMirrored.Filled.ArrowBack`
  on Android, `chevron.left` SF Symbol on iOS). Content description: `common_back_button` string.
- Actions render as `IconButton` (Android) / `Button` with icon (iOS) in trailing position.
- Minimum height: system default (`TopAppBar` height on Android, 44pt on iOS).

**Text-Based Wireframe**:

```
With back + actions:
+------------------------------------------+
|  [<]  Title Text              [icon] [icon] |
+------------------------------------------+

Without back (root screen):
+------------------------------------------+
|       Title Text              [icon] [icon] |
+------------------------------------------+

No actions:
+------------------------------------------+
|  [<]  Title Text                         |
+------------------------------------------+
```

---

### 3.5 MoltBottomBar (Android) / MoltTabBar (iOS)

**Purpose**: Bottom navigation / tab bar for main app sections.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `tabs` | `List<MoltTabItem>` | `[MoltTabItem]` | Yes | -- | Tab definitions |
| `selectedTab` | `Int` | `Int` | Yes | -- | Currently selected tab index |
| `onTabSelected` | `(Int) -> Unit` | `(Int) -> Void` | Yes | -- | Tab selection callback |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**MoltTabItem**:

| Field | Android Type | iOS Type | Description |
|-------|-------------|----------|-------------|
| `icon` | `ImageVector` | `String` (SF Symbol name) | Tab icon (unselected) |
| `selectedIcon` | `ImageVector` | `String` (SF Symbol name) | Tab icon (selected, filled variant) |
| `label` | `String` | `String` | Tab label text |
| `badgeCount` | `Int?` | `Int?` | Badge count (null = no badge) |

**Android**: Wraps `NavigationBar` with `NavigationBarItem` entries. Uses `BadgedBox` for badge.
**iOS**: Wraps `TabView` with `.tabItem` labels or custom `HStack` bar with tab buttons.

**Behavior**:
- Selected tab shows filled icon variant and primary-colored label.
- Unselected tabs show outlined icon and `onSurfaceVariant` label.
- When `badgeCount` is non-null and > 0: shows `MoltBadge` (count variant) on the icon.
- Badge count > 99 displays as "99+".

**Tab Definitions** (used in M0-04 Navigation):

| Index | Icon (Android) | Icon (iOS) | Label Key | English |
|-------|---------------|------------|-----------|---------|
| 0 | `Icons.Outlined.Home` / `Icons.Filled.Home` | `house` / `house.fill` | `nav_tab_home` | Home |
| 1 | `Icons.Outlined.Category` / `Icons.Filled.Category` | `square.grid.2x2` / `square.grid.2x2.fill` | `nav_tab_categories` | Categories |
| 2 | `Icons.Outlined.ShoppingCart` / `Icons.Filled.ShoppingCart` | `cart` / `cart.fill` | `nav_tab_cart` | Cart |
| 3 | `Icons.Outlined.Person` / `Icons.Filled.Person` | `person` / `person.fill` | `nav_tab_profile` | Profile |

**Text-Based Wireframe**:

```
+------------------------------------------+
|  [house]   [grid]   [cart]   [person]    |
|   Home    Categor.   Cart    Profile     |
|    ^                 (3)                 |
| selected          badge count            |
+------------------------------------------+
```

---

### 3.6 MoltLoadingView

**Purpose**: Loading indicators for full-screen and inline contexts.

**Variants**: `FullScreen` (composable/view), `Inline` (composable/view -- exported as `MoltLoadingIndicator`)

#### MoltLoadingView (Full Screen)

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**: Centered `CircularProgressIndicator` (Android) / `ProgressView` (iOS) inside a
`fillMaxSize` / full-frame container. Uses `MaterialTheme.colorScheme.primary` as tint.

#### MoltLoadingIndicator (Inline)

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**: Smaller centered spinner (24dp Android, default size iOS) with
`MoltSpacing.Base` padding. Fills width. Used at the bottom of paginated lists.

**Text-Based Wireframe**:

```
MoltLoadingView (full screen):
+----------------------------------+
|                                  |
|                                  |
|             ( o )                |  centered spinner
|                                  |
|                                  |
+----------------------------------+

MoltLoadingIndicator (inline):
+----------------------------------+
|             (o)                  |  small spinner, padded
+----------------------------------+
```

---

### 3.7 MoltErrorView

**Purpose**: Full-screen error state with icon, message, and optional retry button.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `message` | `String` | `String` | Yes | -- | Error description |
| `onRetry` | `(() -> Unit)?` | `(() -> Void)?` | No | `null` / `nil` | Retry callback. When non-null, shows retry button. |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**:
- Fills available space (`fillMaxSize` / full frame).
- Centered vertically: error icon (48dp/48pt), spacing, message text (`bodyLarge`, centered),
  spacing, optional `MoltButton` with text from `common_retry_button` string resource.
- Icon: `Icons.Outlined.ErrorOutline` (Android) / `exclamationmark.circle` SF Symbol (iOS).
- Icon tint: `onSurfaceVariant` (subtle, not alarming).

**Text-Based Wireframe**:

```
+----------------------------------+
|                                  |
|             [!]                  |  error icon, 48dp/pt
|                                  |
|   Connection error. Please       |  bodyLarge, centered
|   check your internet.           |
|                                  |
|          [ Retry ]               |  MoltButton, primary (optional)
|                                  |
+----------------------------------+
```

---

### 3.8 MoltEmptyView

**Purpose**: Full-screen empty state for lists and screens with no content.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `message` | `String` | `String` | Yes | -- | Empty state description |
| `icon` | `ImageVector` | `String` (SF Symbol name) | No | `Icons.Outlined.Inbox` / `"tray"` | Large illustration icon |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**:
- Fills available space.
- Centered vertically: large icon (64dp/64pt) in `onSurfaceVariant` color, spacing, message
  text (`bodyLarge`, `onSurfaceVariant`).
- No action button (feature screens add their own action below if needed).

**Text-Based Wireframe**:

```
+----------------------------------+
|                                  |
|            [inbox]               |  icon, 64dp/pt, onSurfaceVariant
|                                  |
|     Nothing here yet             |  bodyLarge, onSurfaceVariant
|                                  |
+----------------------------------+
```

---

### 3.9 MoltImage

**Purpose**: Async remote image loader with placeholder, crossfade, and error fallback.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `url` | `String?` | `URL?` | No | `null` / `nil` | Image URL |
| `contentDescription` | `String?` | -- | No | `null` | Accessibility label (Android) |
| `contentScale` | `ContentScale` | -- | No | `ContentScale.Crop` | Scale mode (Android) |
| `contentMode` | -- | `ContentMode` | No | `.fill` | Scale mode (iOS) |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Android**: Wraps Coil `AsyncImage` with `ImageRequest.Builder` configured for `crossfade(true)`.
Uses `painterResource(R.drawable.placeholder)` for both `placeholder` and `error` states.

**iOS**: Wraps NukeUI `LazyImage`. Shows `MoltColors.shimmer` background during loading and on
error. Uses `.opacity` transition with 0.25s ease-in-out animation on image appear.

**Behavior**:
- When `url` is null: shows placeholder drawable/color immediately.
- Loading: shows placeholder (Android drawable) / shimmer color (iOS).
- Success: crossfade to loaded image.
- Error: shows placeholder (Android) / shimmer color (iOS). No broken image icon.

**Text-Based Wireframe**:

```
Loading:
+----------------------------+
|                            |
|     [ shimmer/placeholder ]|  gray placeholder
|                            |
+----------------------------+

Success:
+----------------------------+
|                            |
|     [ loaded image ]       |  crossfade in
|                            |
+----------------------------+

Error:
+----------------------------+
|                            |
|     [ placeholder ]        |  same as loading state
|                            |
+----------------------------+
```

---

### 3.10 MoltBadge

**Purpose**: Small indicator for counts (cart items, notifications) or status labels.

**Variants**: `CountBadge`, `StatusBadge`

#### CountBadge

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `count` | `Int` | `Int` | Yes | -- | Badge count. 0 = hidden. > 99 = "99+" |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**:
- Circular badge with `MoltColors.BadgeBackground` background and `MoltColors.BadgeText` text.
- Font: `labelSmall` (11sp/pt).
- When `count <= 0`: badge is not rendered (fully hidden).
- When `count > 99`: displays "99+".
- Size: auto-sized to text, minimum 16dp/16pt diameter circle. Pill shape for multi-digit.

#### StatusBadge

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `text` | `String` | `String` | Yes | -- | Status label |
| `backgroundColor` | `Color` | `Color` | No | `MoltColors.BadgeBackground` | Background color |
| `textColor` | `Color` | `Color` | No | `MoltColors.BadgeText` | Text color |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**:
- Pill-shaped (`MoltCornerRadius.full`) badge with custom colors.
- Font: `labelSmall`.
- Horizontal padding: `MoltSpacing.SM` (8dp/pt). Vertical padding: `MoltSpacing.XXS` (2dp/pt).
- Used for order status labels ("Processing", "Shipped", "Delivered").

**Text-Based Wireframe**:

```
CountBadge:
  (3)       single digit, circle
  (12)      double digit, pill
  (99+)     overflow, pill

StatusBadge:
  [ Processing ]   pill shape, custom colors
  [ Delivered ]    pill shape, success color
```

---

### 3.11 MoltSearchBar

**Purpose**: Search input field with search icon, clear button, and submit action.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `query` | `String` | `String` (Binding) | Yes | -- | Current search text |
| `onQueryChange` | `(String) -> Unit` | `Binding<String>` | Yes | -- | Text change callback |
| `placeholder` | `String` | `String` | No | `stringResource(R.string.common_search_placeholder)` / `String(localized: "common_search_placeholder")` | Placeholder text |
| `onSearch` | `((String) -> Unit)?` | `((String) -> Void)?` | No | `null` / `nil` | Submit/IME action callback |
| `onClear` | `() -> Unit` | `() -> Void` | Yes | -- | Clear button callback |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**:
- Leading icon: `Icons.Outlined.Search` (Android) / `magnifyingglass` SF Symbol (iOS). Not
  tappable.
- Trailing icon: `Icons.Outlined.Clear` / `xmark.circle.fill` when query is non-empty. Tappable
  (calls `onClear`). Hidden when query is empty.
- Keyboard action: `ImeAction.Search` (Android) / `.search` return key type (iOS). Calls
  `onSearch` on submit.
- Shape: `MoltCornerRadius.full` (pill shape, 999dp/pt corner radius).
- Background: `surfaceVariant` color.
- No elevation/shadow.

**Text-Based Wireframe**:

```
Empty:
+------------------------------------------+
|  [Q]  Search                             |
+------------------------------------------+

With text:
+------------------------------------------+
|  [Q]  running shoes              [X]     |
+------------------------------------------+

Q = search icon, X = clear button
Pill shape, surfaceVariant background
```

---

### 3.12 MoltDivider

**Purpose**: Thin horizontal separator line between content sections.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `thickness` | `Dp` | `CGFloat` | No | `1.dp` / `1` | Line thickness |
| `color` | `Color` | `Color` | No | `MoltColors.Divider` / `MoltColors.divider` | Line color |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Android**: Wraps `HorizontalDivider` (Material 3).
**iOS**: `Rectangle()` with `.frame(height:)` and `.foregroundStyle()`.

**Behavior**: Simple horizontal line. Fills available width. No padding (callers add their own).

**Text-Based Wireframe**:

```
Content above
──────────────────────────────────  <- MoltDivider, 1dp/pt, divider color
Content below
```

---

### 3.13 MoltPriceText

**Purpose**: Locale-aware formatted price display with optional sale price and strikethrough.

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `amount` | `Long` | `Int` | Yes | -- | Price in cents (e.g., 2999 = EUR 29.99) |
| `originalAmount` | `Long?` | `Int?` | No | `null` / `nil` | Original price in cents (before discount) |
| `currencyCode` | `String` | `String` | No | `"EUR"` | ISO 4217 currency code |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**:
- Formats `amount` as currency using `NumberFormat.getCurrencyInstance()` (Android) /
  `Decimal.FormatStyle.Currency(code:)` (iOS) with the user's current locale.
- The display format should respect locale conventions (e.g., `EUR 29.99` or `29,99 EUR`).
- When `originalAmount` is non-null and different from `amount`:
  - Current price: `MoltColors.PriceSale` / `priceSale` color, `titleMedium` weight.
  - Original price: `MoltColors.PriceOriginal` / `priceOriginal` color, `bodyMedium`,
    `TextDecoration.LineThrough` (Android) / `.strikethrough()` (iOS).
  - Layout: current price first, then original price with `MoltSpacing.XS` gap.
- When `originalAmount` is null: price in `MoltColors.PriceRegular` / `priceRegular` color,
  `titleMedium` weight.

**Text-Based Wireframe**:

```
Regular price:
  EUR 29.99                    priceRegular, titleMedium

Sale price:
  EUR 29.99  EUR 39.99         priceSale + priceOriginal (strikethrough)
              ~~~~~~~~
```

---

### 3.14 MoltRatingBar

**Purpose**: Star rating display (read-only, not interactive).

**Props**:

| Prop | Android Type | iOS Type | Required | Default | Description |
|------|-------------|----------|----------|---------|-------------|
| `rating` | `Float` | `Double` | Yes | -- | Rating value 0.0 - 5.0 |
| `maxRating` | `Int` | `Int` | No | `5` | Maximum number of stars |
| `size` | `Dp` | `CGFloat` | No | `16.dp` / `16` | Individual star size |
| `modifier` | `Modifier` | -- | No | `Modifier` | Layout modifier |

**Behavior**:
- Renders `maxRating` stars in a horizontal row with `MoltSpacing.XXS` (2dp/pt) spacing.
- Full stars: `MoltColors.RatingStarFilled` / `ratingStarFilled`.
- Empty stars: `MoltColors.RatingStarEmpty` / `ratingStarEmpty`.
- Half stars: When `rating` has a fractional part >= 0.25 and < 0.75, render a half-filled star.
  Fractional part >= 0.75 rounds up to full star. < 0.25 rounds down to empty star.
- Icons: `Icons.Filled.Star` / `Icons.Filled.StarHalf` / `Icons.Outlined.StarOutline` (Android);
  `star.fill` / `star.leadinghalf.filled` / `star` SF Symbols (iOS).
- Read-only: no tap interaction, no accessibility adjustable trait.

**Text-Based Wireframe**:

```
rating = 3.5, maxRating = 5:
  [*] [*] [*] [/] [ ]         * = filled, / = half, [ ] = empty

rating = 4.0:
  [*] [*] [*] [*] [ ]

rating = 0.0:
  [ ] [ ] [ ] [ ] [ ]
```

---

## 4. UI Wireframe -- Component Gallery Overview

This section shows how all 14 components relate visually. Feature screens compose these
components; a component gallery/preview screen is not shipped in the app but each component
has its own `@Preview` / `#Preview`.

```
+============================================================+
|  [<]  Component Gallery                           [icon]    |  MoltTopBar
+============================================================+
|                                                             |
|  +--search bar (pill shape, surfaceVariant bg)----------+   |  MoltSearchBar
|  | [Q]  Search products                            [X]  |   |
|  +------------------------------------------------------+   |
|                                                             |
|  +---ProductCard---+  +---ProductCard---+                   |  MoltCard (ProductCard)
|  |  [  image  ]    |  |  [  image  ]    |                   |  uses MoltImage
|  |  Product Name   |  |  Product Name   |                   |
|  |  Vendor         |  |  Vendor         |                   |
|  |  EUR 29.99      |  |  EUR 19.99 25.00|                   |  MoltPriceText
|  |  ****_ (4.2)    |  |  ***__ (3.0)    |                   |  MoltRatingBar
|  +-----------------+  +-----------------+                   |
|                                                             |
|  ────────────────────────────────────────────────────────   |  MoltDivider
|                                                             |
|  +---InfoCard--------------------------------------------+  |  MoltCard (InfoCard)
|  |  Order #12345                        [ Delivered ]    |  |  MoltBadge (StatusBadge)
|  |  Feb 15, 2026                                         |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [ Primary Button ]                                         |  MoltButton (Primary)
|  [ Secondary Button ]                                       |  MoltButton (Secondary)
|  [ Text Button ]                                            |  MoltButton (Text)
|                                                             |
|  Email                                                      |  MoltTextField
|  +------------------------------------------------------+   |
|  | [mail]  user@example.com                              |   |
|  +------------------------------------------------------+   |
|                                                             |
|  -- Loading --                                              |  MoltLoadingView
|       ( o )                                                 |
|                                                             |
|  -- Error --                                                |  MoltErrorView
|       [!]                                                   |
|   Error message                                             |
|   [ Retry ]                                                 |
|                                                             |
|  -- Empty --                                                |  MoltEmptyView
|     [inbox]                                                 |
|   Nothing here yet                                          |
|                                                             |
+============================================================+
|  [home]  [grid]  [cart]  [person]                           |  MoltBottomBar / MoltTabBar
|   Home   Categ.   Cart   Profile                            |
|                   (3)                                       |  MoltBadge (CountBadge)
+============================================================+
```

---

## 5. Navigation Flow

Not applicable. Design system components are not screens and do not participate in navigation.
They are composed into feature screens that are wired into the navigation graph (M0-04).

---

## 6. State Management

Design system components are stateless UI building blocks. They receive state via props and
emit events via callbacks. There are no ViewModels, no UiState sealed classes, and no side
effects at the component level.

### Component-Level States

| Component | States | How State Is Expressed |
|-----------|--------|----------------------|
| MoltButton | Normal, Loading, Disabled | `enabled` + `loading` props |
| MoltCard | Normal, Pressed | Platform ripple/highlight (automatic) |
| MoltTextField | Normal, Focused, Error, Disabled | `errorMessage` != null triggers error; `enabled` prop |
| MoltTopBar | With/without back, with/without actions | `onBackClick` nullability, `actions` list |
| MoltBottomBar/TabBar | Selected tab, badge counts | `selectedTab` + `MoltTabItem.badgeCount` |
| MoltLoadingView | Always loading (single state) | No props needed |
| MoltLoadingIndicator | Always loading (single state) | No props needed |
| MoltErrorView | Error with/without retry | `onRetry` nullability |
| MoltEmptyView | Always same (single state) | `message` + `icon` |
| MoltImage | Loading, Success, Error | Internal Coil/Nuke state machine |
| MoltBadge (Count) | Visible (count > 0), Hidden (count <= 0) | `count` prop |
| MoltBadge (Status) | Always visible | `text` + colors |
| MoltSearchBar | Empty, Has Text | `query` emptiness controls clear button visibility |
| MoltDivider | Always same (single state) | No dynamic states |
| MoltPriceText | Regular, Sale | `originalAmount` nullability |
| MoltRatingBar | Always same (renders rating) | `rating` prop value |

### State Ownership Rule

Components NEVER hold their own state. The calling screen (via its ViewModel) owns all state
and passes it down as props. Events flow upward via callback props. This is the Unidirectional
Data Flow (UDF) pattern enforced project-wide.

---

## 7. Error Scenarios

### Component-Level Error Handling

| Component | Error Scenario | Behavior |
|-----------|---------------|----------|
| MoltImage | Image URL returns 4xx/5xx or is malformed | Shows placeholder drawable (Android) or shimmer color (iOS). No error icon, no retry. Silent fallback. |
| MoltImage | URL is null | Shows placeholder immediately. Not treated as an error. |
| MoltTextField | Validation error from ViewModel | ViewModel sets `errorMessage` prop. Field shows red border and error text. Component does NOT validate internally. |
| MoltErrorView | Network/server error on a screen | Feature ViewModel sets `UiState.Error(message)`. Screen renders `MoltErrorView` with the message. Retry button calls ViewModel reload function. |
| MoltPriceText | Amount is 0 | Displays formatted zero price (e.g., "EUR 0.00"). Not treated as an error. |
| MoltPriceText | Invalid currency code | Falls back to code-based display (e.g., "XXX 29.99"). No crash. |
| MoltRatingBar | Rating < 0 or > maxRating | Clamp to valid range: `rating.coerceIn(0f, maxRating.toFloat())`. No crash. |
| MoltBadge (Count) | Negative count | Treated as 0; badge is hidden. |
| MoltSearchBar | Extremely long query | Text field handles truncation naturally. No special handling needed. |

### Error Prevention Rules

1. All components must handle null props gracefully (via nullable types and defaults).
2. No component throws exceptions. Invalid input is clamped, defaulted, or silently ignored.
3. Components log warnings via `Timber.w()` (Android) / `Logger.warning()` (iOS) for
   unexpected inputs in debug builds only.
4. No `!!` (Kotlin) or force unwrap (Swift) in any component code.

---

## 8. Accessibility

### Global Requirements (All Components)

- Minimum touch target: 48dp (Android) / 44pt (iOS) for all interactive elements.
- Dynamic Type / font scaling: all text must scale with system font size settings.
- Color contrast: all text meets WCAG AA (>= 4.5:1 for normal text, >= 3:1 for large text).
- No information conveyed by color alone (e.g., error state also has text and icon, not just
  red border).

### Per-Component Accessibility

| Component | Content Description / Label | Traits / Roles | Notes |
|-----------|---------------------------|----------------|-------|
| MoltButton | Text is the label (automatic) | Button role | Loading state announces "Loading" to screen reader |
| MoltCard (Product) | Combine: "{title}, {vendorName}, {formattedPrice}" | Button role (clickable) | Image has decorative role (title conveys info) |
| MoltCard (Info) | "{title}, {subtitle}" | Button role if clickable, none if not | Trailing content has its own labels |
| MoltTextField | `label` prop is the accessibility label | Text field role | Error message announced as error |
| MoltTopBar | Title is heading | Heading role for title | Back button: label from `common_back_button` string |
| MoltBottomBar/TabBar | Tab label is accessibility label | Tab role | Selected state announced. Badge count announced: "{label}, {count} items" |
| MoltLoadingView | "Loading" (`common_loading_message` string) | Progress indicator | Announce to screen reader on appearance |
| MoltLoadingIndicator | "Loading" | Progress indicator | Same as above |
| MoltErrorView | Message text is announced | Alert role (iOS) | Retry button independently labeled |
| MoltEmptyView | Message text is announced | Static text | Icon is decorative |
| MoltImage | `contentDescription` prop (Android), decorative by default | Image role if description provided | When used inside MoltCard, image is decorative (card handles label) |
| MoltBadge (Count) | "{count} new items" or similar | None (visual only) | Parent element (tab) includes badge count in its label |
| MoltBadge (Status) | `text` is the label | Status role | Read as part of parent container |
| MoltSearchBar | Placeholder is accessibility hint; label is "Search" | Search field role | Clear button: "Clear search" label |
| MoltDivider | No accessibility label | Separator role | Ignored by screen readers by default |
| MoltPriceText | Full price text is announced | Static text | Sale: announces "sale price {amount}, original price {originalAmount}" |
| MoltRatingBar | "{rating} out of {maxRating} stars" | Static text (read-only) | Not adjustable (display only) |

### Accessibility Testing Checklist

- [ ] TalkBack (Android) reads every interactive element with correct label
- [ ] VoiceOver (iOS) reads every interactive element with correct label
- [ ] Font scale at 200% does not clip or overlap text
- [ ] All touch targets >= 48dp/44pt
- [ ] No information conveyed solely by color
- [ ] Focus order follows visual order (top-to-bottom, left-to-right)

---

## 9. String Resources

### New String Keys Required

These keys must be added to existing string resource files created in M0-01.

| Key | English (en) | Maltese (mt) | Turkish (tr) |
|-----|-------------|-------------|-------------|
| `nav_tab_home` | Home | Id-Dar | Ana Sayfa |
| `nav_tab_categories` | Categories | Kategoriji | Kategoriler |
| `nav_tab_cart` | Cart | Kartell | Sepet |
| `nav_tab_profile` | Profile | Profil | Profil |
| `common_back_button` | Back | Lura | Geri |
| `common_empty_message` | Nothing here yet | Xejn hawnhekk ghadha | Henuz burada bir sey yok |

### Existing Keys Used by Components

These keys were created in M0-01 and are referenced by design system components:

| Key | Used By | English |
|-----|---------|---------|
| `common_retry_button` | MoltErrorView | Retry |
| `common_loading_message` | MoltLoadingView (accessibility) | Loading... |
| `common_search_placeholder` | MoltSearchBar (default placeholder) | Search |

### Files to Modify

**Android**:
- `android/app/src/main/res/values/strings.xml` -- add 6 new keys
- `android/app/src/main/res/values-mt/strings.xml` -- add 6 new keys
- `android/app/src/main/res/values-tr/strings.xml` -- add 6 new keys

**iOS**:
- `ios/MoltMarketplace/Resources/Localizable.xcstrings` -- add 6 new keys in all 3 languages

---

## 10. File Manifest

### 10.1 Android Component Files

Base path: `android/app/src/main/java/com/molt/marketplace/core/designsystem/component/`

| # | File Name | Description |
|---|----------|-------------|
| 1 | `MoltButton.kt` | Primary, Secondary, Text button variants with loading state. Enum: `MoltButtonStyle`. |
| 2 | `MoltCard.kt` | `ProductCard` and `InfoCard` composables. Uses `MoltImage`, `MoltPriceText`, `MoltRatingBar`. |
| 3 | `MoltTextField.kt` | Outlined text field with label, error, icons, secure mode. |
| 4 | `MoltTopBar.kt` | Top app bar with back button and actions. Data class: `MoltTopBarAction`. |
| 5 | `MoltBottomBar.kt` | Bottom navigation bar with tab items and badge. Data class: `MoltTabItem`. |
| 6 | `MoltLoadingView.kt` | `MoltLoadingView` (full-screen) and `MoltLoadingIndicator` (inline). |
| 7 | `MoltErrorView.kt` | Error state with icon, message, retry button. |
| 8 | `MoltEmptyView.kt` | Empty state with icon and message. |
| 9 | `MoltImage.kt` | Coil `AsyncImage` wrapper with placeholder and crossfade. |
| 10 | `MoltBadge.kt` | `MoltCountBadge` and `MoltStatusBadge` composables. |
| 11 | `MoltSearchBar.kt` | Pill-shaped search input with search icon and clear button. |
| 12 | `MoltDivider.kt` | `HorizontalDivider` wrapper with default token values. |
| 13 | `MoltPriceText.kt` | Locale-aware currency formatter with sale price strikethrough. |
| 14 | `MoltRatingBar.kt` | Star rating display with filled, half, empty stars. |

### 10.2 iOS Component Files

Base path: `ios/MoltMarketplace/Core/DesignSystem/Component/`

| # | File Name | Description |
|---|----------|-------------|
| 1 | `MoltButton.swift` | Primary, Secondary, Text button variants with loading state. Enum: `MoltButtonStyle`. |
| 2 | `MoltCard.swift` | `MoltProductCard` and `MoltInfoCard` views. Uses `MoltImage`, `MoltPriceText`, `MoltRatingBar`. |
| 3 | `MoltTextField.swift` | Text field with label, error, icons, secure mode. |
| 4 | `MoltTopBar.swift` | Navigation bar wrapper with back button and actions. Struct: `MoltTopBarAction`. |
| 5 | `MoltTabBar.swift` | Tab bar with tab items and badge. Struct: `MoltTabItem`. |
| 6 | `MoltLoadingView.swift` | `MoltLoadingView` (full-screen) and `MoltLoadingIndicator` (inline). |
| 7 | `MoltErrorView.swift` | Error state with icon, message, retry button. |
| 8 | `MoltEmptyView.swift` | Empty state with icon and message. |
| 9 | `MoltImage.swift` | NukeUI `LazyImage` wrapper with shimmer placeholder. |
| 10 | `MoltBadge.swift` | `MoltCountBadge` and `MoltStatusBadge` views. |
| 11 | `MoltSearchBar.swift` | Pill-shaped search input with search icon and clear button. |
| 12 | `MoltDivider.swift` | `Rectangle` divider wrapper with default token values. |
| 13 | `MoltPriceText.swift` | Locale-aware currency formatter with sale price strikethrough. |
| 14 | `MoltRatingBar.swift` | Star rating display with filled, half, empty stars. |

### 10.3 String Resource Files (Modified)

| # | File Path | Action |
|---|----------|--------|
| 1 | `android/app/src/main/res/values/strings.xml` | Add 6 new keys (English) |
| 2 | `android/app/src/main/res/values-mt/strings.xml` | Add 6 new keys (Maltese) |
| 3 | `android/app/src/main/res/values-tr/strings.xml` | Add 6 new keys (Turkish) |
| 4 | `ios/MoltMarketplace/Resources/Localizable.xcstrings` | Add 6 new keys (all 3 languages) |

### 10.4 Android Test Files

Base path: `android/app/src/test/java/com/molt/marketplace/core/designsystem/component/`

| # | File Name | Tests |
|---|----------|-------|
| 1 | `MoltButtonTest.kt` | Renders all variants; loading disables click; spinner visible when loading |
| 2 | `MoltCardTest.kt` | ProductCard renders title/price/vendor; InfoCard renders title/subtitle |
| 3 | `MoltTextFieldTest.kt` | Error message shows; secure field masks text; icons render |
| 4 | `MoltTopBarTest.kt` | Back button visible when onBackClick non-null; actions render |
| 5 | `MoltBottomBarTest.kt` | Correct tab selected; badge count renders; callback fires |
| 6 | `MoltLoadingViewTest.kt` | Progress indicator visible |
| 7 | `MoltErrorViewTest.kt` | Message text visible; retry button present/absent based on onRetry |
| 8 | `MoltEmptyViewTest.kt` | Message text and icon visible |
| 9 | `MoltImageTest.kt` | Placeholder shown when URL is null |
| 10 | `MoltBadgeTest.kt` | Count badge hidden when 0; shows "99+" for > 99; status badge renders text |
| 11 | `MoltSearchBarTest.kt` | Clear button visible only when query non-empty; onSearch fires |
| 12 | `MoltDividerTest.kt` | Divider renders with default and custom thickness |
| 13 | `MoltPriceTextTest.kt` | Formats price correctly; sale price shows strikethrough original |
| 14 | `MoltRatingBarTest.kt` | Correct number of filled/half/empty stars |

### 10.5 iOS Test Files

Base path: `ios/MoltMarketplaceTests/Core/DesignSystem/Component/`

| # | File Name | Tests |
|---|----------|-------|
| 1 | `MoltButtonTests.swift` | Renders all variants; loading disables tap; spinner visible when loading |
| 2 | `MoltCardTests.swift` | ProductCard renders title/price/vendor; InfoCard renders title/subtitle |
| 3 | `MoltTextFieldTests.swift` | Error message shows; secure field masks text; icons render |
| 4 | `MoltTopBarTests.swift` | Back button visible when onBackClick non-nil; actions render |
| 5 | `MoltTabBarTests.swift` | Correct tab selected; badge count renders; callback fires |
| 6 | `MoltLoadingViewTests.swift` | Progress indicator visible |
| 7 | `MoltErrorViewTests.swift` | Message text visible; retry button present/absent based on onRetry |
| 8 | `MoltEmptyViewTests.swift` | Message text and icon visible |
| 9 | `MoltImageTests.swift` | Placeholder shown when URL is nil |
| 10 | `MoltBadgeTests.swift` | Count badge hidden when 0; shows "99+" for > 99; status badge renders text |
| 11 | `MoltSearchBarTests.swift` | Clear button visible only when query non-empty; onSearch fires |
| 12 | `MoltDividerTests.swift` | Divider renders with default and custom thickness |
| 13 | `MoltPriceTextTests.swift` | Formats price correctly; sale price shows strikethrough original |
| 14 | `MoltRatingBarTests.swift` | Correct number of filled/half/empty stars |

---

## 11. Build Verification Criteria

The design system components are complete when:

### Android

- [ ] All 14 component files compile without errors
- [ ] `./gradlew assembleDebug` succeeds
- [ ] Every component has at least one `@Preview` function
- [ ] All previews render in Android Studio preview pane without errors
- [ ] All 14 component test files pass: `./gradlew testDebugUnitTest`
- [ ] No new lint warnings from ktlint or detekt
- [ ] String resources parse without errors in all 3 languages
- [ ] No hardcoded strings, colors, or spacing values in component code
- [ ] All colors from `MoltColors`, all spacing from `MoltSpacing`
- [ ] No direct Material 3 component usage in component public APIs (wrapped internally only)

### iOS

- [ ] All 14 component files compile without errors
- [ ] `xcodebuild -scheme MoltMarketplace-Debug build` succeeds
- [ ] Every component has a `#Preview` block
- [ ] All previews render in Xcode preview canvas without errors
- [ ] All 14 component test files pass
- [ ] No new SwiftLint or SwiftFormat warnings
- [ ] String Catalog includes all 6 new keys in all 3 languages
- [ ] No hardcoded strings, colors, or spacing values in component code
- [ ] All colors from `MoltColors`, all spacing from `MoltSpacing`
- [ ] No force unwraps (`!`) in component code
- [ ] Strict Concurrency Checking: no warnings

---

## 12. Implementation Notes for Developers

### For Android Developer

1. Remove `.gitkeep` from `core/designsystem/component/` before adding files.
2. Create components in dependency order: `MoltDivider` and `MoltImage` first (no deps), then
   `MoltButton`, `MoltBadge`, `MoltLoadingView`, `MoltRatingBar`, `MoltPriceText` (simple),
   then `MoltTextField`, `MoltSearchBar`, `MoltErrorView`, `MoltEmptyView` (use MoltButton),
   then `MoltTopBar`, `MoltBottomBar` (use MoltBadge), then `MoltCard` (uses MoltImage,
   MoltPriceText, MoltRatingBar).
3. Every composable must accept `modifier: Modifier = Modifier` as the first optional parameter.
4. Use `@Stable` annotation on any data classes used as composable parameters.
5. Use `stringResource(R.string.xxx)` for all user-facing strings.
6. Wrap every `@Preview` in `MoltTheme { }`.
7. Add string resources to all 3 string XML files before building.
8. Import only from `com.molt.marketplace.core.designsystem.theme.*` for tokens.

### For iOS Developer

1. Remove `.gitkeep` from `Core/DesignSystem/Component/` before adding files.
2. Create components in the same dependency order as Android (see above).
3. Use `String(localized:)` for all user-facing strings.
4. Every view must have a `#Preview` block.
5. All structs conforming to `View` must be `internal` (default) or `public` if needed
   across modules.
6. No `AnyView` -- use `@ViewBuilder` or conditional `some View` returns.
7. Add new keys to `Localizable.xcstrings` for all 3 languages before building.
8. Use `MoltCornerRadius` constants from `MoltTheme.swift` for corner radii.
9. NukeUI dependency already declared in SPM from M0-01.

### Common Rules

- Every component is self-contained in one file (component + its supporting types).
- No component imports feature-level code or network/repository code.
- Components reference `MoltColors`, `MoltSpacing`, `MoltTypography`, `MoltCornerRadius` only.
- All `@Preview` / `#Preview` blocks demonstrate the component in multiple states (normal,
  loading, error, etc.) using `PreviewProvider` (Android) or `#Preview("state name")` (iOS).
- Naming: Android composable functions use `PascalCase`. iOS struct names use `PascalCase`.
- File names match the primary composable/struct name.

---

## 13. Design Transition Notes

When Figma designs arrive, these component files are the ONLY files that change:

| What Changes | Where |
|-------------|-------|
| Colors, shadows, shapes | `MoltButton.kt` / `MoltButton.swift` internal styling |
| Card layout, padding, corner radius | `MoltCard.kt` / `MoltCard.swift` |
| Input field appearance | `MoltTextField.kt` / `MoltTextField.swift` |
| Top bar height, styling | `MoltTopBar.kt` / `MoltTopBar.swift` |
| Tab bar icons, layout | `MoltBottomBar.kt` / `MoltTabBar.swift` |
| Loading spinner style | `MoltLoadingView.kt` / `MoltLoadingView.swift` |
| Error/empty illustrations | `MoltErrorView.kt` / `MoltEmptyView.swift` etc. |
| Badge size, shape | `MoltBadge.kt` / `MoltBadge.swift` |
| Price text layout | `MoltPriceText.kt` / `MoltPriceText.swift` |
| Star icons, spacing | `MoltRatingBar.kt` / `MoltRatingBar.swift` |

**What NEVER changes**: Feature screen code, ViewModels, UseCases, Repositories, DTOs, domain
models, navigation, API integration, tests (unless component props change).

Component prop signatures are the contract. Prop names and types should be considered stable
after M0-02 is complete. Visual implementation behind those props can change freely.
