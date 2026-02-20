#!/usr/bin/env python3
"""
Migrate feature-queue.jsonl to GitHub Issues + Project Board.

Usage:
    python3 scripts/migrate-to-github.py [--dry-run]

This script:
1. Reads scripts/feature-queue.jsonl
2. Creates GitHub Issues with detailed bodies (requirements, API endpoints, checklist)
3. Assigns milestones and labels
4. Adds all issues to the GitHub Project board
5. Maps dependencies between issues
6. Outputs scripts/issue-map.json for reference
"""

import json
import subprocess
import sys
import time
from pathlib import Path

DRY_RUN = "--dry-run" in sys.argv

# GitHub Project config
PROJECT_NUMBER = 8
PROJECT_OWNER = "atknatk"
PROJECT_ID = "PVT_kwHOACD_yc4BPuzD"
STATUS_FIELD_ID = "PVTSSF_lAHOACD_yc4BPuzDzg-DmhE"
STATUS_BACKLOG = "2d0e9226"
STATUS_READY = "e4e7ba9c"
STATUS_DONE = "37764ee9"

# Milestone mapping (milestone number in GitHub)
MILESTONE_MAP = {
    0: 1,  # M0: Foundation
    1: 2,  # M1: Core Features
    2: 3,  # M2: Commerce
    3: 4,  # M3: User Features
    4: 5,  # M4: Enhancements
}

# Feature type classification
INFRA_FEATURES = {"app-scaffold", "design-system", "network-layer", "navigation", "di-setup", "auth-infrastructure"}

# Priority by layer (lower layer = higher priority)
def get_priority(feature):
    if feature["phase"] == 0:
        return "priority:p0"
    elif feature["layer"] <= 3:
        return "priority:p1"
    else:
        return "priority:p2"

