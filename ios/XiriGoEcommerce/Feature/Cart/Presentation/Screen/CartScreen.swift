import SwiftUI

// MARK: - CartScreen

/// Shopping cart screen. Displays empty state when cart has no items.
struct CartScreen: View {
    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        XGEmptyView(
            message: String(localized: "cart_empty_message"),
            systemImage: "bag",
            actionLabel: String(localized: "cart_start_shopping"),
            onAction: {
                router.selectTab(.home)
            },
        )
        .background(XGColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "nav_tab_cart"))
    }

    // MARK: - Private

    @Environment(AppRouter.self)
    private var router
}

// MARK: - Previews

#Preview("CartScreen") {
    NavigationStack {
        CartScreen()
    }
    .environment(AppRouter())
}
