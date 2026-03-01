import SwiftUI

// MARK: - XGPriceStyle

/// Visual style variants for price display.
/// Token source: `components.json > XGPriceText`.
enum XGPriceStyle {
    /// Default discount price — brand primary color.
    case `default`
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
            case .small:
                Constants.smallCurrencyFontSize
        }
    }

    var integerFontSize: CGFloat {
        switch self {
            case .deal,
                 .default:
                Constants.defaultIntegerFontSize
            case .small:
                Constants.smallIntegerFontSize
        }
    }

    var decimalFontSize: CGFloat {
        switch self {
            case .deal,
                 .default:
                Constants.defaultDecimalFontSize
            case .small:
                Constants.smallDecimalFontSize
        }
    }

    var color: Color {
        switch self {
            case .default,
                 .small:
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

        static let smallCurrencyFontSize: CGFloat = 14
        static let smallIntegerFontSize: CGFloat = 18
        static let smallDecimalFontSize: CGFloat = 14
    }
}

// MARK: - XGPriceText

/// Three-part composite price display component.
/// Renders currency symbol, integer part, and decimal part with separate font sizes.
/// Uses Source Sans 3 Black font per design tokens.
///
/// Token source: `components.json > XGPriceText`, `typography.json > priceTypography`.
struct XGPriceText: View {
    // MARK: - Lifecycle

    init(
        price: String,
        originalPrice: String? = nil,
        currencySymbol: String = "\u{20AC}",
        style: XGPriceStyle = .default,
    ) {
        self.price = price
        self.originalPrice = originalPrice
        self.currencySymbol = currencySymbol
        self.style = style
    }

    // MARK: - Internal

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: XGSpacing.sm) {
            compositePrice

            if let originalPrice {
                strikethroughPrice(originalPrice)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Private

    private enum Constants {
        static let strikethroughFontSize: CGFloat = 15.18
    }

    private let price: String
    private let originalPrice: String?
    private let currencySymbol: String
    private let style: XGPriceStyle

    private var hasSale: Bool {
        originalPrice != nil
    }

    private var priceColor: Color {
        hasSale ? style.color : XGColors.priceRegular
    }

    private var priceParts: (integer: String, decimal: String) {
        let components = price.split(separator: ".", maxSplits: 1)
        let integer = String(components.first ?? "0")
        let decimal = components.count > 1 ? "," + String(components.last ?? "00") : ""
        return (integer, decimal)
    }

    private var accessibilityDescription: String {
        if let originalPrice {
            return String(
                localized: "common_sale_price_label \(currencySymbol) \(price) \(currencySymbol) \(originalPrice)",
            )
        }
        return String(
            localized: "common_price_label \(currencySymbol) \(price)",
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
            .font(.custom("Poppins-Medium", size: Constants.strikethroughFontSize))
            .foregroundStyle(XGColors.priceStrikethrough)
            .strikethrough()
    }

    private func priceFont(size: CGFloat) -> Font {
        .custom("SourceSans3-Black", size: size)
    }
}

// MARK: - Previews

#Preview("XGPriceText Default") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        XGPriceText(price: "29.99", style: .small)
        XGPriceText(price: "149.99")
        XGPriceText(price: "89.99", style: .deal)
    }
    .padding()
}

#Preview("XGPriceText Sale") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        XGPriceText(price: "19.99", originalPrice: "29.99", style: .small)
        XGPriceText(price: "89.99", originalPrice: "149.99")
        XGPriceText(price: "49.99", originalPrice: "99.99", style: .deal)
    }
    .padding()
}
