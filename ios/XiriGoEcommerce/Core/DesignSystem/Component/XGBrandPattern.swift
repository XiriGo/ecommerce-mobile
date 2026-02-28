import SwiftUI

// MARK: - XGBrandPattern

/// Tiled X-motif pattern overlay at 6% white opacity.
/// Drawn using `Canvas` to render repeating X shapes across the view.
/// Used on Splash and Login screens over `XGBrandGradient`.
struct XGBrandPattern: View {
    // MARK: - Constants

    private let tileSize: CGFloat = 40
    private let strokeWidth: CGFloat = 2
    private let patternOpacity: Double = 0.06

    // MARK: - Body

    var body: some View {
        Canvas { context, size in
            let columns = Int(ceil(size.width / tileSize)) + 1
            let rows = Int(ceil(size.height / tileSize)) + 1

            for row in 0..<rows {
                for col in 0..<columns {
                    let origin = CGPoint(
                        x: CGFloat(col) * tileSize,
                        y: CGFloat(row) * tileSize
                    )
                    drawXMotif(in: &context, at: origin)
                }
            }
        }
        .opacity(patternOpacity)
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - Private

    private func drawXMotif(in context: inout GraphicsContext, at origin: CGPoint) {
        let padding: CGFloat = 8
        let topLeft = CGPoint(x: origin.x + padding, y: origin.y + padding)
        let topRight = CGPoint(x: origin.x + tileSize - padding, y: origin.y + padding)
        let bottomLeft = CGPoint(x: origin.x + padding, y: origin.y + tileSize - padding)
        let bottomRight = CGPoint(x: origin.x + tileSize - padding, y: origin.y + tileSize - padding)

        var path = Path()
        path.move(to: topLeft)
        path.addLine(to: bottomRight)
        path.move(to: topRight)
        path.addLine(to: bottomLeft)

        context.stroke(
            path,
            with: .color(.white),
            lineWidth: strokeWidth
        )
    }
}

// MARK: - Previews

#Preview("XGBrandPattern") {
    ZStack {
        Color(hex: "#6000FE")
            .ignoresSafeArea()
        XGBrandPattern()
    }
}

#Preview("XGBrandPattern on Gradient") {
    XGBrandGradient {
        XGBrandPattern()
    }
}
