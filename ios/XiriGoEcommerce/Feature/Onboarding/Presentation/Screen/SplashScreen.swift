import SwiftUI

// MARK: - SplashScreen

/// Branded splash screen with 4 visual layers:
/// 1. XGBrandGradient (radial gradient background)
/// 2. XGBrandPattern (tiled X-motif at 6% opacity)
/// 3. XGLogoMark (green + white chevrons)
/// 4. Dark vignette overlay (bottom gradient for depth)
///
/// Displayed while `OnboardingUiState == .loading`.
struct SplashScreen: View {
    // MARK: - Constants

    private enum Constants {
        static let logoSize: CGFloat = 120
        static let vignetteOpacity: Double = 0.3
        static let vignetteHeight: CGFloat = 200
    }

    // MARK: - Body

    var body: some View {
        XGBrandGradient {
            ZStack {
                XGBrandPattern()

                XGLogoMark(size: Constants.logoSize)

                vignetteOverlay
            }
        }
    }

    // MARK: - Private

    /// Dark vignette overlay at the bottom for visual depth.
    private var vignetteOverlay: some View {
        VStack {
            Spacer()
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(Constants.vignetteOpacity),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Constants.vignetteHeight)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Previews

#Preview("SplashScreen") {
    SplashScreen()
}
