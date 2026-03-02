import SwiftUI

// MARK: - XGPriceStyle

/// Visual style variants for price display.
/// Token source: `components/atoms/xg-price-text.json`.
enum XGPriceStyle {
    /// Default discount price — brand primary color (Featured/Popular cards).
    case `default`
    /// Standard variant for New Arrivals / Standard cards (20/20/14).
    case standard
    /// Small variant for compact layouts (product cards).
    case small
    /// Deal variant — brand secondary color for daily deal contexts.
    case deal

    // MARK: - Internal

    var currencyFontSize: CGFloat {
        switch self {
            case .deal,
                 .default:
                Constants.defaultCurrencyFontSize
            case .standard:
                Constants.standardCurrencyFontSize
            case .small:
                Constants.smallCurrencyFontSize
        }
    }

    var integerFontSize: CGFloat {
        switch self {
            case .deal,
                 .default:
                Constants.defaultIntegerFontSize
            case .standard:
                Constants.standardIntegerFontSize
            case .small:
                Constants.smallIntegerFontSize
        }
    }

    var decimalFontSize: CGFloat {
        switch self {
            case .deal,
                 .default:
                Constants.defaultDecimalFontSize
            case .standard:
                Constants.standardDecimalFontSize
            case .small:
                Constants.smallDecimalFontSize
        }
    }

    var color: Color {
        switch self {
            case .default,
                 .small,
                 .standard:
                XGColors.priceSale
            case .deal:
                XGColors.brandSecondary
        }
    }

    // MARK: - Private

    private enum Constants {
        static let defaultCurrencyFontSize: CGFloat = 22.78
        static let defaultIntegerFontSize: CGFloat = 27.33
        static let defaultDecimalFontSize: CGFloat = 18.98

        static let standardCurrencyFontSize: CGFloat = 20
        static let standardIntegerFontSize: CGFloat = 20
        static let standardDecimalFontSize: CGFloat = 14

        static let smallCurrencyFontSize: CGFloat = 14
        static let smallIntegerFontSize: CGFloat = 18
        static let smallDecimalFontSize: CGFloat = 14
    }
}

// MARK: - XGPriceLayout

/// Controls the arrangement of sale price and strikethrough in ``XGPriceText``.
enum XGPriceLayout {
    /// Sale price + strikethrough side-by-side (HStack). Default for standard/grid cards.
    case inline
    /// Strikethrough above, sale price below (VStack). Used for featured/horizontal-scroll cards.
    case stacked
}

// MARK: - XGPriceText

/// Three-part composite price display component.
/// Renders currency symbol, integer part, and decimal part with separate font sizes.
/// Uses Source Sans 3 Black font per design tokens.
///
/// Token source: `components/atoms/xg-price-text.json`.
struct XGPriceText: View {
    // MARK: - Lifecycle

    init(
        price: String?,
        originalPrice: String? = nil,
        currencySymbol: String = "\u{20AC}",
        style: XGPriceStyle = .default,
        strikethroughFontSize: CGFloat = Constants.defaultStrikethroughFontSize,
        layout: XGPriceLayout = .inline,
    ) {
        self.price = price
        self.originalPrice = originalPrice
        self.currencySymbol = currencySymbol
        self.style = style
        self.strikethroughFontSize = strikethroughFontSize
        self.layout = layout
    }

    // MARK: - Internal

    var body: some View {
        // Null price fallback: hide component entirely (DQ-10)
        if price != nil {
            Group {
                switch layout {
                    case .inline:
                        HStack(alignment: .firstTextBaseline, spacing: XGSpacing.sm) {
                            compositePrice

                            if let originalPrice {
                                strikethroughPrice(originalPrice)
                            }
                        }

                    case .stacked:
                        VStack(alignment: .leading, spacing: XGSpacing.xxs) {
                            if let originalPrice {
                                strikethroughPrice(originalPrice)
                            }

                            compositePrice
                        }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityDescription)
        }
    }

    // MARK: - Private

    private enum Constants {
        static let defaultStrikethroughFontSize: CGFloat = 15.18
        static let standardStrikethroughFontSize: CGFloat = 14
    }

    private let price: String?
    private let originalPrice: String?
    private let currencySymbol: String
    private let style: XGPriceStyle
    private let strikethroughFontSize: CGFloat
    private let layout: XGPriceLayout

    private var hasSale: Bool {
        originalPrice != nil
    }

    private var priceColor: Color {
        style.color
    }

    private var priceParts: (integer: String, decimal: String) {
        let priceValue = price ?? "0"
        let components = priceValue.split(separator: ".", maxSplits: 1)
        let integer = String(components.first ?? "0")
        let decimal = components.count > 1 ? "," + String(components.last ?? "00") : ""
        return (integer, decimal)
    }

    private var accessibilityDescription: String {
        let priceValue = price ?? "0"
        if let originalPrice {
            return String(
                localized: "common_sale_price_label \(currencySymbol) \(priceValue) \(currencySymbol) \(originalPrice)",
            )
        }
        return String(
            localized: "common_price_label \(currencySymbol) \(priceValue)",
        )
    }

    private var compositePrice: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(currencySymbol)
                .font(priceFont(size: style.currencyFontSize))
                .foregroundStyle(priceColor)

            Text(priceParts.integer)
                .font(priceFont(size: style.integerFontSize))
                .foregroundStyle(priceColor)

            Text(priceParts.decimal)
                .font(priceFont(size: style.decimalFontSize))
                .foregroundStyle(priceColor)
        }
    }

    private func strikethroughPrice(_ originalPrice: String) -> some View {
        Text(currencySymbol + originalPrice)
            .font(XGTypography.strikethroughFont(size: strikethroughFontSize))
            .foregroundStyle(XGColors.priceStrikethrough)
            .strikethrough()
    }

    private func priceFont(size: CGFloat) -> Font {
        XGTypography.priceFont(size: size)
    }
}

// MARK: - Previews

#Preview("XGPriceText Default") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        XGPriceText(price: "29.99", style: .small)
        XGPriceText(price: "149.99")
        XGPriceText(price: "99.99", style: .standard)
        XGPriceText(price: "89.99", style: .deal)
    }
    .padding()
    .xgTheme()
}

#Preview("XGPriceText Sale") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        XGPriceText(price: "19.99", originalPrice: "29.99", style: .small)
        XGPriceText(price: "89.99", originalPrice: "149.99")
        XGPriceText(price: "49.99", originalPrice: "69.99", style: .standard, strikethroughFontSize: 14)
        XGPriceText(price: "49.99", originalPrice: "99.99", style: .deal)
    }
    .padding()
    .xgTheme()
}

#Preview("XGPriceText Stacked") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        XGPriceText(price: "89.99", originalPrice: "149.99", layout: .stacked)
        XGPriceText(price: "49.99", originalPrice: "69.99", style: .standard, layout: .stacked)
    }
    .padding()
    .xgTheme()
}

#Preview("XGPriceText Nil Price") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        Text("Before price:")
        XGPriceText(price: nil)
        Text("After price (nothing between):")
    }
    .padding()
    .xgTheme()
}
