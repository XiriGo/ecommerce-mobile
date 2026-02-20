import SwiftUI

// MARK: - MoltTabItem

struct MoltTabItem: Identifiable {
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

// MARK: - MoltTabBar

struct MoltTabBar: View {
    // MARK: - Properties

    private let items: [MoltTabItem]
    @Binding private var selectedIndex: Int

    // MARK: - Init

    init(
        items: [MoltTabItem],
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
        .padding(.top, MoltSpacing.sm)
        .padding(.bottom, MoltSpacing.xs)
        .background(MoltColors.surface)
        .moltElevation(MoltElevation.level4)
    }

    // MARK: - Private

    @ViewBuilder
    private func tabButton(for item: MoltTabItem) -> some View {
        let isSelected = item.id == selectedIndex

        Button {
            selectedIndex = item.id
        } label: {
            VStack(spacing: MoltSpacing.xxs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? item.selectedIcon : item.icon)
                        .font(.system(size: MoltSpacing.IconSize.medium))

                    if let count = item.badgeCount, count > 0 {
                        MoltCountBadge(count: count)
                            .offset(x: MoltSpacing.sm, y: -MoltSpacing.xs)
                    }
                }

                Text(item.label)
                    .font(MoltTypography.labelSmall)
            }
            .foregroundStyle(isSelected ? MoltColors.primary : MoltColors.onSurfaceVariant)
            .frame(maxWidth: .infinity)
            .frame(minHeight: MoltSpacing.minTouchTarget)
        }
        .accessibilityLabel(item.label)
    }
}

// MARK: - Previews

#Preview("MoltTabBar") {
    struct PreviewWrapper: View {
        @State var selectedIndex = 0

        var body: some View {
            VStack {
                Spacer()
                MoltTabBar(
                    items: [
                        MoltTabItem(
                            id: 0,
                            label: String(localized: "common_tab_home"),
                            icon: "house",
                            selectedIcon: "house.fill"
                        ),
                        MoltTabItem(
                            id: 1,
                            label: String(localized: "common_tab_categories"),
                            icon: "square.grid.2x2",
                            selectedIcon: "square.grid.2x2.fill"
                        ),
                        MoltTabItem(
                            id: 2,
                            label: String(localized: "common_tab_cart"),
                            icon: "cart",
                            selectedIcon: "cart.fill",
                            badgeCount: 3
                        ),
                        MoltTabItem(
                            id: 3,
                            label: String(localized: "common_tab_profile"),
                            icon: "person",
                            selectedIcon: "person.fill"
                        ),
                    ],
                    selectedIndex: $selectedIndex
                )
            }
        }
    }
    return PreviewWrapper()
}
