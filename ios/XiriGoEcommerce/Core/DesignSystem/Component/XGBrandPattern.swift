import SwiftUI
import UIKit

// MARK: - XGBrandPattern

/// Tiled X-motif pattern overlay at token-defined opacity (splashPatternOverlay).
/// Uses the exported PNG pattern asset (`xg_brand_pattern`) from the design files,
/// drawn as a repeating tile across the entire surface.
/// Used on Splash and Login screens over `XGBrandGradient`.
struct XGBrandPattern: View {
    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            if let uiImage = UIImage(named: "xg_brand_pattern") {
                let patternColor = UIColor(patternImage: uiImage)
                Color(patternColor)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .opacity(XGColors.brandPatternOpacity)
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

// MARK: - Previews

#Preview("XGBrandPattern") {
    ZStack {
        XGColors.brandPrimary
            .ignoresSafeArea()
        XGBrandPattern()
    }
}

#Preview("XGBrandPattern on Gradient") {
    XGBrandGradient {
        XGBrandPattern()
    }
}
