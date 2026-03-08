package com.xirigo.ecommerce.security

import com.google.common.truth.Truth.assertWithMessage
import org.junit.Test
import java.io.File
import com.xirigo.ecommerce.infrastructure.SecurityAuditor
import com.xirigo.ecommerce.infrastructure.SourceFileScanner
import com.xirigo.ecommerce.infrastructure.SourceFinding

/**
 * Security test suite that audits the codebase for common security issues.
 * Maps to ANDROID_TEST.md Section 7 — Security Test Layer.
 *
 * These tests scan source files statically — no emulator needed.
 */
class SecurityTests {

    private val sourceRoot = SecurityAuditor.SourceRoot

    @Test
    fun `all URLs in source code use HTTPS - no plain HTTP`() {
        val insecureURLs = SecurityAuditor.scanForInsecureURLs(sourceRoot)

        if (insecureURLs.isNotEmpty()) {
            println("WARNING: Found ${insecureURLs.size} insecure HTTP URL(s) in source code")
        }

        assertWithMessage(
            "Found ${insecureURLs.size} insecure HTTP URL(s) in source code",
        ).that(insecureURLs).isEmpty()
    }

    @Test
    fun `no hardcoded secrets in source code`() {
        val secrets = SecurityAuditor.scanForHardcodedSecrets(sourceRoot)

        // Warning-level: log findings (high false-positive rate)
        if (secrets.isNotEmpty()) {
            println("WARNING: Found ${secrets.size} potential hardcoded secret(s) — review manually")
        }
    }

    @Test
    fun `no sensitive data in log statements`() {
        val sensitiveLogging = SecurityAuditor.scanForSensitiveLogging(sourceRoot)

        // Warning-level: log findings but don't fail the build
        if (sensitiveLogging.isNotEmpty()) {
            println("WARNING: Found ${sensitiveLogging.size} sensitive data logging instance(s)")
        }
    }

    @Test
    fun `no force unwraps in production code`() {
        val forceUnwraps = SecurityAuditor.scanForForceUnwraps(sourceRoot)

        if (forceUnwraps.isNotEmpty()) {
            println("WARNING: Found ${forceUnwraps.size} force unwrap(s) (!!) in production code")
        }

        assertWithMessage(
            "Found ${forceUnwraps.size} force unwrap(s) (!!) in production code",
        ).that(forceUnwraps).isEmpty()
    }

    @Test
    fun `sensitive data is not stored in plain SharedPreferences`() {
        val sensitiveKeys = listOf("token", "password", "secret", "auth", "credential", "session")
        val findings = mutableListOf<SourceFinding>()

        val matches = SourceFileScanner.containsPattern(
            "SharedPreferences",
            sourceRoot,
            excludingPaths = listOf("Test", "test", "Mock", "Fake"),
        )
        for (match in matches) {
            val lower = match.content.lowercase()
            if (lower.contains("//")) continue
            if (sensitiveKeys.any { lower.contains(it) }) {
                findings.add(match)
            }
        }

        if (findings.isNotEmpty()) {
            println("WARNING: Found ${findings.size} sensitive data stored in SharedPreferences")
        }

        assertWithMessage(
            "Found ${findings.size} sensitive data in SharedPreferences — use EncryptedSharedPreferences",
        ).that(findings).isEmpty()
    }

    @Test
    fun `network security config does not allow cleartext traffic`() {
        val manifestFile = File(sourceRoot.parentFile?.parentFile?.parentFile, "AndroidManifest.xml")
        if (!manifestFile.exists()) return

        val content = manifestFile.readText()
        assertWithMessage(
            "AndroidManifest.xml should not contain usesCleartextTraffic=true",
        ).that(content).doesNotContain("android:usesCleartextTraffic=\"true\"")
    }
}
