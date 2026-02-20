# CI/CD Pipeline Guide

**Scope**: Molt Marketplace Mobile Buyer App — Android + iOS
**Last Updated**: 2026-02-20

This guide covers the GitHub Actions CI/CD pipelines for the Molt Marketplace mobile app. Both platforms run as separate workflows with distinct job chains.

---

## 1. Pipeline Architecture

**Platform**: GitHub Actions
**Runners**: `ubuntu-latest` (Android), `macos-15` (iOS)

Two independent workflows:

| Workflow | File | Runner |
|----------|------|--------|
| Android CI | `.github/workflows/android-ci.yml` | `ubuntu-latest` |
| iOS CI | `.github/workflows/ios-ci.yml` | `macos-15` |

### Trigger Rules

Both workflows trigger on:

| Event | Branches | Path Filter |
|-------|----------|-------------|
| `pull_request` | `main`, `develop` | Platform-specific paths |
| `push` | `main`, `develop` | Platform-specific paths |

Path filters prevent unnecessary builds. Android CI skips when only iOS files change, and vice versa.

### Concurrency Control

Each workflow uses `concurrency` with `cancel-in-progress: true`. When a new commit arrives on the same ref, the in-flight run is cancelled. This keeps queues clear on active branches.

---

## 2. Android Pipeline

### Job Chain

```
lint  →  test  →  build
```

All jobs use `working-directory: android` as the default.

### Job Details

#### `lint`

| Step | Command |
|------|---------|
| Checkout | `actions/checkout@v4` |
| Setup JDK 17 | `actions/setup-java@v4` (distribution: `temurin`) |
| Setup Gradle | `gradle/actions/setup-gradle@v4` (handles caching) |
| ktlint | `./gradlew ktlintCheck` |
| detekt | `./gradlew detekt` |

#### `test`

Runs after `lint` passes.

| Step | Details |
|------|---------|
| Unit tests | `./gradlew testDebugUnitTest` |
| Upload results | `actions/upload-artifact@v4` → `android-test-results` |
| Retention | 14 days |
| Upload condition | `if: always()` — results uploaded even on test failure |

Test report path: `android/app/build/reports/tests/`

#### `build`

Runs after `test` passes.

| Step | Details |
|------|---------|
| Assemble | `./gradlew assembleDebug` |
| Upload APK | `actions/upload-artifact@v4` → `debug-apk` |
| APK path | `android/app/build/outputs/apk/debug/` |
| Retention | 14 days |

APK artifact is only produced on builds that pass both lint and test.

### Gradle Caching

`gradle/actions/setup-gradle@v4` manages Gradle caching automatically. It caches:
- `~/.gradle/caches`
- `~/.gradle/wrapper`

Cache key is derived from Gradle wrapper properties and build files. Typical savings: 2–4 minutes per build by skipping dependency downloads and compilation cache warm-up.

Manual cache key pattern (if overriding):

```
gradle-${{ hashFiles('android/gradle/libs.versions.toml', 'android/**/*.gradle.kts') }}
```

### Versions in Use

| Tool | Version |
|------|---------|
| JDK | 17 (Temurin) |
| Gradle | 9.2.1 (from `gradle-wrapper.properties`) |
| AGP | 8.8.0 |
| Kotlin | 2.1.0 |
| ktlint plugin | 12.1.2 |
| detekt plugin | 1.23.8 |

---

## 3. iOS Pipeline

### Job Chain

```
lint  →  build-and-test
```

### Job Details

#### `lint`

Runs on `macos-15`. No Xcode dependency for lint — only CLI tools.

| Step | Command |
|------|---------|
| Checkout | `actions/checkout@v4` |
| Install tools | `brew install swiftlint swiftformat` |
| SwiftLint | `swiftlint lint --reporter github-actions-logging` (working-directory: `ios`) |
| SwiftFormat | `swiftformat --lint .` (working-directory: `ios`) |

`--reporter github-actions-logging` annotates PRs with lint violations inline.

#### `build-and-test`

Runs after `lint` passes. Uses SPM cache.

| Step | Command |
|------|---------|
| Checkout | `actions/checkout@v4` |
| Restore SPM cache | `actions/cache@v4` |
| Build for testing | `xcodebuild build-for-testing` |
| Run tests | `xcodebuild test-without-building` |
| Upload results | `actions/upload-artifact@v4` → `ios-test-results` |

Scheme used: `MoltMarketplace`
Destination: `platform=iOS Simulator,name=iPhone 16`
Code signing: `CODE_SIGNING_ALLOWED=NO` (no certificates on CI)
Results path: `ios/build/*.xcresult`
Retention: 14 days

### SPM Caching

SPM packages are cached using the `Package.resolved` hash:

```
key: spm-${{ hashFiles('ios/MoltMarketplace.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved') }}
restore-keys: spm-
```

Cached path: `~/Library/Developer/Xcode/DerivedData`

The `restore-keys: spm-` fallback restores the most recent cache when `Package.resolved` changes (e.g., after a dependency update), avoiding a full cold build. Typical savings: 3–5 minutes.

### Versions in Use

| Tool | Version |
|------|---------|
| macOS runner | `macos-15` |
| Xcode | 16+ (runner default) |
| Swift | 6.2 |
| Minimum iOS target | 17.0 |
| SwiftLint | Latest (brew) |
| SwiftFormat | Latest (brew) |

---

## 4. Caching Strategy

| Platform | What Is Cached | Cache Key |
|----------|---------------|-----------|
| Android | Gradle caches + wrapper | Hash of `libs.versions.toml` + `*.gradle.kts` |
| iOS | DerivedData (SPM resolved packages) | Hash of `Package.resolved` |

