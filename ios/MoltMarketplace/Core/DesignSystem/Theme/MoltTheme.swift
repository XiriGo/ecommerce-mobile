import SwiftUI

// MARK: - Molt Theme View Modifier
struct MoltThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(colorScheme)
    }
}

extension View {
    func moltTheme() -> some View {
        modifier(MoltThemeModifier())
    }
}

// MARK: - Corner Radius Tokens
enum MoltCornerRadius {
    static let none: CGFloat = 0
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let extraLarge: CGFloat = 16
    static let full: CGFloat = 999  // Pill shape
}
