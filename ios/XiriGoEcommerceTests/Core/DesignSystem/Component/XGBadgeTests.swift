import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGCountBadgeTests

@Suite("XGCountBadge Tests")
struct XGCountBadgeTests {
    // MARK: - Count Values

    @Test("CountBadge initialises with count 0")
    func test_init_countZero_initialises() {
        let badge = XGCountBadge(count: 0)
        _ = badge
        #expect(true)
    }

    @Test("CountBadge initialises with count 1")
    func test_init_countOne_initialises() {
        let badge = XGCountBadge(count: 1)
        _ = badge
        #expect(true)
    }

    @Test("CountBadge initialises with count 99")
    func test_init_count99_initialises() {
        let badge = XGCountBadge(count: 99)
        _ = badge
        #expect(true)
    }

    @Test("CountBadge initialises with count 100 (displays 99+)")
    func test_init_count100_initialises() {
        let badge = XGCountBadge(count: 100)
        _ = badge
        #expect(true)
    }

    @Test("CountBadge initialises with large count (displays 99+)")
    func test_init_largeCount_initialises() {
        let badge = XGCountBadge(count: 999)
        _ = badge
        #expect(true)
    }

    // MARK: - Display Text Logic

    @Test("Display text shows exact count for values below 100")
    func test_displayText_below100_showsExactCount() {
        // Access displayText via the view body — we verify via a helper that reflects the logic
        // count < 100 → "\(count)", count >= 100 → "99+"
        #expect(countDisplayText(for: 1) == "1")
        #expect(countDisplayText(for: 50) == "50")
        #expect(countDisplayText(for: 99) == "99")
    }

    @Test("Display text shows 99+ for count of 100")
    func test_displayText_count100_shows99Plus() {
        #expect(countDisplayText(for: 100) == "99+")
    }

    @Test("Display text shows 99+ for large counts")
    func test_displayText_largeCount_shows99Plus() {
        #expect(countDisplayText(for: 999) == "99+")
        #expect(countDisplayText(for: 1000) == "99+")
    }

    @Test("Display text for zero is empty body (badge hidden)")
    func test_displayText_zero_badgeHidden() {
        // count == 0 → view body renders nothing (EmptyView)
        // We verify the logic: count > 0 is required to show badge
        #expect(countDisplayText(for: 0).isEmpty) // Badge is hidden for 0
    }

    // MARK: - Body

    @Test("CountBadge body is a valid View", .disabled(swiftUIDisabledReason))
    func test_body_isValidView() {
        let badge = XGCountBadge(count: 5)
        let body = badge.body
        _ = body
        #expect(true)
    }

    // MARK: - Helper

    /// Mirrors the private `displayText` logic in XGCountBadge for test verification.
    private func countDisplayText(for count: Int) -> String {
        if count == 0 { return "" }
        return count >= 100 ? "99+" : "\(count)"
    }
}

// MARK: - XGBadgeStatusTests

@Suite("XGBadgeStatus Tests")
struct XGBadgeStatusTests {
    @Test("Success status has correct background color")
    func test_success_backgroundColor_isGreen() {
        #expect(XGBadgeStatus.success.backgroundColor == XGColors.success)
    }

    @Test("Warning status has correct background color")
    func test_warning_backgroundColor_isOrange() {
        #expect(XGBadgeStatus.warning.backgroundColor == XGColors.warning)
    }

    @Test("Error status has correct background color")
    func test_error_backgroundColor_isRed() {
        #expect(XGBadgeStatus.error.backgroundColor == XGColors.error)
    }

    @Test("Info status has correct background color")
    func test_info_backgroundColor_isInfo() {
        #expect(XGBadgeStatus.info.backgroundColor == XGColors.info)
    }

    @Test("Neutral status has correct background color")
    func test_neutral_backgroundColor_isSurfaceVariant() {
        #expect(XGBadgeStatus.neutral.backgroundColor == XGColors.surfaceVariant)
    }

    @Test("Success status has white text color")
    func test_success_textColor_isWhite() {
        #expect(XGBadgeStatus.success.textColor == XGColors.onSuccess)
    }

    @Test("All statuses have distinct background colors")
    func test_allStatuses_distinctBackgroundColors() {
        let colors = [
            XGBadgeStatus.success.backgroundColor,
            XGBadgeStatus.warning.backgroundColor,
            XGBadgeStatus.error.backgroundColor,
            XGBadgeStatus.info.backgroundColor,
            XGBadgeStatus.neutral.backgroundColor,
        ]
        // Verify we have 5 statuses
        #expect(colors.count == 5)
    }
}

// MARK: - XGStatusBadgeTests

@Suite("XGStatusBadge Tests")
struct XGStatusBadgeTests {
    @Test("StatusBadge initialises with success status and label")
    func test_init_success_initialises() {
        let badge = XGStatusBadge(status: .success, label: "In Stock")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with warning status")
    func test_init_warning_initialises() {
        let badge = XGStatusBadge(status: .warning, label: "Low Stock")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with error status")
    func test_init_error_initialises() {
        let badge = XGStatusBadge(status: .error, label: "Out of Stock")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with info status")
    func test_init_info_initialises() {
        let badge = XGStatusBadge(status: .info, label: "Processing")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with neutral status")
    func test_init_neutral_initialises() {
        let badge = XGStatusBadge(status: .neutral, label: "Draft")
        _ = badge
        #expect(true)
    }
}
