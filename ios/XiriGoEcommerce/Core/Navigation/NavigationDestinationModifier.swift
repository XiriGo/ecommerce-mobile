import SwiftUI

// MARK: - MoltNavigationDestinationModifier

/// ViewModifier that registers `.navigationDestination(for: Route.self)`
/// to map all routes to their corresponding views.
struct MoltNavigationDestinationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Route.self) { route in
                RouteView(route: route)
            }
    }
}

// MARK: - View Extension

extension View {
    /// Applies the Molt navigation destination registration to the view.
    /// Each tab's NavigationStack root should apply this modifier.
    func moltNavigationDestinations() -> some View {
        modifier(MoltNavigationDestinationModifier())
    }
}
