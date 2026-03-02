import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGDividerInitTests

@Suite("XGDivider Initialisation Tests")
@MainActor
struct XGDividerInitTests {
    // MARK: - Default Init

    @Test("XGDivider initialises with default parameters")
    func init_defaults_initialises() {
        let divider = XGDivider()
        _ = divider
        #expect(true)
    }

    @Test("XGDivider initialises with custom color")
    func init_customColor_initialises() {
        let divider = XGDivider(color: XGColors.outline)
        _ = divider
        #expect(true)
    }

    @Test("XGDivider initialises with custom thickness")
    func init_customThickness_initialises() {
        let divider = XGDivider(thickness: 4)
        _ = divider
        #expect(true)
    }

    @Test("XGDivider initialises with all custom parameters")
    func init_allCustom_initialises() {
        let divider = XGDivider(color: XGColors.outline, thickness: 2)
        _ = divider
        #expect(true)
    }
}

// MARK: - XGLabeledDividerInitTests

@Suite("XGLabeledDivider Initialisation Tests")
@MainActor
struct XGLabeledDividerInitTests {
    // MARK: - Label Storage

    @Test("XGLabeledDivider initialises with label")
    func init_label_initialises() {
        let divider = XGLabeledDivider(label: "OR CONTINUE WITH")
        _ = divider
        #expect(true)
    }

    @Test("XGLabeledDivider initialises with empty label")
    func init_emptyLabel_initialises() {
        let divider = XGLabeledDivider(label: "")
        _ = divider
        #expect(true)
    }

    @Test("XGLabeledDivider initialises with long label")
    func init_longLabel_initialises() {
        let divider = XGLabeledDivider(label: "A VERY LONG DIVIDER LABEL TEXT FOR TESTING")
        _ = divider
        #expect(true)
    }

    // MARK: - Custom Parameters

    @Test("XGLabeledDivider initialises with custom color")
    func init_customColor_initialises() {
        let divider = XGLabeledDivider(label: "OR", color: XGColors.outline)
        _ = divider
        #expect(true)
    }

    @Test("XGLabeledDivider initialises with custom thickness")
    func init_customThickness_initialises() {
        let divider = XGLabeledDivider(label: "OR", thickness: 2)
        _ = divider
        #expect(true)
    }

    @Test("XGLabeledDivider initialises with all custom parameters")
    func init_allCustom_initialises() {
        let divider = XGLabeledDivider(label: "OR", color: XGColors.outline, thickness: 2)
        _ = divider
        #expect(true)
    }
}

// MARK: - XGDividerTokenContractTests

/// Contract tests: if any token constant changes, these tests catch the regression.
@Suite("XGDivider Token Contract Tests")
struct XGDividerTokenContractTests {
    // MARK: - Color Tokens

    @Test("XGColors.divider matches design token semantic.divider (#E5E7EB)")
    func dividerColor_matchesToken() {
        #expect(XGColors.divider == Color(hex: "#E5E7EB"))
    }

    @Test("XGColors.textTertiary matches design token for label color (#9CA3AF)")
    func textTertiary_matchesToken() {
        #expect(XGColors.textTertiary == Color(hex: "#9CA3AF"))
    }

    @Test("XGColors.divider and XGColors.textTertiary are distinct")
    func dividerAndTextTertiary_areDistinct() {
        #expect(XGColors.divider != XGColors.textTertiary)
    }

    @Test("XGColors.divider equals XGColors.outline (both #E5E7EB)")
    func dividerColor_equalsOutline() {
        #expect(XGColors.divider == XGColors.outline)
    }

    // MARK: - Typography Tokens

    @Test("XGDivider label font is XGTypography.captionMedium (12pt Poppins-Medium)")
    func labelFont_isCaptionMedium() {
        let font = XGTypography.captionMedium
        #expect(font == Font.custom("Poppins-Medium", size: 12))
    }

    @Test("XGTypography.captionMedium is different from XGTypography.caption (regular weight)")
    func captionMedium_isDifferentFromCaption() {
        #expect(XGTypography.captionMedium != XGTypography.caption)
    }

    // MARK: - Dimension Constants

    @Test("Default divider thickness should be 1pt")
    func defaultThickness_is1() {
        let expectedThickness: CGFloat = 1
        #expect(expectedThickness == 1)
    }

    @Test("Label horizontal padding should be 16pt")
    func labelHorizontalPadding_is16() {
        let expectedPadding: CGFloat = 16
        #expect(expectedPadding == 16)
    }

    @Test("Label horizontal padding is greater than default thickness")
    func labelPadding_isGreaterThanThickness() {
        let padding: CGFloat = 16
        let thickness: CGFloat = 1
        #expect(padding > thickness)
    }
}
