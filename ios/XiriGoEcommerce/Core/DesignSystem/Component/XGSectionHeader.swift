import SwiftUI

// MARK: - XGSectionHeader

/// Section title with optional subtitle and optional "See All" action link.
/// Token source: `typography.json > typeScale.subtitle` (18sp semiBold).
struct XGSectionHeader: View {
    // MARK: - Lifecycle

    init(
        title: String,
        subtitle: String? = nil,
        onSeeAllAction: (() -> Void)? = nil,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onSeeAllAction = onSeeAllAction
    }

    // MARK: - Internal

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: XGSpacing.xxs) {
                Text(title)
                    .font(.system(size: Constants.titleFontSize, weight: .semibold))
                    .foregroundStyle(XGColors.onSurface)

                if let subtitle {
                    Text(subtitle)
                        .font(XGTypography.bodyMedium)
                        .foregroundStyle(XGColors.onSurfaceVariant)
                }
            }

            Spacer()

            if let onSeeAllAction {
                Button(action: onSeeAllAction) {
                    HStack(spacing: XGSpacing.xs) {
                        Text(String(localized: "common_see_all"))
                            .font(.system(size: Constants.seeAllFontSize, weight: .medium))
                            .foregroundStyle(XGColors.brandPrimary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: Constants.arrowIconSize, weight: .medium))
                            .foregroundStyle(XGColors.brandPrimary)
                            .accessibilityHidden(true)
                    }
                }
                .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
                .accessibilityLabel(
                    String(localized: "common_see_all") + " " + title,
                )
            }
        }
        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
    }

    // MARK: - Private

    private enum Constants {
        static let titleFontSize: CGFloat = 18
        static let seeAllFontSize: CGFloat = 14
        static let arrowIconSize: CGFloat = 12
    }

    private let title: String
    private let subtitle: String?
    private let onSeeAllAction: (() -> Void)?
}

// MARK: - Previews

#Preview("XGSectionHeader") {
    VStack(spacing: XGSpacing.lg) {
        XGSectionHeader(title: "Popular Products")

        XGSectionHeader(
            title: "New Arrivals",
            subtitle: "Just added this week",
            onSeeAllAction: {},
        )

        XGSectionHeader(
            title: "Categories",
            onSeeAllAction: {},
        )
    }
    .padding(.vertical)
}
