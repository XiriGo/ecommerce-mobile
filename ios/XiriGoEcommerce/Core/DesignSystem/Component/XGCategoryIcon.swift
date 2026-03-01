import SwiftUI

// MARK: - XGCategoryIcon

/// A colored rounded-rectangle tile with an icon and label below.
/// Token source: `components.json > XGCategoryIcon`.
///
/// - Tile size: 79x79pt
/// - Corner radius: 10pt (medium)
/// - Icon: 40pt, centered, white
/// - Label: below tile, 12pt medium, max 1 line
/// - Label spacing: 6pt
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
        .accessibilityLabel(name)
    }

    // MARK: - Private

    private enum Constants {
        static let tileSize: CGFloat = 79
        static let iconSize: CGFloat = 40
        static let labelFontSize: CGFloat = 12
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
            backgroundColor: Color(hex: "#37B4F2"),
            action: {},
        )
        XGCategoryIcon(
            name: "Fashion",
            systemIconName: "tshirt",
            backgroundColor: Color(hex: "#FE75D4"),
            action: {},
        )
        XGCategoryIcon(
            name: "Home",
            systemIconName: "house",
            backgroundColor: Color(hex: "#FDF29C"),
            action: {},
        )
    }
    .padding()
    .xgTheme()
}
