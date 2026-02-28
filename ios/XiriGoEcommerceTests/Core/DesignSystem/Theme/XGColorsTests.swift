import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGColorsTests

@Suite("XGColors Tests")
struct XGColorsTests {
    // MARK: - Primary Colors

    @Test("Primary color is defined and not transparent")
    func primaryColorExists() {
        #expect(XGColors.primary != Color.clear)
    }

    @Test("OnPrimary color is white")
    func onPrimaryIsWhite() {
        #expect(XGColors.onPrimary == Color.white)
    }

    // MARK: - Semantic E-commerce Colors

    @Test("Success color is green")
    func successColorIsGreen() {
        // Success color should be green (#4CAF50)
        let expectedGreen = Color(hex: "#4CAF50")
        #expect(XGColors.success == expectedGreen)
    }

    @Test("Warning color is orange")
    func warningColorIsOrange() {
        // Warning color should be orange (#FF9800)
        let expectedOrange = Color(hex: "#FF9800")
        #expect(XGColors.warning == expectedOrange)
    }

    @Test("Error color is red")
    func errorColorIsRed() {
        // Error color should be red (#B3261E)
        let expectedRed = Color(hex: "#B3261E")
        #expect(XGColors.error == expectedRed)
    }

    @Test("PriceSale color is red")
    func priceSaleColorIsRed() {
        #expect(XGColors.priceSale == XGColors.error)
    }

    @Test("Rating star filled color is yellow")
    func ratingStarFilledIsYellow() {
        let expectedYellow = Color(hex: "#FFC107")
        #expect(XGColors.ratingStarFilled == expectedYellow)
    }

    // MARK: - Color Contrast (Accessibility)

    @Test("OnPrimary has sufficient contrast with Primary")
    func primaryContrastRatio() {
        // White on purple should have good contrast
        #expect(XGColors.onPrimary == Color.white)
        #expect(XGColors.primary != Color.white)
    }

    @Test("OnSuccess has sufficient contrast with Success")
    func successContrastRatio() {
        // White on green should have good contrast
        #expect(XGColors.onSuccess == Color.white)
    }

    // MARK: - Badge Colors

    @Test("Badge background and text colors are defined")
    func badgeColors() {
        #expect(XGColors.badgeBackground != Color.clear)
        #expect(XGColors.badgeText == Color.white)
    }

    // MARK: - Surface Colors

    @Test("Surface color is near white")
    func surfaceColorIsLight() {
        let expectedSurface = Color(hex: "#FFFBFE")
        #expect(XGColors.surface == expectedSurface)
    }

    @Test("Background color is near white")
    func backgroundColorIsLight() {
        let expectedBackground = Color(hex: "#FFFBFE")
        #expect(XGColors.background == expectedBackground)
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
        let color1 = Color(hex: "#6750A4")
        let color2 = Color(hex: "#6750a4")
        #expect(color1 == color2)
    }
}
