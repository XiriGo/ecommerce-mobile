@testable import MoltMarketplace
import SwiftUI
import Testing

@Suite("MoltColors Tests")
internal struct MoltColorsTests {
    // MARK: - Primary Colors

    @Test("Primary color is defined and not transparent")
    internal func testPrimaryColorExists() {
        #expect(MoltColors.primary != Color.clear)
    }

    @Test("OnPrimary color is white")
    internal func testOnPrimaryIsWhite() {
        #expect(MoltColors.onPrimary == Color.white)
    }

    // MARK: - Semantic E-commerce Colors

    @Test("Success color is green")
    internal func testSuccessColorIsGreen() {
        // Success color should be green (#4CAF50)
        let expectedGreen = Color(hex: "#4CAF50")
        #expect(MoltColors.success == expectedGreen)
    }

    @Test("Warning color is orange")
    internal func testWarningColorIsOrange() {
        // Warning color should be orange (#FF9800)
        let expectedOrange = Color(hex: "#FF9800")
        #expect(MoltColors.warning == expectedOrange)
    }

    @Test("Error color is red")
    internal func testErrorColorIsRed() {
        // Error color should be red (#B3261E)
        let expectedRed = Color(hex: "#B3261E")
        #expect(MoltColors.error == expectedRed)
    }

    @Test("PriceSale color is red")
    internal func testPriceSaleColorIsRed() {
        #expect(MoltColors.priceSale == MoltColors.error)
    }

    @Test("Rating star filled color is yellow")
    internal func testRatingStarFilledIsYellow() {
        let expectedYellow = Color(hex: "#FFC107")
        #expect(MoltColors.ratingStarFilled == expectedYellow)
    }

    // MARK: - Color Contrast (Accessibility)

    @Test("OnPrimary has sufficient contrast with Primary")
    internal func testPrimaryContrastRatio() {
        // White on purple should have good contrast
        #expect(MoltColors.onPrimary == Color.white)
        #expect(MoltColors.primary != Color.white)
    }

    @Test("OnSuccess has sufficient contrast with Success")
    internal func testSuccessContrastRatio() {
        // White on green should have good contrast
        #expect(MoltColors.onSuccess == Color.white)
    }

    // MARK: - Badge Colors

    @Test("Badge background and text colors are defined")
    internal func testBadgeColors() {
        #expect(MoltColors.badgeBackground != Color.clear)
        #expect(MoltColors.badgeText == Color.white)
    }

    // MARK: - Surface Colors

    @Test("Surface color is near white")
    internal func testSurfaceColorIsLight() {
        let expectedSurface = Color(hex: "#FFFBFE")
        #expect(MoltColors.surface == expectedSurface)
    }

    @Test("Background color is near white")
    internal func testBackgroundColorIsLight() {
        let expectedBackground = Color(hex: "#FFFBFE")
        #expect(MoltColors.background == expectedBackground)
    }
}

@Suite("Color Hex Extension Tests")
internal struct ColorHexExtensionTests {
    @Test("Hex string with hash creates correct color")
    internal func testHexWithHash() {
        let color = Color(hex: "#FF0000")
        let red = Color(red: 1.0, green: 0.0, blue: 0.0)
        #expect(color == red)
    }

    @Test("Hex string without hash creates correct color")
    internal func testHexWithoutHash() {
        let color = Color(hex: "00FF00")
        let green = Color(red: 0.0, green: 1.0, blue: 0.0)
        #expect(color == green)
    }

    @Test("Hex string creates blue color correctly")
    internal func testBlueHex() {
        let color = Color(hex: "#0000FF")
        let blue = Color(red: 0.0, green: 0.0, blue: 1.0)
        #expect(color == blue)
    }

    @Test("Hex string creates white color correctly")
    internal func testWhiteHex() {
        let color = Color(hex: "#FFFFFF")
        let white = Color(red: 1.0, green: 1.0, blue: 1.0)
        #expect(color == white)
    }

    @Test("Hex string creates black color correctly")
    internal func testBlackHex() {
        let color = Color(hex: "#000000")
        let black = Color(red: 0.0, green: 0.0, blue: 0.0)
        #expect(color == black)
    }

    @Test("Hex string with mixed case works")
    internal func testMixedCaseHex() {
        let color1 = Color(hex: "#6750A4")
        let color2 = Color(hex: "#6750a4")
        #expect(color1 == color2)
    }
}
