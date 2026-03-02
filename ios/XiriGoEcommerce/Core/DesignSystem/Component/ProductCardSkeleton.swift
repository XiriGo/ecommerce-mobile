import SwiftUI

// MARK: - ProductCardSkeleton

/// Skeleton loading placeholder that mirrors the XGProductCard layout.
/// Uses skeleton primitives from `Skeleton.swift` (DQ-05/DQ-06).
/// Token source: `components/molecules/xg-product-card.json`.
struct ProductCardSkeleton: View {
    // MARK: - Internal

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageArea
            contentArea
        }
        .background(XGColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: XGCornerRadius.medium)
                .stroke(XGColors.outlineVariant, lineWidth: Constants.borderWidth),
        )
        .accessibilityHidden(true)
    }

    // MARK: - Private

    private enum Constants {
        static let cardPadding: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let titleLine2Fraction: CGFloat = 0.8
        static let priceFraction: CGFloat = 0.6
        static let ratingFraction: CGFloat = 0.4
        static let ratingLineHeight: CGFloat = 12
        static let contentAreaHeight: CGFloat = 68
    }

    private var imageArea: some View {
        GeometryReader { geometry in
            SkeletonBox(width: geometry.size.width, height: geometry.size.width)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }

    private var contentArea: some View {
        VStack(alignment: .leading, spacing: XGSpacing.xs) {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: XGSpacing.xs) {
                    SkeletonLine(width: geometry.size.width)
                    SkeletonLine(width: geometry.size.width * Constants.titleLine2Fraction)
                    SkeletonLine(width: geometry.size.width * Constants.priceFraction)
                    SkeletonLine(
                        width: geometry.size.width * Constants.ratingFraction,
                        height: Constants.ratingLineHeight,
                    )
                }
            }
            .frame(height: Constants.contentAreaHeight)
        }
        .padding(Constants.cardPadding)
    }
}

// MARK: - Previews

#Preview("ProductCardSkeleton") {
    ProductCardSkeleton()
        .frame(width: 170)
        .padding()
        .xgTheme()
}

#Preview("Skeleton + Real Side by Side") {
    SkeletonSideBySidePreview()
        .padding()
        .xgTheme()
}

// MARK: - SkeletonSideBySidePreview

/// Preview helper showing skeleton next to a real card.
private struct SkeletonSideBySidePreview: View {
    var body: some View {
        HStack(spacing: XGSpacing.sm) {
            ProductCardSkeleton().frame(width: 160)
            XGProductCard(
                imageUrl: nil,
                title: "Premium Wireless Headphones",
                price: "29.99",
                originalPrice: "39.99",
                rating: 4.5,
                reviewCount: 123,
                priceLayout: .stacked,
                showRatingAbovePrice: true,
                action: {},
            )
            .frame(width: 160)
        }
    }
}

// MARK: - Uniform Height Preview

#Preview("Uniform Height Grid") {
    UniformHeightPreview()
        .padding()
        .xgTheme()
}

// MARK: - UniformHeightPreview

/// Preview helper for demonstrating uniform card heights with `reserveSpace`.
private struct UniformHeightPreview: View {
    // MARK: - Internal

    var body: some View {
        HStack(spacing: XGSpacing.sm) {
            fullCard
            minimalCard
        }
    }

    // MARK: - Private

    private var fullCard: some View {
        XGProductCard(
            imageUrl: nil,
            title: "With Rating & Delivery",
            price: "9.99",
            rating: 3.5,
            reviewCount: 42,
            deliveryLabel: "Delivered Monday",
            deliveryBoldRange: "Monday",
            priceStyle: .standard,
            priceLayout: .stacked,
            showRatingAbovePrice: true,
            showDeliveryAbovePrice: true,
            reserveSpace: true,
            onAddToCartAction: {},
            action: {},
        )
    }

    private var minimalCard: some View {
        XGProductCard(
            imageUrl: nil,
            title: "Minimal Product",
            price: "4.99",
            priceStyle: .standard,
            priceLayout: .stacked,
            showRatingAbovePrice: true,
            showDeliveryAbovePrice: true,
            reserveSpace: true,
            action: {},
        )
    }
}
