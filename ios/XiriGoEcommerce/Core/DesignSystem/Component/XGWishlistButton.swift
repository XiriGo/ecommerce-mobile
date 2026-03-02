import SwiftUI

// MARK: - XGWishlistButton

/// A heart icon toggle button overlaid on product cards.
/// Token source: `components/atoms/xg-wishlist-button.json`.
///
/// - Size: 32x32pt, circular
/// - Active: filled heart in brand primary
/// - Inactive: outlined heart in text secondary
///
/// **Motion tokens** (from `XGMotion`):
/// - Color transition: `.easeInOut(duration: XGMotion.Duration.instant)` (0.1s)
/// - Scale bounce: `XGMotion.Easing.spring` (response=0.35, dampingFraction=0.7)
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
        Button(
            action: {
                bounceScale = Constants.bounceScale
                withAnimation(.easeInOut(duration: XGMotion.Duration.instant)) {
                    onToggle()
                }
                withAnimation(XGMotion.Easing.spring) {
                    bounceScale = 1.0
                }
            },
            label: {
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
                    .scaleEffect(bounceScale)
                    .accessibilityHidden(true)
            },
        )
        .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        .accessibilityLabel(
            isWishlisted
                ? String(localized: "common_remove_from_wishlist")
                : String(localized: "common_add_to_wishlist"),
        )
        .accessibilityAddTraits(.isToggle)
        .animation(.easeInOut(duration: XGMotion.Duration.instant), value: isWishlisted)
    }

    // MARK: - Private

    private enum Constants {
        static let buttonSize: CGFloat = 32
        static let iconSize: CGFloat = 16
        static let bounceScale: CGFloat = 1.2
    }

    @State private var bounceScale: CGFloat = 1.0

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
