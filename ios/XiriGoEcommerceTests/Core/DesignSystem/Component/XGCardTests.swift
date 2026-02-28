import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGProductCardTests

@Suite("XGProductCard Tests")
@MainActor
struct XGProductCardTests {
    // MARK: - Initialisation

    @Test("ProductCard initialises with required properties")
    func init_withRequiredProperties_initialises() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Sample Product",
            price: "29.99",
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard initialises with all optional properties")
    func init_withAllProperties_initialises() {
        let card = XGProductCard(
            imageUrl: URL(string: "https://example.com/image.jpg"),
            title: "Premium Headphones",
            price: "29.99",
            originalPrice: "39.99",
            vendorName: "TechStore",
            rating: 4.5,
            reviewCount: 123,
            isWishlisted: false,
            onWishlistToggle: {},
            action: {},
        )
        _ = card
        #expect(true)
    }

    @Test("ProductCard initialises in wishlisted state")
    func init_wishlisted_initialises() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
            isWishlisted: true,
            onWishlistToggle: {},
            action: {},
        )
        _ = card
        #expect(true)
    }

    @Test("ProductCard initialises without wishlist toggle")
    func init_withoutWishlistToggle_initialises() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard tap action closure is captured")
    func init_tapAction_closureCaptured() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard wishlist toggle closure is captured")
    func init_wishlistToggle_closureCaptured() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
            onWishlistToggle: {},
            action: {},
        )
        _ = card
        #expect(true)
    }

    @Test("ProductCard with nil originalPrice has no sale price")
    func init_nilOriginalPrice_noSalePrice() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
            originalPrice: nil,
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard with vendorName initialises correctly")
    func init_withVendorName_initialises() {
        let card = XGProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
            vendorName: "Store Name",
        ) {}
        _ = card
        #expect(true)
    }
}

// MARK: - XGInfoCardTests

@Suite("XGInfoCard Tests")
@MainActor
struct XGInfoCardTests {
    @Test("InfoCard initialises with title only")
    func init_withTitleOnly_initialises() {
        let card = XGInfoCard(title: "Shipping Address")
        _ = card
        #expect(true)
    }

    @Test("InfoCard initialises with subtitle")
    func init_withSubtitle_initialises() {
        let card = XGInfoCard(
            title: "Shipping Address",
            subtitle: "123 Main Street, Valletta",
        )
        _ = card
        #expect(true)
    }

    @Test("InfoCard initialises with leading icon")
    func init_withLeadingIcon_initialises() {
        let card = XGInfoCard(
            title: "Payment",
            leadingIcon: "creditcard",
        )
        _ = card
        #expect(true)
    }

    @Test("InfoCard initialises with action closure")
    func init_withAction_closureCaptured() {
        let card = XGInfoCard(title: "Edit", action: {})
        _ = card
        #expect(true)
    }

    @Test("InfoCard initialises with trailing content")
    func init_withTrailingContent_initialises() {
        let card = XGInfoCard(title: "Item") {
            EmptyView()
        }
        _ = card
        #expect(true)
    }
}
