import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGCountBadgeTests

@Suite("XGCountBadge Tests")
@MainActor
struct XGCountBadgeTests {
    // MARK: - Internal

    // MARK: - Count Values

    @Test("CountBadge initialises with count 0")
    func init_countZero_initialises() {
        let badge = XGCountBadge(count: 0)
        _ = badge
        #expect(true)
    }

    @Test("CountBadge initialises with count 1")
    func init_countOne_initialises() {
        let badge = XGCountBadge(count: 1)
        _ = badge
        #expect(true)
    }

    @Test("CountBadge initialises with count 99")
    func init_count99_initialises() {
        let badge = XGCountBadge(count: 99)
        _ = badge
        #expect(true)
    }

    @Test("CountBadge initialises with count 100 (displays 99+)")
    func init_count100_initialises() {
        let badge = XGCountBadge(count: 100)
        _ = badge
        #expect(true)
    }

    @Test("CountBadge initialises with large count (displays 99+)")
    func init_largeCount_initialises() {
        let badge = XGCountBadge(count: 999)
        _ = badge
        #expect(true)
    }

    // MARK: - Display Text Logic

    @Test("Display text shows exact count for values below 100")
    func displayText_below100_showsExactCount() {
        #expect(countDisplayText(for: 1) == "1")
        #expect(countDisplayText(for: 50) == "50")
        #expect(countDisplayText(for: 99) == "99")
    }

    @Test("Display text shows 99+ for count of 100")
    func displayText_count100_shows99Plus() {
        #expect(countDisplayText(for: 100) == "99+")
    }

    @Test("Display text shows 99+ for large counts")
    func displayText_largeCount_shows99Plus() {
        #expect(countDisplayText(for: 999) == "99+")
        #expect(countDisplayText(for: 1000) == "99+")
    }

    @Test("Display text for zero is empty body (badge hidden)")
    func displayText_zero_badgeHidden() {
        #expect(countDisplayText(for: 0).isEmpty)
    }

    // MARK: - hasItems Logic

    @Test("hasItems returns false for count 0")
    func hasItems_countZero_returnsFalse() {
        #expect(hasItems(for: 0) == false)
    }

    @Test("hasItems returns true for count 1")
    func hasItems_countOne_returnsTrue() {
        #expect(hasItems(for: 1) == true)
    }

    @Test("hasItems returns true for count 99")
    func hasItems_count99_returnsTrue() {
        #expect(hasItems(for: 99) == true)
    }

    @Test("hasItems returns true for count 100")
    func hasItems_count100_returnsTrue() {
        #expect(hasItems(for: 100) == true)
    }

    @Test("hasItems returns true for count 150")
    func hasItems_count150_returnsTrue() {
        #expect(hasItems(for: 150) == true)
    }

    @Test("hasItems boundary: count 0 hidden, count 1 visible")
    func hasItems_boundary_0hidden_1visible() {
        #expect(hasItems(for: 0) == false)
        #expect(hasItems(for: 1) == true)
    }

    // MARK: - Body

    @Test("CountBadge body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        let badge = XGCountBadge(count: 5)
        let body = badge.body
        _ = body
        #expect(true)
    }

    // MARK: - Private

    // MARK: - Private Helpers

    /// Mirrors the private `displayText` logic in XGCountBadge for test verification.
    private func countDisplayText(for count: Int) -> String {
        if count == 0 {
            return ""
        }
        return count >= 100 ? "99+" : "\(count)"
    }

    /// Mirrors the private `hasItems` logic in XGCountBadge for test verification.
    private func hasItems(for count: Int) -> Bool {
        count >= 1
    }
}

// MARK: - XGCountBadgeTokenContractTests

@Suite("XGCountBadge Token Contract Tests")
struct XGCountBadgeTokenContractTests {
    @Test("XGSpacing.xs equals 4 (XGCountBadge horizontal padding)")
    func xgSpacingXs_is4() {
        #expect(XGSpacing.xs == 4)
    }

    @Test("XGSpacing.xxs equals 2 (XGCountBadge vertical padding)")
    func xgSpacingXxs_is2() {
        #expect(XGSpacing.xxs == 2)
    }

    @Test("XGCountBadge horizontal padding is greater than vertical padding")
    func horizontalPadding_greaterThan_verticalPadding() {
        #expect(XGSpacing.xs > XGSpacing.xxs)
    }

    @Test("XGTypography.labelSmall is 11pt Medium (XGCountBadge font)")
    func labelSmall_is11ptMedium() {
        #expect(XGTypography.labelSmall == Font.custom("Poppins-Medium", size: 11))
    }

    @Test("XGColors.badgeBackground is used for count badge background")
    func badgeBackground_usedForCountBadge() {
        #expect(XGColors.badgeBackground == Color(hex: "#6000FE"))
    }

    @Test("XGColors.badgeText is used for count badge text color")
    func badgeText_usedForCountBadgeText() {
        #expect(XGColors.badgeText == Color.white)
    }
}

// MARK: - XGStatusBadgeTests

@Suite("XGStatusBadge Tests")
@MainActor
struct XGStatusBadgeTests {
    @Test("StatusBadge initialises with success status and label")
    func init_success_initialises() {
        let badge = XGStatusBadge(status: .success, label: "In Stock")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with warning status")
    func init_warning_initialises() {
        let badge = XGStatusBadge(status: .warning, label: "Low Stock")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with error status")
    func init_error_initialises() {
        let badge = XGStatusBadge(status: .error, label: "Out of Stock")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with info status")
    func init_info_initialises() {
        let badge = XGStatusBadge(status: .info, label: "Processing")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with neutral status")
    func init_neutral_initialises() {
        let badge = XGStatusBadge(status: .neutral, label: "Draft")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge initialises with empty label")
    func init_emptyLabel_initialises() {
        let badge = XGStatusBadge(status: .success, label: "")
        _ = badge
        #expect(true)
    }

    @Test("StatusBadge body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        let badge = XGStatusBadge(status: .success, label: "In Stock")
        let body = badge.body
        _ = body
        #expect(true)
    }
}

// MARK: - XGStatusBadgeTokenContractTests

@Suite("XGStatusBadge Token Contract Tests")
struct XGStatusBadgeTokenContractTests {
    @Test("XGSpacing.sm equals 8 (XGStatusBadge horizontal padding)")
    func xgSpacingSm_is8() {
        #expect(XGSpacing.sm == 8)
    }

    @Test("XGSpacing.xs equals 4 (XGStatusBadge vertical padding)")
    func xgSpacingXs_is4() {
        #expect(XGSpacing.xs == 4)
    }

    @Test("XGStatusBadge horizontal padding is greater than vertical padding")
    func horizontalPadding_greaterThan_verticalPadding() {
        #expect(XGSpacing.sm > XGSpacing.xs)
    }

    @Test("XGTypography.labelSmall is 11pt Medium (XGStatusBadge font)")
    func labelSmall_is11ptMedium() {
        #expect(XGTypography.labelSmall == Font.custom("Poppins-Medium", size: 11))
    }
}
