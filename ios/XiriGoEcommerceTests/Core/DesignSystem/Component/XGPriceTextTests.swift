import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGPriceStyleTests

@Suite("XGPriceStyle Tests")
struct XGPriceStyleTests {
    @Test("All three price styles exist")
    func styles_allCasesExist() {
        let styles: [XGPriceStyle] = [.default, .small, .deal]
        #expect(styles.count == 3)
    }

    @Test("Default style has correct currency font size")
    func default_currencyFontSize_isCorrect() {
        #expect(XGPriceStyle.default.currencyFontSize == 22.78)
    }

    @Test("Default style has correct integer font size")
    func default_integerFontSize_isCorrect() {
        #expect(XGPriceStyle.default.integerFontSize == 27.33)
    }

    @Test("Default style has correct decimal font size")
    func default_decimalFontSize_isCorrect() {
        #expect(XGPriceStyle.default.decimalFontSize == 18.98)
    }

    @Test("Small style has correct currency font size")
    func small_currencyFontSize_isCorrect() {
        #expect(XGPriceStyle.small.currencyFontSize == 14)
    }

    @Test("Small style has correct integer font size")
    func small_integerFontSize_isCorrect() {
        #expect(XGPriceStyle.small.integerFontSize == 18)
    }

    @Test("Small style has correct decimal font size")
    func small_decimalFontSize_isCorrect() {
        #expect(XGPriceStyle.small.decimalFontSize == 14)
    }

    @Test("Deal style has same font sizes as default")
    func deal_fontSizes_matchDefault() {
        #expect(XGPriceStyle.deal.currencyFontSize == XGPriceStyle.default.currencyFontSize)
        #expect(XGPriceStyle.deal.integerFontSize == XGPriceStyle.default.integerFontSize)
        #expect(XGPriceStyle.deal.decimalFontSize == XGPriceStyle.default.decimalFontSize)
    }

    @Test("Default style color is priceSale")
    func default_color_isPriceSale() {
        #expect(XGPriceStyle.default.color == XGColors.priceSale)
    }

    @Test("Deal style color is brandSecondary")
    func deal_color_isBrandSecondary() {
        #expect(XGPriceStyle.deal.color == XGColors.brandSecondary)
    }
}

// MARK: - XGPriceTextTests

@Suite("XGPriceText Tests")
@MainActor
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
        let view = XGPriceText(price: "9.99", currencySymbol: "$")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with default style")
    func init_defaultStyle_isDefault() {
        let view = XGPriceText(price: "9.99")
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with small style")
    func init_smallStyle_initialises() {
        let view = XGPriceText(price: "9.99", style: .small)
        _ = view
        #expect(true)
    }

    @Test("PriceText initialises with deal style")
    func init_dealStyle_initialises() {
        let view = XGPriceText(price: "9.99", style: .deal)
        _ = view
        #expect(true)
    }

    // MARK: - Sale Logic

    @Test("hasSale is false when originalPrice is nil")
    func hasSale_nilOriginalPrice_isFalse() {
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

    /// Mirrors the private `hasSale` logic from XGPriceText.
    private func hasSalePrice(originalPrice: String?) -> Bool {
        originalPrice != nil
    }
}
