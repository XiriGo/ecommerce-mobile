# Agent Teams Prompt Reference

Copy-paste these prompts to run Agent Teams or individual subagents.

---

## Full Pipeline (Agent Teams)

### Syntax

```
/pipeline-run <feature-id> <feature-name>
```

### M0 — Foundation

```
/pipeline-run M0-01 app-scaffold
```

```
/pipeline-run M0-02 design-system
```

```
/pipeline-run M0-03 network-layer
```

```
/pipeline-run M0-04 navigation
```

```
/pipeline-run M0-05 di-setup
```

```
/pipeline-run M0-06 auth-infrastructure
```

### M1 — Core Buyer Features

```
/pipeline-run M1-01 login-screen
```

```
/pipeline-run M1-02 register-screen
```

```
/pipeline-run M1-03 forgot-password
```

```
/pipeline-run M1-04 home-screen
```

```
/pipeline-run M1-05 category-browsing
```

```
/pipeline-run M1-06 product-list
```

```
/pipeline-run M1-07 product-detail
```

```
/pipeline-run M1-08 product-search
```

### M2 — Commerce

```
/pipeline-run M2-01 cart
```

```
/pipeline-run M2-02 wishlist
```

```
/pipeline-run M2-03 address-management
```

```
/pipeline-run M2-04 checkout-address
```

```
/pipeline-run M2-05 checkout-shipping
```

```
/pipeline-run M2-06 checkout-payment
```

```
/pipeline-run M2-07 order-confirmation
```

### M3 — Post-Purchase & Profile

```
/pipeline-run M3-01 order-list
```

```
/pipeline-run M3-02 order-detail
```

```
/pipeline-run M3-03 user-profile
```

```
/pipeline-run M3-04 payment-methods
```

```
/pipeline-run M3-05 notifications
```

```
/pipeline-run M3-06 settings
```

```
/pipeline-run M3-07 product-reviews
```

```
/pipeline-run M3-08 vendor-store-page
```

### M4 — Advanced Features

```
/pipeline-run M4-01 product-qna
```

```
/pipeline-run M4-02 recently-viewed
```

```
/pipeline-run M4-03 price-alerts
```

```
/pipeline-run M4-04 share-product
```

```
/pipeline-run M4-05 app-onboarding
```

---

## Individual Subagent Prompts

### Architect — Design a Feature Spec

```
Use the architect subagent to design a platform-agnostic spec for the {feature-name} feature (feature ID: {feature-id}).

Read PROMPTS/BUYER_APP.md for requirements.
Read shared/api-contracts/ for API contracts.
Output to shared/feature-specs/{feature-name}.md
```

### Android Dev — Implement a Feature

```
Use the android-dev subagent to implement the {feature-name} feature for Android.

Read the spec at shared/feature-specs/{feature-name}.md
Follow Clean Architecture: data/ → domain/ → presentation/
Follow CLAUDE.md Android coding standards.
```

### iOS Dev — Implement a Feature

```
Use the ios-dev subagent to implement the {feature-name} feature for iOS.

Read the spec at shared/feature-specs/{feature-name}.md
Read the Android implementation for consistency.
Follow Clean Architecture: Data/ → Domain/ → Presentation/
Follow CLAUDE.md iOS coding standards.
```

### Android Tester — Write Tests

```
Use the android-tester subagent to write tests for the {feature-name} feature on Android.

Read all source files in android/app/src/main/java/com/molt/marketplace/feature/{name}/
Coverage target: >= 80% lines, >= 70% branches.
Use JUnit 4, Truth, MockK, Turbine, Compose UI Test.
Prefer Fake repositories over mocks.
```

### iOS Tester — Write Tests

```
Use the ios-tester subagent to write tests for the {feature-name} feature on iOS.

Read all source files in ios/MoltMarketplace/Feature/{Name}/
Coverage target: >= 80% lines, >= 70% branches.
Use Swift Testing (@Test), ViewInspector, swift-snapshot-testing.
Prefer Fake repositories over mocks.
```

### Doc Writer — Document a Feature

```
Use the doc-writer subagent to document the {feature-name} feature.

Read all source code and handoff files for this feature.
Create docs/features/{feature-name}.md with overview, architecture, screens, file locations.
Update CHANGELOG.md under [Unreleased].
```

### Reviewer — Review a Feature

```
Use the reviewer subagent to review the {feature-name} feature on both platforms.

Check: spec compliance, code quality, cross-platform consistency, test coverage >= 80%, security.
Report issues with severity (critical/warning/info).
Create docs/pipeline/{feature-name}-review.handoff.md
```

