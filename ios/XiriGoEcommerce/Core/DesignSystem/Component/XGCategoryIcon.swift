import SwiftUI

// MARK: - XGCategoryIcon

/// A colored rounded-rectangle tile with an icon and label below.
///
/// Token source: `shared/design-tokens/components/atoms/xg-category-icon.json`.
///
/// Token mapping:
/// - tileSize      = 79pt
/// - cornerRadius  = `$foundations/spacing.cornerRadius.medium` -> `XGCornerRadius.medium` (10pt)
/// - iconSize      = 40pt
/// - iconColor     = `$foundations/colors.light.iconOnDark`     -> `XGColors.iconOnDark`
/// - labelFont     = `$foundations/typography.typeScale.captionMedium` -> `XGTypography.captionMedium` (12pt Medium)
/// - labelColor    = `$foundations/colors.light.textPrimary`    -> `XGColors.onSurface`
/// - labelSpacing  = 6pt
struct XGCategoryIcon: View {
    // MARK: - Lifecycle

    init(
        name: String,
        systemIconName: String,
        backgroundColor: Color,
        action: @escaping () -> Void,
    ) {
        self.name = name
        self.systemIconName = systemIconName
        self.backgroundColor = backgroundColor
        self.action = action
    }

    // MARK: - Internal

    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.labelSpacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: XGCornerRadius.medium)
                        .fill(backgroundColor)
                        .frame(
                            width: Constants.tileSize,
                            height: Constants.tileSize,
                        )

                    Image(systemName: systemIconName)
                        .font(.system(size: Constants.iconSize))
                        .foregroundStyle(XGColors.iconOnDark)
                        .accessibilityHidden(true)
                }

                Text(name)
                    .font(XGTypography.captionMedium)
                    .foregroundStyle(XGColors.onSurface)
                    .lineLimit(1)
            }
            .frame(width: Constants.tileSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name)
    }

    // MARK: - Private

    private enum Constants {
        static let tileSize: CGFloat = 79
        static let iconSize: CGFloat = 40
        static let labelSpacing: CGFloat = 6
    }

    private let name: String
    private let systemIconName: String
    private let backgroundColor: Color
    private let action: () -> Void
}

// MARK: - Previews

#Preview("XGCategoryIcon") {
    HStack(spacing: XGSpacing.base) {
        XGCategoryIcon(
            name: "Electronics",
            systemIconName: "desktopcomputer",
            backgroundColor: XGColors.categoryBlue,
            action: {},
        )
        XGCategoryIcon(
            name: "Fashion",
            systemIconName: "tshirt",
            backgroundColor: XGColors.categoryPink,
            action: {},
        )
        XGCategoryIcon(
            name: "Home",
            systemIconName: "house",
            backgroundColor: XGColors.categoryYellow,
            action: {},
        )
    }
    .padding()
    .xgTheme()
}
