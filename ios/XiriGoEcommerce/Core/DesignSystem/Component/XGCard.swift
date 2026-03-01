import SwiftUI

// MARK: - XGProductCard

/// Product card component for grid displays.
/// Token source: `components.json > XGCard.productFeatured / productStandard`.
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

            XGPriceText(
                price: price,
                originalPrice: originalPrice,
                style: priceStyle,
                strikethroughFontSize: strikethroughFontSize,
            )

            ratingSection
            deliveryAndCartSection
        }
        .padding(Constants.cardPadding)
    }

    @ViewBuilder
    private var ratingSection: some View {
        if let rating {
            XGRatingBar(rating: rating, showValue: false, reviewCount: reviewCount)
        }
    }

    @ViewBuilder
    private var deliveryAndCartSection: some View {
        if let deliveryLabel {
            Text(deliveryAttributedString(deliveryLabel))
                .font(XGTypography.micro)
                .foregroundStyle(XGColors.deliveryText)
        }
        if onAddToCartAction != nil {
            HStack {
                Spacer()
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
        }
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

// MARK: - XGInfoCard

struct XGInfoCard<TrailingContent: View>: View {
    // MARK: - Lifecycle

    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder trailingContent: () -> TrailingContent,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.action = action
        self.trailingContent = trailingContent()
    }

    // MARK: - Internal

    var body: some View {
        let content = HStack(spacing: XGSpacing.md) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: XGSpacing.xxs) {
                Text(title)
                    .font(XGTypography.titleMedium)
                    .foregroundStyle(XGColors.onSurface)

                if let subtitle {
                    Text(subtitle)
                        .font(XGTypography.bodySmall)
                        .foregroundStyle(XGColors.onSurfaceVariant)
                }
            }

            Spacer()

            if let trailingContent {
                trailingContent
            }
        }
        .padding(XGSpacing.cardPadding)
        .background(XGColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .xgElevation(XGElevation.level1)

        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isButton)
        } else {
            content
        }
    }

    // MARK: - Private

    private let title: String
    private let subtitle: String?
    private let leadingIcon: String?
    private let trailingContent: TrailingContent?
    private let action: (() -> Void)?
}

extension XGInfoCard where TrailingContent == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        action: (() -> Void)? = nil,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.action = action
        trailingContent = nil
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
        isWishlisted: true,
        onWishlistToggle: {},
        deliveryLabel: "Order before 23:59, delivered Monday",
        deliveryBoldRange: "Monday",
        priceStyle: .standard,
        strikethroughFontSize: 14,
        onAddToCartAction: {},
        action: {},
    )
    .frame(width: 170)
    .padding()
    .xgTheme()
}

#Preview("XGInfoCard") {
    VStack(spacing: XGSpacing.sm) {
        XGInfoCard(
            title: "Shipping Address",
            subtitle: "123 Main Street, Valletta",
            leadingIcon: "location",
            action: {},
        )

        XGInfoCard(
            title: "Payment Method",
            subtitle: "Visa ending in 4242",
            leadingIcon: "creditcard",
        ) {
            Image(systemName: "chevron.right")
                .foregroundStyle(XGColors.onSurfaceVariant)
                .accessibilityHidden(true)
        }
    }
    .padding()
    .xgTheme()
}
