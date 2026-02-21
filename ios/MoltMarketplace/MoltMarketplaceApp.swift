import SwiftUI

// MARK: - MoltMarketplaceApp

@main
struct MoltMarketplaceApp: App {
    // MARK: - Lifecycle

    init() {
        // DI container setup will be added in M0-05
    }

    // MARK: - Internal

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .background(MoltColors.background.ignoresSafeArea())
        }
    }
}
