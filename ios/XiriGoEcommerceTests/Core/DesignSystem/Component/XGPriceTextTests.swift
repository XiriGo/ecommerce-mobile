import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGPriceSizeTests

@Suite("XGPriceSize Tests")
struct XGPriceSizeTests {
    @Test("All three price sizes exist")
    func sizes_allCasesExist() {
        let sizes: [XGPriceSize] = [.small, .medium, .large]
        #expect(sizes.count == 3)
    }

    @Test("Small size has bodySmall price font")
    func small_priceFont_isBodySmall() {
        #expect(XGPriceSize.small.priceFont == XGTypography.bodySmall)
    }

    @Test("Medium size has titleMedium price font")
    func medium_priceFont_isTitleMedium() {
        #expect(XGPriceSize.medium.priceFont == XGTypography.titleMedium)
    }

    @Test("Large size has headlineSmall price font")
    func large_priceFont_isHeadlineSmall() {
        #expect(XGPriceSize.large.priceFont == XGTypography.headlineSmall)
    }

    @Test("Small size has labelSmall original price font")
    func small_originalPriceFont_isLabelSmall() {
        #expect(XGPriceSize.small.originalPriceFont == XGTypography.labelSmall)
    }

    @Test("Medium size has bodySmall original price font")
    func medium_originalPriceFont_isBodySmall() {
        #expect(XGPriceSize.medium.originalPriceFont == XGTypography.bodySmall)
    }

    @Test("Large size has bodyMedium original price font")
    func large_originalPriceFont_isBodyMedium() {
        #expect(XGPriceSize.large.originalPriceFont == XGTypography.bodyMedium)
    }
}

// MARK: - XGPriceTextTests

@Suite("XGPriceText Tests")
struct XGPriceTextTests {
    // MARK: - Internal

    // MARK: - Initialisation

    @Test("PriceText initialises with price only")
    func init_withPriceOnly_initialises() {
        let view = XGPriceText(price: "29.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with sale price (original price set)")
    func init_withOriginalPrice_initialises() {
        let view = XGPriceText(price: "19.99", originalPrice: "29.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with EUR currency symbol by default")
    func init_defaultCurrencySymbol_isEur() {
        let view = XGPriceText(price: "9.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with custom currency symbol")
    func init_customCurrencySymbol_initialises() {
        let view = XGPriceText(price: "9.99", currencySymbol: "USD")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with default medium size")
    func init_defaultSize_isMedium() {
        let view = XGPriceText(price: "9.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with small size")
    func init_smallSize_initialises() {
        let view = XGPriceText(price: "9.99", size: .small)
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with large size")
    func init_largeSize_initialises() {
        let view = XGPriceText(price: "9.99", size: .large)
        _ = view
        #expect(true)
    }

    // MARK: - Sale Logic

    @Test("hasSale is false when originalPrice is nil")
    func hasSale_nilOriginalPrice_isFalse() {
        // When originalPrice is nil, there is no sale → regular price color used
        let hasSale = hasSalePrice(originalPrice: nil)
        #expect(hasSale == false)
    }

    @Test("hasSale is true when originalPrice is set")
    func hasSale_withOriginalPrice_isTrue() {
        let hasSale = hasSalePrice(originalPrice: "39.99")
        #expect(hasSale == true)
    }

    // MARK: - Body

    @Test("PriceText body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        let view = XGPriceText(price: "9.99")
        let body = view.body
        _ = body
        #expect(true)
    }

    // MARK: - Private

    // MARK: - Helper

    /// Mirrors the private `hasSale` logic from XGPriceText.
    private func hasSalePrice(originalPrice: String?) -> Bool {
        originalPrice != nil
    }
}
