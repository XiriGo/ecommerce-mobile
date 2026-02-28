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
    // MARK: - Body

    var body: some View {
        XGBrandGradient {
            ZStack {
                XGBrandPattern()

                XGLogoMark(size: 120)

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
                    Color.black.opacity(0.3),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Previews

#Preview("SplashScreen") {
    SplashScreen()
}
