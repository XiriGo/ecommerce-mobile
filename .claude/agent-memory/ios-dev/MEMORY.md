# iOS Dev Agent Memory

## SwiftLint Rules to Watch
- `no_magic_numbers`: Integers 2+ and all floating-point literals must be named constants. Use `private enum Constants {}` or nested enums for sample data counts/ratings.
- `prefer_self_in_static_references`: Inside static members, use `Self(...)` and `[Self]` instead of the type name.
- `attributes`: `@MainActor`, `@Observable`, `@ViewBuilder` must each be on their own line above types/functions. `@Environment(X.self)` with arguments also goes on its own line.
- `accessibility_label_for_image`: Every `Image(systemName:)` needs `.accessibilityLabel()` or `.accessibilityHidden(true)`.
- `vertical_whitespace_between_cases`: Blank line required between switch cases.
- `file_length`: Max 300 lines (warning). Extract sample data models to separate files when needed.
- `closure_body_length`: Max 30 lines. Extract sub-views as computed properties to break up large closures.
- Zero `swiftlint:disable` comments allowed per project standards.

## Project File Paths
- SwiftLint config: `ios/.swiftlint.yml`
- Xcode project: `ios/XiriGoEcommerce.xcodeproj/project.pbxproj`
- Source root: `ios/XiriGoEcommerce/`
- Tests: `ios/XiriGoEcommerceTests/`

## Key Patterns
- New `.swift` files MUST be added to `project.pbxproj` (file reference + group + build phase).
- When extracting sample data to a new file, change `private struct` to `struct` (internal) since it's now in a separate file.
- `OnboardingPage.Index` enum provides named constants for page indices (browse=0, compare=1, checkout=2, track=3).
