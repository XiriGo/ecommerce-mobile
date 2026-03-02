import SwiftUI

// MARK: - XGProductCard

/// Product card component for grid displays.
/// Token source: `components/molecules/xg-product-card.json`.
///
/// - productFeatured: 160x293, cornerRadius 10, padding 8, 1:1 image, title 12 semiBold, 2 lines
/// - productStandard: 170x344, same + deliveryLabel + addToCartButton
struct XGProductCard: View {
    // MARK: - Lifecycle

    init(
        imageUrl: URL?,
        title: String,
        price: String,
        originalPrice: String? = nil,
        vendorName: String? = nil,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        isWishlisted: Bool = false,
        onWishlistToggle: (() -> Void)? = nil,
        deliveryLabel: String? = nil,
        deliveryBoldRange: String? = nil,
        priceStyle: XGPriceStyle = .default,
        strikethroughFontSize: CGFloat = Constants.defaultStrikethroughFontSize,
        priceLayout: XGPriceLayout = .inline,
        showRatingAbovePrice: Bool = false,
        showDeliveryAbovePrice: Bool = false,
        reserveSpace: Bool = false,
        onAddToCartAction: (() -> Void)? = nil,
        action: @escaping () -> Void,
    ) {
        self.imageUrl = imageUrl
        self.title = title
        self.price = price
        self.originalPrice = originalPrice
        self.vendorName = vendorName
        self.rating = rating
        self.reviewCount = reviewCount
        self.isWishlisted = isWishlisted
        self.onWishlistToggle = onWishlistToggle
        self.deliveryLabel = deliveryLabel
        self.deliveryBoldRange = deliveryBoldRange
        self.priceStyle = priceStyle
        self.strikethroughFontSize = strikethroughFontSize
        self.priceLayout = priceLayout
        self.showRatingAbovePrice = showRatingAbovePrice
        self.showDeliveryAbovePrice = showDeliveryAbovePrice
        self.reserveSpace = reserveSpace
        self.onAddToCartAction = onAddToCartAction
        self.action = action
    }

