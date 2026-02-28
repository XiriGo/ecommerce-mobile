import SwiftUI

// MARK: - XGTabItem

struct XGTabItem: Identifiable {
    let id: Int
    let label: String
    let icon: String
    let selectedIcon: String
    let badgeCount: Int?

    init(
        id: Int,
        label: String,
        icon: String,
        selectedIcon: String,
        badgeCount: Int? = nil
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.badgeCount = badgeCount
    }
}

// MARK: - XGTabBar

struct XGTabBar: View {
    // MARK: - Properties

    private let items: [XGTabItem]
    @Binding private var selectedIndex: Int

    // MARK: - Init

    init(
        items: [XGTabItem],
        selectedIndex: Binding<Int>
    ) {
        self.items = items
        self._selectedIndex = selectedIndex
    }

    // MARK: - Body

    var body: some View {
        HStack {
            ForEach(items) { item in
                tabButton(for: item)
            }
        }
        .padding(.top, XGSpacing.sm)
        .padding(.bottom, XGSpacing.xs)
        .background(XGColors.surface)
        .xgElevation(XGElevation.level4)
    }

    // MARK: - Private

    @ViewBuilder
    private func tabButton(for item: XGTabItem) -> some View {
        let isSelected = item.id == selectedIndex

        Button {
            selectedIndex = item.id
        } label: {
            VStack(spacing: XGSpacing.xxs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? item.selectedIcon : item.icon)
                        .font(.system(size: XGSpacing.IconSize.medium))

                    if let count = item.badgeCount, count > 0 {
                        XGCountBadge(count: count)
                            .offset(x: XGSpacing.sm, y: -XGSpacing.xs)
                    }
                }

                Text(item.label)
                    .font(XGTypography.labelSmall)
            }
            .foregroundStyle(isSelected ? XGColors.primary : XGColors.onSurfaceVariant)
            .frame(maxWidth: .infinity)
            .frame(minHeight: XGSpacing.minTouchTarget)
        }
        .accessibilityLabel(item.label)
    }
}

// MARK: - Previews

// MARK: - Preview Helpers

private let previewTabItems: [XGTabItem] = [
    XGTabItem(
        id: 0,
        label: String(localized: "common_tab_home"),
        icon: "house",
        selectedIcon: "house.fill"
    ),
    XGTabItem(
        id: 1,
        label: String(localized: "common_tab_categories"),
        icon: "square.grid.2x2",
        selectedIcon: "square.grid.2x2.fill"
    ),
    XGTabItem(
        id: 2,
        label: String(localized: "common_tab_cart"),
        icon: "cart",
        selectedIcon: "cart.fill",
        badgeCount: 3
    ),
    XGTabItem(
        id: 3,
        label: String(localized: "common_tab_profile"),
        icon: "person",
        selectedIcon: "person.fill"
    ),
]

#Preview("XGTabBar") {
    struct PreviewWrapper: View {
        @State var selectedIndex = 0

        var body: some View {
            VStack {
                Spacer()
                XGTabBar(
                    items: previewTabItems,
                    selectedIndex: $selectedIndex
                )
            }
        }
    }
    return PreviewWrapper()
}
