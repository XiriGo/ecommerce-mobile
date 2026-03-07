---
name: verify
description: "Run quality checks (build, lint, test) for Android and/or iOS"
argument-hint: "[all|android|ios|build|lint|test]"
---

# Verify

Run quality checks on the mobile codebase. Covers build, lint, test, coverage,
and security audit layers.

## Makefile

A root-level `Makefile` provides shortcuts for all checks. Prefer `make` targets when running from the terminal:

```bash
make help              # Show all targets
make all               # Build + lint + test both platforms
make android           # Build + lint + test Android
make ios               # Build + lint + test iOS
make lint              # Lint both + suppress check
make test              # Test both
make check-suppress    # Verify zero @Suppress / swiftlint:disable
```

## Arguments
`$ARGUMENTS` — scope of verification: `all`, `android`, `ios`, `build`, `lint`, `test`

## iOS Simulator Detection

Auto-detect the first available iPhone simulator:

```bash
IOS_SIM=$(xcrun simctl list devices available 2>/dev/null \
  | grep -m1 'iPhone' | sed 's/^ *//;s/ (.*//')
# Fallback: iPhone 16
```

Use the detected name in xcodebuild `-destination` flag.

## Checks

### Android
1. **Build**: `cd android && ./gradlew assembleDebug`
2. **Lint**: `cd android && ./gradlew ktlintCheck` + `./gradlew detekt`
3. **Unit Tests**: `cd android && ./gradlew test`
4. **UI Tests**: `cd android && ./gradlew connectedAndroidTest` (if emulator available)
5. **Suppress Check**: `grep -rn '@Suppress(' --include='*.kt' android/app/src/` (must return empty)

### iOS
1. **Build**: `cd ios && xcodebuild build -scheme XiriGoEcommerce -destination 'platform=iOS Simulator,name=$IOS_SIM'`
2. **Lint**: `cd ios && swiftlint lint --strict`
3. **Unit Tests**: `cd ios && xcodebuild test -scheme XiriGoEcommerce -destination 'platform=iOS Simulator,name=$IOS_SIM' -enableCodeCoverage YES -resultBundlePath TestResults.xcresult`
4. **Coverage Check**: Extract coverage from xcresult and verify >= 80% lines
5. **Suppress Check**: `grep -rn 'swiftlint:disable' --include='*.swift' ios/` (must return empty)
6. **Security Audit**: Verify SecurityTests, ArchitectureTests, AccessibilityTests all pass

### Coverage Extraction (iOS)
After tests pass, extract and display coverage:

```bash
xcrun xccov view --report TestResults.xcresult --json > coverage.json
python3 -c "
import json
data = json.load(open('coverage.json'))
for t in data.get('targets', []):
    name = t.get('name', '')
    if 'XiriGoEcommerce' == name:
        pct = t.get('lineCoverage', 0) * 100
        print(f'Coverage: {pct:.1f}%')
        status = 'PASS' if pct >= 80 else 'WARNING' if pct >= 70 else 'FAIL'
        print(f'Status: {status}')
"
```

## Output
Print a summary table:
```
Platform | Check      | Status
---------|------------|--------
Android  | Build      | PASS / FAIL
Android  | Lint       | PASS / FAIL
Android  | Tests      | PASS / FAIL
Android  | Suppress   | PASS / FAIL
iOS      | Build      | PASS / FAIL
iOS      | Lint       | PASS / FAIL
iOS      | Tests      | PASS / FAIL
iOS      | Coverage   | XX% (PASS/WARNING/FAIL)
iOS      | Suppress   | PASS / FAIL
iOS      | Security   | PASS / FAIL (auto tests)
iOS      | A11y       | PASS / FAIL (auto tests)
```
