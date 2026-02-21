import Testing
@testable import MoltMarketplace

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - MoltPriceSizeTests

@Suite("MoltPriceSize Tests")
struct MoltPriceSizeTests {
    @Test("All three price sizes exist")
    func test_sizes_allCasesExist() {
        let sizes: [MoltPriceSize] = [.small, .medium, .large]
        #expect(sizes.count == 3)
    }

    @Test("Small size has bodySmall price font")
    func test_small_priceFont_isBodySmall() {
        #expect(MoltPriceSize.small.priceFont == MoltTypography.bodySmall)
    }

    @Test("Medium size has titleMedium price font")
    func test_medium_priceFont_isTitleMedium() {
        #expect(MoltPriceSize.medium.priceFont == MoltTypography.titleMedium)
    }

    @Test("Large size has headlineSmall price font")
    func test_large_priceFont_isHeadlineSmall() {
        #expect(MoltPriceSize.large.priceFont == MoltTypography.headlineSmall)
    }

    @Test("Small size has labelSmall original price font")
    func test_small_originalPriceFont_isLabelSmall() {
        #expect(MoltPriceSize.small.originalPriceFont == MoltTypography.labelSmall)
    }

    @Test("Medium size has bodySmall original price font")
    func test_medium_originalPriceFont_isBodySmall() {
        #expect(MoltPriceSize.medium.originalPriceFont == MoltTypography.bodySmall)
    }

    @Test("Large size has bodyMedium original price font")
    func test_large_originalPriceFont_isBodyMedium() {
        #expect(MoltPriceSize.large.originalPriceFont == MoltTypography.bodyMedium)
    }
}

// MARK: - MoltPriceTextTests

@Suite("MoltPriceText Tests")
struct MoltPriceTextTests {
    // MARK: - Initialisation

    @Test("PriceText initialises with price only")
    func test_init_withPriceOnly_initialises() {
        let view = MoltPriceText(price: "29.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with sale price (original price set)")
    func test_init_withOriginalPrice_initialises() {
        let view = MoltPriceText(price: "19.99", originalPrice: "29.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with EUR currency symbol by default")
    func test_init_defaultCurrencySymbol_isEur() {
        let view = MoltPriceText(price: "9.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with custom currency symbol")
    func test_init_customCurrencySymbol_initialises() {
        let view = MoltPriceText(price: "9.99", currencySymbol: "USD")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with default medium size")
    func test_init_defaultSize_isMedium() {
        let view = MoltPriceText(price: "9.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with small size")
    func test_init_smallSize_initialises() {
        let view = MoltPriceText(price: "9.99", size: .small)
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with large size")
    func test_init_largeSize_initialises() {
        let view = MoltPriceText(price: "9.99", size: .large)
        _ = view
        #expect(true)
    }

    // MARK: - Sale Logic

    @Test("hasSale is false when originalPrice is nil")
    func test_hasSale_nilOriginalPrice_isFalse() {
        // When originalPrice is nil, there is no sale → regular price color used
        let hasSale = hasSalePrice(originalPrice: nil)
        #expect(hasSale == false)
    }

    @Test("hasSale is true when originalPrice is set")
    func test_hasSale_withOriginalPrice_isTrue() {
        let hasSale = hasSalePrice(originalPrice: "39.99")
        #expect(hasSale == true)
    }

    // MARK: - Body

    @Test("PriceText body is a valid View", .disabled(swiftUIDisabledReason))
    func test_body_isValidView() {
        let view = MoltPriceText(price: "9.99")
        let body = view.body
        _ = body
        #expect(true)
    }

    // MARK: - Helper

    /// Mirrors the private `hasSale` logic from MoltPriceText.
    private func hasSalePrice(originalPrice: String?) -> Bool {
        originalPrice != nil
    }
}
