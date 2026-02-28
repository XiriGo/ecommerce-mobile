import SwiftUI

// MARK: - XGRatingBar

struct XGRatingBar: View {
    // MARK: - Properties

    private let rating: Double
    private let maxRating: Int
    private let starSize: CGFloat
    private let showValue: Bool
    private let reviewCount: Int?

    // MARK: - Init

    init(
        rating: Double,
        maxRating: Int = 5,
        starSize: CGFloat = 16,
        showValue: Bool = false,
        reviewCount: Int? = nil
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.starSize = starSize
        self.showValue = showValue
        self.reviewCount = reviewCount
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: XGSpacing.xxs) {
            starsView

            if showValue {
                Text(String(format: "%.1f", rating))
                    .font(XGTypography.bodySmall)
                    .foregroundStyle(XGColors.onSurfaceVariant)
            }

            if let reviewCount {
                Text("(\(reviewCount))")
                    .font(XGTypography.bodySmall)
                    .foregroundStyle(XGColors.onSurfaceVariant)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Private

    private var starsView: some View {
        HStack(spacing: XGSpacing.xxs) {
            ForEach(1...maxRating, id: \.self) { position in
                starImage(for: position)
                    .font(.system(size: starSize))
            }
        }
    }

    @ViewBuilder
    private func starImage(for position: Int) -> some View {
        let positionDouble = Double(position)
        if rating >= positionDouble {
            Image(systemName: "star.fill")
                .foregroundStyle(XGColors.ratingStarFilled)
                .accessibilityHidden(true)
        } else if rating >= positionDouble - 0.5 {
            Image(systemName: "star.leadinghalf.filled")
                .foregroundStyle(XGColors.ratingStarFilled)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "star")
                .foregroundStyle(XGColors.ratingStarEmpty)
                .accessibilityHidden(true)
        }
    }

    private var accessibilityDescription: String {
        var desc = String(localized: "common_rating_description \(rating) \(maxRating)")
        if let reviewCount {
            desc += " " + String(localized: "common_reviews_count \(reviewCount)")
        }
        return desc
    }
}

// MARK: - Previews

#Preview("XGRatingBar Default") {
    VStack(spacing: XGSpacing.sm) {
        XGRatingBar(rating: 4.5, showValue: true, reviewCount: 123)
        XGRatingBar(rating: 3.0, showValue: true)
        XGRatingBar(rating: 1.5)
        XGRatingBar(rating: 5.0, starSize: 24, showValue: true)
    }
    .padding()
}
