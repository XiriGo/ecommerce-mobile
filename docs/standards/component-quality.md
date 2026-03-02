# Component Quality & Performance Standards

> **Scope**: All agents (Android Dev, iOS Dev, Reviewer). These rules are mandatory for all UI components and feature screens.
> **Token file**: `shared/design-tokens/foundations/motion.json`

---

## 1. Lazy Rendering (Mandatory)

**Rule**: All scrollable lists with more than 4 items MUST use lazy rendering containers. No exceptions.

**Why**: Eager rendering (`Column + verticalScroll`, `ScrollView { VStack }`) inflates all items at once, causing frame drops, excessive memory usage, and slow initial render — especially in product grids with images.

### Android (Correct)

```kotlin
// Vertical list
LazyColumn {
    items(products, key = { it.id }) { product ->
        XGProductCard(product = product)
    }
}

// Horizontal list
LazyRow {
    items(categories, key = { it.id }) { category ->
        XGCategoryIcon(category = category)
    }
}

// Product grid
LazyVerticalGrid(
    columns = GridCells.Fixed(2),
    contentPadding = PaddingValues(horizontal = XGSpacing.Medium),
    horizontalArrangement = Arrangement.spacedBy(XGSpacing.Small),
    verticalArrangement = Arrangement.spacedBy(XGSpacing.Small),
) {
    items(products, key = { it.id }) { product ->
        XGProductCard(product = product)
    }
}
```

### Android (Wrong)

```kotlin
// WRONG: Loads all items at once
Column(modifier = Modifier.verticalScroll(rememberScrollState())) {
    products.chunked(2).forEach { row ->
        Row { row.forEach { XGProductCard(it) } }
    }
}
```

### iOS (Correct)

```swift
// Vertical list
ScrollView {
    LazyVStack(spacing: XGSpacing.small) {
        ForEach(products, id: \.id) { product in
            XGProductCard(product: product)
        }
    }
}

// Product grid
ScrollView {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: XGSpacing.small) {
        ForEach(products, id: \.id) { product in
            XGProductCard(product: product)
        }
    }
}
```

### iOS (Wrong)

```swift
// WRONG: VStack without Lazy renders all items immediately
ScrollView {
    VStack {
        ForEach(products, id: \.id) { product in
            XGProductCard(product: product)
        }
    }
}
```

### Key Requirements

- **`key` parameter is mandatory**: Always use the domain model's unique ID (e.g., `product.id`), never the list index
- **Stable keys**: Keys must not change across recompositions/redraws
- **Content padding**: Use `contentPadding` on the lazy container, not padding on a parent wrapper (avoids clipping scroll content)

---

## 2. Shimmer Loading (Animated)

**Rule**: All loading placeholders MUST use an animated gradient sweep (shimmer effect). Never use a static solid color placeholder.

**Why**: Static placeholders look like broken UI. Animated shimmer communicates "loading in progress" and matches user expectations from apps like Amazon, Instagram, and YouTube.

### Shimmer Specification (from `motion.json`)

| Property | Value |
|----------|-------|
| Gradient colors | `#E0E0E0` → `#F5F5F5` → `#E0E0E0` |
| Angle | 20 degrees |
| Duration | 1200ms per sweep |
| Repeat | Infinite, restart mode |
| Corner radius | Match content shape |

### Android Implementation Pattern

```kotlin
// Modifier extension for shimmer effect
fun Modifier.shimmerEffect(): Modifier = composed {
    val transition = rememberInfiniteTransition(label = "shimmer")
    val translateX by transition.animateFloat(
        initialValue = -1000f,
        targetValue = 1000f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1200, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "shimmerTranslate",
    )
    drawWithContent {
        drawContent()
        val brush = Brush.linearGradient(
            colors = listOf(
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
            ),
            start = Offset(translateX, 0f),
            end = Offset(translateX + size.width, size.height),
        )
        drawRect(brush = brush)
    }
}
```

