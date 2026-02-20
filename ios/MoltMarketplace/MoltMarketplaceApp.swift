import SwiftUI

@main
internal struct MoltMarketplaceApp: App {
    internal init() {
        // DI container setup will be added in M0-05
    }

    internal var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Placeholder view - replaced with navigation in M0-04
internal struct ContentView: View {
    internal var body: some View {
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
