import SwiftUI

// MARK: - XGPriceSize

enum XGPriceSize {
    case small
    case medium
    case large

    var priceFont: Font {
        switch self {
        case .small: return XGTypography.bodySmall
        case .medium: return XGTypography.titleMedium
        case .large: return XGTypography.headlineSmall
        }
    }

    var originalPriceFont: Font {
        switch self {
        case .small: return XGTypography.labelSmall
        case .medium: return XGTypography.bodySmall
        case .large: return XGTypography.bodyMedium
        }
    }
}

// MARK: - XGPriceText

struct XGPriceText: View {
    // MARK: - Properties

    private let price: String
    private let originalPrice: String?
    private let currencySymbol: String
    private let size: XGPriceSize

    // MARK: - Init

    init(
        price: String,
        originalPrice: String? = nil,
        currencySymbol: String = "EUR",
        size: XGPriceSize = .medium
    ) {
        self.price = price
        self.originalPrice = originalPrice
        self.currencySymbol = currencySymbol
        self.size = size
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: XGSpacing.sm) {
            Text("\(currencySymbol) \(price)")
                .font(size.priceFont)
                .foregroundStyle(hasSale ? XGColors.priceSale : XGColors.priceRegular)

            if let originalPrice {
                Text("\(currencySymbol) \(originalPrice)")
                    .font(size.originalPriceFont)
                    .foregroundStyle(XGColors.priceOriginal)
                    .strikethrough()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Private

    private var hasSale: Bool {
        originalPrice != nil
    }

    private var accessibilityDescription: String {
        if let originalPrice {
            return String(
                localized: "common_sale_price_label \(currencySymbol) \(price) \(currencySymbol) \(originalPrice)"
            )
        }
        return String(
            localized: "common_price_label \(currencySymbol) \(price)"
        )
    }
}

// MARK: - Previews

#Preview("XGPriceText Regular") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        XGPriceText(price: "29.99", size: .small)
        XGPriceText(price: "29.99", size: .medium)
        XGPriceText(price: "29.99", size: .large)
    }
    .padding()
}

#Preview("XGPriceText Sale") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        XGPriceText(price: "19.99", originalPrice: "29.99", size: .small)
        XGPriceText(price: "19.99", originalPrice: "29.99", size: .medium)
        XGPriceText(price: "19.99", originalPrice: "29.99", size: .large)
    }
    .padding()
}
