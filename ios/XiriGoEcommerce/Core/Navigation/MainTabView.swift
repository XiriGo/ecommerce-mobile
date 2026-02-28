import SwiftUI

// MARK: - MainTabView

/// Root view of the application. Displays a four-tab layout using native TabView
/// for iOS Liquid Glass treatment. Each tab maintains its own independent NavigationStack.
struct MainTabView: View {
    // MARK: - Properties

    @State private var router: AppRouter

    // MARK: - Init

    init(router: AppRouter = AppRouter()) {
        _router = State(initialValue: router)
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: tabSelection) {
            homeTab
                .tabItem {
                    Label(Tab.home.title, systemImage: Tab.home.systemImage)
                }
                .tag(Tab.home)

            categoriesTab
                .tabItem {
                    Label(Tab.categories.title, systemImage: Tab.categories.systemImage)
                }
                .tag(Tab.categories)

            cartTab
                .tabItem {
                    Label(Tab.cart.title, systemImage: Tab.cart.systemImage)
                }
                .tag(Tab.cart)
                .badge(router.cartBadgeCount > 0 ? router.cartBadgeCount : 0)

            profileTab
                .tabItem {
                    Label(Tab.profile.title, systemImage: Tab.profile.systemImage)
                }
                .tag(Tab.profile)
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

    // MARK: - Tabs

    private var homeTab: some View {
        NavigationStack(path: router.bindingForPath(.home)) {
            HomeScreen()
                .moltNavigationDestinations()
        }
    }

    private var categoriesTab: some View {
        NavigationStack(path: router.bindingForPath(.categories)) {
            CategoriesScreen()
                .moltNavigationDestinations()
        }
    }

    private var cartTab: some View {
        NavigationStack(path: router.bindingForPath(.cart)) {
            CartScreen()
                .moltNavigationDestinations()
        }
    }

    private var profileTab: some View {
        NavigationStack(path: router.bindingForPath(.profile)) {
            ProfileScreen()
                .moltNavigationDestinations()
        }
    }

    // MARK: - Bindings

    private var tabSelection: Binding<Tab> {
        Binding(
            get: { router.selectedTab },
            set: { newTab in
                router.selectTab(newTab)
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
