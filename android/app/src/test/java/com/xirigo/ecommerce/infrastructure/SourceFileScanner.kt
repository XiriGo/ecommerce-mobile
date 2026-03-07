package com.xirigo.ecommerce.infrastructure

import java.io.File

/**
 * Finding from source file scanning.
 */
data class SourceFinding(
    val file: String,
    val line: Int,
    val content: String,
)

/**
 * Finding with pattern info for secret detection.
 */
data class SecretFinding(
    val file: String,
    val line: Int,
    val content: String,
    val pattern: String,
)

/**
 * Scans Kotlin source files for pattern matching (used by security/accessibility/architecture tests).
 */
object SourceFileScanner {

    /**
     * Returns all Kotlin files in a directory, recursively.
     */
    fun kotlinFiles(directory: File): List<File> {
        if (!directory.exists()) return emptyList()
        return directory.walkTopDown()
            .filter { it.isFile && it.extension == "kt" }
            .toList()
    }

    /**
     * Returns lines matching a pattern in a given file.
     */
    fun linesMatching(pattern: String, file: File): List<SourceFinding> {
        if (!file.exists()) return emptyList()
        return file.readLines()
            .mapIndexedNotNull { index, line ->
                if (line.contains(pattern)) {
                    SourceFinding(file = file.path, line = index + 1, content = line)
                } else {
                    null
                }
            }
    }

    /**
     * Finds all lines containing a pattern across all Kotlin files in a directory.
     */
    fun containsPattern(
        pattern: String,
        directory: File,
        excludingPaths: List<String> = emptyList(),
    ): List<SourceFinding> {
        return kotlinFiles(directory)
            .filter { file -> excludingPaths.none { file.path.contains(it) } }
            .flatMap { linesMatching(pattern, it) }
    }
}
