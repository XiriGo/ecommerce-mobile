@testable import MoltMarketplace
import SwiftUI
import Testing

@Suite("MoltSpacing Tests")
internal struct MoltSpacingTests {
    // MARK: - Base Spacing Values

    @Test("Base spacing values are in ascending order")
    internal func testSpacingValuesAscending() {
        #expect(MoltSpacing.xxs < MoltSpacing.xs)
        #expect(MoltSpacing.xs < MoltSpacing.sm)
        #expect(MoltSpacing.sm < MoltSpacing.md)
        #expect(MoltSpacing.md < MoltSpacing.base)
        #expect(MoltSpacing.base < MoltSpacing.lg)
        #expect(MoltSpacing.lg < MoltSpacing.xl)
        #expect(MoltSpacing.xl < MoltSpacing.xxl)
        #expect(MoltSpacing.xxl < MoltSpacing.xxxl)
    }

    @Test("Base spacing is 16 points")
    internal func testBaseSpacing() {
        #expect(MoltSpacing.base == 16)
    }

    @Test("XXS spacing is 2 points")
    internal func testXXSSpacing() {
        #expect(MoltSpacing.xxs == 2)
    }

    @Test("XS spacing is 4 points")
    internal func testXSSpacing() {
        #expect(MoltSpacing.xs == 4)
    }

    @Test("SM spacing is 8 points")
    internal func testSMSpacing() {
        #expect(MoltSpacing.sm == 8)
    }

    @Test("MD spacing is 12 points")
    internal func testMDSpacing() {
        #expect(MoltSpacing.md == 12)
    }

    @Test("LG spacing is 24 points")
    internal func testLGSpacing() {
        #expect(MoltSpacing.lg == 24)
    }

    @Test("XL spacing is 32 points")
    internal func testXLSpacing() {
        #expect(MoltSpacing.xl == 32)
    }

    @Test("XXL spacing is 48 points")
    internal func testXXLSpacing() {
        #expect(MoltSpacing.xxl == 48)
    }

    @Test("XXXL spacing is 64 points")
    internal func testXXXLSpacing() {
        #expect(MoltSpacing.xxxl == 64)
    }

    // MARK: - Layout Constants

    @Test("Screen padding horizontal is 16 points")
    internal func testScreenPaddingHorizontal() {
        #expect(MoltSpacing.screenPaddingHorizontal == 16)
        #expect(MoltSpacing.screenPaddingHorizontal == MoltSpacing.base)
    }

    @Test("Screen padding vertical is 16 points")
    internal func testScreenPaddingVertical() {
        #expect(MoltSpacing.screenPaddingVertical == 16)
        #expect(MoltSpacing.screenPaddingVertical == MoltSpacing.base)
    }

    @Test("Card padding is 12 points")
    internal func testCardPadding() {
        #expect(MoltSpacing.cardPadding == 12)
        #expect(MoltSpacing.cardPadding == MoltSpacing.md)
    }

    @Test("List item spacing is 8 points")
    internal func testListItemSpacing() {
        #expect(MoltSpacing.listItemSpacing == 8)
        #expect(MoltSpacing.listItemSpacing == MoltSpacing.sm)
    }

    @Test("Section spacing is 24 points")
    internal func testSectionSpacing() {
        #expect(MoltSpacing.sectionSpacing == 24)
        #expect(MoltSpacing.sectionSpacing == MoltSpacing.lg)
    }

    @Test("Product grid spacing is 8 points")
    internal func testProductGridSpacing() {
        #expect(MoltSpacing.productGridSpacing == 8)
        #expect(MoltSpacing.productGridSpacing == MoltSpacing.sm)
    }

    @Test("Product grid has 2 columns")
    internal func testProductGridColumns() {
        #expect(MoltSpacing.productGridColumns == 2)
    }

    // MARK: - Accessibility

    @Test("Minimum touch target meets Apple HIG requirement (44pt)")
    internal func testMinTouchTargetAppleHIG() {
        #expect(MoltSpacing.minTouchTarget == 44)
    }

    @Test("Minimum touch target is larger than base spacing")
    internal func testMinTouchTargetIsLarge() {
        #expect(MoltSpacing.minTouchTarget > MoltSpacing.base)
    }
}
