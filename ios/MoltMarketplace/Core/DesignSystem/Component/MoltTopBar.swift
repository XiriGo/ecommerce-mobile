import SwiftUI

// MARK: - MoltTopBarAction

struct MoltTopBarAction: Identifiable {
    let id = UUID()
    let icon: String
    let accessibilityLabel: String
    let badgeCount: Int?
    let action: () -> Void

    init(
        icon: String,
        accessibilityLabel: String,
        badgeCount: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.badgeCount = badgeCount
        self.action = action
    }
}

// MARK: - MoltTopBar

struct MoltTopBar: View {
    // MARK: - Properties

    private let title: String
    private let onBackTap: (() -> Void)?
    private let actions: [MoltTopBarAction]

    // MARK: - Init

    init(
        title: String,
        onBackTap: (() -> Void)? = nil,
        actions: [MoltTopBarAction] = []
    ) {
        self.title = title
        self.onBackTap = onBackTap
        self.actions = actions
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: MoltSpacing.sm) {
            if let onBackTap {
                Button(action: onBackTap) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: MoltSpacing.IconSize.medium))
                        .foregroundStyle(MoltColors.onSurface)
                }
                .frame(minWidth: MoltSpacing.minTouchTarget, minHeight: MoltSpacing.minTouchTarget)
                .accessibilityLabel(String(localized: "common_navigate_back"))
            }

            Text(title)
                .font(MoltTypography.titleLarge)
                .foregroundStyle(MoltColors.onSurface)

            Spacer()

            ForEach(actions) { actionItem in
                actionButton(for: actionItem)
            }
        }
        .padding(.horizontal, MoltSpacing.base)
        .frame(minHeight: MoltSpacing.minTouchTarget)
        .background(MoltColors.surface)
    }

    // MARK: - Private

    @ViewBuilder
    private func actionButton(for item: MoltTopBarAction) -> some View {
        Button(action: item.action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: item.icon)
                    .font(.system(size: MoltSpacing.IconSize.medium))
                    .foregroundStyle(MoltColors.onSurface)

                if let count = item.badgeCount, count > 0 {
                    MoltCountBadge(count: count)
                        .offset(x: MoltSpacing.sm, y: -MoltSpacing.sm)
                }
            }
        }
        .frame(minWidth: MoltSpacing.minTouchTarget, minHeight: MoltSpacing.minTouchTarget)
        .accessibilityLabel(item.accessibilityLabel)
    }
}

// MARK: - View Modifier

extension View {
    func moltTopBar(
        title: String,
        onBackTap: (() -> Void)? = nil,
        actions: [MoltTopBarAction] = []
    ) -> some View {
        VStack(spacing: 0) {
            MoltTopBar(title: title, onBackTap: onBackTap, actions: actions)
            self
        }
    }
}

// MARK: - Previews

#Preview("MoltTopBar Default") {
    MoltTopBar(title: "Products")
}

#Preview("MoltTopBar with Back") {
    MoltTopBar(title: "Product Details", onBackTap: {})
}

#Preview("MoltTopBar with Actions") {
    MoltTopBar(
        title: "Home",
        actions: [
            MoltTopBarAction(icon: "magnifyingglass", accessibilityLabel: "Search") {},
            MoltTopBarAction(icon: "cart", accessibilityLabel: "Cart", badgeCount: 3) {},
        ]
    )
}