---

## Common Workflow Prompts

### Bug Fix (Single Platform)

```
Use the android-dev subagent to fix the bug in {screen/component}: {description}.
After fixing, use the android-tester subagent to verify existing tests pass and add a regression test.
```

```
Use the ios-dev subagent to fix the bug in {screen/component}: {description}.
After fixing, use the ios-tester subagent to verify existing tests pass and add a regression test.
```

### Quick Code Review

```
Use the reviewer subagent to review the changes in the current branch.
Run git diff develop to see all changes, then check for quality, consistency, and security issues.
```

### Add Tests Only

```
Use the android-tester subagent to add missing tests for feature/{name}.
Focus on ViewModel and UseCase layers. Coverage target: 80% lines.
```

```
Use the ios-tester subagent to add missing tests for Feature/{Name}.
Focus on ViewModel and UseCase layers. Coverage target: 80% lines.
```

### Spec Only (No Implementation)

```
Use the architect subagent to design the spec for {feature-name}.
Do NOT implement — only create shared/feature-specs/{feature-name}.md
```

### Cross-Platform Consistency Check

```
Use the reviewer subagent to check cross-platform consistency between
android/app/src/main/java/com/molt/marketplace/feature/{name}/ and
ios/MoltMarketplace/Feature/{Name}/.
Verify: same behavior, same states, same error handling, same navigation flow.
```

---

## Execution Order Reference

### Dependency-Free (Can Run in Parallel)

```
M0-01, M0-02, M0-03, M0-04, M0-05 — all independent
```

### Sequential Dependencies

```
M0-03 + M0-05 → M0-06 (auth needs network + DI)
M0-06 + M0-04 + M0-02 → M1-01, M1-02, M1-03 (auth screens need auth + nav + design)
M0-02 + M0-04 + M0-03 → M1-04 (home needs design + nav + network)
M1-04 → M1-05, M1-06 (browsing/list needs home)
M1-06 → M1-07, M1-08 (detail/search needs product list)
M1-07 → M2-01, M2-02 (cart/wishlist needs product detail)
M2-01 + M2-03 → M2-04 → M2-05 → M2-06 → M2-07 (checkout chain)
```

### Recommended Batch Execution

**Batch 1** (M0 foundation — run all 5 in parallel):
```
/pipeline-run M0-01 app-scaffold
/pipeline-run M0-02 design-system
/pipeline-run M0-03 network-layer
/pipeline-run M0-04 navigation
/pipeline-run M0-05 di-setup
```

**Batch 2** (M0 auth — depends on batch 1):
```
/pipeline-run M0-06 auth-infrastructure
```

**Batch 3** (M1 screens — run auth screens + home in parallel):
```
/pipeline-run M1-01 login-screen
/pipeline-run M1-02 register-screen
/pipeline-run M1-03 forgot-password
/pipeline-run M1-04 home-screen
```

**Batch 4** (M1 product — run in parallel):
```
/pipeline-run M1-05 category-browsing
/pipeline-run M1-06 product-list
```

**Batch 5** (M1 detail):
```
/pipeline-run M1-07 product-detail
/pipeline-run M1-08 product-search
```

**Batch 6** (M2 commerce — run cart + wishlist + address in parallel):
```
/pipeline-run M2-01 cart
/pipeline-run M2-02 wishlist
/pipeline-run M2-03 address-management
```

**Batch 7** (M2 checkout — sequential chain):
```
/pipeline-run M2-04 checkout-address
/pipeline-run M2-05 checkout-shipping
/pipeline-run M2-06 checkout-payment
/pipeline-run M2-07 order-confirmation
```

**Batch 8** (M3 post-purchase — run in parallel):
```
/pipeline-run M3-01 order-list
/pipeline-run M3-03 user-profile
/pipeline-run M3-04 payment-methods
/pipeline-run M3-05 notifications
/pipeline-run M3-06 settings
/pipeline-run M3-08 vendor-store-page
```

**Batch 9** (M3 dependent):
```
/pipeline-run M3-02 order-detail
/pipeline-run M3-07 product-reviews
```

**Batch 10** (M4 advanced — run in parallel):
```
/pipeline-run M4-01 product-qna
/pipeline-run M4-02 recently-viewed
/pipeline-run M4-03 price-alerts
/pipeline-run M4-04 share-product
/pipeline-run M4-05 app-onboarding
```
