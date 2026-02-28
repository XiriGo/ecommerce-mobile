import SwiftUI

// MARK: - XGBrandPattern

/// Tiled X-motif pattern overlay at 6% opacity.
/// Uses the exported PNG pattern asset (`xg_brand_pattern`) from the design files.
/// Used on Splash and Login screens over `XGBrandGradient`.
struct XGBrandPattern: View {
    // MARK: - Constants

    private let patternOpacity: Double = 0.06

    // MARK: - Body

    var body: some View {
        Image("xg_brand_pattern")
            .resizable()
            .scaledToFill()
            .opacity(patternOpacity)
            .allowsHitTesting(false)
            .ignoresSafeArea()
            .accessibilityHidden(true)
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
