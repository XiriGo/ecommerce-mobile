import SwiftUI

// MARK: - XGTabItem

struct XGTabItem: Identifiable {
    // MARK: - Lifecycle

    init(
        id: Int,
        label: String,
        icon: String,
        selectedIcon: String,
        badgeCount: Int? = nil,
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.badgeCount = badgeCount
    }

    // MARK: - Internal

    let id: Int
    let label: String
    let icon: String
    let selectedIcon: String
    let badgeCount: Int?
}

// MARK: - XGTabBar

/// Bottom navigation bar with tab items and optional badge counts.
///
/// Uses XG design tokens for all visual properties:
/// - Colors: `XGColors.bottomNavBackground`, `bottomNavIconActive`, `bottomNavIconInactive`
/// - Icon size: `XGSpacing.IconSize.medium` (24pt)
/// - Label font: `XGTypography.micro` (10pt Regular)
/// - Animation: `XGMotion.Duration.fast` (200ms) with standard easing
///
/// Token source: `shared/design-tokens/components/molecules/xg-bottom-bar.json`
struct XGTabBar: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        items: [XGTabItem],
        selectedIndex: Binding<Int>,
    ) {
        self.items = items
        _selectedIndex = selectedIndex
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Top border — borderSubtle divider
            Rectangle()
                .fill(XGColors.outlineVariant)
                .frame(height: Constants.topBorderWidth)

            // Tab items row
            HStack {
                ForEach(items) { item in
                    tabButton(for: item)
                }
            }
            .frame(height: Constants.barHeight)
            .background(XGColors.bottomNavBackground)
        }
    }

    // MARK: - Private

    // MARK: - Constants

    private enum Constants {
        /// Bar height — from spacing.json: bottomNavigation.height = 75
        static let barHeight: CGFloat = 75

        /// Top border width — from xg-bottom-bar.json: topBorderWidth = 0.5
        static let topBorderWidth: CGFloat = 0.5
    }

    @Binding private var selectedIndex: Int

    private let items: [XGTabItem]

    @ViewBuilder
    private func tabButton(for item: XGTabItem) -> some View {
        let isSelected = item.id == selectedIndex

        Button {
            withAnimation(.easeInOut(duration: XGMotion.Duration.fast)) {
                selectedIndex = item.id
            }
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
                    .font(XGTypography.micro)
            }
            .foregroundStyle(isSelected ? XGColors.bottomNavIconActive : XGColors.bottomNavIconInactive)
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
        selectedIcon: "house.fill",
    ),
    XGTabItem(
        id: 1,
        label: String(localized: "common_tab_categories"),
        icon: "square.grid.2x2",
        selectedIcon: "square.grid.2x2.fill",
    ),
    XGTabItem(
        id: 2,
        label: String(localized: "common_tab_cart"),
        icon: "cart",
        selectedIcon: "cart.fill",
        badgeCount: 3,
    ),
    XGTabItem(
        id: 3,
        label: String(localized: "common_tab_profile"),
        icon: "person",
        selectedIcon: "person.fill",
    ),
]

// MARK: - XGTabBarPreview

private struct XGTabBarPreview: View {
    @State var selectedIndex = 0

    var body: some View {
        VStack {
            Spacer()
            XGTabBar(items: previewTabItems, selectedIndex: $selectedIndex)
        }
    }
}

#Preview("XGTabBar") {
    XGTabBarPreview()
}
