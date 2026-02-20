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
            ContentView()
        }
    }
}

// MARK: - ContentView

// Placeholder view - replaced with navigation in M0-04
struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Molt Marketplace")
                .font(MoltTypography.headlineSmall)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(MoltColors.background))
    }
}

#Preview {
    ContentView()
}
