import Foundation
import Testing

/// Architecture tests that enforce Clean Architecture layer boundaries.
///
/// These tests scan the actual source files to verify:
/// - Domain layer does not depend on Data layer
/// - Presentation layer does not depend on Data layer
/// - Feature screens use design system components instead of raw SwiftUI components
/// - ViewModels include required @MainActor and @Observable annotations
@Suite("Architecture Tests")
internal struct ArchitectureTests {
    // MARK: - Helpers

    private static let sourceRoot: URL = {
        // Navigate from the test bundle to the iOS source root
        // In Xcode, the working directory for tests is the build products dir.
        // We use a well-known relative path from the project root.

        // Try to find the source root relative to the package/project directory
        // First check for SRCROOT environment variable (set by Xcode)
        if let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] {
            return URL(fileURLWithPath: srcRoot)
                .appendingPathComponent("MoltMarketplace")
        }

        // Fallback: walk up from current file location to find the project
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // ArchitectureTests.swift -> MoltMarketplaceTests/
        let projectRoot = url.deletingLastPathComponent() // MoltMarketplaceTests/ -> ios/
        return projectRoot.appendingPathComponent("MoltMarketplace")
    }()

    private static func findSwiftFiles(in directory: URL) -> [URL] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var files: [URL] = []
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
            files.append(fileURL)
        }
        return files
    }

    private static func importLines(in fileURL: URL) -> [String] {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.hasPrefix("import ") }
    }

    private static func relativePath(for fileURL: URL) -> String {
        fileURL.path.replacingOccurrences(
            of: sourceRoot.path + "/",
            with: ""
        )
    }

    private static func containsDataLayerReference(_ line: String) -> Bool {
        line.contains("RepositoryImpl")
            || line.contains("DTO")
            || line.contains("Endpoint")
            || line.contains("APIClient")
    }

    private static func isCodeLine(_ trimmed: String) -> Bool {
        !trimmed.hasPrefix("//")
            && !trimmed.hasPrefix("*")
            && !trimmed.hasPrefix("import ")
    }

    // MARK: - Rule 1: Domain layer must NOT import from Data types

    @Test("Domain layer must not depend on Data layer")
    internal func domainMustNotDependOnData() {
        let allFiles = Self.findSwiftFiles(in: Self.sourceRoot)
        let domainFiles = allFiles.filter { $0.path.contains("/Domain/") }
        var violations: [String] = []

        for file in domainFiles {
            guard let content = try? String(contentsOf: file, encoding: .utf8) else { continue }
            let lines = content.components(separatedBy: .newlines)

            for (index, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                let hasDataImport = trimmed.hasPrefix("import ")
                    && Self.containsDataLayerReference(trimmed)
                if hasDataImport {
                    let path = Self.relativePath(for: file)
                    violations.append(
                        "\(path):\(index + 1): '\(trimmed)' "
                        + "-- domain layer must not depend on data layer"
                    )
                }
                if Self.isCodeLine(trimmed) && Self.containsDataLayerReference(trimmed) {
                    let path = Self.relativePath(for: file)
                    violations.append(
                        "\(path):\(index + 1): references data-layer type "
                        + "'\(trimmed.prefix(80))...' "
                        + "-- domain layer must not reference data-layer types"
                    )
                }
            }
        }

        #expect(violations.isEmpty, """
        Domain layer boundary violations found:
        \(violations.joined(separator: "\n"))
        """)
    }

    // MARK: - Rule 2: Presentation layer must NOT import from Data types

    @Test("Presentation layer must not depend on Data layer")
    internal func presentationMustNotDependOnData() {
        let allFiles = Self.findSwiftFiles(in: Self.sourceRoot)
        let presentationFiles = allFiles.filter { $0.path.contains("/Presentation/") }
        var violations: [String] = []

        for file in presentationFiles {
            guard let content = try? String(contentsOf: file, encoding: .utf8) else { continue }
            let lines = content.components(separatedBy: .newlines)

            for (index, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if Self.isCodeLine(trimmed) && Self.containsDataLayerReference(trimmed) {
                    let path = Self.relativePath(for: file)
                    violations.append(
                        "\(path):\(index + 1): references data-layer type "
                        + "'\(trimmed.prefix(80))...' "
                        + "-- presentation layer must not reference data-layer types"
                    )
                }
            }
        }

        #expect(violations.isEmpty, """
        Presentation layer boundary violations found:
        \(violations.joined(separator: "\n"))
        """)
    }

    // MARK: - Rule 3: Feature screens must use design system components

    @Test("Feature screens must use Molt design system components instead of raw SwiftUI")
    internal func featureScreensMustUseDesignSystem() {
        let allFiles = Self.findSwiftFiles(in: Self.sourceRoot)

        // Find files in Feature/*/Presentation/ directories
        let presentationFiles = allFiles.filter { url in
            let path = url.path
            return path.contains("/Feature/") && path.contains("/Presentation/")
        }

        // Map of raw SwiftUI components to their Molt equivalents
        let forbiddenPatterns: [(pattern: String, replacement: String)] = [
            ("ProgressView(", "MoltLoadingView or MoltLoadingIndicator"),
            ("ProgressView {", "MoltLoadingView or MoltLoadingIndicator"),
        ]

        var violations: [String] = []

        for file in presentationFiles {
            guard let content = try? String(contentsOf: file, encoding: .utf8) else { continue }
            let lines = content.components(separatedBy: .newlines)

            for (index, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)

                // Skip comments
                if trimmed.hasPrefix("//") || trimmed.hasPrefix("*") { continue }

                for (pattern, replacement) in forbiddenPatterns where trimmed.contains(pattern) {
                    let relativePath = Self.relativePath(for: file)
                    violations.append(
                        "\(relativePath):\(index + 1): uses raw '\(pattern)' "
                        + "-- use \(replacement) from Core/DesignSystem instead"
                    )
                }
            }
        }

        #expect(violations.isEmpty, """
        Raw SwiftUI component usage in feature screens:
        \(violations.joined(separator: "\n"))
        """)
    }

    // MARK: - Rule 4: ViewModels must use @MainActor and @Observable

    @Test("ViewModels must include @MainActor and @Observable annotations")
    internal func viewModelsMustHaveRequiredAnnotations() {
        let allFiles = Self.findSwiftFiles(in: Self.sourceRoot)

        let viewModelFiles = allFiles.filter { url in
            url.lastPathComponent.hasSuffix("ViewModel.swift")
        }

        var violations: [String] = []

        for file in viewModelFiles {
            guard let content = try? String(contentsOf: file, encoding: .utf8) else { continue }
            let relativePath = Self.relativePath(for: file)

            let hasMainActor = content.contains("@MainActor")
            let hasObservable = content.contains("@Observable")

            if !hasMainActor {
                violations.append(
                    "\(relativePath): missing @MainActor annotation "
                    + "-- all ViewModels must be annotated with @MainActor"
                )
            }

            if !hasObservable {
                violations.append(
                    "\(relativePath): missing @Observable annotation "
                    + "-- all ViewModels must be annotated with @Observable (iOS 17+)"
                )
            }
        }

        #expect(violations.isEmpty, """
        ViewModel annotation violations found:
        \(violations.joined(separator: "\n"))
        """)
    }
}
