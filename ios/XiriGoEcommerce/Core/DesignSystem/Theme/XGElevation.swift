import SwiftUI

// MARK: - XGElevation

/// Elevation / shadow constants for the XG Marketplace design system.
/// Maps Material elevation levels to iOS shadow parameters.
enum XGElevation {
    static let level0 = ShadowStyle(radius: 0, y: 0, opacity: 0)
    static let level1 = ShadowStyle(radius: 1, y: 1, opacity: 0.15)
    static let level2 = ShadowStyle(radius: 3, y: 2, opacity: 0.20)
    static let level3 = ShadowStyle(radius: 6, y: 4, opacity: 0.25)
    static let level4 = ShadowStyle(radius: 8, y: 6, opacity: 0.25)
    static let level5 = ShadowStyle(radius: 12, y: 8, opacity: 0.30)
}

// MARK: - ShadowStyle

struct ShadowStyle {
    let radius: CGFloat
    let y: CGFloat
    let opacity: Double
}

// MARK: - View+XGElevation

extension View {
    func xgElevation(_ style: ShadowStyle) -> some View {
        shadow(
            color: XGColors.shadow.opacity(style.opacity),
            radius: style.radius,
            x: 0,
            y: style.y,
        )
    }
}
