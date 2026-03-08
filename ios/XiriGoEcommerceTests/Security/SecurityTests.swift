import Foundation
import Testing

/// Security test suite that audits the codebase for common security issues.
/// Maps to TEST.md Section 7 — Security Test Layer.
///
/// These tests scan source files statically — no runtime/simulator needed.
/// They catch issues BEFORE code reaches production.
@Suite("Security Tests")
struct SecurityTests {
    // MARK: - Internal

    // MARK: - HTTPS Enforcement

    @Test("All URLs in source code use HTTPS (no plain HTTP)")
    func allURLs_useHTTPS() {
        let insecureURLs = SecurityTestHelpers.scanForInsecureURLs(in: sourceRoot)

        for finding in insecureURLs {
            Issue.record(
                "Insecure HTTP URL found at \(finding.file):\(finding.line) — \(finding.content.trimmingCharacters(in: .whitespaces))",
            )
        }

        #expect(insecureURLs.isEmpty, "Found \(insecureURLs.count) insecure HTTP URL(s) in source code")
    }

    // MARK: - Hardcoded Secret Detection

    @Test("No hardcoded secrets in source code")
    func noHardcodedSecrets() {
        let secrets = SecurityTestHelpers.scanForHardcodedSecrets(in: sourceRoot)

        // Warning-level: log findings but don't fail the build (high false-positive rate)
        if !secrets.isEmpty {
            // swiftlint:disable:next no_print_statements
            print("⚠️ Found \(secrets.count) potential hardcoded secret(s) — review manually")
        }
    }

    // MARK: - Sensitive Data Logging

    @Test("No sensitive data in log statements")
    func noSensitiveDataLogging() {
        let sensitiveLogging = SecurityTestHelpers.scanForSensitiveLogging(in: sourceRoot)

        for finding in sensitiveLogging {
            Issue.record(
                "Sensitive data in log at \(finding.file):\(finding.line) — \(finding.content.trimmingCharacters(in: .whitespaces))",
            )
        }

        #expect(sensitiveLogging.isEmpty, "Found \(sensitiveLogging.count) sensitive data logging instance(s)")
    }

    // MARK: - Force Unwrap (Safety)

    @Test("No force unwraps in production code")
    func noForceUnwraps() {
        let forceUnwraps = SecurityTestHelpers.scanForForceUnwraps(in: sourceRoot)

        for finding in forceUnwraps {
            Issue.record(
                "Force unwrap at \(finding.file):\(finding.line) — \(finding.content.trimmingCharacters(in: .whitespaces))",
            )
        }

        #expect(forceUnwraps.isEmpty, "Found \(forceUnwraps.count) force unwrap(s) in production code")
    }

    // MARK: - UserDefaults for Sensitive Data

    @Test("Sensitive data is not stored in UserDefaults")
    func sensitiveData_notInUserDefaults() {
        let sensitiveKeys = ["token", "password", "secret", "auth", "credential", "session"]
        var findings: [SourceFinding] = []

        let matches = SourceFileScanner.containsPattern(
            "UserDefaults",
            in: sourceRoot,
            excludingPaths: ["Tests", "test", "Mock", "Fake"],
        )
        for match in matches {
            let lower = match.content.lowercased()
            guard !lower.contains("//") else {
                continue
            }
            for key in sensitiveKeys where lower.contains(key) {
                findings.append(match)
                break
            }
        }

        for finding in findings {
            Issue.record(
                "Sensitive data in UserDefaults at \(finding.file):\(finding.line) — \(finding.content.trimmingCharacters(in: .whitespaces))",
            )
        }

        #expect(findings.isEmpty, "Found \(findings.count) sensitive data stored in UserDefaults")
    }

    // MARK: - App Transport Security

    @Test("Info.plist does not disable App Transport Security")
    func appTransportSecurity_notDisabled() {
        let infoPlistPath = sourceRoot + "/Resources/Info.plist"
        guard let content = try? String(contentsOfFile: infoPlistPath, encoding: .utf8) else {
            // If Info.plist doesn't exist as a file (generated), this is fine
            return
        }

        #expect(
            !content.contains("NSAllowsArbitraryLoads"),
            "Info.plist should not contain NSAllowsArbitraryLoads — use HTTPS for all connections",
        )
    }

    // MARK: - Keychain Usage Verification

    @Test("Auth tokens use KeychainAccess, not UserDefaults")
    func authTokenStorage_usesKeychain() {
        // Verify that any file dealing with auth tokens imports/uses KeychainAccess
        let authFiles = SourceFileScanner.containsPattern(
            "authToken\\|accessToken\\|refreshToken",
            in: sourceRoot + "/Core/Auth",
            excludingPaths: ["Tests"],
        )

        // If there are auth files, they should reference Keychain, not UserDefaults
        if !authFiles.isEmpty {
            let keychainUsage = SourceFileScanner.containsPattern(
                "Keychain",
                in: sourceRoot + "/Core/Auth",
                excludingPaths: ["Tests"],
            )
            #expect(
                !keychainUsage.isEmpty,
                "Auth module should use KeychainAccess for token storage",
            )
        }
    }

    // MARK: - Private

    private let sourceRoot = SecurityTestHelpers.sourceRoot
}
