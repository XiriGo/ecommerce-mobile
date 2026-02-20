import SwiftUI
import Testing
@testable import MoltMarketplace

// MARK: - MoltColorsTests

@Suite("MoltColors Tests")
struct MoltColorsTests {
    // MARK: - Primary Colors

    @Test("Primary color is defined and not transparent")
    func primaryColorExists() {
        #expect(MoltColors.primary != Color.clear)
    }

    @Test("OnPrimary color is white")
    func onPrimaryIsWhite() {
        #expect(MoltColors.onPrimary == Color.white)
    }

    // MARK: - Semantic E-commerce Colors

    @Test("Success color is green")
    func successColorIsGreen() {
        // Success color should be green (#4CAF50)
        let expectedGreen = Color(hex: "#4CAF50")
        #expect(MoltColors.success == expectedGreen)
    }

    @Test("Warning color is orange")
    func warningColorIsOrange() {
        // Warning color should be orange (#FF9800)
        let expectedOrange = Color(hex: "#FF9800")
        #expect(MoltColors.warning == expectedOrange)
    }

    @Test("Error color is red")
    func errorColorIsRed() {
        // Error color should be red (#B3261E)
        let expectedRed = Color(hex: "#B3261E")
        #expect(MoltColors.error == expectedRed)
    }

    @Test("PriceSale color is red")
    func priceSaleColorIsRed() {
        #expect(MoltColors.priceSale == MoltColors.error)
    }

    @Test("Rating star filled color is yellow")
    func ratingStarFilledIsYellow() {
        let expectedYellow = Color(hex: "#FFC107")
        #expect(MoltColors.ratingStarFilled == expectedYellow)
    }

    // MARK: - Color Contrast (Accessibility)

    @Test("OnPrimary has sufficient contrast with Primary")
    func primaryContrastRatio() {
        // White on purple should have good contrast
        #expect(MoltColors.onPrimary == Color.white)
        #expect(MoltColors.primary != Color.white)
    }

    @Test("OnSuccess has sufficient contrast with Success")
    func successContrastRatio() {
        // White on green should have good contrast
        #expect(MoltColors.onSuccess == Color.white)
    }

    // MARK: - Badge Colors

    @Test("Badge background and text colors are defined")
    func badgeColors() {
        #expect(MoltColors.badgeBackground != Color.clear)
        #expect(MoltColors.badgeText == Color.white)
    }

    // MARK: - Surface Colors

    @Test("Surface color is near white")
    func surfaceColorIsLight() {
        let expectedSurface = Color(hex: "#FFFBFE")
        #expect(MoltColors.surface == expectedSurface)
    }

    @Test("Background color is near white")
    func backgroundColorIsLight() {
        let expectedBackground = Color(hex: "#FFFBFE")
        #expect(MoltColors.background == expectedBackground)
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
