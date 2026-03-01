package com.xirigo.ecommerce

import com.google.common.truth.Truth.assertWithMessage
import org.junit.Test
import java.io.File

/**
 * Architecture tests that enforce Clean Architecture layer boundaries.
 *
 * These tests scan the actual source files to verify:
 * - Domain layer does not depend on Data or Presentation layers
 * - Presentation layer does not depend on Data layer
 * - Feature screens use design system components instead of raw Material 3
 * - ViewModels do not depend on Android Context
 * - Screen composables include @Preview functions
 */
class ArchitectureTest {

    private val sourceRoot = File("src/main/java/com/xirigo/ecommerce")

    private fun findKotlinFiles(directory: File): List<File> {
        if (!directory.exists()) return emptyList()
        return directory.walkTopDown()
            .filter { it.isFile && it.extension == "kt" }
            .toList()
    }

    private fun File.importLines(): List<String> = readLines().filter { it.trimStart().startsWith("import ") }

    // -------------------------------------------------------------------------
    // Rule 1: Domain layer must NOT import from Data or Presentation layers
    // -------------------------------------------------------------------------
    @Test
    fun `domain layer must not depend on data or presentation layers`() {
        val domainFiles = findKotlinFiles(sourceRoot)
            .filter { file ->
                val relativePath = file.relativeTo(sourceRoot).path.replace(File.separatorChar, '/')
                relativePath.contains("/domain/")
            }

        val violations = mutableListOf<String>()

        for (file in domainFiles) {
            val imports = file.importLines()
            for (importLine in imports) {
                val importPath = importLine.substringAfter("import ").trim()
                if (importPath.contains(".data.") || importPath.contains(".presentation.")) {
                    violations.add(
                        "${file.relativeTo(sourceRoot).path}: illegal import '$importPath' " +
                            "-- domain layer must not depend on data or presentation layers",
                    )
                }
            }
        }

        assertWithMessage(
            "Domain layer boundary violations found:\n${violations.joinToString("\n")}",
        ).that(violations).isEmpty()
    }

    // -------------------------------------------------------------------------
    // Rule 2: Presentation layer must NOT import from Data layer
    // -------------------------------------------------------------------------
    @Test
    fun `presentation layer must not depend on data layer`() {
        val presentationFiles = findKotlinFiles(sourceRoot)
            .filter { file ->
                val relativePath = file.relativeTo(sourceRoot).path.replace(File.separatorChar, '/')
                relativePath.contains("/presentation/")
            }

        val violations = mutableListOf<String>()

        for (file in presentationFiles) {
            val imports = file.importLines()
            for (importLine in imports) {
                val importPath = importLine.substringAfter("import ").trim()
                if (importPath.contains(".data.")) {
                    violations.add(
                        "${file.relativeTo(sourceRoot).path}: illegal import '$importPath' " +
                            "-- presentation layer must not depend on data layer",
                    )
                }
            }
        }

        assertWithMessage(
            "Presentation layer boundary violations found:\n${violations.joinToString("\n")}",
        ).that(violations).isEmpty()
    }

    // -------------------------------------------------------------------------
    // Rule 3: Feature screens must use design system components, not raw Material 3
    // -------------------------------------------------------------------------
    @Test
    fun `feature screens must not import raw material3 components`() {
        val screenFiles = findKotlinFiles(sourceRoot)
            .filter { file ->
                val relativePath = file.relativeTo(sourceRoot).path.replace(File.separatorChar, '/')
                relativePath.matches(Regex(".*/feature/.*/presentation/screen/.*\\.kt"))
            }

        val violations = mutableListOf<String>()

        for (file in screenFiles) {
            val imports = file.importLines()
            for (importLine in imports) {
                val importPath = importLine.substringAfter("import ").trim()
                if (importPath.startsWith("androidx.compose.material3")) {
                    violations.add(
                        "${file.relativeTo(sourceRoot).path}: illegal import '$importPath' " +
                            "-- feature screens must use core.designsystem components " +
                            "instead of raw Material 3 imports",
                    )
                }
            }
        }

        assertWithMessage(
            "Material 3 direct-import violations in feature screens:\n${violations.joinToString("\n")}",
        ).that(violations).isEmpty()
    }

    // -------------------------------------------------------------------------
    // Rule 4: ViewModels must not depend on Android Context or android.app
    // -------------------------------------------------------------------------
    @Test
    fun `viewmodels must not import android context or android app`() {
        val viewModelFiles = findKotlinFiles(sourceRoot)
            .filter { it.name.endsWith("ViewModel.kt") }

        val forbiddenPrefixes = listOf(
            "android.content.Context",
            "android.app.",
        )

        val violations = mutableListOf<String>()

        for (file in viewModelFiles) {
            val imports = file.importLines()
            for (importLine in imports) {
                val importPath = importLine.substringAfter("import ").trim()
                for (prefix in forbiddenPrefixes) {
                    if (importPath.startsWith(prefix)) {
                        violations.add(
                            "${file.relativeTo(sourceRoot).path}: illegal import '$importPath' " +
                                "-- ViewModels must not depend on Android Context or " +
                                "android.app package. Inject dependencies via Hilt instead.",
                        )
                    }
                }
            }
        }

        assertWithMessage(
            "ViewModel Android-dependency violations found:\n${violations.joinToString("\n")}",
        ).that(violations).isEmpty()
    }

    // -------------------------------------------------------------------------
    // Rule 5: Screen composables with @Composable must include @Preview
    // -------------------------------------------------------------------------
    @Test
    fun `screen composables must include preview functions`() {
        val screenFiles = findKotlinFiles(sourceRoot)
            .filter { file ->
                val relativePath = file.relativeTo(sourceRoot).path.replace(File.separatorChar, '/')
                relativePath.matches(Regex(".*/feature/.*/presentation/screen/.*\\.kt"))
            }

        val violations = mutableListOf<String>()

        for (file in screenFiles) {
            val content = file.readText()
            val hasComposable = content.contains("@Composable")
            val hasPreview = content.contains("@Preview")

            if (hasComposable && !hasPreview) {
                violations.add(
                    "${file.relativeTo(sourceRoot).path}: " +
                        "contains @Composable functions but no @Preview -- " +
                        "every screen composable must have a @Preview function",
                )
            }
        }

        assertWithMessage(
            "Missing @Preview in screen composables:\n${violations.joinToString("\n")}",
        ).that(violations).isEmpty()
    }
}