# Requirements from PROMPTS/BUYER_APP.md (extracted per feature)
REQUIREMENTS = {
    "M0-01": [
        "Android: Kotlin 2.1+, Jetpack Compose, Material 3, Gradle KTS with version catalog",
        "iOS: Swift 6+, SwiftUI, Xcode 16+, SPM",
        "Both: Clean Architecture (data/domain/presentation), feature-based package structure",
        "Base Application/App class with DI initialization",
        "Environment config (dev/staging/prod) with different base URLs",
        "Splash screen with app logo",
    ],
    "M0-02": [
        "Colors: Primary, Secondary, Tertiary, Surface, Background, Error + semantic colors",
        "Typography: Display/Headline/Title/Body/Label in Large/Medium/Small",
        "Spacing: 4dp/pt increments (4, 8, 12, 16, 24, 32, 48, 64)",
        "Corner Radius: small (4), medium (8), large (12), extraLarge (16), full (999)",
        "MoltButton: primary, secondary, outlined, text variants",
        "MoltTextField: with label, error, helper text",
        "MoltCard: product card, info card variants",
        "MoltChip: filter chip, category chip",
        "LoadingView: full screen + inline variants",
        "ErrorView: with retry button and message",
        "EmptyView: with illustration, message, action button",
        "MoltImage: async loading with placeholder and error state",
        "RatingBar: star rating display (1-5)",
        "PriceText: formatted price with currency, sale price strikethrough",
        "Badge: notification count, status indicator",
        "QuantityStepper: +/- buttons with count",
    ],
    "M0-03": [
        "Base URL from environment config (dev/staging/prod)",
        "Auth token injection via Interceptor (Android) / middleware (iOS)",
        "Token refresh: On 401, attempt refresh via /auth/token/refresh, retry original request",
        "Error response parsing: Medusa format { type, message, code }",
        "Request/response logging (debug builds only)",
        "Timeout: 30s connection, 60s read",
        "Retry policy: 3 retries with exponential backoff for 5xx errors",
    ],
    "M0-04": [
        "Tab Bar: Home (house), Categories (grid), Cart (cart + badge), Profile (person)",
        "Navigation Stack per tab (independent back stacks)",
        "Type-safe routes: Sealed class (Android) / Enum (iOS) with params",
        "Deep Links: molt://product/{id}, molt://category/{id}, molt://order/{id}, molt://cart",
        "Modal sheets: Login required, filters, sort options",
        "Default platform animations (Material motion / iOS push)",
    ],
    "M0-05": [
        "Android (Hilt): @Singleton for API client, auth storage, database",
        "Android (Hilt): @ViewModelScoped for repositories and use cases",
        "Android: NetworkModule, StorageModule, RepositoryModule per feature",
        "iOS (Factory): Protocol-based with @Injected property wrapper",
        "iOS: Lazy initialization for all dependencies",
        "iOS: Feature-level sub-containers for isolation",
    ],
    "M0-06": [
        "Token Storage: Proto DataStore + Tink (Android), Keychain (iOS)",
        "Auth State: sealed interface with LoggedIn, LoggedOut, Loading, TokenExpired",
        "Session: On app launch check token validity, refresh if expired",
        "On 401: attempt refresh, if fails -> LoggedOut state",
        "On logout: clear tokens, clear cart, navigate to home",
        "Login flow: POST /auth/customer/emailpass -> token -> session -> customer data",
        "Register flow: POST /auth/customer/emailpass/register -> auto-login",
        "Logout flow: DELETE /auth/session -> clear local data",
    ],
    "M1-01": [
        "Layout: App logo, email field, password field (show/hide), Login button",
        "Forgot Password link, divider, Create Account button",
        "Validation: Email format (regex), password min 6 chars",
        "States: Idle, Loading (button disabled, spinner), Error (inline), Success (navigate)",
        "Error Messages: Invalid email or password, Network error, Too many attempts",
    ],
    "M1-02": [
        "Layout: first name, last name, email, password (strength indicator), confirm password",
        "Terms checkbox, Register button, Already have an account? Login link",
        "Validation: All required, email format, password min 8 chars (1 uppercase + 1 number), passwords match, terms accepted",
        "States: Idle, Loading, Validation Error (per field), Server Error, Success",
        "After success: Navigate to home with welcome message",
    ],
    "M1-03": [
        "Step 1 - Email: Email input, Send Reset Code button",
        "Step 2 - Code: 6-digit OTP input, Verify button, Resend Code link",
        "Step 3 - New Password: New password, confirm password, Reset Password button",
        "After success: Navigate to login with success message",
    ],
    "M1-04": [
        "Search bar (tap navigates to search screen)",
        "Hero banner carousel (auto-scroll 5s, manual swipe, page dots)",
        "Category chips (horizontal scroll, icon + label)",
        "Featured Products section with See All link (2-column grid, first 6)",
        "New Arrivals section with See All link (2-column grid, latest 6)",
        "Pull-to-refresh all sections",
    ],
    "M1-05": [
        "Category List: Grid of category cards (image, name, product count)",
        "Subcategories: If has children, show subcategory chips at top",
        "Category Products: Product grid filtered by category (reuse ProductList)",
    ],
    "M1-06": [
        "Grid (2 col) / List (1 col) toggle button",
        "Product Card: image (16:9), title (2 lines), price, vendor name, rating, wishlist heart",
        "Pagination: Infinite scroll, offset-based (limit=20)",
        "Sort: Bottom sheet (Recommended, Price asc/desc, Newest, Best Rating)",
        "Filter Chips: On sale, free shipping, rating 4+",
        "Pull-to-refresh: Reset to page 1",
    ],
    "M1-07": [
        "Image gallery: horizontal pager, dots, pinch-to-zoom, fullscreen on tap",
        "Price: current large, original strikethrough if sale, discount badge",
        "Title (full), Rating row (stars, average, count, See All Reviews)",
        "Variant selector: Size chips, Color circles",
        "Vendor card: logo, name, rating, Visit Store link",
        "Description: expandable Read More for long text",
        "Specifications table (key-value pairs)",
        "You May Also Like: horizontal product scroll",
        "Sticky bottom: Quantity selector + Add to Cart button (with price)",
        "States: Loading (skeleton), Success, Error (retry), Not Found",
    ],
    "M1-08": [
        "Search Bar: auto-focus, debounce 300ms, clear button",
        "Recent Searches: local storage, max 10, clear all",
        "Search Suggestions: as-you-type from product titles",
        "Results: Product grid (reuse ProductList) with count",
        "Empty State: No products found for '{query}' with illustration",
    ],
    "M2-01": [
        "Cart Item: image, title, variant, unit price, quantity stepper (1-99), line total, swipe-to-delete",
        "Cart Summary: Subtotal, shipping estimate, tax estimate, discount, total",
        "Coupon Input: text field + Apply button, applied coupon chip with remove",
        "Empty Cart: illustration, message, Browse Products button",
        "Proceed to Checkout: requires login (show modal if not authenticated)",
        "Local Persistence: Cart ID stored locally, re-fetch on app launch",
    ],
    "M2-02": [
        "Heart Toggle: on product cards and Product Detail",
        "Wishlist Screen: product grid with remove option (from Profile tab)",
        "Local Storage: product IDs in DataStore/UserDefaults",
        "Empty State: No favorites yet with illustration",
    ],
    "M2-03": [
        "Address List: cards with name, address, city/state, postal, country, phone, default badge",
        "Edit/Delete swipe actions",
        "Add/Edit Form: full name, address lines, city, state, postal, country dropdown, phone",
        "Country-specific validation",
    ],
    "M2-04": [
        "Checkout Step 1: Shipping Address selection",
        "Select from saved addresses (radio) or Add New Address",
        "New Address: bottom sheet with address form",
        "Selected address summary + Continue button",
    ],
    "M2-05": [
        "Checkout Step 2: Shipping Method selection",
        "List of shipping options (radio): provider name, delivery estimate, price",
        "Continue button",
    ],
    "M2-06": [
        "Checkout Step 3: Payment",
        "Order summary (items, shipping, total)",
        "Payment method selection (card form, saved cards, cash on delivery)",
        "Place Order button",
        "Full screen loading during payment processing",
    ],
    "M2-07": [
        "Success checkmark animation",
        "Order Placed title + order number + summary + estimated delivery",
        "Continue Shopping button + View Order button",
        "Clear cart locally, back goes to home (clear checkout stack)",
    ],
    "M3-01": [
        "Tabs: All, Processing, Shipped, Delivered, Cancelled",
        "Order Card: order number, date, status badge, total, item count, first item thumbnail",
        "Infinite scroll (paginated)",
        "Empty State per tab",
    ],
    "M3-02": [
        "Status Timeline: vertical stepper (Order Placed -> Confirmed -> Processing -> Shipped -> Delivered)",
        "Items list: image, title, variant, quantity, price",
        "Shipping: address, carrier, tracking number (tappable)",
        "Payment: method, last 4 digits, amount",
        "Price Breakdown: subtotal, shipping, tax, discount, total",
        "Actions: Cancel Order (if allowed), Return Item (if delivered), Reorder",
    ],
    "M3-03": [
        "View Mode: Avatar (initials/image), full name, email, phone",
        "Edit Mode: editable fields + Save button",
        "Change Password: current, new, confirm new password",
    ],
    "M3-04": [
        "Card List: brand icon, masked number, expiry, default badge",
        "Add Card: number (formatted), expiry (MM/YY), CVV, cardholder name",
        "Actions: Set as default, delete",
    ],
    "M3-05": [
        "Notification List: icon, title, message, time ago, read/unread indicator",
        "Types: order update, promotion, price drop, system",
        "Push: FCM (Android), APNs (iOS), token registration on login",
        "Badge: tab bar count for unread",
    ],
    "M3-06": [
        "Language: English (default), Maltese, Turkish - changes app locale",
        "Theme: Light, Dark, System (follow device)",
        "Notification toggles: order updates, promotions, price alerts",
        "Account: About, Terms, Privacy Policy, Rate App, Logout, Delete Account",
    ],
    "M3-07": [
        "Review List: average rating, distribution bars, total count",
        "Review cards: stars, title, text, user name, date, helpful count",
        "Write Review: star picker, title, text (min 20 chars), photo upload (max 3)",
        "Only if purchased and not already reviewed",
    ],
    "M3-08": [
        "Header: banner image, vendor logo, name, rating, product count, Follow button",
        "Tabs: Products (reuse ProductList filtered by vendor), About",
        "About: description, contact info, return policy",
    ],
    "M4-01": [
        "Q&A List on Product Detail: questions with answers, sorted by date",
        "Ask Question: text field + Ask button",
        "Vendor answer highlighted with Vendor badge",
    ],
    "M4-02": [
        "Home Section: horizontal scroll of last 10 viewed products",
        "Dedicated Screen: full list from profile or home",
        "Storage: local (max 50 products), Clear History option",
    ],
    "M4-03": [
        "Set Alert: Notify me when price drops button on Product Detail",
        "Target Price: optional input (or just any drop)",
        "Alert List: from profile, active alerts with current/target price",
        "Push notification when price drops",
    ],
    "M4-04": [
        "Share Button: on Product Detail toolbar",
        "Content: title, price, deep link URL, product image",
        "Android: Intent.ACTION_SEND",
        "iOS: ShareLink / UIActivityViewController",
    ],
    "M4-05": [
        "3-4 onboarding pages with illustrations",
        "Horizontal swipe, page dots, Skip button, Get Started on last page",
        "Show once: flag in local storage, never show again",
    ],
}

