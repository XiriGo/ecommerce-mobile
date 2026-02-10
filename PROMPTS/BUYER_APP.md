# Molt Marketplace — Buyer Mobile App Requirements

## Overview

Native mobile buyer application for the Molt Marketplace. Users can browse products from multiple vendors, search, filter, add to cart, checkout, track orders, and manage their profile. The app connects to the Medusa v2 backend via REST API.

---

## Phase M0: Foundation

### M0-01: App Scaffold
- Android: Kotlin 2.1+, Jetpack Compose, Material 3, Gradle KTS with version catalog
- iOS: Swift 6+, SwiftUI, Xcode 16+, SPM
- Both: Clean Architecture (data/domain/presentation), feature-based package structure
- Base Application/App class with DI initialization
- Environment config (dev/staging/prod) with different base URLs
- Splash screen with app logo

### M0-02: Design System
- **Colors**: Primary (brand color), Secondary, Tertiary, Surface, Background, Error, OnPrimary, OnSecondary, etc.
- **Typography**: DisplayLarge/Medium/Small, HeadlineLarge/Medium/Small, TitleLarge/Medium/Small, BodyLarge/Medium/Small, LabelLarge/Medium/Small
- **Spacing**: 4dp/pt increments (4, 8, 12, 16, 24, 32, 48, 64)
- **Corner Radius**: small (4), medium (8), large (12), extraLarge (16), full (999)
- **Elevation**: level0-5
- **Common Components**:
  - `MoltButton` (primary, secondary, outlined, text variants)
  - `MoltTextField` (with label, error, helper text)
  - `MoltCard` (product card, info card)
  - `MoltChip` (filter chip, category chip)
  - `LoadingView` (full screen, inline)
  - `ErrorView` (with retry button, message)
  - `EmptyView` (with illustration, message, action button)
  - `MoltImage` (async loading with placeholder and error state)
  - `RatingBar` (star rating display, 1-5)
  - `PriceText` (formatted price with currency, sale price strikethrough)
  - `Badge` (notification count, status indicator)
  - `QuantityStepper` (+/- buttons with count)

### M0-03: Network Layer
- Base URL from environment config
- Auth token injection:
  - Android: OkHttp Interceptor adds `Authorization: Bearer {token}` header
  - iOS: URLSession middleware adds same header
- Token refresh: On 401 response, attempt refresh via `/auth/token/refresh`, retry original request
- Error response parsing: Medusa error format `{ type, message, code }`
- Request/response logging (debug builds only)
- Timeout: 30s connection, 60s read
- Retry policy: 3 retries with exponential backoff for 5xx errors

### M0-04: Navigation
- **Tab Bar** (bottom navigation):
  - Home (house icon)
  - Categories (grid icon)
  - Cart (shopping cart icon with badge count)
  - Profile (person icon)
- **Navigation Stack** per tab (independent back stacks)
- **Type-safe routes**: Sealed class (Android) / Enum (iOS) with associated values for params
- **Deep Links**:
  - `molt://product/{id}` → Product Detail
  - `molt://category/{id}` → Category Products
  - `molt://order/{id}` → Order Detail
  - `molt://cart` → Cart
- **Modal sheets**: Login required, filters, sort options
- **Transitions**: Default platform animations (Material motion / iOS push)

### M0-05: DI Setup
- **Android (Hilt)**:
  - `@Singleton`: API client, auth token storage, database
  - `@ViewModelScoped`: Repositories, use cases
  - Modules: NetworkModule, StorageModule, RepositoryModule (per feature)
- **iOS (DI Container)**:
  - Protocol: `protocol Resolver { func resolve<T>(_ type: T.Type) -> T }`
  - Lazy initialization for all dependencies
  - Feature-level sub-containers for isolation

### M0-06: Auth Infrastructure
- **Token Storage**:
  - Android: EncryptedDataStore (EncryptedSharedPreferences fallback)
  - iOS: Keychain via KeychainAccess or custom wrapper
- **Auth State**: `sealed interface AuthState { LoggedIn(token, customer), LoggedOut, Loading, TokenExpired }`
- **Session Management**:
  - On app launch: check token validity, refresh if expired
  - On 401: attempt refresh, if fails → LoggedOut
  - On logout: clear tokens, clear cart, navigate to home
- **Auth Flow**:
  - Login: POST /auth/customer/emailpass → token → POST /auth/session → session → GET /store/customers/me → customer data
  - Register: POST /auth/customer/emailpass (register) → auto-login
  - Logout: DELETE /auth/session → clear local data

---

## Phase M1: Core Buyer Features

