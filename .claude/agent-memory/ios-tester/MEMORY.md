# iOS Tester Agent Memory

## Project: XiriGo Ecommerce Mobile

### Key Patterns

#### Xcode Project File Management
- The `xcodeproj` Ruby gem fails to parse pbxproj files with unquoted `+` in path values (e.g., `Container+Home.swift`). Use manual editing instead.
- When manually editing pbxproj, add: PBXBuildFile, PBXFileReference, PBXGroup entries, children reference, and Sources buildPhase entry.
- Files with `+` in filename MUST be quoted in pbxproj: `name = "File+Name.swift"; path = "File+Name.swift";`
- Design system components (`XGBrand*.swift`, `XGLogoMark.swift`, `XGPaginationDots.swift`) were added by iOS dev but NOT in the Xcode project — always check with `grep "FileName" project.pbxproj`
- Feature source files may be on disk but not in the Xcode project — always verify before running tests
- Always add `import Foundation` to test files that use `Date`, `URL`, or other Foundation types

#### Container+Onboarding Pattern (MainActor)
- `@MainActor @Observable` ViewModels have `@MainActor`-isolated inits
- Factory closures are not `@MainActor` — must wrap with `MainActor.assumeIsolated { }`
- Pattern already used in `Container+Extensions.swift` for `AuthStateManagerImpl`

#### Test Structure
- Unit tests: `ios/XiriGoEcommerceTests/Feature/{Feature}/`
- Subdirectories: `Fakes/`, `UseCase/`, `ViewModel/`, `Domain/`, `Repository/`, `Component/`, `Screen/`
- Framework: Swift Testing with `@Suite` and `@Test` macros
- `@MainActor` on test structs when testing `@MainActor` ViewModels
- No force unwrap, no mocks — use `Fake{Name}Repository` pattern

#### Build & Test Commands
```bash
# Build for testing
xcodebuild build-for-testing \
  -project ios/XiriGoEcommerce.xcodeproj \
  -scheme XiriGoEcommerce \
  -destination 'id=993F4498-B3CE-4A7D-9CFE-A9BDB5A5C9A7' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Run unit tests only
xcodebuild test \
  -project ios/XiriGoEcommerce.xcodeproj \
  -scheme XiriGoEcommerce \
  -destination 'id=993F4498-B3CE-4A7D-9CFE-A9BDB5A5C9A7' \
  -only-testing:XiriGoEcommerceTests \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```
- Simulator: `id=993F4498-B3CE-4A7D-9CFE-A9BDB5A5C9A7` = iPhone 16, iOS 18.6
- `** TEST FAILED **` with no actual failing tests = UITest target has 0 tests (pre-existing project issue)

#### Fake Repository Pattern
```swift
final class FakeXyzRepository: XyzRepository, @unchecked Sendable {
    var errorToThrow: AppError?
    var callCount: Int = 0
    // Configure state before each test, check callCount after
}
```

### Files Modified Per Feature Session (app-onboarding)
- `ios/XiriGoEcommerce/Core/DI/Container+Onboarding.swift` — fixed MainActor.assumeIsolated
- `ios/XiriGoEcommerce.xcodeproj/project.pbxproj` — added all Onboarding source + test files
- `ios/XiriGoEcommerceTests/Feature/Onboarding/` — 13 new test files