# API endpoints per feature
API_ENDPOINTS = {
    "M0-03": [
        ("POST", "/auth/token/refresh", "Refresh expired auth token"),
    ],
    "M0-06": [
        ("POST", "/auth/customer/emailpass", "Login with email/password"),
        ("POST", "/auth/customer/emailpass/register", "Register new auth identity"),
        ("POST", "/auth/session", "Create authenticated session"),
        ("DELETE", "/auth/session", "Logout (destroy session)"),
        ("POST", "/auth/token/refresh", "Refresh token"),
        ("GET", "/store/customers/me", "Get current customer profile"),
    ],
    "M1-01": [
        ("POST", "/auth/customer/emailpass", "Login with email/password"),
        ("POST", "/auth/session", "Create session from token"),
        ("GET", "/store/customers/me", "Fetch customer data after login"),
    ],
    "M1-02": [
        ("POST", "/auth/customer/emailpass/register", "Register auth identity"),
        ("POST", "/store/customers", "Create customer profile"),
        ("POST", "/auth/session", "Auto-login after registration"),
    ],
    "M1-03": [
        ("POST", "/store/customers/password-token", "Request password reset token"),
        ("POST", "/store/customers/password", "Reset password with token"),
    ],
    "M1-04": [
        ("GET", "/store/products?limit=6&order=-created_at", "New arrivals"),
        ("GET", "/store/products?limit=6&tag=featured", "Featured products"),
        ("GET", "/store/product-categories?limit=10", "Category chips"),
    ],
    "M1-05": [
        ("GET", "/store/product-categories", "List categories (with parent_category_id)"),
        ("GET", "/store/products?category_id[]=xxx", "Products by category"),
    ],
    "M1-06": [
        ("GET", "/store/products?limit=20&offset={n}&order={field}", "List products with pagination/sort"),
    ],
    "M1-07": [
        ("GET", "/store/products/{id}?fields=+variants,+images,+categories,+tags,+options", "Product detail"),
    ],
    "M1-08": [
        ("GET", "/store/products?q={query}&limit=20&offset={n}", "Search products"),
    ],
    "M2-01": [
        ("POST", "/store/carts", "Create new cart"),
        ("POST", "/store/carts/{id}/line-items", "Add item to cart"),
        ("POST", "/store/carts/{id}/line-items/{line_id}", "Update quantity"),
        ("DELETE", "/store/carts/{id}/line-items/{line_id}", "Remove item"),
        ("POST", "/store/carts/{id}/promotions", "Apply coupon code"),
    ],
    "M2-03": [
        ("GET", "/store/customers/me/addresses", "List addresses"),
        ("POST", "/store/customers/me/addresses", "Add new address"),
        ("POST", "/store/customers/me/addresses/{id}", "Update address"),
        ("DELETE", "/store/customers/me/addresses/{id}", "Delete address"),
    ],
    "M2-04": [
        ("POST", "/store/carts/{id}", "Update cart shipping address"),
    ],
    "M2-05": [
        ("GET", "/store/shipping-options?cart_id={id}", "List shipping options"),
        ("POST", "/store/carts/{id}/shipping-methods", "Select shipping method"),
    ],
    "M2-06": [
        ("POST", "/store/payment-collections/{id}/payment-sessions", "Create payment session"),
        ("POST", "/store/carts/{id}/complete", "Complete cart -> create order"),
    ],
    "M3-01": [
        ("GET", "/store/orders?limit=20&offset={n}&status={s}", "List orders (filtered)"),
    ],
    "M3-02": [
        ("GET", "/store/orders/{id}", "Get order detail"),
    ],
    "M3-03": [
        ("GET", "/store/customers/me", "Get profile"),
        ("POST", "/store/customers/me", "Update profile"),
    ],
}


