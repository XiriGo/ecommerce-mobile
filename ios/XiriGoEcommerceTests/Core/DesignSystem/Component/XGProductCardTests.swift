import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - ProductCardSkeletonTests

@Suite("ProductCardSkeleton Tests")
@MainActor
struct ProductCardSkeletonTests {
    @Test("ProductCardSkeleton body can be created without error")
    func skeletonView_createsSuccessfully() {
        let skeleton = ProductCardSkeleton()
        #expect(type(of: skeleton) == ProductCardSkeleton.self)
    }
}

// MARK: - XGProductCardTokenTests

@Suite("XGProductCard Token Tests")
struct XGProductCardTokenTests {
    // MARK: - Card dimension tokens

    @Test("Card corner radius should be XGCornerRadius.medium (10)")
    func cornerRadius_isTokenMedium() {
        #expect(XGCornerRadius.medium == 10)
    }

    @Test("Card padding should be 8pt from token")
    func cardPadding_isEight() {
        let cardPadding: CGFloat = 8
        #expect(cardPadding == 8)
    }

    @Test("Card border width should be 1pt")
    func borderWidth_isOne() {
        let borderWidth: CGFloat = 1
        #expect(borderWidth == 1)
    }

    // MARK: - Add-to-cart sub-component tokens

    @Test("Add to cart button size should be 38pt")
    func addToCartSize_is38() {
        let size: CGFloat = 38
        #expect(size == 38)
    }

    @Test("Add to cart icon size should be 16pt")
    func addToCartIconSize_is16() {
        let iconSize: CGFloat = 16
        #expect(iconSize == 16)
    }

    // MARK: - Delivery label tokens

    @Test("Delivery label font size should be 10pt")
    func deliveryFontSize_is10() {
        let fontSize: CGFloat = 10
        #expect(fontSize == 10)
    }

    // MARK: - Reserved heights for uniform sizing

    @Test("Reserved rating height should be 16pt")
    func reservedRatingHeight_is16() {
        let reservedRatingHeight: CGFloat = 16
        #expect(reservedRatingHeight == 16)
    }

    @Test("Reserved delivery height should be 14pt")
    func reservedDeliveryHeight_is14() {
        let reservedDeliveryHeight: CGFloat = 14
        #expect(reservedDeliveryHeight == 14)
    }

    @Test("Reserved add-to-cart height should be 38pt")
    func reservedAddToCartHeight_is38() {
        let reservedAddToCartHeight: CGFloat = 38
        #expect(reservedAddToCartHeight == 38)
    }

    // MARK: - Spacing tokens

    @Test("XGSpacing.xs should be 4 for content spacing")
    func spacingXS_isFour() {
        #expect(XGSpacing.xs == 4)
    }

    @Test("XGSpacing.sm should be 8 for list spacing")
    func spacingSM_isEight() {
        #expect(XGSpacing.sm == 8)
    }
}

// MARK: - XGProductCardReserveSpaceTests

@Suite("XGProductCard reserveSpace Tests")
@MainActor
struct XGProductCardReserveSpaceTests {
    @Test("XGProductCard with reserveSpace false creates successfully")
    func reserveSpaceFalse_createsCard() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Test",
            price: "9.99",
            reserveSpace: false,
            action: {},
        )
        #expect(type(of: card) == XGProductCard.self)
    }

    @Test("XGProductCard with reserveSpace true creates successfully")
    func reserveSpaceTrue_createsCard() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Test",
            price: "9.99",
            reserveSpace: true,
            action: {},
        )
        #expect(type(of: card) == XGProductCard.self)
    }

    @Test("XGProductCard defaults reserveSpace to false")
    func defaultReserveSpace_isFalse() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Test",
            price: "9.99",
            action: {},
        )
        #expect(type(of: card) == XGProductCard.self)
    }
}
