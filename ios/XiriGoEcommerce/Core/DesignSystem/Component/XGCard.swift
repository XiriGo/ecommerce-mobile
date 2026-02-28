import SwiftUI

// MARK: - XGProductCard

struct XGProductCard: View {
    // MARK: - Properties

    private let imageUrl: URL?
    private let title: String
    private let price: String
    private let originalPrice: String?
    private let vendorName: String?
    private let rating: Double?
    private let reviewCount: Int?
    private let isWishlisted: Bool
    private let onWishlistToggle: (() -> Void)?
    private let action: () -> Void

    // MARK: - Init

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
        action: @escaping () -> Void
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
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: XGSpacing.xs) {
                imageSection
                contentSection
            }
            .background(XGColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
            .xgElevation(XGElevation.level1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Subviews

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            XGImage(url: imageUrl)
                .aspectRatio(16.0 / 9.0, contentMode: .fill)
                .clipped()

            if let onWishlistToggle {
                Button(action: onWishlistToggle) {
                    Image(systemName: isWishlisted ? "heart.fill" : "heart")
                        .foregroundStyle(isWishlisted ? XGColors.error : XGColors.onSurfaceVariant)
                        .font(.system(size: XGSpacing.IconSize.medium))
                        .padding(XGSpacing.sm)
                        .background(XGColors.surface.opacity(0.8))
                        .clipShape(Circle())
                }
                .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
                .padding(XGSpacing.xs)
                .accessibilityLabel(
                    isWishlisted
                        ? String(localized: "common_remove_from_wishlist")
                        : String(localized: "common_add_to_wishlist")
                )
            }
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: XGSpacing.xs) {
            Text(title)
                .font(XGTypography.titleMedium)
                .foregroundStyle(XGColors.onSurface)
                .lineLimit(2)

            if let vendorName {
                Text(vendorName)
                    .font(XGTypography.bodySmall)
                    .foregroundStyle(XGColors.onSurfaceVariant)
            }

            XGPriceText(price: price, originalPrice: originalPrice)

            if let rating {
                XGRatingBar(
                    rating: rating,
                    showValue: true,
                    reviewCount: reviewCount
                )
            }
        }
        .padding(XGSpacing.cardPadding)
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        var parts = [title, price]
        if let vendorName {
            parts.append(vendorName)
        }
        if let rating {
            parts.append(
                String(localized: "common_rating_description \(rating) \(5)")
            )
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - XGInfoCard

struct XGInfoCard<TrailingContent: View>: View {
    // MARK: - Properties

    private let title: String
    private let subtitle: String?
    private let leadingIcon: String?
    private let trailingContent: TrailingContent?
    private let action: (() -> Void)?

    // MARK: - Init

    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.action = action
        self.trailingContent = trailingContent()
    }

    // MARK: - Body

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
}

extension XGInfoCard where TrailingContent == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.action = action
        self.trailingContent = nil
    }
}

// MARK: - Previews

#Preview("XGProductCard") {
    XGProductCard(
        imageUrl: nil,
        title: "Premium Wireless Headphones with Noise Cancellation",
        price: "29.99",
        originalPrice: "39.99",
        vendorName: "TechStore",
        rating: 4.5,
        reviewCount: 123,
        isWishlisted: false,
        onWishlistToggle: {},
        action: {}
    )
    .frame(width: 200)
    .padding()
}

#Preview("XGProductCard Wishlisted") {
    XGProductCard(
        imageUrl: nil,
        title: "Simple Product",
        price: "9.99",
        isWishlisted: true,
        onWishlistToggle: {},
        action: {}
    )
    .frame(width: 200)
    .padding()
}

#Preview("XGInfoCard") {
    VStack(spacing: XGSpacing.sm) {
        XGInfoCard(
            title: "Shipping Address",
            subtitle: "123 Main Street, Valletta",
            leadingIcon: "location",
            action: {}
        )

        XGInfoCard(
            title: "Payment Method",
            subtitle: "Visa ending in 4242",
            leadingIcon: "creditcard"
        ) {
            Image(systemName: "chevron.right")
                .foregroundStyle(XGColors.onSurfaceVariant)
        }
    }
    .padding()
}