def run_gh(args, capture=True):
    """Run a gh CLI command."""
    cmd = ["gh"] + args
    if DRY_RUN:
        print(f"  [DRY RUN] gh {' '.join(args[:5])}...")
        return '{"number": 0, "url": "dry-run"}'
    result = subprocess.run(cmd, capture_output=capture, text=True, timeout=30)
    if result.returncode != 0:
        print(f"  ERROR: {result.stderr.strip()}")
        return None
    return result.stdout.strip() if capture else ""


def build_issue_body(feature, dep_issues):
    """Build the full issue body markdown."""
    fid = feature["id"]
    name = feature["name"]
    pipeline_id = feature["pipeline_id"]
    desc = feature["description"]
    deps = feature.get("deps", [])

    # Requirements
    reqs = REQUIREMENTS.get(fid, [])
    req_lines = "\n".join(f"- [ ] {r}" for r in reqs) if reqs else "- [ ] _(Requirements to be detailed during architect phase)_"

    # API Endpoints
    endpoints = API_ENDPOINTS.get(fid, [])
    if endpoints:
        api_table = "| Method | Path | Purpose |\n|--------|------|---------|"
        for method, path, purpose in endpoints:
            api_table += f"\n| `{method}` | `{path}` | {purpose} |"
    else:
        api_table = "_No direct API endpoints (local-only or custom backend)_"

    # Dependencies
    if deps and dep_issues:
        dep_lines = "\n".join(f"- Depends on #{dep_issues[d]} ({d})" for d in deps if d in dep_issues)
    elif deps:
        dep_lines = "\n".join(f"- Depends on {d}" for d in deps)
    else:
        dep_lines = "_No dependencies_"

    # Spec status
    spec_exists = feature.get("spec_status") == "ready" or feature.get("checkpoint", 0) >= 1
    spec_line = f"`shared/feature-specs/{name}.md`" if spec_exists else "_(To be created by architect)_"

    # Determine feature type for paths
    is_infra = name in INFRA_FEATURES
    if is_infra:
        android_path = f"`android/app/src/main/java/com/molt/marketplace/core/{name.replace('-', '')}/`"
        ios_path = f"`ios/MoltMarketplace/Core/{name.replace('-', '').title()}/`"
    else:
        clean_name = name.replace("-", "")
        android_path = f"`android/app/src/main/java/com/molt/marketplace/feature/{clean_name}/`"
        pascal_name = "".join(w.capitalize() for w in name.split("-"))
        ios_path = f"`ios/MoltMarketplace/Feature/{pascal_name}/`"

    body = f"""## Overview

{desc}

## Requirements

### Functional

{req_lines}

### Non-Functional

- [ ] Loading, success, error, empty states handled on both platforms
- [ ] Min 60fps scroll performance (no frame drops)
- [ ] Accessibility: content descriptions on all interactive elements
- [ ] All strings localized (en, mt, tr) - no hardcoded strings
- [ ] Molt* design system components used (no raw Material 3 / SwiftUI in screens)

## API Endpoints

{api_table}

## Acceptance Criteria

- [ ] Architect spec completed
- [ ] Android implementation complete (Clean Architecture)
- [ ] iOS implementation complete (Clean Architecture)
- [ ] Unit test coverage >= 80% lines, >= 70% branches
- [ ] All lint checks pass (ktlint + detekt + SwiftLint)
- [ ] Architecture tests pass (no layer violations)
- [ ] Cross-platform consistency verified
- [ ] Documentation written

## Pipeline Checklist

- [ ] Architect: Feature spec designed
- [ ] Android Dev: Kotlin + Compose implementation
- [ ] iOS Dev: Swift + SwiftUI implementation
- [ ] Android Tester: Unit + UI tests
- [ ] iOS Tester: Unit + UI tests
- [ ] Doc Writer: Feature docs + CHANGELOG
- [ ] Reviewer: Cross-platform review
- [ ] Quality Gate: Build + Lint + Test pass

## Technical Details

| Item | Value |
|------|-------|
| **Feature ID** | `{fid}` |
| **Pipeline ID** | `{pipeline_id}` |
| **Spec** | {spec_line} |
| **Branch** | `feature/{pipeline_id}` |
| **Android Path** | {android_path} |
| **iOS Path** | {ios_path} |

## Dependencies

{dep_lines}
"""
    return body.strip()


