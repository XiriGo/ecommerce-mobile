import SwiftUI

// MARK: - XGPriceSize

enum XGPriceSize {
    case small
    case medium
    case large

    // MARK: - Internal

    var priceFont: Font {
        switch self {
            case .small: XGTypography.bodySmall
            case .medium: XGTypography.titleMedium
            case .large: XGTypography.headlineSmall
        }
    }

    var originalPriceFont: Font {
        switch self {
            case .small: XGTypography.labelSmall
            case .medium: XGTypography.bodySmall
            case .large: XGTypography.bodyMedium
        }
    }
}

// MARK: - XGPriceText

struct XGPriceText: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        price: String,
        originalPrice: String? = nil,
        currencySymbol: String = "EUR",
        size: XGPriceSize = .medium,
    ) {
        self.price = price
        self.originalPrice = originalPrice
        self.currencySymbol = currencySymbol
        self.size = size
    }

    // MARK: - Internal

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

    private let price: String
    private let originalPrice: String?
    private let currencySymbol: String
    private let size: XGPriceSize

    private var hasSale: Bool {
        originalPrice != nil
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
