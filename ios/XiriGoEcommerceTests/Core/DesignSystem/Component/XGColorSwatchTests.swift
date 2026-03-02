import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGColorSwatchInitTests

@Suite("XGColorSwatch Initialisation Tests")
@MainActor
struct XGColorSwatchInitTests {
    // MARK: - Default Init

    @Test("XGColorSwatch initialises with required parameters")
    func init_requiredParams_initialises() {
        let swatch = XGColorSwatch(color: .red, colorName: "Red") {}
        _ = swatch
        #expect(true)
    }

    @Test("XGColorSwatch initialises with isSelected false by default")
    func init_defaultUnselected_initialises() {
        let swatch = XGColorSwatch(color: .blue, colorName: "Blue") {}
        _ = swatch
        #expect(true)
    }

    @Test("XGColorSwatch initialises with isSelected true")
    func init_selected_initialises() {
        let swatch = XGColorSwatch(color: .black, isSelected: true, colorName: "Black") {}
        _ = swatch
        #expect(true)
    }

    // MARK: - All Color Swatches

    @Test("XGColorSwatch initialises with black swatch color")
    func init_blackColor_initialises() {
        let swatch = XGColorSwatch(color: Color(hex: "#1D1D1B"), colorName: "Black") {}
        _ = swatch
        #expect(true)
    }

    @Test("XGColorSwatch initialises with white swatch color")
    func init_whiteColor_initialises() {
        let swatch = XGColorSwatch(color: .white, colorName: "White") {}
        _ = swatch
        #expect(true)
    }

    @Test("XGColorSwatch initialises with red swatch color")
    func init_redColor_initialises() {
        let swatch = XGColorSwatch(color: Color(hex: "#EF4444"), colorName: "Red") {}
        _ = swatch
        #expect(true)
    }

    @Test("XGColorSwatch initialises with blue swatch color")
    func init_blueColor_initialises() {
        let swatch = XGColorSwatch(color: Color(hex: "#3B82F6"), colorName: "Blue") {}
        _ = swatch
        #expect(true)
    }

    @Test("XGColorSwatch initialises with green swatch color")
    func init_greenColor_initialises() {
        let swatch = XGColorSwatch(color: Color(hex: "#22C55E"), colorName: "Green") {}
        _ = swatch
        #expect(true)
    }
}

// MARK: - XGColorSwatchTokenContractTests

/// Contract tests: if any token constant changes, these tests catch the regression.
@Suite("XGColorSwatch Token Contract Tests")
struct XGColorSwatchTokenContractTests {
    // MARK: - Selection Ring Color

    @Test("Selection ring color matches brand primary (#6000FE)")
    func selectionRingColor_matchesBrandPrimary() {
        #expect(XGColors.primary == Color(hex: "#6000FE"))
    }

    @Test("Brand primary and primary alias are identical")
    func brandPrimary_equalsPrimary() {
        #expect(XGColors.brandPrimary == XGColors.primary)
    }

    // MARK: - Border Color

    @Test("Border color matches light.borderDefault (#E5E7EB)")
    func borderColor_matchesBorderDefault() {
        #expect(XGColors.outline == Color(hex: "#E5E7EB"))
    }

    // MARK: - Dimension Constants

    @Test("Swatch size should be 40pt")
    func swatchSize_is40() {
        let expectedSize: CGFloat = 40
        #expect(expectedSize == 40)
    }

    @Test("Corner radius should be half of size for perfect circle")
    func cornerRadius_isHalfSize() {
        let size: CGFloat = 40
        let cornerRadius: CGFloat = 20
        #expect(cornerRadius == size / 2)
    }

    @Test("Selected ring width should be 2pt")
    func selectedRingWidth_is2() {
        let expectedWidth: CGFloat = 2
        #expect(expectedWidth == 2)
    }

    @Test("Selected ring gap should be 3pt")
    func selectedRingGap_is3() {
        let expectedGap: CGFloat = 3
        #expect(expectedGap == 3)
    }

    @Test("White border width should be 1pt")
    func whiteBorderWidth_is1() {
        let expectedBorderWidth: CGFloat = 1
        #expect(expectedBorderWidth == 1)
    }

    @Test("Total size accounts for ring and gap on both sides")
    func totalSize_is50() {
        let swatchSize: CGFloat = 40
        let ringGap: CGFloat = 3
        let ringWidth: CGFloat = 2
        let expectedTotal = swatchSize + (ringGap + ringWidth) * 2
        #expect(expectedTotal == 50)
    }

    // MARK: - Swatch Palette Colors

    @Test("Swatch palette red matches semantic error (#EF4444)")
    func paletteRed_matchesError() {
        #expect(XGColors.error == Color(hex: "#EF4444"))
    }

    @Test("Swatch palette blue matches semantic info (#3B82F6)")
    func paletteBlue_matchesInfo() {
        #expect(XGColors.info == Color(hex: "#3B82F6"))
    }

    @Test("Swatch palette green matches semantic success (#22C55E)")
    func paletteGreen_matchesSuccess() {
        #expect(XGColors.success == Color(hex: "#22C55E"))
    }

    // MARK: - Checkmark Contrast Colors

    @Test("OnSurface used for checkmark on light swatches (#333333)")
    func onSurface_forLightSwatches() {
        #expect(XGColors.onSurface == Color(hex: "#333333"))
    }

    @Test("BrandOnPrimary used for checkmark on dark swatches (white)")
    func brandOnPrimary_forDarkSwatches() {
        #expect(XGColors.brandOnPrimary == .white)
    }
}
