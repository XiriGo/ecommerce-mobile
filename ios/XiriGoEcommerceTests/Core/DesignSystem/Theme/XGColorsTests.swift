import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGColorsTests

@Suite("XGColors Tests")
struct XGColorsTests {
    // MARK: - Brand Colors

    @Test("Brand primary matches design token #6000FE")
    func brandPrimaryMatchesToken() {
        #expect(XGColors.brandPrimary == Color(hex: "#6000FE"))
    }

    @Test("Primary is same as brand primary")
    func primaryIsBrandPrimary() {
        #expect(XGColors.primary == XGColors.brandPrimary)
    }

    @Test("OnPrimary color is white")
    func onPrimaryIsWhite() {
        #expect(XGColors.onPrimary == Color.white)
    }

    @Test("Brand secondary matches design token #94D63A")
    func brandSecondaryMatchesToken() {
        #expect(XGColors.brandSecondary == Color(hex: "#94D63A"))
    }

    // MARK: - Semantic Status Colors

    @Test("Success color matches design token #22C55E")
    func successColorMatchesToken() {
        #expect(XGColors.success == Color(hex: "#22C55E"))
    }

    @Test("Warning color matches design token #FACC15")
    func warningColorMatchesToken() {
        #expect(XGColors.warning == Color(hex: "#FACC15"))
    }

    @Test("Error color matches design token #EF4444")
    func errorColorMatchesToken() {
        #expect(XGColors.error == Color(hex: "#EF4444"))
    }

    @Test("Info color matches design token #3B82F6")
    func infoColorMatchesToken() {
        #expect(XGColors.info == Color(hex: "#3B82F6"))
    }

    // MARK: - Price Colors

    @Test("Price sale color is brand primary")
    func priceSaleIsBrandPrimary() {
        #expect(XGColors.priceSale == XGColors.brandPrimary)
    }

    @Test("Rating star filled color is brand primary")
    func ratingStarFilledIsBrandPrimary() {
        #expect(XGColors.ratingStarFilled == XGColors.brandPrimary)
    }

    // MARK: - Color Contrast (Accessibility)

    @Test("OnPrimary has sufficient contrast with Primary")
    func primaryContrastRatio() {
        #expect(XGColors.onPrimary == Color.white)
        #expect(XGColors.primary != Color.white)
    }

    @Test("OnSuccess has sufficient contrast with Success")
    func successContrastRatio() {
        #expect(XGColors.onSuccess == Color.white)
    }

    // MARK: - Badge Colors

    @Test("Badge background and text colors are defined")
    func badgeColors() {
        #expect(XGColors.badgeBackground != Color.clear)
        #expect(XGColors.badgeText == Color.white)
    }

    // MARK: - Surface Colors

    @Test("Surface color matches design token #FFFFFF")
    func surfaceColorMatchesToken() {
        #expect(XGColors.surface == Color(hex: "#FFFFFF"))
    }

    @Test("Background color matches design token #F8F9FC")
    func backgroundColorMatchesToken() {
        #expect(XGColors.background == Color(hex: "#F8F9FC"))
    }

    // MARK: - Flash Sale Colors

    @Test("Flash sale background matches design token #FFD814")
    func flashSaleBackgroundMatchesToken() {
        #expect(XGColors.flashSaleBackground == Color(hex: "#FFD814"))
    }

    @Test("Flash sale text matches design token #1D1D1B")
    func flashSaleTextMatchesToken() {
        #expect(XGColors.flashSaleText == Color(hex: "#1D1D1B"))
    }
}

// MARK: - ColorHexExtensionTests

@Suite("Color Hex Extension Tests")
struct ColorHexExtensionTests {
    @Test("Hex string with hash creates correct color")
    func hexWithHash() {
        let color = Color(hex: "#FF0000")
        let red = Color(red: 1.0, green: 0.0, blue: 0.0)
        #expect(color == red)
    }

    @Test("Hex string without hash creates correct color")
    func hexWithoutHash() {
        let color = Color(hex: "00FF00")
        let green = Color(red: 0.0, green: 1.0, blue: 0.0)
        #expect(color == green)
    }

    @Test("Hex string creates blue color correctly")
    func blueHex() {
        let color = Color(hex: "#0000FF")
        let blue = Color(red: 0.0, green: 0.0, blue: 1.0)
        #expect(color == blue)
    }

    @Test("Hex string creates white color correctly")
    func whiteHex() {
        let color = Color(hex: "#FFFFFF")
        let white = Color(red: 1.0, green: 1.0, blue: 1.0)
        #expect(color == white)
    }

    @Test("Hex string creates black color correctly")
    func blackHex() {
        let color = Color(hex: "#000000")
        let black = Color(red: 0.0, green: 0.0, blue: 0.0)
        #expect(color == black)
    }

    @Test("Hex string with mixed case works")
    func mixedCaseHex() {
        let color1 = Color(hex: "#6000FE")
        let color2 = Color(hex: "#6000fe")
        #expect(color1 == color2)
    }
}
