import SwiftUI

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

struct XGTopBar: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        title: String,
        onBackTap: (() -> Void)? = nil,
        actions: [XGTopBarAction] = [],
    ) {
        self.title = title
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
                        .foregroundStyle(XGColors.onSurface)
                }
                .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
                .accessibilityLabel(String(localized: "common_navigate_back"))
            }

            Text(title)
                .font(XGTypography.titleLarge)
                .foregroundStyle(XGColors.onSurface)

            Spacer()

            ForEach(actions) { actionItem in
                actionButton(for: actionItem)
            }
        }
        .padding(.horizontal, XGSpacing.base)
        .frame(minHeight: XGSpacing.minTouchTarget)
        .background(XGColors.surface)
    }

    // MARK: - Private

    private let title: String
    private let onBackTap: (() -> Void)?
    private let actions: [XGTopBarAction]

    private func actionButton(for item: XGTopBarAction) -> some View {
        Button(action: item.action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: item.icon)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .foregroundStyle(XGColors.onSurface)

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
        onBackTap: (() -> Void)? = nil,
        actions: [XGTopBarAction] = [],
    ) -> some View {
        VStack(spacing: 0) {
            XGTopBar(title: title, onBackTap: onBackTap, actions: actions)
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
