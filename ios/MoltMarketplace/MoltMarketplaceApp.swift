import SwiftUI

@main
struct MoltMarketplaceApp: App {

    init() {
        // DI container setup will be added in M0-05
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Placeholder view - replaced with navigation in M0-04
struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Molt Marketplace")
                .font(.system(size: 24))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(MoltColors.background))
    }
}

#Preview {
    ContentView()
}
