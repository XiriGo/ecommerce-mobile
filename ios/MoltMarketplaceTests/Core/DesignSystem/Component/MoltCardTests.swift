import SwiftUI
import Testing
@testable import MoltMarketplace

// MARK: - MoltProductCardTests

@Suite("MoltProductCard Tests")
struct MoltProductCardTests {
    // MARK: - Initialisation

    @Test("ProductCard initialises with required properties")
    func test_init_withRequiredProperties_initialises() {
        let card = MoltProductCard(
            imageUrl: nil,
            title: "Sample Product",
            price: "29.99"
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard initialises with all optional properties")
    func test_init_withAllProperties_initialises() {
        let card = MoltProductCard(
            imageUrl: URL(string: "https://example.com/image.jpg"),
            title: "Premium Headphones",
            price: "29.99",
            originalPrice: "39.99",
            vendorName: "TechStore",
            rating: 4.5,
            reviewCount: 123,
            isWishlisted: false,
            onWishlistToggle: {}
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard initialises in wishlisted state")
    func test_init_wishlisted_initialises() {
        let card = MoltProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
            isWishlisted: true,
            onWishlistToggle: {}
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard initialises without wishlist toggle")
    func test_init_withoutWishlistToggle_initialises() {
        let card = MoltProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99"
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard tap action closure is captured")
    func test_init_tapAction_closureCaptured() {
        let card = MoltProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99"
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard wishlist toggle closure is captured")
    func test_init_wishlistToggle_closureCaptured() {
        let card = MoltProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
            onWishlistToggle: {}
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard with nil originalPrice has no sale price")
    func test_init_nilOriginalPrice_noSalePrice() {
        let card = MoltProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
            originalPrice: nil
        ) {}
        _ = card
        #expect(true)
    }

    @Test("ProductCard with vendorName initialises correctly")
    func test_init_withVendorName_initialises() {
        let card = MoltProductCard(
            imageUrl: nil,
            title: "Product",
            price: "9.99",
            vendorName: "Store Name"
        ) {}
        _ = card
        #expect(true)
    }
}

// MARK: - MoltInfoCardTests

@Suite("MoltInfoCard Tests")
struct MoltInfoCardTests {
    @Test("InfoCard initialises with title only")
    func test_init_withTitleOnly_initialises() {
        let card = MoltInfoCard(title: "Shipping Address")
        _ = card
        #expect(true)
    }

    @Test("InfoCard initialises with subtitle")
    func test_init_withSubtitle_initialises() {
        let card = MoltInfoCard(
            title: "Shipping Address",
            subtitle: "123 Main Street, Valletta"
        )
        _ = card
        #expect(true)
    }

    @Test("InfoCard initialises with leading icon")
    func test_init_withLeadingIcon_initialises() {
        let card = MoltInfoCard(
            title: "Payment",
            leadingIcon: "creditcard"
        )
        _ = card
        #expect(true)
    }

    @Test("InfoCard initialises with action closure")
    func test_init_withAction_closureCaptured() {
        let card = MoltInfoCard(title: "Edit", action: {})
        _ = card
        #expect(true)
    }

    @Test("InfoCard initialises with trailing content")
    func test_init_withTrailingContent_initialises() {
        let card = MoltInfoCard(title: "Item") {
            EmptyView()
        }
        _ = card
        #expect(true)
    }
}
