import SwiftUI

// MARK: - MainTabView

/// Root view of the application. Displays a four-tab layout where each tab
/// maintains its own independent NavigationStack. Uses MoltTabBar for the
/// bottom navigation and presents auth flows as fullscreen covers.
struct MainTabView: View {
    // MARK: - Properties

    @State private var router: AppRouter

    // MARK: - Init

    init(router: AppRouter = AppRouter()) {
        _router = State(initialValue: router)
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
            MoltTabBar(
                items: tabItems,
                selectedIndex: tabBarSelection
            )
        }
        .fullScreenCover(item: authBinding) { route in
            NavigationStack {
                RouteView(route: route)
            }
        }
        .onOpenURL { url in
            router.handleDeepLink(url)
        }
        .environment(router)
    }

    // MARK: - Tab Content

    /// Displays the NavigationStack for the currently selected tab.
    /// Each tab preserves its own navigation path independently.
    @ViewBuilder
    private var tabContent: some View {
        ZStack {
            homeTab
                .opacity(router.selectedTab == .home ? 1 : 0)
                .accessibilityHidden(router.selectedTab != .home)

            categoriesTab
                .opacity(router.selectedTab == .categories ? 1 : 0)
                .accessibilityHidden(router.selectedTab != .categories)

            cartTab
                .opacity(router.selectedTab == .cart ? 1 : 0)
                .accessibilityHidden(router.selectedTab != .cart)

            profileTab
                .opacity(router.selectedTab == .profile ? 1 : 0)
                .accessibilityHidden(router.selectedTab != .profile)
        }
    }

    // MARK: - Tabs

    private var homeTab: some View {
        NavigationStack(path: router.bindingForPath(.home)) {
            PlaceholderView(title: Tab.home.title, systemImage: Tab.home.systemImage)
                .moltNavigationDestinations()
        }
    }

    private var categoriesTab: some View {
        NavigationStack(path: router.bindingForPath(.categories)) {
            PlaceholderView(title: Tab.categories.title, systemImage: Tab.categories.systemImage)
                .moltNavigationDestinations()
        }
    }

    private var cartTab: some View {
        NavigationStack(path: router.bindingForPath(.cart)) {
            PlaceholderView(title: Tab.cart.title, systemImage: Tab.cart.systemImage)
                .moltNavigationDestinations()
        }
    }

    private var profileTab: some View {
        NavigationStack(path: router.bindingForPath(.profile)) {
            PlaceholderView(title: Tab.profile.title, systemImage: Tab.profile.systemImage)
                .moltNavigationDestinations()
        }
    }

    // MARK: - Tab Bar Items

    private var tabItems: [MoltTabItem] {
        Tab.allCases.enumerated().map { index, tab in
            MoltTabItem(
                id: index,
                label: tab.title,
                icon: tab.systemImage,
                selectedIcon: tab.selectedSystemImage,
                badgeCount: tab == .cart ? router.cartBadgeCount : nil
            )
        }
    }

    // MARK: - Bindings

    private var tabBarSelection: Binding<Int> {
        Binding(
            get: { Tab.allCases.firstIndex(of: router.selectedTab) ?? 0 },
            set: { index in
                guard let tab = Tab.allCases[safe: index] else { return }
                router.selectTab(tab)
            }
        )
    }

    private var authBinding: Binding<Route?> {
        Binding(
            get: { router.presentedAuth },
            set: { newValue in
                if newValue == nil {
                    router.dismissAuth()
                }
            }
        )
    }
}

// MARK: - Collection Safe Subscript

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Route + Identifiable

extension Route: Identifiable {
    var id: Int { hashValue }
}

// MARK: - Previews

#Preview("MainTabView") {
    MainTabView()
}

#Preview("MainTabView with Badge") {
    let router = AppRouter()
    router.cartBadgeCount = 3
    return MainTabView(router: router)
}
