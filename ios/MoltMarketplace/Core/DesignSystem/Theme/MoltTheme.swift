import SwiftUI

// MARK: - MoltThemeModifier

struct MoltThemeModifier: ViewModifier {
    // MARK: - Internal

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(colorScheme)
    }

    // MARK: - Private

    @Environment(\.colorScheme)
    private var colorScheme
}

extension View {
    func moltTheme() -> some View {
        modifier(MoltThemeModifier())
    }
}

// MARK: - MoltCornerRadius

enum MoltCornerRadius {
    static let none: CGFloat = 0
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let extraLarge: CGFloat = 16
    static let full: CGFloat = 999 // Pill shape
}