Both caches use `restore-keys` fallback to get a partial cache hit when keys change.

### Estimated Time Savings

| Scenario | Without Cache | With Cache | Savings |
|----------|--------------|------------|---------|
| Android cold build | ~8 min | ~4 min | ~4 min |
| Android warm build | ~6 min | ~2 min | ~4 min |
| iOS cold build | ~12 min | ~7 min | ~5 min |
| iOS warm build | ~9 min | ~4 min | ~5 min |

---

## 5. Artifact Management

| Artifact | Platform | Upload Trigger | Retention |
|----------|----------|---------------|-----------|
| `android-test-results` | Android | Always (pass or fail) | 14 days |
| `debug-apk` | Android | On `build` job success | 14 days |
| `ios-test-results` | iOS | Always (pass or fail) | 14 days |

Artifacts are accessible from the GitHub Actions run page under the "Artifacts" section.

The debug APK is only produced when both `lint` and `test` jobs pass. This means the artifact in GitHub Actions always represents a tested build.

---

## 6. Code Signing (Future)

Code signing is not configured for the current CI pipeline. Debug builds use `CODE_SIGNING_ALLOWED=NO` (iOS) and the default debug keystore (Android).

When release builds are needed:

### Android

1. Generate a release keystore locally.
2. Base64-encode it: `base64 -i release.keystore | pbcopy`
3. Store in GitHub Secrets:
   - `KEYSTORE_BASE64`
   - `KEYSTORE_PASSWORD`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`
4. Decode in workflow and pass to `assembleRelease` via Gradle properties.

```yaml
- name: Decode keystore
  run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > app/release.keystore

- run: ./gradlew assembleRelease
  env:
    KEYSTORE_PATH: release.keystore
    KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
    KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
```

### iOS

Two options:

**Option A — Fastlane Match** (recommended for teams)
- Certificates and profiles stored in a private git repo
- `match` fetches and installs them at build time
- Requires `MATCH_PASSWORD` and repo access secret

**Option B — Manual provisioning**
- Export `.p12` + mobileprovision, base64-encode both
- Store as GitHub Secrets
- Decode and install in CI keychain before `xcodebuild archive`

Both options require an Apple Developer account and are only needed for App Store or TestFlight distribution builds.

---

## 7. Matrix Testing (Future)

The current pipeline tests on a single configuration per platform. Planned expansion:

### Android Matrix

```yaml
strategy:
  matrix:
    api-level: [26, 35]   # minSdk + targetSdk
```

Runs instrumented tests on both API 26 (minimum supported) and API 35 (target) using `reactivecircus/android-emulator-runner`.

### iOS Matrix

```yaml
strategy:
  matrix:
    ios-version: ['17.0', '18.0']   # minimum + latest
    device: ['iPhone 16', 'iPad Air 11-inch (M2)']
```

Matrix testing catches version-specific regressions before they reach production. This is planned for M2+ milestones when the app has sufficient screen coverage to justify the increased CI time.

---

## 8. Running CI Checks Locally

### Android

```bash
# Navigate to android directory
cd android

# Lint
./gradlew ktlintCheck detekt

# Unit tests
./gradlew testDebugUnitTest

# Full debug build
./gradlew assembleDebug

# Coverage report (requires jacocoTestReport task to be configured)
./gradlew testDebugUnitTest jacocoTestReport
```

### iOS

```bash
# Lint (requires swiftlint and swiftformat installed)
cd ios
swiftlint lint
swiftformat --lint .

# Build for testing
xcodebuild build-for-testing \
  -project MoltMarketplace.xcodeproj \
  -scheme MoltMarketplace \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO

# Run tests
xcodebuild test-without-building \
  -project MoltMarketplace.xcodeproj \
  -scheme MoltMarketplace \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO

# Combined build + test in one step
xcodebuild test \
  -project MoltMarketplace.xcodeproj \
  -scheme MoltMarketplace \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

---

## 9. Secrets and Environment Variables

No secrets are required for the current debug-only CI pipeline. When secrets are needed, add them at the repository level in GitHub Settings > Secrets and variables > Actions.

| Secret | Purpose | When Needed |
|--------|---------|-------------|
| `KEYSTORE_BASE64` | Android release signing | Release builds |
| `KEYSTORE_PASSWORD` | Android release signing | Release builds |
| `KEY_ALIAS` | Android release signing | Release builds |
| `KEY_PASSWORD` | Android release signing | Release builds |
| `MATCH_PASSWORD` | iOS Fastlane Match | Release builds |
| `FIREBASE_APP_ID_ANDROID` | Firebase test lab | Instrumented CI tests |
| `FIREBASE_APP_ID_IOS` | Firebase test lab | Instrumented CI tests |

---

## 10. Related Files

| File | Purpose |
|------|---------|
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/.github/workflows/android-ci.yml` | Android CI workflow |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/.github/workflows/ios-ci.yml` | iOS CI workflow |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/gradle/libs.versions.toml` | Android dependency + tool versions |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/gradle/wrapper/gradle-wrapper.properties` | Gradle version (9.2.1) |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace.xcodeproj/xcshareddata/xcschemes/MoltMarketplace.xcscheme` | Xcode scheme used by CI |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` | SPM lock file (cache key source) |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/docs/guides/testing-strategy.md` | Full test strategy, coverage thresholds, fixture management |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/CLAUDE.md` | Project standards, coverage thresholds (>= 80% lines/functions) |
