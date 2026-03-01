import SwiftUI

// MARK: - SplashScreen

/// Branded splash screen: full-screen pattern background image with centered logo.
/// Displayed while `OnboardingUiState == .loading`.
struct SplashScreen: View {
    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        ZStack {
            Image("xg_brand_pattern")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            XGLogoMark(size: Constants.logoSize)
        }
    }

    // MARK: - Private

    // MARK: - Constants

    private enum Constants {
        static let logoSize: CGFloat = 120
    }
}

// MARK: - Previews

#Preview("SplashScreen") {
    SplashScreen()
}