### M1-01: Login Screen
- **Layout**: App logo top, email field, password field (with show/hide toggle), "Login" button, "Forgot Password?" link, divider "or", "Create Account" button
- **Validation**: Email format (regex), password min 6 chars
- **States**: Idle, Loading (button disabled, spinner), Error (inline message), Success (navigate to previous screen or home)
- **API**: POST /auth/customer/emailpass `{ email, password }` → `{ token }`
- **Error Messages**: "Invalid email or password", "Network error, try again", "Too many attempts"

### M1-02: Register Screen
- **Layout**: "Create Account" title, first name, last name, email, password (with strength indicator), confirm password, terms checkbox, "Register" button, "Already have an account? Login" link
- **Validation**: All fields required, email format, password min 8 chars with 1 uppercase + 1 number, passwords match, terms accepted
- **States**: Idle, Loading, Validation Error (per field), Server Error, Success
- **API**: POST /auth/customer/emailpass `{ email, password }` (register) → POST /store/customers `{ first_name, last_name, email }` → auto-login
- **After success**: Navigate to home with welcome message

### M1-03: Forgot Password
- **Step 1 - Email**: Email input, "Send Reset Code" button
  - API: POST /store/customers/password-token `{ email }`
- **Step 2 - Code**: 6-digit OTP input, "Verify" button, "Resend Code" link
- **Step 3 - New Password**: New password, confirm password, "Reset Password" button
  - API: POST /store/customers/password `{ email, token, password }`
- **After success**: Navigate to login with "Password reset successfully" message

### M1-04: Home Screen
- **Layout** (top to bottom):
  1. Search bar (tap to navigate to search screen)
  2. Hero banner carousel (auto-scroll every 5s, manual swipe, page indicator dots)
  3. Category chips (horizontal scroll, icon + label)
  4. "Featured Products" section header with "See All" link → product list
  5. Product grid (2 columns, first 6 products)
  6. "New Arrivals" section header with "See All" link
  7. Product grid (2 columns, latest 6 products)
- **Pull-to-refresh**: Refresh all sections
- **API**: GET /store/products?limit=6&order=-created_at (new arrivals), GET /store/products?limit=6&tag=featured (featured), GET /store/product-categories?limit=10

### M1-05: Category Browsing
- **Category List**: Grid of category cards (image, name, product count)
- **Subcategories**: If category has children, show subcategory chips at top
- **Category Products**: Product grid filtered by category (reuse ProductList component)
- **API**: GET /store/product-categories (with parent_category_id for subcategories), GET /store/products?category_id[]=xxx

### M1-06: Product List
- **Layout**: Grid (2 columns, default) / List (1 column) toggle button
- **Product Card**:
  - Image (16:9 aspect ratio)
  - Product title (max 2 lines, ellipsis)
  - Price (formatted with currency symbol, sale price with strikethrough)
  - Vendor name (small text)
  - Rating (stars + count)
  - Wishlist heart icon (top right of image)
- **Pagination**: Infinite scroll, offset-based (limit=20)
- **Sort**: Bottom sheet with options: "Recommended", "Price: Low to High", "Price: High to Low", "Newest", "Best Rating"
- **Filter Chips**: Quick filter chips at top (on sale, free shipping, rating 4+)
- **Pull-to-refresh**: Reset to page 1
- **API**: GET /store/products?limit=20&offset={n}&order={field}

### M1-07: Product Detail
- **Layout** (scrollable):
  1. Image gallery (horizontal pager, page indicator, pinch-to-zoom, fullscreen on tap)
  2. Price section (current price large, original price strikethrough if on sale, discount percentage badge)
  3. Title (full, no truncation)
  4. Rating row (stars, average, review count, "See All Reviews" link)
  5. Variant selector (e.g., Size: S/M/L/XL chips, Color: color circles)
  6. Vendor card (logo, name, rating, "Visit Store" link)
  7. Description (expandable, "Read More" for long text)
  8. Specifications table (key-value pairs)
  9. "You May Also Like" horizontal product scroll (related products)
- **Sticky Bottom Bar**: Quantity selector, "Add to Cart" button (with price)
- **States**: Loading (skeleton), Success, Error (retry), Not Found
- **API**: GET /store/products/{id}?fields=+variants,+images,+categories,+tags,+options

### M1-08: Product Search
- **Search Bar**: Auto-focus, debounce 300ms, clear button
- **Recent Searches**: Local storage, max 10, clear all button
- **Search Suggestions**: As-you-type suggestions (from product titles)
- **Results**: Product grid (reuse ProductList), with result count "X products found"
- **Empty State**: "No products found for '{query}'" with illustration
- **API**: GET /store/products?q={query}&limit=20&offset={n}

