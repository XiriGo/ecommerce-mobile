import SwiftUI

// MARK: - MoltThemeModifier

struct MoltThemeModifier: ViewModifier {
    // MARK: - Internal

    func body(content: Content) -> some View {
        content
            .tint(MoltColors.primary)
    }
}

extension View {
    func moltTheme() -> some View {
        modifier(MoltThemeModifier())
    }
}
