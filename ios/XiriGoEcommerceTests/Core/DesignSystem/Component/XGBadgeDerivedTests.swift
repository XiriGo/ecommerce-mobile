import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGBadgeStatusTests

@Suite("XGBadgeStatus Tests")
struct XGBadgeStatusTests {
    @Test("Success status has correct background color")
    func success_backgroundColor_isGreen() {
        #expect(XGBadgeStatus.success.backgroundColor == XGColors.success)
    }

    @Test("Warning status has correct background color")
    func warning_backgroundColor_isYellow() {
        #expect(XGBadgeStatus.warning.backgroundColor == XGColors.warning)
    }

    @Test("Error status has correct background color")
    func error_backgroundColor_isRed() {
        #expect(XGBadgeStatus.error.backgroundColor == XGColors.error)
    }

    @Test("Info status has correct background color")
    func info_backgroundColor_isInfo() {
        #expect(XGBadgeStatus.info.backgroundColor == XGColors.info)
    }

    @Test("Neutral status has correct background color")
    func neutral_backgroundColor_isSurfaceVariant() {
        #expect(XGBadgeStatus.neutral.backgroundColor == XGColors.surfaceVariant)
    }

    @Test("Success status has white text color")
    func success_textColor_isWhite() {
        #expect(XGBadgeStatus.success.textColor == XGColors.onSuccess)
    }

    @Test("All statuses have distinct background colors")
    func allStatuses_distinctBackgroundColors() {
        let colors = [
            XGBadgeStatus.success.backgroundColor,
            XGBadgeStatus.warning.backgroundColor,
            XGBadgeStatus.error.backgroundColor,
            XGBadgeStatus.info.backgroundColor,
            XGBadgeStatus.neutral.backgroundColor,
        ]
        #expect(colors.count == 5)
    }
}

// MARK: - XGBadgeStatusTextColorTests

@Suite("XGBadgeStatus Text Color Tests")
struct XGBadgeStatusTextColorTests {
    @Test("Success textColor is XGColors.onSuccess (white)")
    func success_textColor_isOnSuccess() {
        #expect(XGBadgeStatus.success.textColor == XGColors.onSuccess)
    }

    @Test("Warning textColor is XGColors.onWarning (dark)")
    func warning_textColor_isOnWarning() {
        #expect(XGBadgeStatus.warning.textColor == XGColors.onWarning)
    }

    @Test("Error textColor is XGColors.onError (white)")
    func error_textColor_isOnError() {
        #expect(XGBadgeStatus.error.textColor == XGColors.onError)
    }

    @Test("Info textColor is XGColors.onInfo (white)")
    func info_textColor_isOnInfo() {
        #expect(XGBadgeStatus.info.textColor == XGColors.onInfo)
    }

    @Test("Neutral textColor is XGColors.onSurfaceVariant")
    func neutral_textColor_isOnSurfaceVariant() {
        #expect(XGBadgeStatus.neutral.textColor == XGColors.onSurfaceVariant)
    }

    @Test("All 5 status variants have text color definitions")
    func allStatuses_haveTextColors() {
        let textColors = [
            XGBadgeStatus.success.textColor,
            XGBadgeStatus.warning.textColor,
            XGBadgeStatus.error.textColor,
            XGBadgeStatus.info.textColor,
            XGBadgeStatus.neutral.textColor,
        ]
        #expect(textColors.count == 5)
    }

    @Test("Warning textColor differs from success textColor (dark vs white)")
    func warning_textColor_differFromSuccess() {
        #expect(XGBadgeStatus.warning.textColor != XGBadgeStatus.success.textColor)
    }
}

// MARK: - XGBadgeStatusColorContractTests

/// Token contracts for XGBadgeStatus hex values cross-referenced against colors.json.
@Suite("XGBadgeStatus Color Contract Tests")
struct XGBadgeStatusColorContractTests {
    @Test("XGColors.success equals #22C55E (green)")
    func success_color_is22C55E() {
        #expect(XGColors.success == Color(hex: "#22C55E"))
    }

    @Test("XGColors.onSuccess equals white")
    func onSuccess_isWhite() {
        #expect(XGColors.onSuccess == Color.white)
    }

    @Test("XGColors.warning equals #FACC15 (yellow)")
    func warning_color_isFACC15() {
        #expect(XGColors.warning == Color(hex: "#FACC15"))
    }

    @Test("XGColors.onWarning equals #1D1D1B (dark, for accessibility on yellow)")
    func onWarning_is1D1D1B() {
        #expect(XGColors.onWarning == Color(hex: "#1D1D1B"))
    }

    @Test("XGColors.error equals #EF4444 (red)")
    func error_color_isEF4444() {
        #expect(XGColors.error == Color(hex: "#EF4444"))
    }

    @Test("XGColors.onError equals white")
    func onError_isWhite() {
        #expect(XGColors.onError == Color.white)
    }

    @Test("XGColors.info equals #3B82F6 (blue)")
    func info_color_is3B82F6() {
        #expect(XGColors.info == Color(hex: "#3B82F6"))
    }

    @Test("XGColors.onInfo equals white")
    func onInfo_isWhite() {
        #expect(XGColors.onInfo == Color.white)
    }

    @Test("XGColors.surfaceVariant equals #F9FAFB (neutral background)")
    func surfaceVariant_isF9FAFB() {
        #expect(XGColors.surfaceVariant == Color(hex: "#F9FAFB"))
    }

    @Test("XGColors.onSurfaceVariant equals #8E8E93 (secondary text on neutral)")
    func onSurfaceVariant_is8E8E93() {
        #expect(XGColors.onSurfaceVariant == Color(hex: "#8E8E93"))
    }
}