---

## Phase M2: Commerce Features

### M2-01: Cart
- **Cart Item**: Product image, title, selected variant text, unit price, quantity stepper (1-99), line total, swipe-to-delete (or long-press delete on iOS)
- **Cart Summary**: Subtotal, estimated shipping, estimated tax, discount (if coupon applied), total
- **Coupon Input**: Text field + "Apply" button, applied coupon chip with remove
- **Empty Cart**: Illustration, "Your cart is empty" message, "Browse Products" button
- **"Proceed to Checkout"**: Button at bottom, disabled if cart empty, requires login (show login modal if not authenticated)
- **API**:
  - Create cart: POST /store/carts
  - Add item: POST /store/carts/{id}/line-items `{ variant_id, quantity }`
  - Update quantity: POST /store/carts/{id}/line-items/{line_id} `{ quantity }`
  - Remove item: DELETE /store/carts/{id}/line-items/{line_id}
  - Apply discount: POST /store/carts/{id}/promotions `{ code }`
- **Local Persistence**: Cart ID stored locally, re-fetch on app launch

### M2-02: Wishlist
- **Heart Toggle**: On product cards (ProductList, Home) and Product Detail
- **Wishlist Screen**: Accessible from Profile tab, product grid with remove option
- **Local Storage**: Store product IDs in DataStore/UserDefaults
- **Sync**: When logged in, optionally sync with backend (future)
- **Empty State**: "No favorites yet" with illustration

### M2-03: Address Management
- **Address List**: Cards showing name, address lines, city/state, postal code, country, phone. Default address badge. Edit/Delete swipe actions.
- **Add/Edit Form**: Full name, address line 1, address line 2 (optional), city, state/province, postal code, country (dropdown), phone number. Country-specific validation.
- **API**:
  - List: GET /store/customers/me/addresses
  - Add: POST /store/customers/me/addresses `{ first_name, last_name, address_1, city, province, postal_code, country_code, phone }`
  - Update: POST /store/customers/me/addresses/{id}
  - Delete: DELETE /store/customers/me/addresses/{id}

### M2-04: Checkout - Address Selection
- **Layout**: "Shipping Address" title, list of saved addresses (radio select), "Add New Address" button, selected address summary, "Continue" button
- **New Address**: Bottom sheet with address form
- **API**: POST /store/carts/{id} `{ shipping_address: { ... } }`

### M2-05: Checkout - Shipping Method
- **Layout**: "Shipping Method" title, list of shipping options (radio select, each showing: provider name, estimated delivery, price), "Continue" button
- **API**: GET /store/shipping-options?cart_id={id}, POST /store/carts/{id}/shipping-methods `{ option_id }`

### M2-06: Checkout - Payment
- **Layout**: Order summary (items, shipping, total), payment method selection, "Place Order" button
- **Payment Options**: Credit/debit card form (number, expiry, CVV), saved cards (future), cash on delivery (if enabled)
- **API**: POST /store/payment-collections/{id}/payment-sessions `{ provider_id }`, POST /store/carts/{id}/complete
- **Loading**: Full screen loading overlay during payment processing

### M2-07: Order Confirmation
- **Layout**: Success checkmark animation, "Order Placed!" title, order number, order summary, estimated delivery, "Continue Shopping" button, "View Order" button
- **Actions**: Clear cart locally, refresh order list if navigating there
- **Navigation**: Back button goes to home (clear checkout stack)

---

## Phase M3: Post-Purchase & Profile

### M3-01: Order List
- **Tabs**: All, Processing, Shipped, Delivered, Cancelled
- **Order Card**: Order number, date, status badge (colored), total amount, item count, first item thumbnail
- **Infinite scroll**: Paginated
- **Empty State**: Per tab
- **API**: GET /store/orders?limit=20&offset={n}&status={status}

### M3-02: Order Detail
- **Status Timeline**: Vertical stepper showing: Order Placed → Payment Confirmed → Processing → Shipped → Delivered (with dates for completed steps, "Pending" for future steps)
- **Items**: Product image, title, variant, quantity, price
- **Shipping**: Address, carrier, tracking number (tappable → open carrier website)
- **Payment**: Method, last 4 digits, amount
- **Price Breakdown**: Subtotal, shipping, tax, discount, total
- **Actions**: "Cancel Order" (if status allows), "Return Item" (if delivered), "Reorder" (add all items to cart)
- **API**: GET /store/orders/{id}

