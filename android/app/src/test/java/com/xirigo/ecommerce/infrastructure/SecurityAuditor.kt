package com.xirigo.ecommerce.infrastructure

import java.io.File

/**
 * Audits source code for common security issues.
 * Mirrors iOS SecurityTestHelpers — scans source code statically.
 */
object SecurityAuditor {

    val SourceRoot: File by lazy {
        File("src/main/java/com/xirigo/ecommerce")
    }

    private val SECRET_PATTERNS = listOf(
        "api_key", "apiKey", "API_KEY",
        "secret_key", "secretKey", "SECRET_KEY",
        "password", "PASSWORD",
        "private_key", "PRIVATE_KEY",
        "access_token", "bearer ",
    )

    private val FALSE_POSITIVE_PATTERNS = listOf(
        "//", "/*", "*", "/**",
        "fun ", "val ", "var ", "class ", "object ", "interface ", "enum ",
        "annotation ", "@",
        "forKey", "SharedPreferences", "Keychain",
        "getString(", "putString(",
    )

    fun scanForHardcodedSecrets(directory: File): List<SecretFinding> {
        val findings = mutableListOf<SecretFinding>()

        for (pattern in SECRET_PATTERNS) {
            val matches = SourceFileScanner.containsPattern(
                pattern,
                directory,
                excludingPaths = listOf("Test", "test", "Mock", "Fake", "Preview"),
            )
            for (match in matches) {
                val trimmed = match.content.trim()
                val isFalsePositive = FALSE_POSITIVE_PATTERNS.any { trimmed.startsWith(it) }
                val hasStringLiteral = trimmed.contains("\"") && !isFalsePositive
                if (hasStringLiteral) {
                    findings.add(
                        SecretFinding(
                            file = match.file,
                            line = match.line,
                            content = match.content,
                            pattern = pattern,
                        ),
                    )
                }
            }
        }

        return findings
    }

    fun scanForInsecureURLs(directory: File): List<SourceFinding> {
        return SourceFileScanner.containsPattern(
            "http://",
            directory,
            excludingPaths = listOf("Test", "test", "Mock", "Fake", "Preview"),
        ).filter { match ->
            val trimmed = match.content.trim()
            !trimmed.startsWith("//") &&
                !trimmed.startsWith("/*") &&
                !trimmed.startsWith("*") &&
                !match.content.contains("http://localhost") &&
                !match.content.contains("http://127.0.0.1") &&
                !match.content.contains("http://10.0.2.2")
        }
    }

    fun scanForSensitiveLogging(directory: File): List<SourceFinding> {
        val sensitiveTerms = listOf("password", "token", "secret", "creditCard", "cvv", "ssn")
        val logPatterns = listOf("Log.", "Timber.", "println(", "print(")
        val findings = mutableListOf<SourceFinding>()

        for (logPattern in logPatterns) {
            val logMatches = SourceFileScanner.containsPattern(
                logPattern,
                directory,
                excludingPaths = listOf("Test", "test", "Mock", "Fake"),
            )
            for (match in logMatches) {
                if (sensitiveTerms.any { match.content.lowercase().contains(it) }) {
                    findings.add(match)
                }
            }
        }

        return findings
    }

    fun scanForForceUnwraps(directory: File): List<SourceFinding> {
        return SourceFileScanner.containsPattern(
            "!!",
            directory,
            excludingPaths = listOf("Test", "test", "Mock", "Fake", "Preview"),
        ).filter { match ->
            val trimmed = match.content.trim()
            !trimmed.startsWith("//") &&
                !trimmed.startsWith("/*") &&
                !trimmed.startsWith("*") &&
                match.content.contains("!!")
        }
    }
}