### iOS Implementation Pattern

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color(hex: "#E0E0E0"),
                        Color(hex: "#F5F5F5"),
                        Color(hex: "#E0E0E0")
                    ],
                    startPoint: .init(x: phase, y: 0.5),
                    endPoint: .init(x: phase + 1, y: 0.5)
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}
```

### Rules

- Shimmer shapes MUST match the content shape (card shimmer for cards, text-line shimmer for text)
- Shimmer corner radius matches the component's corner radius token
- Shimmer is used in `XGImage` during loading, in skeleton screens, and anywhere async data is pending

---

## 3. Skeleton Screens

**Rule**: Loading states MUST show layout-matching skeletons, not centered spinners or generic progress indicators.

**Why**: Skeleton screens reduce perceived loading time by ~30% (Google research). They give users a mental model of the incoming layout, reducing layout shift and improving perceived performance.

### Skeleton Design Principles

1. **Match final layout shape**: Each skeleton element corresponds to a real UI element
2. **Use shimmer animation**: All skeleton rectangles use the animated shimmer from Section 2
3. **Approximate dimensions**: Skeleton heights match typical content heights (title = 16dp/pt, subtitle = 12dp/pt, image = actual aspect ratio)
4. **No text or icons**: Skeleton elements are plain rounded rectangles

### Android Pattern

```kotlin
@Composable
fun ProductCardSkeleton(modifier: Modifier = Modifier) {
    XGCard(modifier = modifier) {
        // Image placeholder
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .shimmerEffect()
        )
        Column(modifier = Modifier.padding(XGSpacing.Small)) {
            // Title placeholder
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.8f)
                    .height(16.dp)
                    .clip(RoundedCornerShape(XGCornerRadius.Small))
                    .shimmerEffect()
            )
            Spacer(modifier = Modifier.height(XGSpacing.XSmall))
            // Price placeholder
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.4f)
                    .height(14.dp)
                    .clip(RoundedCornerShape(XGCornerRadius.Small))
                    .shimmerEffect()
            )
        }
    }
}
```

### iOS Pattern

```swift
struct ProductCardSkeleton: View {
    var body: some View {
        XGCard {
            VStack(alignment: .leading, spacing: XGSpacing.small) {
                // Image placeholder
                RoundedRectangle(cornerRadius: XGCornerRadius.medium)
                    .fill(Color.clear)
                    .aspectRatio(1, contentMode: .fit)
                    .shimmerEffect()

                // Title placeholder
                RoundedRectangle(cornerRadius: XGCornerRadius.small)
                    .fill(Color.clear)
                    .frame(height: 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shimmerEffect()

                // Price placeholder
                RoundedRectangle(cornerRadius: XGCornerRadius.small)
                    .fill(Color.clear)
                    .frame(width: 80, height: 14)
                    .shimmerEffect()
            }
        }
    }
}
```

### Rules

- Every screen with async data MUST have a corresponding skeleton variant
- Skeleton is shown during `UiState.Loading` — never a centered `CircularProgressIndicator` / `ProgressView`
- Grid skeletons show the same number of columns as the real grid
- Pull-to-refresh uses inline indicator (not full skeleton replacement) when data already exists

---

## 4. Image Pipeline

**Rule**: All images use the platform image library with memory + disk cache, downsampling, and the 3-state loading pattern.

**Why**: Images are the #1 cause of scroll jank and memory pressure in e-commerce apps. Proper pipeline eliminates both.

### Configuration (from `motion.json`)

| Setting | Value |
|---------|-------|
| Memory cache | 100 MB |
| Disk cache | 250 MB |
| Thumbnail multiplier | 0.1x |
| Progressive loading | Enabled |
| WebP | Preferred format |
| Downsampling | Enabled |

### 3-State Image Loading

```
State 1: LOADING  → Animated shimmer placeholder (matches image frame size)
State 2: SUCCESS  → Crossfade in (300ms) from shimmer to loaded image
State 3: ERROR    → Branded fallback (product silhouette on XGColors.Surface)
```

### Android (Coil)

```kotlin
AsyncImage(
    model = ImageRequest.Builder(LocalContext.current)
        .data(imageUrl)
        .crossfade(300)
        .size(Size.ORIGINAL) // Coil auto-downsamples to ImageView size
        .build(),
    contentDescription = contentDescription,
    contentScale = ContentScale.Crop,
    placeholder = null, // Use shimmer modifier on parent
    error = painterResource(R.drawable.xg_image_fallback),
)
```

### iOS (Nuke)

```swift
LazyImage(url: URL(string: imageUrl)) { state in
    if let image = state.image {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
    } else if state.error != nil {
        Image("xg_image_fallback")
            .resizable()
            .aspectRatio(contentMode: .fit)
    } else {
        RoundedRectangle(cornerRadius: XGCornerRadius.medium)
            .shimmerEffect()
    }
}
```

### Rules

- **Never decode full-resolution images for thumbnails** — always downsample to display size
- **Prefetch next page**: When user scrolls within `prefetchDistance` (5) items of the end, prefetch next page images
- **WebP preferred**: Request WebP format from CDN when available (smaller file size)
- **Cancel on disappear**: Cancel image requests when the view scrolls off screen
- **Never show broken image icon**: Always show branded fallback on error

---

## 5. Recomposition / Redraw Optimization

**Rule**: Minimize unnecessary recompositions (Android) and view redraws (iOS) through proper state management and stability annotations.

**Why**: Unnecessary recomposition is the #1 cause of UI jank in Compose apps. Each unnecessary redraw wastes CPU cycles and can drop frames below 60fps.

### Android Rules

```kotlin
// 1. Mark UI state classes as @Immutable or @Stable
@Immutable
data class ProductCardData(
    val id: String,
    val name: String,
    val price: String,
    val imageUrl: String,
)

// 2. Use derivedStateOf for computed values
val showBadge by remember { derivedStateOf { product.discount > 0 } }

// 3. key() in LazyColumn items — MANDATORY
LazyColumn {
    items(products, key = { it.id }) { product ->
        // Compose skips recomposition if item data unchanged
        XGProductCard(product = product)
    }
}

// 4. Lambda stability — wrap in remember
val onProductClick = remember(viewModel) { { id: String -> viewModel.onProductClick(id) } }
```

### Android Anti-Patterns

```kotlin
// WRONG: Unstable lambda causes recomposition every frame
XGProductCard(
    product = product,
    onClick = { viewModel.onProductClick(product.id) } // New lambda every recomposition
)

// WRONG: Reading mutable state in composition without derivedStateOf
val filtered = products.filter { it.price > threshold } // Recomputes every recomposition
```

### iOS Rules

```swift
// 1. Equatable conformance on view data for diffing
struct ProductCardData: Equatable, Identifiable {
    let id: String
    let name: String
    let price: String
    let imageUrl: String
}

// 2. @Observable for ViewModels (iOS 17+)
@Observable
final class HomeViewModel {
    private(set) var uiState: HomeUiState = .loading
}

// 3. ForEach with explicit id parameter
ForEach(products, id: \.id) { product in
    XGProductCard(product: product)
}

// 4. Avoid unnecessary @State for derived values
// Use computed properties instead of @State for values derived from other state
```

### iOS Anti-Patterns

```swift
// WRONG: @State for a derived value causes extra redraws
@State private var showBadge: Bool = false // Updated in .onChange — unnecessary

// RIGHT: Compute inline
var showBadge: Bool { product.discount > 0 }
```

---

## 6. Scroll State Preservation

**Rule**: Scroll position MUST be preserved when navigating away from and returning to a screen.

**Why**: Losing scroll position forces users to re-scroll to where they were, which is frustrating — especially in long product lists. Every major e-commerce app preserves scroll position.

### Android

```kotlin
@Composable
fun HomeScreen(viewModel: HomeViewModel = hiltViewModel()) {
    // LazyListState is automatically saved/restored with rememberLazyListState
    val listState = rememberLazyListState()

    // For deeper restoration (across process death), save to SavedStateHandle
    LaunchedEffect(listState.firstVisibleItemIndex) {
        viewModel.saveScrollPosition(listState.firstVisibleItemIndex)
    }

    LazyColumn(state = listState) {
        // ...
    }
}
```

### iOS

```swift
struct HomeScreen: View {
    @State private var scrollPosition: String?

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(products, id: \.id) { product in
                    XGProductCard(product: product)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
    }
}
```

### Rules

- `rememberLazyListState()` is sufficient for in-memory restoration (Android)
- For process-death restoration, save `firstVisibleItemIndex` to `SavedStateHandle`
- Pull-to-refresh does NOT reset scroll position (only scrolls to top if user explicitly pulls)
- Screen rotation: not applicable (portrait-only app), but state is preserved regardless

---

## 7. Animation Standards

**Rule**: All animation durations and easing curves MUST come from `motion.json` tokens. Never hardcode animation values.

**Why**: Consistent motion language creates a polished, professional feel. Hardcoded values lead to inconsistent timing across screens and make it impossible to tune globally.

### Duration Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `instant` | 100ms | Micro-interactions (button press feedback) |
| `fast` | 200ms | Content switch, crossfade between states |
| `normal` | 300ms | Standard transitions, image fade-in |
| `slow` | 450ms | Complex transitions, modal appearance |
| `pageTransition` | 350ms | Screen-to-screen navigation |

### Easing Tokens

| Token | Use Case |
|-------|----------|
| `standard` | Most transitions (enter + exit) |
| `decelerate` | Elements entering the screen |
| `accelerate` | Elements leaving the screen |
| `spring` | Interactive gestures, pull-to-refresh, pagination dots |

### Android Patterns

```kotlin
// Content state transition — use AnimatedContent
AnimatedContent(
    targetState = uiState,
    transitionSpec = {
        fadeIn(tween(200, easing = EaseInOut)) togetherWith
            fadeOut(tween(200, easing = EaseInOut))
    },
    label = "contentTransition",
) { state ->
    when (state) {
        is UiState.Loading -> SkeletonScreen()
        is UiState.Success -> ContentScreen(state.data)
        is UiState.Error -> XGErrorView(state.message)
    }
}

// Pagination dots — spring animation
val offsetX by animateFloatAsState(
    targetValue = selectedIndex * dotSpacing,
    animationSpec = spring(
        dampingRatio = 0.7f,
        stiffness = Spring.StiffnessMedium,
    ),
    label = "paginationDot",
)
```

### iOS Patterns

```swift
// Content state transition
Group {
    switch uiState {
    case .loading:
        SkeletonScreen()
    case .success(let data):
        ContentScreen(data: data)
    case .error(let message):
        XGErrorView(message: message)
    }
}
.animation(.easeInOut(duration: 0.2), value: uiState)

// Pagination dots — spring animation
Circle()
    .offset(x: CGFloat(selectedIndex) * dotSpacing)
    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedIndex)
