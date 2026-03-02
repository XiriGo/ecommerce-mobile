import SwiftUI

// MARK: - XGTopBarVariant

/// Style variants for ``XGTopBar``, matching `components/molecules/xg-top-bar.json`.
enum XGTopBarVariant {
    /// Surface: white background, dark text/icons (filter screen, product list).
    case surface
    /// Transparent: clear background, white text/icons (splash, login over gradient).
    case transparent

    // MARK: - Internal

    var backgroundColor: Color {
        switch self {
            case .surface:
                XGColors.surface
            case .transparent:
                Color.clear
        }
    }

    var contentColor: Color {
        switch self {
            case .surface:
                XGColors.onSurface
            case .transparent:
                XGColors.textOnDark
        }
    }
}

// MARK: - XGTopBarAction

struct XGTopBarAction: Identifiable {
    // MARK: - Lifecycle

    init(
        icon: String,
        accessibilityLabel: String,
        badgeCount: Int? = nil,
        action: @escaping () -> Void,
    ) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.badgeCount = badgeCount
        self.action = action
    }

    // MARK: - Internal

    let id = UUID()
    let icon: String
    let accessibilityLabel: String
    let badgeCount: Int?
    let action: () -> Void
}

// MARK: - XGTopBar

/// Top bar with title, optional back navigation, and action slots.
///
/// Token source: `components/molecules/xg-top-bar.json`.
/// - Height: 56pt
/// - Title font: titleLarge (20pt SemiBold Poppins)
/// - Icon size: 24pt (layout.iconSize.medium)
/// - Horizontal padding: 16pt (spacing.base)
/// - Min touch target: 48pt
struct XGTopBar: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        title: String,
        variant: XGTopBarVariant = .surface,
        onBackTap: (() -> Void)? = nil,
        actions: [XGTopBarAction] = [],
    ) {
        self.title = title
        self.variant = variant
        self.onBackTap = onBackTap
        self.actions = actions
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        HStack(spacing: XGSpacing.sm) {
            if let onBackTap {
                Button(action: onBackTap) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: XGSpacing.IconSize.medium))
                        .foregroundStyle(variant.contentColor)
                }
                .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
                .accessibilityLabel(String(localized: "common_navigate_back"))
            }

            Text(title)
                .font(XGTypography.titleLarge)
                .foregroundStyle(variant.contentColor)

            Spacer()

            ForEach(actions) { actionItem in
                actionButton(for: actionItem)
            }
        }
        .padding(.horizontal, XGSpacing.base)
        .frame(height: Constants.topBarHeight)
        .frame(maxWidth: .infinity)
        .background(variant.backgroundColor)
    }

    // MARK: - Private

    // MARK: - Constants

    private enum Constants {
        /// Top bar height from token spec: `tokens.height = 56`.
        static let topBarHeight: CGFloat = 56
    }

    private let title: String
    private let variant: XGTopBarVariant
    private let onBackTap: (() -> Void)?
    private let actions: [XGTopBarAction]

    private func actionButton(for item: XGTopBarAction) -> some View {
        Button(action: item.action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: item.icon)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .foregroundStyle(variant.contentColor)

                if let count = item.badgeCount, count > 0 {
                    XGCountBadge(count: count)
                        .offset(x: XGSpacing.sm, y: -XGSpacing.sm)
                }
            }
        }
        .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        .accessibilityLabel(item.accessibilityLabel)
    }
}

// MARK: - View Modifier

extension View {
    func xgTopBar(
        title: String,
        variant: XGTopBarVariant = .surface,
        onBackTap: (() -> Void)? = nil,
        actions: [XGTopBarAction] = [],
    ) -> some View {
        VStack(spacing: 0) {
            XGTopBar(title: title, variant: variant, onBackTap: onBackTap, actions: actions)
            self
        }
    }
}

// MARK: - Previews

#Preview("XGTopBar Default") {
    XGTopBar(title: "Products")
}

#Preview("XGTopBar with Back") {
    XGTopBar(title: "Product Details", onBackTap: {})
}

#Preview("XGTopBar with Actions") {
    XGTopBar(
        title: "Home",
        actions: [
            XGTopBarAction(icon: "magnifyingglass", accessibilityLabel: "Search") {},
            XGTopBarAction(icon: "cart", accessibilityLabel: "Cart", badgeCount: 3) {},
        ],
    )
}

#Preview("XGTopBar Transparent") {
    ZStack {
        Color(hex: "#6000FE")
        XGTopBar(
            title: "Login",
            variant: .transparent,
            onBackTap: {},
        )
    }
}
