import SwiftUI

// MARK: - XGThemeModifier

struct XGThemeModifier: ViewModifier {
    // MARK: - Internal

    func body(content: Content) -> some View {
        content
            .tint(XGColors.primary)
    }
}

extension View {
    func xgTheme() -> some View {
        modifier(XGThemeModifier())
    }
}