```

### Anti-Patterns

```kotlin
// WRONG: Hardcoded duration
fadeIn(tween(300)) // Where does 300 come from?

// WRONG: No animation on state change
when (uiState) { ... } // Abrupt state switch, no crossfade

// WRONG: Animation on configuration change
// Don't animate on rotation or theme change — only on data/state changes
```

---

## 8. Fallback Chain Pattern

**Rule**: Every async operation MUST have a complete fallback chain. Never show broken/empty/zero states to the user.

**Why**: In e-commerce, a broken image or "€0.00" price kills trust and conversion. Fallback chains ensure graceful degradation.

### Image Fallback Chain

```
Loading → Animated shimmer (matches frame size)
Success → Crossfade to loaded image
Error   → Branded fallback (product silhouette on XGColors.Surface)
```

Never show: broken image icon, empty white box, or platform default error image.

### Network Fallback Chain

```
Cached data available → Show cached data + "Pull to refresh" hint
No cached data        → Show skeleton loading screen
Success               → Crossfade to content
Error (with data)     → Keep showing data + error snackbar with retry
Error (no data)       → XGErrorView with retry button
```

### Price Fallback Chain

```
Price available           → Format with locale (€12.99)
Price null/zero           → Hide entire price section
Original + sale price     → Show original (strikethrough) + sale price
Sale price > original     → Show only original price (data error protection)
```

Never show: "€0.00", empty price text, or unformatted raw numbers.

### Empty State Chain

```
Data loaded, list empty → XGEmptyView with illustration + message + action button
Data loading            → Skeleton screen (not empty view)
Search with no results  → "No results for {query}" with suggestions
```

---

## 9. E-Commerce Specific Patterns

### Product Grid: Uniform Card Heights

All product cards in a grid MUST have uniform height within each row. Use fixed aspect ratio for images and constrained text heights:

```kotlin
// Android: Fixed image aspect ratio + maxLines for text
XGCard {
    XGImage(
        url = product.imageUrl,
        modifier = Modifier.aspectRatio(1f), // Square images
    )
    Text(
        text = product.name,
        maxLines = 2,
        overflow = TextOverflow.Ellipsis,
        style = XGTypography.BodySmall,
    )
}
```

```swift
// iOS: Fixed image aspect ratio + lineLimit for text
XGCard {
    XGImage(url: product.imageUrl)
        .aspectRatio(1, contentMode: .fill)
    Text(product.name)
        .font(XGTypography.bodySmall)
        .lineLimit(2)
}
```

### Add-to-Cart: Optimistic UI

```
User taps "Add to Cart"
→ Immediately update cart badge count (optimistic)
→ Send API request in background
→ On success: confirm (no visible change needed)
→ On failure: rollback badge count + show error snackbar
```

### Countdown Timers (Flash Sales, Daily Deals)

```kotlin
// Android: LaunchedEffect with 1-second tick
LaunchedEffect(endTime) {
    while (endTime > System.currentTimeMillis()) {
        delay(1000L)
        remainingTime = endTime - System.currentTimeMillis()
    }
    // Timer expired — hide or show "Expired" state
}
```

```swift
// iOS: Timer.publish with 1-second interval
.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
    let remaining = endDate.timeIntervalSinceNow
    if remaining <= 0 {
        // Timer expired
    } else {
        remainingTime = remaining
    }
}
```

### Price Formatting

- Always use locale-aware formatters: `NumberFormat.getCurrencyInstance()` (Android) / `NumberFormatter` (iOS)
- Currency: EUR
- Format: `€12.99` (symbol before, dot separator, always 2 decimal places)
- Never concatenate currency symbol manually

### Stock Indicator

- **In stock**: No indicator (default state)
- **Low stock** (< 5): "Only X left" in warning color
- **Out of stock**: Grayed-out card + "Out of Stock" badge, disable add-to-cart

---

## 10. Performance Budgets & Profiling

**Rule**: All screens MUST meet performance budgets before merge. Profile with platform tools.

### Budgets (from `motion.json`)

| Metric | Budget | Tool |
|--------|--------|------|
| Frame time | <= 16ms (60fps) | Android Studio Profiler / Xcode Instruments |
| Cold startup | < 2000ms to first content | Macrobenchmark / XCTest metrics |
| Screen transition | < 300ms | Visual inspection + profiler |
| First contentful paint | < 1000ms | Profiler timeline |
| Scroll jank frames | 0 | Jank stats (Android) / Hitches (iOS) |

### Android Profiling Checklist

- [ ] Run with Layout Inspector — verify recomposition counts (should be minimal)
- [ ] Check Jank stats in Compose metrics — zero jank frames during scroll
- [ ] Memory: no image-related OOM, Coil cache stays within budget
- [ ] LeakCanary: zero leaks
- [ ] Baseline Profile: generated and included for critical paths

### iOS Profiling Checklist

- [ ] Instruments → Animation Hitches — zero hitches during scroll
- [ ] Instruments → Allocations — no excessive image memory
- [ ] Instruments → Time Profiler — no main-thread image decoding
- [ ] Memory graph: no retain cycles in ViewModels or image loading
- [ ] Scroll test: 60fps sustained during rapid scroll in product grid

### Rules

- Image decoding MUST happen off the main thread (both platforms handle this by default with Coil/Nuke)
- Never perform synchronous network calls on the main thread
- Large lists: measure with 100+ items to catch scaling issues
- Profiling is the Reviewer's responsibility during code review (see `docs/standards/faang-rules.md`)

---

## Quick Reference: Anti-Pattern Detector

Use this checklist during code review to catch violations:

| Anti-Pattern | Grep Pattern | Fix |
|-------------|-------------|-----|
| Eager list rendering (Android) | `Column.*verticalScroll` with `forEach` | Replace with `LazyColumn` |
| Eager list rendering (iOS) | `ScrollView.*VStack.*ForEach` (without `Lazy`) | Replace with `LazyVStack` |
| Static shimmer | `Color.Gray` or `Color.LightGray` as placeholder | Use `shimmerEffect()` modifier |
| Missing key in lazy list | `items(list)` without `key =` | Add `key = { it.id }` |
| Hardcoded animation duration | `tween(300)`, `withAnimation(.linear(duration: 0.3))` | Use motion.json token constant |
| Broken image fallback | No error state in image loading | Add branded fallback |
| Centered spinner for loading | `CircularProgressIndicator` in `Box(center)` | Replace with skeleton screen |
| Price showing €0.00 | No null check before price display | Hide section if price is null |
| Hardcoded hex color | `Color(0xFF...)` or `Color(hex: "#...")` in component | Use `XGColors.*` token |
| Missing `XGMotion` reference | `tween(100)`, `.easeInOut(duration: 0.1)` | Use `XGMotion.Duration.*` + `XGMotion.Easing.*` |
| Non-skeleton loading in feature | `XGLoadingView()` without skeleton slot | Provide custom skeleton layout matching the screen |

---

## 11. DQ Backfill Lessons Learned

The Design Quality (DQ) backfill (40 issues, DQ-01 through DQ-40) upgraded every design system component to production-quality standards. These are the key learnings that inform all future component development.

### Token-First Development

**Lesson**: Every new component MUST start with its design token JSON file before any platform code is written.

**Why**: The DQ backfill revealed that components built without token files (M0 phase) accumulated hardcoded values that required costly audits later. Components built token-first (DQ-19 onward) shipped with full compliance on the first iteration.

**Workflow**:
1. Create `shared/design-tokens/components/{atoms|molecules|brand}/<component>.json`
2. Define all visual properties: colors, sizes, spacing, corner radius, typography, motion references
3. Reference foundation tokens (`$foundations/colors.*`, `$foundations/motion.*`) rather than raw values
4. Implement platform code referencing token constants only

### Skeleton-First Loading

**Lesson**: Design the skeleton layout at the same time as the component, not as an afterthought.

**Why**: Retrofitting skeletons after the component is done requires re-analyzing the layout. Designing them together ensures the skeleton precisely mirrors the content shape.

**Pattern**:
- Every `XGProductCard` has a `ProductCardSkeleton`
- Every `XGHeroBanner` has a `HeroBannerSkeleton`
- Every screen-level loading state uses a composite skeleton, not a centered spinner

### Motion Token Adoption

**Lesson**: Replace ALL hardcoded animation values with `XGMotion` references during initial implementation.

**DQ findings**:
- `XGPaginationDots` had `tween(300ms)` replaced with `XGMotion.Easing.springSpec()` (DQ-09)
- `XGWishlistButton` had no animation, received `XGMotion.Duration.INSTANT` + spring bounce (DQ-15)
- `XGHeroBanner` auto-scroll interval was hardcoded, replaced with `XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS` (DQ-23)

**Rule**: Grep the codebase for raw duration values (`tween(`, `withAnimation(.linear(duration:`) before any PR merge.

### Brand Color Centralization

**Lesson**: Brand-specific colors (gradient stops, pattern opacity, social auth icons) belong in `XGColors`, not as local constants.

**DQ findings** (DQ-33): `XGBrandGradient`, `XGBrandPattern`, and `XGLogoMark` had hardcoded hex literals that duplicated values. The fix added 5 new gradient tokens and 1 opacity constant to `XGColors`, making all brand components consistent.

### Component Variant Extraction

**Lesson**: When a component needs multiple visual modes, extract a typed enum (e.g., `XGTopBarVariant`, `XGBadgeVariant`) rather than using boolean flags.

**Examples**:
- `XGTopBarVariant.surface` / `.transparent` (DQ-29)
- `XGBadgeVariant.primary` / `.secondary` (DQ-08)
- `XGPriceLayout.inline` / `.stacked` (DQ-38)

### Uniform Card Height in Grids

**Lesson**: Product cards in grid layouts MUST reserve space for optional elements using invisible spacers.

**DQ finding** (DQ-22): Cards with rating bars were taller than cards without, causing uneven grid rows. The fix added a `reserveSpace` parameter that renders invisible spacers for optional rows, ensuring uniform height regardless of data presence.

### Cross-Platform Consistency Checklist

Apply to every new component:

- [ ] Same token JSON file referenced on both platforms
- [ ] Same visual behavior (colors, spacing, corner radius)
- [ ] Same interaction model (tap, toggle, swipe)
- [ ] Same accessibility labels (localized in EN/MT/TR)
- [ ] Same animation timing via `XGMotion` tokens
- [ ] Same skeleton layout (if applicable)
- [ ] Platform-idiomatic naming (`XGButtonStyle` on Android, `XGButtonVariant` on iOS)
- [ ] `#Preview` / `@Preview` for all visual states
