import SwiftUI

// MARK: - XGLogoMark

/// Two-chevron logo mark: green (#94D63A) top chevron + white bottom chevron.
/// Uses the existing `SplashLogo` PNG asset from the asset catalog.
/// Used on Splash and Login screens.
struct XGLogoMark: View {
    // MARK: - Properties

    private let size: CGFloat

    // MARK: - Init

    init(size: CGFloat = 120) {
        self.size = size
    }

    // MARK: - Body

    var body: some View {
        Image("SplashLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .accessibilityLabel(String(localized: "onboarding_logo_a11y"))
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
