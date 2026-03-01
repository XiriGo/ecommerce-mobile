import SwiftUI

// MARK: - XGRatingBar

/// Star rating display with optional numeric value and review count.
/// Token source: `components.json > XGStarRating`.
///
/// - Star size: 12pt
/// - Star gap: 2pt
/// - Count: 5 stars
/// - Review count spacing: 4pt from stars
/// - Review count font: 12pt, textSecondary color
struct XGRatingBar: View {
    // MARK: - Lifecycle

    init(
        rating: Double,
        maxRating: Int = Constants.starCount,
        starSize: CGFloat = Constants.starSize,
        showValue: Bool = false,
        reviewCount: Int? = nil,
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.starSize = starSize
        self.showValue = showValue
        self.reviewCount = reviewCount
    }

    // MARK: - Internal

    var body: some View {
        HStack(spacing: Constants.reviewCountSpacing) {
            starsView

            if showValue {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: Constants.reviewCountFontSize))
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .lineLimit(1)
                    .fixedSize()
            }

            if let reviewCount {
                Text("(\(reviewCount))")
                    .font(.system(size: Constants.reviewCountFontSize))
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Private

    private enum Constants {
        static let starSize: CGFloat = 12
        static let starGap: CGFloat = 2
        static let starCount = 5
        static let reviewCountFontSize: CGFloat = 12
        static let reviewCountSpacing: CGFloat = 4
    }

    private let rating: Double
    private let maxRating: Int
    private let starSize: CGFloat
    private let showValue: Bool
    private let reviewCount: Int?

    private var accessibilityDescription: String {
        var desc = String(localized: "common_rating_description \(rating) \(maxRating)")
        if let reviewCount {
            desc += " " + String(localized: "common_reviews_count \(reviewCount)")
        }
        return desc
    }

    private var starsView: some View {
        HStack(spacing: Constants.starGap) {
            ForEach(1 ... maxRating, id: \.self) { position in
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
