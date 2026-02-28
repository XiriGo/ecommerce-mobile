import SwiftUI

// MARK: - XGLogoMark

/// Two-chevron logo mark: green (#94D63A) top chevron + white bottom chevron.
/// Rendered using SwiftUI `Shape` paths. Used on Splash and Login screens.
struct XGLogoMark: View {
    // MARK: - Properties

    private let size: CGFloat

    // MARK: - Init

    init(size: CGFloat = 120) {
        self.size = size
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            ChevronShape()
                .fill(Color(hex: "#94D63A"))
                .frame(width: size, height: size * 0.52)
                .offset(y: -size * 0.12)

            ChevronShape()
                .fill(Color.white)
                .frame(width: size, height: size * 0.52)
                .offset(y: size * 0.12)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(String(localized: "onboarding_logo_a11y"))
    }
}

// MARK: - ChevronShape

/// A downward-pointing chevron / inverted V shape.
private struct ChevronShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let thickness = height * 0.35

        // Top-left corner
        path.move(to: CGPoint(x: 0, y: 0))
        // Center bottom point
        path.addLine(to: CGPoint(x: width / 2, y: height))
        // Top-right corner
        path.addLine(to: CGPoint(x: width, y: 0))
        // Inner-right
        path.addLine(to: CGPoint(x: width, y: thickness))
        // Inner center bottom
        path.addLine(to: CGPoint(x: width / 2, y: height - (height - thickness) * 0.05))
        // Inner-left
        path.addLine(to: CGPoint(x: 0, y: thickness))
        path.closeSubpath()

        return path
    }
}

// MARK: - Previews

#Preview("XGLogoMark") {
    ZStack {
        Color(hex: "#6000FE")
            .ignoresSafeArea()
        XGLogoMark()
    }
}

#Preview("XGLogoMark Large") {
    ZStack {
        Color(hex: "#6000FE")
            .ignoresSafeArea()
        XGLogoMark(size: 200)
    }
}

#Preview("XGLogoMark on Gradient") {
    XGBrandGradient {
        XGLogoMark(size: 120)
    }
}
