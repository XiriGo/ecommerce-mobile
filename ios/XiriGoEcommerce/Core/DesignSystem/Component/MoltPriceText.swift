import SwiftUI

// MARK: - MoltPriceSize

enum MoltPriceSize {
    case small
    case medium
    case large

    var priceFont: Font {
        switch self {
        case .small: return MoltTypography.bodySmall
        case .medium: return MoltTypography.titleMedium
        case .large: return MoltTypography.headlineSmall
        }
    }

    var originalPriceFont: Font {
        switch self {
        case .small: return MoltTypography.labelSmall
        case .medium: return MoltTypography.bodySmall
        case .large: return MoltTypography.bodyMedium
        }
    }
}

// MARK: - MoltPriceText

struct MoltPriceText: View {
    // MARK: - Properties

    private let price: String
    private let originalPrice: String?
    private let currencySymbol: String
    private let size: MoltPriceSize

    // MARK: - Init

    init(
        price: String,
        originalPrice: String? = nil,
        currencySymbol: String = "EUR",
        size: MoltPriceSize = .medium
    ) {
        self.price = price
        self.originalPrice = originalPrice
        self.currencySymbol = currencySymbol
        self.size = size
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: MoltSpacing.sm) {
            Text("\(currencySymbol) \(price)")
                .font(size.priceFont)
                .foregroundStyle(hasSale ? MoltColors.priceSale : MoltColors.priceRegular)

            if let originalPrice {
                Text("\(currencySymbol) \(originalPrice)")
                    .font(size.originalPriceFont)
                    .foregroundStyle(MoltColors.priceOriginal)
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

#Preview("MoltPriceText Regular") {
    VStack(alignment: .leading, spacing: MoltSpacing.sm) {
        MoltPriceText(price: "29.99", size: .small)
        MoltPriceText(price: "29.99", size: .medium)
        MoltPriceText(price: "29.99", size: .large)
    }
    .padding()
}

#Preview("MoltPriceText Sale") {
    VStack(alignment: .leading, spacing: MoltSpacing.sm) {
        MoltPriceText(price: "19.99", originalPrice: "29.99", size: .small)
        MoltPriceText(price: "19.99", originalPrice: "29.99", size: .medium)
        MoltPriceText(price: "19.99", originalPrice: "29.99", size: .large)
    }
    .padding()
}
