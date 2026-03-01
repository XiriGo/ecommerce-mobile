import SwiftUI
import UIKit

// MARK: - XGBrandPattern

/// Tiled X-motif pattern overlay at 6% opacity.
/// Uses the exported PNG pattern asset (`xg_brand_pattern`) from the design files,
/// drawn as a repeating tile across the entire surface.
/// Used on Splash and Login screens over `XGBrandGradient`.
struct XGBrandPattern: View {
    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            if let uiImage = UIImage(named: "xg_brand_pattern") {
                let patternColor = UIColor(patternImage: uiImage)
                Color(patternColor)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .opacity(patternOpacity)
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - Private

    // MARK: - Constants

    private let patternOpacity: Double = 0.06
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