def main():
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    # Read feature queue
    queue_file = project_root / "scripts" / "feature-queue.jsonl"
    features = []
    with open(queue_file) as f:
        for line in f:
            line = line.strip()
            if line:
                features.append(json.loads(line))

    print(f"Found {len(features)} features in queue")
    print(f"{'DRY RUN MODE' if DRY_RUN else 'LIVE MODE'}")
    print("=" * 60)

    # Issue map: feature_id -> github issue number
    issue_map = {}

    # Pass 1: Create all issues
    for i, feature in enumerate(features):
        fid = feature["id"]
        name = feature["name"]
        phase = feature["phase"]
        deps = feature.get("deps", [])
        title = f"[{fid}] {name.replace('-', ' ').title()}"

        # Labels
        labels = [
            f"phase:m{phase}",
            "platform:both",
            "agent:pipeline",
            get_priority(feature),
        ]
        if name in INFRA_FEATURES:
            labels.append("type:infra")
        else:
            labels.append("type:feature")

        # Status label
        if fid == "M0-01":
            # Already completed
            labels.append("status:ready")  # Will be closed after creation
        elif not deps:
            labels.append("status:ready")
        else:
            labels.append("status:blocked")

        # Build body (without dep issue numbers for now)
        body = build_issue_body(feature, issue_map)

        # Milestone number
        milestone = MILESTONE_MAP.get(phase, 1)

        label_args = []
        for l in labels:
            label_args.extend(["--label", l])

        print(f"\n[{i+1}/{len(features)}] Creating: {title}")
        print(f"  Labels: {', '.join(labels)}")
        print(f"  Milestone: M{phase}")

        if DRY_RUN:
            issue_number = i + 1
            issue_map[fid] = issue_number
            print(f"  -> Issue #{issue_number} (dry run)")
            continue

        # Create issue (gh issue create outputs URL like https://github.com/.../issues/N)
        milestone_name = {0: "M0: Foundation", 1: "M1: Core Features", 2: "M2: Commerce", 3: "M3: User Features", 4: "M4: Enhancements"}[phase]
        result = run_gh([
            "issue", "create",
            "--title", title,
            "--body", body,
            "--milestone", milestone_name,
        ] + label_args)

        if result:
            # Parse issue number from URL: https://github.com/owner/repo/issues/N
            try:
                issue_number = int(result.strip().split("/")[-1])
                issue_map[fid] = issue_number
                print(f"  -> Issue #{issue_number}: {result.strip()}")
            except (ValueError, IndexError):
                print(f"  -> Created but couldn't parse number: {result}")
        else:
            print(f"  -> FAILED to create issue for {fid}")
            continue

        # Rate limiting - GitHub API has limits
        time.sleep(0.5)

    print("\n" + "=" * 60)
    print(f"Created {len(issue_map)} issues")

    # Save issue map
    map_file = project_root / "scripts" / "issue-map.json"
    with open(map_file, "w") as f:
        json.dump(issue_map, f, indent=2)
    print(f"Issue map saved to {map_file}")

    # Pass 2: Update issues with dependency links
    print("\n--- Pass 2: Updating dependency links ---")
    for feature in features:
        fid = feature["id"]
        deps = feature.get("deps", [])
        if not deps or fid not in issue_map:
            continue

        issue_num = issue_map[fid]
        dep_links = []
        for dep_id in deps:
            if dep_id in issue_map:
                dep_links.append(f"- Depends on #{issue_map[dep_id]} ({dep_id})")

        if dep_links and not DRY_RUN:
            # Update the issue body with correct dependency links
            body = build_issue_body(feature, issue_map)
            run_gh(["issue", "edit", str(issue_num), "--body", body])
            print(f"  Updated #{issue_num} ({fid}) with dependency links")
            time.sleep(0.3)

    # Pass 3: Add all issues to the project board
    print("\n--- Pass 3: Adding issues to project board ---")
    for fid, issue_num in issue_map.items():
        if DRY_RUN:
            print(f"  [DRY RUN] Would add #{issue_num} to project")
            continue

        # Get the issue node ID
        result = run_gh(["issue", "view", str(issue_num), "--json", "id"])
        if not result:
            continue
        node_id = json.loads(result)["id"]

        # Add to project
        add_result = subprocess.run(
            ["gh", "project", "item-add", str(PROJECT_NUMBER),
             "--owner", PROJECT_OWNER,
             "--url", f"https://github.com/atknatk/molt-mobile/issues/{issue_num}"],
            capture_output=True, text=True, timeout=30
        )

        if add_result.returncode == 0:
            print(f"  Added #{issue_num} ({fid}) to project")
        else:
            print(f"  Failed to add #{issue_num}: {add_result.stderr.strip()}")

        time.sleep(0.3)

    # Pass 4: Close M0-01 (already completed)
    if "M0-01" in issue_map and not DRY_RUN:
        print("\n--- Pass 4: Closing completed issue M0-01 ---")
        run_gh(["issue", "close", str(issue_map["M0-01"]),
                "--reason", "completed",
                "--comment", "Completed in previous sprint. App scaffold fully implemented on both platforms."])
        print(f"  Closed #{issue_map['M0-01']} (M0-01)")

    print("\n" + "=" * 60)
    print("Migration complete!")
    print(f"Project: https://github.com/users/atknatk/projects/{PROJECT_NUMBER}")
    print(f"Issues: {len(issue_map)} created")
    if not DRY_RUN:
        print("\nNext: Run /queue-run M0 to start processing foundation features")


if __name__ == "__main__":
    main()
