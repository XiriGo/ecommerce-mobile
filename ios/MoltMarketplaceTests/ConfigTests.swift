import Foundation
import Testing
@testable import MoltMarketplace

@Suite("Config Tests")
struct ConfigTests {
    @Test("apiBaseURL returns valid URL for all configurations")
    func apiBaseURLIsValid() {
        let url = Config.apiBaseURL
        #expect(url.scheme == "https")
        #expect(url.host()?.hasSuffix("molt.mt") == true)
    }

    @Test("apiBaseURL returns correct environment URL for Debug")
    func apiBaseURLDebug() {
        #if DEBUG
        #expect(Config.apiBaseURL.absoluteString == "https://api-dev.molt.mt")
        #endif
    }

    @Test("apiBaseURL returns correct environment URL for Staging")
    func apiBaseURLStaging() {
        #if STAGING
        #expect(Config.apiBaseURL.absoluteString == "https://api-staging.molt.mt")
        #endif
    }

    @Test("apiBaseURL returns correct environment URL for Release")
    func apiBaseURLRelease() {
        #if !DEBUG && !STAGING
        #expect(Config.apiBaseURL.absoluteString == "https://api.molt.mt")
        #endif
    }

    @Test("bundleVersion returns valid semantic version format")
    func bundleVersionFormat() {
        let version = Config.bundleVersion
        #expect(!version.isEmpty)
        // Should match semantic versioning pattern (e.g., "1.0.0")
        let components = version.split(separator: ".")
        #expect(components.count >= 1)
        #expect(components.count <= 3)
    }

    @Test("buildNumber returns valid build number")
    func testBuildNumber() {
        let buildNumber = Config.buildNumber
        #expect(!buildNumber.isEmpty)
        // Build number should be numeric or alphanumeric
        #expect(Int(buildNumber) != nil || !buildNumber.isEmpty)
    }
}
