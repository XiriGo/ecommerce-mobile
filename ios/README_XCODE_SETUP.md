# Xcode Project Setup Instructions

The iOS app scaffold has been implemented but requires Xcode to complete the project configuration.

## Quick Setup (5 minutes)

### Step 1: Install xcodegen (Optional but Recommended)

```bash
brew install xcodegen
```

### Step 2: Open in Xcode

```bash
open ios/MoltMarketplace.xcodeproj
```

If the project won't open or shows errors, follow Manual Setup below.

## Manual Setup

### 1. Create New Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose: iOS → App
4. Product Name: `MoltMarketplace`
5. Team: (your team)
6. Organization Identifier: `com.molt`
7. Interface: **SwiftUI**
8. Language: **Swift**
9. Storage: None (we'll add SwiftData later)
10. Save to: Select the `/ios` directory (REPLACE existing project if asked)

### 2. Configure Build Settings

1. Select project in navigator → MoltMarketplace target
2. General tab:
   - Deployment Info → iOS 17.0
   - Supported Orientations: Portrait only (iPhone), All (iPad)

### 3. Add Source Files

1. Delete the default `ContentView.swift` and `MoltMarketplaceApp.swift` created by Xcode
2. Right-click MoltMarketplace group → Add Files to "MoltMarketplace"
3. Select entire `MoltMarketplace` folder
4. **Check**: "Copy items if needed" = NO (already in place)
5. **Check**: "Create groups"
6. **Check**: Add to targets → MoltMarketplace
7. Click Add

### 4. Add SPM Dependencies

1. File → Add Package Dependencies
2. Add each package (paste URL in search):

```
https://github.com/hmlongco/Factory
https://github.com/kean/Nuke
https://github.com/kishikawakatsumi/KeychainAccess
https://github.com/firebase/firebase-ios-sdk
https://github.com/getsentry/sentry-cocoa
```

For each:
- Factory: version 2.4.0+
- Nuke: version 12.8.0+
- KeychainAccess: version 4.2.2+
- Firebase: version 11.7.0+ → select FirebaseAnalytics, FirebaseCrashlytics, FirebaseMessaging, FirebaseRemoteConfig
- Sentry: version 8.40.0+

### 5. Configure Build Configurations

1. Project → Info tab → Configurations
2. Rename "Debug" to "Debug" (keep as is)
3. Duplicate "Release" → Rename to "Staging"
4. Keep "Release"

For each configuration, set Base Configuration:
- Debug → `MoltMarketplace/Configuration/Debug.xcconfig`
- Staging → `MoltMarketplace/Configuration/Staging.xcconfig`
- Release → `MoltMarketplace/Configuration/Release.xcconfig`

### 6. Configure Info.plist

1. Select MoltMarketplace target → Build Settings
2. Search for "Info.plist"
3. Set "Info.plist File" to: `MoltMarketplace/Resources/Info.plist`

### 7. Configure Build Schemes

1. Product → Scheme → Edit Scheme
2. Duplicate scheme twice (for Staging and Release)
3. For each scheme:
   - Run → Build Configuration → Select matching config
   - Archive → Build Configuration → Select matching config

### 8. Verify Build

```bash
# From terminal
cd ios
xcodebuild -scheme MoltMarketplace -configuration Debug build
xcodebuild -scheme MoltMarketplace -configuration Staging build
xcodebuild -scheme MoltMarketplace -configuration Release build
```

Or in Xcode:
- Product → Build (Cmd+B)
- Switch schemes and build each

### 9. Commit Changes

```bash
git add ios/
git commit -m "fix(scaffold): configure Xcode project with all source files and dependencies [agent:ios-dev] [platform:ios]"
```

## Verification Checklist

- [ ] Project builds without errors (Debug)
- [ ] Project builds without errors (Staging)  
- [ ] Project builds without errors (Release)
- [ ] App launches in simulator
- [ ] Shows placeholder screen with "Molt Marketplace" text
- [ ] `Config.apiBaseURL` returns correct URL per configuration
- [ ] All Swift files compile without warnings
- [ ] No strict concurrency warnings

## Troubleshooting

**"Missing package product"**: Re-add SPM dependencies via File → Add Package Dependencies

**"Info.plist not found"**: Check Build Settings → Info.plist File path

**"Module not found"**: Clean build folder (Cmd+Shift+K) and rebuild

**Build fails**: Check that all .swift files are added to the target (Target Membership in File Inspector)

## Alternative: Use xcodegen

If you have `xcodegen` installed, you can use the project.yml spec (create this file):

```yaml
name: MoltMarketplace
options:
  bundleIdPrefix: com.molt
  deploymentTarget:
    iOS: 17.0
settings:
  SWIFT_VERSION: 6.0
  IPHONEOS_DEPLOYMENT_TARGET: 17.0
targets:
  MoltMarketplace:
    type: application
    platform: iOS
    sources:
      - MoltMarketplace
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.molt.marketplace
      INFOPLIST_FILE: MoltMarketplace/Resources/Info.plist
    dependencies:
      - package: Factory
      - package: Nuke
      - package: KeychainAccess
      - package: FirebaseAnalytics
      - package: Sentry
packages:
  Factory:
    url: https://github.com/hmlongco/Factory
    from: 2.4.0
  Nuke:
    url: https://github.com/kean/Nuke
    from: 12.8.0
  KeychainAccess:
    url: https://github.com/kishikawakatsumi/KeychainAccess
    from: 4.2.2
  Firebase:
    url: https://github.com/firebase/firebase-ios-sdk
    from: 11.7.0
  Sentry:
    url: https://github.com/getsentry/sentry-cocoa
    from: 8.40.0
```

Then run:
```bash
cd ios
xcodegen generate
```

This will create a properly configured Xcode project automatically.
