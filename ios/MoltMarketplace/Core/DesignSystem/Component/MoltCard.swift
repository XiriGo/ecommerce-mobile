import SwiftUI

// MARK: - MoltProductCard

struct MoltProductCard: View {
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
            VStack(alignment: .leading, spacing: MoltSpacing.xs) {
                imageSection
                contentSection
            }
            .background(MoltColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.medium))
            .moltElevation(MoltElevation.level1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Subviews

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            MoltImage(url: imageUrl)
                .aspectRatio(16.0 / 9.0, contentMode: .fill)
                .clipped()

            if let onWishlistToggle {
                Button(action: onWishlistToggle) {
                    Image(systemName: isWishlisted ? "heart.fill" : "heart")
                        .foregroundStyle(isWishlisted ? MoltColors.error : MoltColors.onSurfaceVariant)
                        .font(.system(size: MoltSpacing.IconSize.medium))
                        .padding(MoltSpacing.sm)
                        .background(MoltColors.surface.opacity(0.8))
                        .clipShape(Circle())
                }
                .frame(minWidth: MoltSpacing.minTouchTarget, minHeight: MoltSpacing.minTouchTarget)
                .padding(MoltSpacing.xs)
                .accessibilityLabel(
                    isWishlisted
                        ? String(localized: "common_remove_from_wishlist")
                        : String(localized: "common_add_to_wishlist")
                )
            }
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: MoltSpacing.xs) {
            Text(title)
                .font(MoltTypography.titleMedium)
                .foregroundStyle(MoltColors.onSurface)
                .lineLimit(2)

            if let vendorName {
                Text(vendorName)
                    .font(MoltTypography.bodySmall)
                    .foregroundStyle(MoltColors.onSurfaceVariant)
            }

            MoltPriceText(price: price, originalPrice: originalPrice)

            if let rating {
                MoltRatingBar(
                    rating: rating,
                    showValue: true,
                    reviewCount: reviewCount
                )
            }
        }
        .padding(MoltSpacing.cardPadding)
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

// MARK: - MoltInfoCard

struct MoltInfoCard<TrailingContent: View>: View {
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
        let content = HStack(spacing: MoltSpacing.md) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .foregroundStyle(MoltColors.onSurfaceVariant)
                    .font(.system(size: MoltSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: MoltSpacing.xxs) {
                Text(title)
                    .font(MoltTypography.titleMedium)
                    .foregroundStyle(MoltColors.onSurface)

                if let subtitle {
                    Text(subtitle)
                        .font(MoltTypography.bodySmall)
                        .foregroundStyle(MoltColors.onSurfaceVariant)
                }
            }

            Spacer()

            if let trailingContent {
                trailingContent
            }
        }
        .padding(MoltSpacing.cardPadding)
        .background(MoltColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.medium))
        .moltElevation(MoltElevation.level1)

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

extension MoltInfoCard where TrailingContent == EmptyView {
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

#Preview("MoltProductCard") {
    MoltProductCard(
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

#Preview("MoltProductCard Wishlisted") {
    MoltProductCard(
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

#Preview("MoltInfoCard") {
    VStack(spacing: MoltSpacing.sm) {
        MoltInfoCard(
            title: "Shipping Address",
            subtitle: "123 Main Street, Valletta",
            leadingIcon: "location",
            action: {}
        )

        MoltInfoCard(
            title: "Payment Method",
            subtitle: "Visa ending in 4242",
            leadingIcon: "creditcard"
        ) {
            Image(systemName: "chevron.right")
                .foregroundStyle(MoltColors.onSurfaceVariant)
        }
    }
    .padding()
}
