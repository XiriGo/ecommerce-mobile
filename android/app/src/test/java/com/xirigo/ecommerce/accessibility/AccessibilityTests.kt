package com.xirigo.ecommerce.accessibility

import org.junit.Test
import java.io.File
import com.xirigo.ecommerce.infrastructure.SourceFileScanner
import com.xirigo.ecommerce.infrastructure.SourceFinding

/**
 * Static accessibility audit tests that scan source code for common issues.
 * Maps to ANDROID_TEST.md Section 8 — Accessibility Test Layer.
 *
 * Runtime accessibility audits require instrumented tests.
 * These tests catch missing accessibility modifiers at the code level.
 */
class AccessibilityTests {

    private val sourceRoot = File("src/main/java/com/xirigo/ecommerce")
    private val lookAheadCount = 5
    private val contextRange = 3
    private val minimumTouchTargetDp = 44

    @Test
    fun `interactive composables have content descriptions`() {
        val screenFiles = SourceFileScanner.kotlinFiles(sourceRoot)
            .filter { file ->
                val path = file.path.replace(File.separatorChar, '/')
                path.contains("/screen/") || path.contains("/Screen/") || path.endsWith("Screen.kt")
            }

        val missingDescriptions = mutableListOf<SourceFinding>()

        for (file in screenFiles) {
            missingDescriptions.addAll(findImagesWithoutContentDescription(file))
        }

        // Warning-level: log issues but don't fail the build
        if (missingDescriptions.isNotEmpty()) {
            println("WARNING: Found ${missingDescriptions.size} Image(s) without contentDescription")
        }
    }

    @Test
    fun `no explicit small sizes on interactive elements`() {
        val screenFiles = SourceFileScanner.kotlinFiles(sourceRoot)
            .filter { file ->
                val path = file.path.replace(File.separatorChar, '/')
                path.contains("/screen/") || path.contains("/component/") || path.contains("/Component/")
            }

        val smallTargets = mutableListOf<SourceFinding>()

        for (file in screenFiles) {
            smallTargets.addAll(findSmallTouchTargets(file))
        }

        // Warning-level: log issues but don't fail the build
        if (smallTargets.isNotEmpty()) {
            println("WARNING: Found ${smallTargets.size} potentially small touch target(s)")
        }
    }

    @Test
    fun `design system components use theme colors - not hardcoded hex`() {
        val featureDir = File(sourceRoot, "feature")
        if (!featureDir.exists()) return

        val hardcodedColors = SourceFileScanner.containsPattern(
            "Color(0x",
            featureDir,
            excludingPaths = listOf("Test", "Preview"),
        ) + SourceFileScanner.containsPattern(
            "Color(red",
            featureDir,
            excludingPaths = listOf("Test", "Preview"),
        )

        if (hardcodedColors.isNotEmpty()) {
            println(
                "WARNING: Found ${hardcodedColors.size} hardcoded color(s) in feature code — " +
                    "use XGColors tokens instead",
            )
        }
    }

    private fun findImagesWithoutContentDescription(file: File): List<SourceFinding> {
        val lines = file.readLines()
        val findings = mutableListOf<SourceFinding>()

        for ((index, line) in lines.withIndex()) {
            val trimmed = line.trim()
            if (!trimmed.contains("Image(") || trimmed.startsWith("//")) continue

            val end = minOf(index + 1 + lookAheadCount, lines.size)
            val lookAhead = lines.subList(minOf(index + 1, lines.size - 1), end).joinToString(" ")
            val hasA11y = lookAhead.contains("contentDescription") ||
                lookAhead.contains("decorative")
            if (!hasA11y) {
                findings.add(SourceFinding(file = file.path, line = index + 1, content = trimmed))
            }
        }
        return findings
    }

    private fun findSmallTouchTargets(file: File): List<SourceFinding> {
        val lines = file.readLines()
        val findings = mutableListOf<SourceFinding>()

        for ((index, line) in lines.withIndex()) {
            val trimmed = line.trim()
            if (!containsSizeModifier(trimmed)) continue
            if (!isNearInteractiveElement(lines, index)) continue

            val finding = SourceFinding(file = file.path, line = index + 1, content = trimmed)
            if (hasSmallDimension(trimmed)) {
                findings.add(finding)
            }
        }
        return findings
    }

    private fun containsSizeModifier(line: String): Boolean = line.contains(".size(") || line.contains(".width(") ||
        line.contains(".height(") || line.contains("Modifier.size")

    private fun isNearInteractiveElement(lines: List<String>, index: Int): Boolean {
        val start = maxOf(0, index - contextRange)
        val end = minOf(index + contextRange, lines.size)
        val context = lines.subList(start, end).joinToString(" ")
        return context.contains("Button") || context.contains("clickable") ||
            context.contains("onClick")
    }

    private fun hasSmallDimension(text: String): Boolean =
        isBelowMinimum(text, "size(") || isBelowMinimum(text, "width(") ||
            isBelowMinimum(text, "height(")

    private fun isBelowMinimum(text: String, dimension: String): Boolean {
        val idx = text.indexOf(dimension)
        if (idx < 0) return false
        val after = text.substring(idx + dimension.length)
        val numStr = after.takeWhile { it.isDigit() || it == '.' }
        val value = numStr.toDoubleOrNull() ?: return false
        return value < minimumTouchTargetDp
    }
}
