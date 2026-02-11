// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MoltMarketplace",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MoltMarketplace",
            targets: ["MoltMarketplace"]
        )
    ],
    dependencies: [
        // Dependency Injection
        .package(url: "https://github.com/hmlongco/Factory", from: "2.4.0"),
        // Image Loading
        .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
        // Keychain
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        // Firebase
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.7.0"),
        // Sentry (Crash Reporting)
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.40.0"),
        // Testing
        .package(url: "https://github.com/nicklockwood/ViewInspector", from: "0.10.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0")
    ],
    targets: [
        .target(
            name: "MoltMarketplace",
            dependencies: [
                .product(name: "Factory", package: "Factory"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "Sentry", package: "sentry-cocoa")
            ]
        ),
        .testTarget(
            name: "MoltMarketplaceTests",
            dependencies: [
                "MoltMarketplace",
                .product(name: "ViewInspector", package: "ViewInspector"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
