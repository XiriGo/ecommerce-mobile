import SwiftUI

// MARK: - XGBrandGradient

/// Branded radial gradient background composed of two layers from `gradients.json > brandHeader`.
/// Used on Splash, Login, and Home hero screens. Accepts overlay content via `@ViewBuilder`.
struct XGBrandGradient<Content: View>: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        ZStack {
            baseGradient
            darkOverlay
            content
        }
    }

    // MARK: - Private

    private let content: Content

    /// Base radial gradient: #9000FE -> #6900FE -> #6900FE -> #9000FE
    private var baseGradient: some View {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "#9000FE"), location: 0.00),
                .init(color: Color(hex: "#6900FE"), location: 0.27),
                .init(color: Color(hex: "#6900FE"), location: 0.66),
                .init(color: Color(hex: "#9000FE"), location: 1.00),
            ]),
            center: UnitPoint(x: 0.5, y: 0.3),
            startRadius: 0,
            endRadius: 500,
        )
        .ignoresSafeArea()
    }

    /// Dark overlay radial gradient: transparent center fading to #3C00D2 at edges
    private var darkOverlay: some View {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "#6000FE").opacity(0.00), location: 0.32),
                .init(color: Color(hex: "#5D00FB").opacity(0.06), location: 0.38),
                .init(color: Color(hex: "#5800F4").opacity(0.21), location: 0.49),
                .init(color: Color(hex: "#4F00E9").opacity(0.46), location: 0.64),
                .init(color: Color(hex: "#4200DA").opacity(0.81), location: 0.81),
                .init(color: Color(hex: "#3C00D2").opacity(1.00), location: 0.90),
            ]),
            center: UnitPoint(x: 0.5, y: 0.3),
            startRadius: 0,
            endRadius: 500,
        )
        .ignoresSafeArea()
    }
}

// MARK: - Convenience Init (no content)

extension XGBrandGradient where Content == EmptyView {
    init() {
        self.init { EmptyView() }
    }
}

// MARK: - Previews

#Preview("XGBrandGradient") {
    XGBrandGradient()
}

#Preview("XGBrandGradient with Content") {
    XGBrandGradient {
        Text("XiriGo")
            .font(XGTypography.displayLarge)
            .foregroundStyle(.white)
    }
}
