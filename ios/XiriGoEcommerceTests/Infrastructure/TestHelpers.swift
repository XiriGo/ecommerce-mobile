import Foundation
import Testing

// MARK: - MemoryLeakTracker

/// Asserts that an object is deallocated after the test scope ends.
/// Usage: Track the object before setting it to nil, then verify weak ref is nil.
///
/// ```swift
/// @Test func viewModel_noRetainCycle() {
///     var vm: SomeViewModel? = SomeViewModel()
///     let tracker = MemoryLeakTracker(vm!)
///     vm = nil
///     tracker.verify()
/// }
/// ```
struct MemoryLeakTracker {
    // MARK: - Lifecycle

    init(_ instance: AnyObject) {
        self.instance = instance
        typeName = String(describing: type(of: instance))
    }

    // MARK: - Internal

    func verify(sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(
            instance == nil,
            "Potential memory leak: \(typeName) was not deallocated",
            sourceLocation: sourceLocation,
        )
    }

    // MARK: - Private

    private weak var instance: AnyObject?
    private let typeName: String
}

// MARK: - Async Test Helpers

/// Waits for a condition to become true within a timeout.
/// Useful for testing async state transitions.
func waitForCondition(
    timeout: TimeInterval = 2.0,
    pollInterval: TimeInterval = 0.05,
    condition: @Sendable () async -> Bool,
) async -> Bool {
    let start = Date()
    while Date().timeIntervalSince(start) < timeout {
        if await condition() {
            return true
        }
        let nanosecondsPerSecond: Double = 1_000_000_000
        try? await Task.sleep(nanoseconds: UInt64(pollInterval * nanosecondsPerSecond))
    }
    return false
}

// MARK: - TestFixture

/// Protocol for creating test fixtures with builder pattern.
/// Conforming types provide a `.mock` static property and can be customized.
protocol TestFixture {
    static var mock: Self { get }
}

// MARK: - SourceFileScanner

/// Scans source files for pattern validation (used by architecture/security tests).
enum SourceFileScanner {
    /// Returns all Swift files in a directory, recursively.
    static func swiftFiles(in directory: String) -> [URL] {
        let fm = FileManager.default
        guard
            let enumerator = fm.enumerator(
                at: URL(fileURLWithPath: directory),
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles],
            )
        else {
            return []
        }

        var files: [URL] = []
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            files.append(url)
        }
        return files
    }

    /// Returns lines of a file that match a pattern.
    static func linesMatching(
        pattern: String,
        in fileURL: URL,
    ) -> [SourceFinding] {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }
        let lines = content.components(separatedBy: .newlines)
        var matches: [SourceFinding] = []
        for (index, line) in lines.enumerated() where line.contains(pattern) {
            matches.append(SourceFinding(file: fileURL.path, line: index + 1, content: line))
        }
        return matches
    }

    /// Checks if any file in the directory contains the given pattern.
    static func containsPattern(
        _ pattern: String,
        in directory: String,
        excludingPaths: [String] = [],
    ) -> [SourceFinding] {
        var results: [SourceFinding] = []
        for file in swiftFiles(in: directory) where !excludingPaths.contains(where: { file.path.contains($0) }) {
            results.append(contentsOf: linesMatching(pattern: pattern, in: file))
        }
        return results
    }
}
