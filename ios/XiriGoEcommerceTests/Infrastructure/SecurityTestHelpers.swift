import Foundation
import Testing

// MARK: - String + Helpers

private extension String {
    func containsAny(_ terms: [String]) -> Bool {
        terms.contains { contains($0) }
    }
}

// MARK: - SecretFinding

struct SecretFinding {
    let file: String
    let line: Int
    let content: String
    let pattern: String
}

// MARK: - SourceFinding

struct SourceFinding {
    let file: String
    let line: Int
    let content: String
}

// MARK: - SecurityTestHelpers

/// Helpers for security-related test assertions.
/// Used by SecurityTests suite to audit the codebase for common security issues.
enum SecurityTestHelpers {
    // MARK: - Hardcoded Secret Detection

    /// Patterns that indicate potential hardcoded secrets.
    static let secretPatterns: [String] = [
        "api_key",
        "apiKey",
        "API_KEY",
        "secret_key",
        "secretKey",
        "SECRET_KEY",
        "password",
        "PASSWORD",
        "private_key",
        "PRIVATE_KEY",
        "access_token",
        "bearer ",
    ]

    /// Patterns that are false positives (in comments, test data, protocol names).
    static let falsePositivePatterns: [String] = [
        "//",
        "///",
        "/*",
        "protocol",
        "func",
        "var ",
        "let ",
        "case ",
        "enum ",
        "struct ",
        "@",
        "forKey:",
        "UserDefaults",
        "Keychain",
        "NSLocalizedString",
        "String(localized:",
    ]

    // MARK: - Project Root Detection

    /// Finds the iOS source root by walking up from the test bundle.
    static var projectRoot: String {
        // When running tests, the source root is typically accessible via environment
        // or by traversing from the current file location
        let currentFile = #filePath
        // Walk up from XiriGoEcommerceTests/Infrastructure/SecurityTestHelpers.swift
        // to ios/
        var url = URL(fileURLWithPath: currentFile)
        // Go up: Infrastructure -> XiriGoEcommerceTests -> ios
        let directoryDepth = 3
        for _ in 0 ..< directoryDepth {
            url = url.deletingLastPathComponent()
        }
        return url.path
    }

    static var sourceRoot: String {
        projectRoot + "/XiriGoEcommerce"
    }

    /// Scans source files for potential hardcoded secrets.
    /// Returns findings that are NOT in comments or declarations.
    static func scanForHardcodedSecrets(
        in directory: String,
    ) -> [SecretFinding] {
        var findings: [SecretFinding] = []

        for pattern in secretPatterns {
            let matches = SourceFileScanner.containsPattern(
                pattern,
                in: directory,
                excludingPaths: ["Tests", "test", "Mock", "Fake", "Preview"],
            )

            for match in matches {
                let trimmed = match.content.trimmingCharacters(in: .whitespaces)
                // Skip if it's a declaration, comment, or framework usage
                let isFalsePositive = falsePositivePatterns.contains { fp in
                    trimmed.hasPrefix(fp)
                }
                // Only flag if it contains a string literal with the pattern
                let hasStringLiteral = trimmed.contains("\"") && !isFalsePositive
                if hasStringLiteral {
                    findings.append(SecretFinding(
                        file: match.file,
                        line: match.line,
                        content: match.content,
                        pattern: pattern,
                    ))
                }
            }
        }

        return findings
    }

    // MARK: - HTTPS Enforcement

    /// Scans for HTTP (non-HTTPS) URLs in source code.
    static func scanForInsecureURLs(
        in directory: String,
    ) -> [SourceFinding] {
        let httpMatches = SourceFileScanner.containsPattern(
            "http://",
            in: directory,
            excludingPaths: ["Tests", "test", "Mock", "Fake", "Preview", ".xcconfig"],
        )

        return httpMatches.filter { match in
            let trimmed = match.content.trimmingCharacters(in: .whitespaces)
            // Skip comments
            guard !trimmed.hasPrefix("//"), !trimmed.hasPrefix("/*"), !trimmed.hasPrefix("*") else {
                return false
            }
            // Skip localhost (acceptable for dev)
            guard
                !match.content.contains("http://localhost"),
                !match.content.contains("http://127.0.0.1")
            else {
                return false
            }
            return true
        }
    }

    // MARK: - Sensitive Data Logging

    /// Scans for potential sensitive data in print/log statements.
    static func scanForSensitiveLogging(
        in directory: String,
    ) -> [SourceFinding] {
        let sensitiveTerms = ["password", "token", "secret", "creditCard", "cvv", "ssn"]
        var findings: [SourceFinding] = []

        // swiftlint:disable no_nslog no_print_statements
        let logPatterns = [
            "print(",
            "NSLog(",
            "os_log(",
            "Logger.",
        ]
        // swiftlint:enable no_nslog no_print_statements
        for logPattern in logPatterns {
            let logMatches = SourceFileScanner.containsPattern(
                logPattern,
                in: directory,
                excludingPaths: ["Tests", "test", "Mock", "Fake"],
            )
            for match in logMatches where match.content.lowercased().containsAny(sensitiveTerms) {
                findings.append(match)
            }
        }

        return findings
    }

    // MARK: - Force Unwrap Detection

    /// Scans for force unwrap usage in production code.
    static func scanForForceUnwraps(
        in directory: String,
    ) -> [SourceFinding] {
        let allMatches = SourceFileScanner.containsPattern(
            "!",
            in: directory,
            excludingPaths: ["Tests", "test", "Mock", "Fake", "Preview"],
        )
        return allMatches.filter { match in
            let trimmed = match.content.trimmingCharacters(in: .whitespaces)
            // Skip comments, IBOutlet, and boolean negation
            guard !trimmed.hasPrefix("//"), !trimmed.hasPrefix("/*") else {
                return false
            }
            // Look for patterns like `variable!.` or `variable!)`
            let content = match.content
            // Simple heuristic: contains `!.` or `!)` or `!,` but not `!=`
            let hasForceUnwrap = content.contains("!.") || content.contains("!)") ||
                content.contains("!,") || content.contains("! ")
            return hasForceUnwrap
                && !content.contains("!=")
                && !content.contains("@IBOutlet")
                && !content.contains("nonisolated(unsafe)")
        }
    }
}
