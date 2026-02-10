---
name: verify
description: "Run quality checks (build, lint, test) for Android and/or iOS"
allowed-tools: Bash, Read
argument-hint: "[all|android|ios|build|lint|test]"
---

# Verify

Run quality checks on the mobile codebase.

## Arguments
`$ARGUMENTS` — scope of verification: `all`, `android`, `ios`, `build`, `lint`, `test`

## Checks

### Android
1. **Build**: `cd android && ./gradlew assembleDebug`
2. **Lint**: `cd android && ./gradlew ktlintCheck` + `./gradlew detekt`
3. **Unit Tests**: `cd android && ./gradlew test`
4. **UI Tests**: `cd android && ./gradlew connectedAndroidTest` (if emulator available)

### iOS
1. **Build**: `cd ios && xcodebuild build -scheme MoltMarketplace -destination 'platform=iOS Simulator,name=iPhone 16'`
2. **Lint**: `cd ios && swiftlint`
3. **Tests**: `cd ios && xcodebuild test -scheme MoltMarketplace -destination 'platform=iOS Simulator,name=iPhone 16'`

## Output
Print a summary table:
```
Platform | Check      | Status
---------|------------|--------
Android  | Build      | ✓ PASS / ✗ FAIL
Android  | Lint       | ✓ PASS / ✗ FAIL
Android  | Tests      | ✓ PASS / ✗ FAIL
iOS      | Build      | ✓ PASS / ✗ FAIL
iOS      | Lint       | ✓ PASS / ✗ FAIL
iOS      | Tests      | ✓ PASS / ✗ FAIL
```
