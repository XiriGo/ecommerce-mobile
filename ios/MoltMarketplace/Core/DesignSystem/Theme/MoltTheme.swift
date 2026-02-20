import SwiftUI

// MARK: - Molt Theme View Modifier
internal struct MoltThemeModifier: ViewModifier {
    @Environment(\.colorScheme)
    private var colorScheme

    internal func body(content: Content) -> some View {
        content
            .preferredColorScheme(colorScheme)
    }
}

extension View {
    internal func moltTheme() -> some View {
        modifier(MoltThemeModifier())
    }
}

// MARK: - Corner Radius Tokens
internal enum MoltCornerRadius {
    internal static let none: CGFloat = 0
    internal static let small: CGFloat = 4
    internal static let medium: CGFloat = 8
    internal static let large: CGFloat = 12
    internal static let extraLarge: CGFloat = 16
    internal static let full: CGFloat = 999  // Pill shape
}
