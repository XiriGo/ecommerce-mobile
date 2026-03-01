import SwiftUI
import Testing
@testable import XiriGoEcommerce

@Suite("XGSpacing Tests")
struct XGSpacingTests {
    // MARK: - Base Spacing Values

    @Test("Base spacing values are in ascending order")
    func spacingValuesAscending() {
        #expect(XGSpacing.xxs < XGSpacing.xs)
        #expect(XGSpacing.xs < XGSpacing.sm)
        #expect(XGSpacing.sm < XGSpacing.md)
        #expect(XGSpacing.md < XGSpacing.base)
        #expect(XGSpacing.base < XGSpacing.lg)
        #expect(XGSpacing.lg < XGSpacing.xl)
        #expect(XGSpacing.xl < XGSpacing.xxl)
        #expect(XGSpacing.xxl < XGSpacing.xxxl)
    }

    @Test("Base spacing is 16 points")
    func baseSpacing() {
        #expect(XGSpacing.base == 16)
    }

    @Test("XXS spacing is 2 points")
    func xXSSpacing() {
        #expect(XGSpacing.xxs == 2)
    }

    @Test("XS spacing is 4 points")
    func xSSpacing() {
        #expect(XGSpacing.xs == 4)
    }

    @Test("SM spacing is 8 points")
    func sMSpacing() {
        #expect(XGSpacing.sm == 8)
    }

    @Test("MD spacing is 12 points")
    func mDSpacing() {
        #expect(XGSpacing.md == 12)
    }

    @Test("LG spacing is 20 points")
    func lGSpacing() {
        #expect(XGSpacing.lg == 20)
    }

    @Test("XL spacing is 24 points")
    func xLSpacing() {
        #expect(XGSpacing.xl == 24)
    }

    @Test("XXL spacing is 32 points")
    func xXLSpacing() {
        #expect(XGSpacing.xxl == 32)
    }

    @Test("XXXL spacing is 48 points")
    func xXXLSpacing() {
        #expect(XGSpacing.xxxl == 48)
    }

    // MARK: - Layout Constants

    @Test("Screen padding horizontal is 20 points")
    func testScreenPaddingHorizontal() {
        #expect(XGSpacing.screenPaddingHorizontal == 20)
        #expect(XGSpacing.screenPaddingHorizontal == XGSpacing.lg)
    }

    @Test("Screen padding vertical is 16 points")
    func testScreenPaddingVertical() {
        #expect(XGSpacing.screenPaddingVertical == 16)
        #expect(XGSpacing.screenPaddingVertical == XGSpacing.base)
    }

    @Test("Card padding is 12 points")
    func testCardPadding() {
        #expect(XGSpacing.cardPadding == 12)
        #expect(XGSpacing.cardPadding == XGSpacing.md)
    }

    @Test("List item spacing is 10 points")
    func testListItemSpacing() {
        #expect(XGSpacing.listItemSpacing == 10)
    }

    @Test("Section spacing is 24 points")
    func testSectionSpacing() {
        #expect(XGSpacing.sectionSpacing == 24)
        #expect(XGSpacing.sectionSpacing == XGSpacing.xl)
    }

    @Test("Product grid spacing is 10 points")
    func testProductGridSpacing() {
        #expect(XGSpacing.productGridSpacing == 10)
    }

    @Test("Product grid has 2 columns")
    func testProductGridColumns() {
        #expect(XGSpacing.productGridColumns == 2)
    }

    // MARK: - Accessibility

    @Test("Minimum touch target meets design token requirement (48pt)")
    func minTouchTargetDesignToken() {
        #expect(XGSpacing.minTouchTarget == 48)
    }

    @Test("Minimum touch target is larger than base spacing")
    func minTouchTargetIsLarge() {
        #expect(XGSpacing.minTouchTarget > XGSpacing.base)
    }
}
