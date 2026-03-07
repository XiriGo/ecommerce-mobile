import SnapshotTesting
import SwiftUI
import XCTest

/// Base class for snapshot tests with standard configurations.
/// Maps to TEST.md Section 3 — Snapshot (Visual Regression) Tests.
///
/// Usage:
/// ```swift
/// final class LoginScreenSnapshotTests: SnapshotTestCase {
///     func test_loginScreen_default() {
///         let view = LoginScreen()
///         assertScreenSnapshot(view, named: "default")
///     }
///
///     func test_loginScreen_darkMode() {
///         let view = LoginScreen()
///         assertScreenSnapshot(view, named: "dark", colorScheme: .dark)
///     }
/// }
/// ```
class SnapshotTestCase: XCTestCase {
    // MARK: - Internal

    override func setUp() {
        super.setUp()
        if isRecordingMode {
            SnapshotTesting.isRecording = true
        }
    }

    override func tearDown() {
        SnapshotTesting.isRecording = false
        super.tearDown()
    }

    // MARK: - Private

    /// Set to `true` to record new reference snapshots.
    /// Run once to generate baselines, then set back to `false`.
    private var isRecordingMode: Bool {
        ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"] == "true"
    }

    // MARK: - SwiftUI Snapshot Assertions

    /// Asserts a SwiftUI view matches its reference snapshot.
    private func assertScreenSnapshot(
        _ view: some View,
        named name: String? = nil,
        colorScheme: ColorScheme = .light,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
    ) {
        let themedView = view
            .environment(\.colorScheme, colorScheme)

        assertSnapshot(
            of: themedView,
            as: .image(
                layout: .device(config: .iPhone13),
            ),
            named: name,
            file: file,
            testName: testName,
            line: line,
        )
    }

    /// Asserts a SwiftUI component matches its reference snapshot with fixed size.
    private func assertComponentSnapshot(
        _ view: some View,
        named name: String? = nil,
        size: CGSize = CGSize(width: 375, height: 200),
        colorScheme: ColorScheme = .light,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
    ) {
        let themedView = view
            .environment(\.colorScheme, colorScheme)

        assertSnapshot(
            of: themedView,
            as: .image(
                layout: .fixed(width: size.width, height: size.height),
            ),
            named: name,
            file: file,
            testName: testName,
            line: line,
        )
    }

    /// Tests a view in both light and dark mode.
    private func assertLightAndDarkSnapshot(
        _ view: some View,
        named name: String? = nil,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
    ) {
        assertScreenSnapshot(
            view,
            named: (name.map { $0 + "_" } ?? "") + "light",
            colorScheme: .light,
            file: file,
            testName: testName,
            line: line,
        )

        assertScreenSnapshot(
            view,
            named: (name.map { $0 + "_" } ?? "") + "dark",
            colorScheme: .dark,
            file: file,
            testName: testName,
            line: line,
        )
    }

    /// Tests a view with large accessibility font.
    private func assertAccessibilityFontSnapshot(
        _ view: some View,
        named name: String? = nil,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
    ) {
        let accessibleView = view
            .environment(\.sizeCategory, .accessibilityExtraLarge)

        assertScreenSnapshot(
            accessibleView,
            named: (name.map { $0 + "_" } ?? "") + "a11y_large_font",
            file: file,
            testName: testName,
            line: line,
        )
    }
}
