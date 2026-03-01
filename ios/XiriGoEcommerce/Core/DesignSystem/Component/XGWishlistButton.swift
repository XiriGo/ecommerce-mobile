import SwiftUI

// MARK: - XGWishlistButton

/// A heart icon toggle button overlaid on product cards.
/// Token source: `components/atoms/xg-wishlist-button.json`.
///
/// - Size: 32x32pt, circular
/// - Active: filled heart in brand primary
/// - Inactive: outlined heart in text secondary
struct XGWishlistButton: View {
    // MARK: - Lifecycle

    init(
        isWishlisted: Bool,
        onToggle: @escaping () -> Void,
    ) {
        self.isWishlisted = isWishlisted
        self.onToggle = onToggle
    }

    // MARK: - Internal

    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isWishlisted ? "heart.fill" : "heart")
                .font(.system(size: Constants.iconSize))
                .foregroundStyle(
                    isWishlisted
                        ? XGColors.brandPrimary
                        : XGColors.onSurfaceVariant,
                )
                .frame(
                    width: Constants.buttonSize,
                    height: Constants.buttonSize,
                )
                .background(XGColors.surface)
                .clipShape(Circle())
                .xgElevation(XGElevation.level2)
                .accessibilityHidden(true)
        }
        .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        .accessibilityLabel(
            isWishlisted
                ? String(localized: "common_remove_from_wishlist")
                : String(localized: "common_add_to_wishlist"),
        )
        .accessibilityAddTraits(.isToggle)
    }

    // MARK: - Private

    private enum Constants {
        static let buttonSize: CGFloat = 32
        static let iconSize: CGFloat = 16
    }

    private let isWishlisted: Bool
    private let onToggle: () -> Void
}

// MARK: - Previews

#Preview("XGWishlistButton") {
    HStack(spacing: XGSpacing.lg) {
        XGWishlistButton(isWishlisted: false, onToggle: {})
        XGWishlistButton(isWishlisted: true, onToggle: {})
    }
    .padding()
    .xgTheme()
}
