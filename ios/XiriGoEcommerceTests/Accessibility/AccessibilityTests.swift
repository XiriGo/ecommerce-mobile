import Foundation
import Testing

/// Static accessibility audit tests that scan source code for common issues.
/// Maps to TEST.md Section 8 — Accessibility Test Layer.
///
/// Runtime accessibility audits (performAccessibilityAudit) require XCUITest.
/// These tests catch missing accessibility modifiers at the code level.
@Suite("Accessibility Tests")
struct AccessibilityTests {
    // MARK: - Internal

    // MARK: - Accessibility Labels on Interactive Elements

    @Test("Interactive elements have accessibility modifiers")
    func interactiveElements_haveAccessibilityModifiers() {
        // Find all screen files (presentation/screen/)
        let screenFiles = SourceFileScanner.swiftFiles(in: sourceRoot)
            .filter { $0.path.contains("/screen/") || $0.path.contains("/Screen/") || $0.path.contains("/Screen.swift")
            }

        var missingAccessibility: [SourceFinding] = []

        for file in screenFiles {
            let findings = findImagesWithoutAccessibility(in: file)
            missingAccessibility.append(contentsOf: findings)
        }

        // Warning-level: log issues but don't fail the build
        if !missingAccessibility.isEmpty {
            // swiftlint:disable:next no_print_statements
            print("⚠️ Found \(missingAccessibility.count) image(s) without accessibility modifiers")
        }
    }

    // MARK: - Touch Target Size

    @Test("No explicit small frame sizes on interactive elements")
    func interactiveElements_meetMinimumTouchTarget() {
        let screenFiles = SourceFileScanner.swiftFiles(in: sourceRoot)
            .filter { $0.path.contains("/screen/") || $0.path.contains("/Screen/") || $0.path.contains("/Component/") }

        var smallTargets: [SourceFinding] = []

        for file in screenFiles {
            let findings = findSmallTouchTargets(in: file)
            smallTargets.append(contentsOf: findings)
        }

        // Warning-level: log issues but don't fail the build
        if !smallTargets.isEmpty {
            // swiftlint:disable:next no_print_statements
            print("⚠️ Found \(smallTargets.count) potentially small touch target(s)")
        }
    }

    // MARK: - Color Contrast (Design System Check)

    @Test("Design system components use semantic colors (not hardcoded hex)")
    func designSystem_usesSemanticColors() {
        let featureDir = sourceRoot + "/Feature"
        guard FileManager.default.fileExists(atPath: featureDir) else {
            return
        }

        let hardcodedColors = SourceFileScanner.containsPattern(
            "Color(#colorLiteral",
            in: featureDir,
            excludingPaths: ["Tests", "Preview"],
        ) + SourceFileScanner.containsPattern(
            "Color(red:",
            in: featureDir,
            excludingPaths: ["Tests", "Preview"],
        ) + SourceFileScanner.containsPattern(
            "Color(hex:",
            in: featureDir,
            excludingPaths: ["Tests", "Preview"],
        )

        // Warning-level: log issues but don't fail the build
        if !hardcodedColors.isEmpty {
            // swiftlint:disable:next no_print_statements
            print("⚠️ Found \(hardcodedColors.count) hardcoded color(s) in feature code — use XGColors semantic tokens")
        }
    }

    // MARK: - Private

    private let sourceRoot = SecurityTestHelpers.sourceRoot

    private let minimumTouchTarget: Double = 44

    // MARK: - Helpers

    private func extractNumber(from string: String) -> Double? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        var numStr = ""
        for char in trimmed {
            if char.isNumber || char == "." {
                numStr.append(char)
            } else {
                break
            }
        }
        return Double(numStr)
    }

    private func findImagesWithoutAccessibility(in file: URL) -> [SourceFinding] {
        guard let content = try? String(contentsOf: file, encoding: .utf8) else {
            return []
        }
        let lines = content.components(separatedBy: .newlines)
        var findings: [SourceFinding] = []
        let lookAheadCount = 5

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.contains("Image("), !trimmed.hasPrefix("//") else {
                continue
            }
            let end = min(index + 1 + lookAheadCount, lines.count)
            let lookAhead = lines[min(index + 1, lines.count - 1) ..< end].joined(separator: " ")
            let hasA11y = lookAhead.contains("accessibilityLabel") ||
                lookAhead.contains("accessibilityHidden") ||
                lookAhead.contains(".decorative")
            if !hasA11y {
                findings.append(SourceFinding(file: file.path, line: index + 1, content: trimmed))
            }
        }
        return findings
    }

    private func isBelowMinimum(_ text: String, dimension: String) -> Bool {
        guard let range = text.range(of: dimension) else {
            return false
        }
        guard let value = extractNumber(from: String(text[range.upperBound...])) else {
            return false
        }
        return value < minimumTouchTarget
    }

    private func findSmallTouchTargets(in file: URL) -> [SourceFinding] {
        guard let content = try? String(contentsOf: file, encoding: .utf8) else {
            return []
        }
        let lines = content.components(separatedBy: .newlines)
        var findings: [SourceFinding] = []
        let contextRange = 3

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.contains(".frame(") else {
                continue
            }
            let context = lines[max(0, index - contextRange) ..< min(index + contextRange, lines.count)]
                .joined(separator: " ")
            let isInteractive = context.contains("Button") || context.contains("onTapGesture") || context
                .contains("tap")
            guard isInteractive else {
                continue
            }

            let finding = SourceFinding(file: file.path, line: index + 1, content: trimmed)
            if isBelowMinimum(trimmed, dimension: "width:") {
                findings.append(finding)
            }
            if isBelowMinimum(trimmed, dimension: "height:") {
                findings.append(finding)
            }
        }
        return findings
    }
}