    // MARK: - Internal

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                imageSection
                contentSection
            }
            .background(XGColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: XGCornerRadius.medium)
                    .stroke(XGColors.outlineVariant, lineWidth: Constants.borderWidth),
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Private

    private enum Constants {
        static let cardPadding: CGFloat = 8
        static let titleFontSize: CGFloat = 12
        static let titleMaxLines = 2
        static let deliveryFontSize: CGFloat = 10
        static let addToCartSize: CGFloat = 38
        static let addToCartIconSize: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let defaultStrikethroughFontSize: CGFloat = 15.18

        // Reserved heights for uniform card sizing (reserveSpace strategy)
        // Token source: spacing.json > starRating.starSize (12) + gap
        static let reservedRatingHeight: CGFloat = 16
        // Token source: xg-product-card.json > deliveryLabelSubComponent.lineHeight
        static let reservedDeliveryHeight: CGFloat = 14
        // Token source: xg-product-card.json > addToCartSubComponent.size
        static let reservedAddToCartHeight: CGFloat = 38
    }

    private let imageUrl: URL?
    private let title: String
    private let price: String
    private let originalPrice: String?
    private let vendorName: String?
    private let rating: Double?
    private let reviewCount: Int?
    private let isWishlisted: Bool
    private let onWishlistToggle: (() -> Void)?
    private let deliveryLabel: String?
    private let deliveryBoldRange: String?
    private let priceStyle: XGPriceStyle
    private let strikethroughFontSize: CGFloat
    private let priceLayout: XGPriceLayout
    private let showRatingAbovePrice: Bool
    private let showDeliveryAbovePrice: Bool
    private let reserveSpace: Bool
    private let onAddToCartAction: (() -> Void)?
    private let action: () -> Void

    private var accessibilityDescription: String {
        var parts = [title, price]
        if let vendorName {
            parts.append(vendorName)
        }
        if let rating {
            parts.append(
                String(localized: "common_rating_description \(rating) \(5)"),
            )
        }
        return parts.joined(separator: ", ")
    }

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            XGImage(url: imageUrl)
                .aspectRatio(1.0, contentMode: .fit)
                .clipped()

            if let onWishlistToggle {
                XGWishlistButton(
                    isWishlisted: isWishlisted,
                    onToggle: onWishlistToggle,
                )
                .padding(XGSpacing.xs)
            }
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: XGSpacing.xs) {
            Text(title)
                .font(XGTypography.captionSemiBold)
                .foregroundStyle(XGColors.onSurface)
                .lineLimit(Constants.titleMaxLines)

            if let vendorName {
                Text(vendorName)
                    .font(XGTypography.bodySmall)
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .lineLimit(1)
            }

            if showRatingAbovePrice {
                ratingSection
            }

            if showDeliveryAbovePrice {
                deliveryLabelSection
                priceWithCartRow
            } else {
                priceSection
                if !showRatingAbovePrice {
                    ratingSection
                }
                deliveryLabelSection
                standaloneCartSection
            }
        }
        .padding(Constants.cardPadding)
    }

    private var priceSection: some View {
        XGPriceText(
            price: price,
            originalPrice: originalPrice,
            style: priceStyle,
            strikethroughFontSize: strikethroughFontSize,
            layout: priceLayout,
        )
    }

    @ViewBuilder
    private var ratingSection: some View {
        if let rating {
            XGRatingBar(rating: rating, showValue: false, reviewCount: reviewCount)
        } else if reserveSpace {
            Color.clear.frame(height: Constants.reservedRatingHeight)
        }
    }

    @ViewBuilder
    private var deliveryLabelSection: some View {
        if let deliveryLabel {
            Text(deliveryAttributedString(deliveryLabel))
                .font(XGTypography.micro)
                .foregroundStyle(XGColors.deliveryText)
        } else if reserveSpace {
            Color.clear.frame(height: Constants.reservedDeliveryHeight)
        }
    }

    private var priceWithCartRow: some View {
        HStack(alignment: .bottom) {
            priceSection
            Spacer()
            if onAddToCartAction != nil {
                addToCartButton
            } else if reserveSpace {
                Color.clear
                    .frame(width: Constants.addToCartSize, height: Constants.addToCartSize)
            }
        }
    }

    @ViewBuilder
    private var standaloneCartSection: some View {
        if onAddToCartAction != nil {
            HStack {
                Spacer()
                addToCartButton
            }
        } else if reserveSpace {
            Color.clear.frame(height: Constants.reservedAddToCartHeight)
        }
    }

    private var addToCartButton: some View {
        Button {
            onAddToCartAction?()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: Constants.addToCartIconSize))
                .foregroundStyle(XGColors.onSurface)
                .frame(width: Constants.addToCartSize, height: Constants.addToCartSize)
                .background(XGColors.brandSecondary)
                .clipShape(Circle())
                .accessibilityHidden(true)
        }
        .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        .accessibilityLabel(String(localized: "common_add_to_cart"))
    }

    private func deliveryAttributedString(_ label: String) -> AttributedString {
        var attributed = AttributedString(label)
        attributed.font = .custom("Poppins-Regular", size: Constants.deliveryFontSize)
        attributed.foregroundColor = XGColors.deliveryText
        if let boldPart = deliveryBoldRange, let range = attributed.range(of: boldPart) {
            attributed[range].font = .custom("Poppins-Bold", size: Constants.deliveryFontSize)
        }
        return attributed
    }
}

// MARK: - Previews

#Preview("XGProductCard Featured") {
    XGProductCard(
        imageUrl: nil,
        title: "Premium Wireless Headphones with Noise Cancellation",
        price: "29.99",
        originalPrice: "39.99",
        rating: 4.5,
        reviewCount: 123,
        isWishlisted: false,
        onWishlistToggle: {},
        priceLayout: .stacked,
        showRatingAbovePrice: true,
        action: {},
    )
    .frame(width: 160)
    .padding()
    .xgTheme()
}

#Preview("XGProductCard Standard") {
    XGProductCard(
        imageUrl: nil,
        title: "Simple Product",
        price: "9.99",
        originalPrice: "14.99",
        rating: 3.5,
        reviewCount: 42,
        isWishlisted: true,
        onWishlistToggle: {},
        deliveryLabel: "Order before 23:59, delivered Monday",
        deliveryBoldRange: "Monday",
        priceStyle: .standard,
        strikethroughFontSize: 14,
        priceLayout: .stacked,
        showRatingAbovePrice: true,
        showDeliveryAbovePrice: true,
        onAddToCartAction: {},
        action: {},
    )
    .frame(width: 170)
    .padding()
    .xgTheme()
}