### M3-03: User Profile
- **View Mode**: Avatar (initials or image), full name, email, phone
- **Edit Mode**: Editable fields, "Save" button
- **Change Password**: Current password, new password, confirm new password
- **API**: GET /store/customers/me, POST /store/customers/me `{ first_name, last_name, phone }`

### M3-04: Payment Methods
- **Card List**: Brand icon, masked number (•••• 4242), expiry date, default badge
- **Add Card**: Card number (with formatting), expiry (MM/YY), CVV, cardholder name
- **Actions**: Set as default, delete
- **Note**: Implementation depends on payment provider (Stripe, etc.)

### M3-05: Notifications
- **Notification List**: Icon, title, message, time ago, read/unread indicator
- **Types**: Order update, promotion, price drop, system
- **Push Notifications**:
  - Android: Firebase Cloud Messaging (FCM)
  - iOS: Apple Push Notification service (APNs)
  - Token registration on login
- **Badge**: Tab bar badge count for unread

### M3-06: Settings
- **Language**: Turkish (default), English. Changes app locale.
- **Theme**: Light, Dark, System (follow device)
- **Notifications**: Toggle for: order updates, promotions, price alerts
- **Account**: About, Terms, Privacy Policy, Rate App, Logout, Delete Account

### M3-07: Product Reviews
- **Review List** (on Product Detail):
  - Summary: Average rating (large), rating distribution bars (5-1 stars), total count
  - Review cards: Stars, title, text, user name, date, helpful count
  - "Write a Review" button (only if purchased and not already reviewed)
- **Write Review**: Star rating picker (tap/drag), title field, text field (min 20 chars), photo upload (optional, max 3), "Submit" button
- **API**: Backend review endpoints (custom)

### M3-08: Vendor Store Page
- **Header**: Banner image, vendor logo (overlapping), vendor name, rating, product count, "Follow" button
- **Tabs**: Products, About
- **Products Tab**: Product grid filtered by vendor (reuse ProductList)
- **About Tab**: Description, contact info, return policy
- **API**: Custom vendor endpoints, GET /store/products filtered by vendor

---

## Phase M4: Advanced Features

### M4-01: Product Q&A
- **Q&A List** (on Product Detail): Questions with answers, sorted by date
- **Ask Question**: Text field, "Ask" button
- **Answers**: Vendor answer highlighted with "Vendor" badge
- **API**: Custom Q&A endpoints

### M4-02: Recently Viewed
- **Home Section**: Horizontal scroll of last 10 viewed products
- **Dedicated Screen**: Full list accessible from profile or home
- **Storage**: Local (DataStore/UserDefaults), max 50 products
- **Clear**: "Clear History" option

### M4-03: Price Alerts
- **Set Alert**: On Product Detail, "Notify me when price drops" button
- **Target Price**: Optional target price input (or just "any drop")
- **Alert List**: Accessible from profile, active alerts with current/target price
- **Notification**: Push notification when price drops

### M4-04: Share Product
- **Share Button**: On Product Detail toolbar
- **Content**: Product title, price, deep link URL, product image
- **Android**: Intent.ACTION_SEND with text/plain + image
- **iOS**: ShareLink / UIActivityViewController

### M4-05: App Onboarding
- **Pages** (3-4):
  1. "Browse Thousands of Products" + marketplace illustration
  2. "Compare Vendors & Prices" + comparison illustration
  3. "Fast & Secure Checkout" + payment illustration
  4. "Track Your Orders" + tracking illustration
- **Navigation**: Horizontal swipe, page dots, "Skip" button, "Get Started" on last page
- **Show Once**: Store flag in local storage, never show again

---

## Non-Functional Requirements

### Performance
- App launch to interactive: < 2 seconds
- Screen transition: < 300ms
- Image loading: Progressive/placeholder → full image
- List scrolling: 60fps (no frame drops)
- API response caching: 5 min for product lists, 1 hour for categories

### Accessibility
- All interactive elements have content descriptions
- Dynamic type support (text scales with system settings)
- Minimum touch target: 48dp/pt
- Color contrast ratio: >= 4.5:1
- Screen reader compatibility (TalkBack/VoiceOver)

### Security
- Auth tokens in secure storage (Keychain/EncryptedDataStore)
- No sensitive data in logs
- Certificate pinning for API calls (production)
- Biometric authentication option for login (future)
- ProGuard/R8 obfuscation (Android release)

### Offline Support
- Cached data available offline (read-only)
- Wishlist works offline (syncs when online)
- Cart persists locally
- "No Internet" banner when offline
- Automatic retry when connection restored

### Analytics Events (Future)
- screen_view, product_view, add_to_cart, remove_from_cart
- begin_checkout, purchase, search, filter_applied
- sign_up, login, logout
