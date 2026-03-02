import SwiftUI

// MARK: - XGLogoMark

/// Two-chevron logo mark: green (#94D63A) top chevron + white bottom chevron.
/// Uses the existing `SplashLogo` PNG asset from the asset catalog.
/// Used on Splash and Login screens.
struct XGLogoMark: View {
    // MARK: - Lifecycle

    // MARK: - Init

    /// - Parameter size: Logo dimensions. Default from `xg-logo-mark.json > tokens.defaultSize`.
    init(size: CGFloat = Self.defaultSize) {
        self.size = size
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        Image("SplashLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .accessibilityLabel(String(localized: "onboarding_logo_a11y"))
    }

    // MARK: - Private

    /// Default logo size sourced from `xg-logo-mark.json > tokens.defaultSize`.
    private static let defaultSize: CGFloat = 120

    private let size: CGFloat
}

// MARK: - Previews

#Preview("XGLogoMark") {
    ZStack {
        XGColors.brandPrimary
            .ignoresSafeArea()
        XGLogoMark()
    }
}

#Preview("XGLogoMark Large") {
    ZStack {
        XGColors.brandPrimary
            .ignoresSafeArea()
        XGLogoMark(size: 200)
    }
}

#Preview("XGLogoMark on Gradient") {
    XGBrandGradient {
        XGLogoMark(size: 120)
    }
}
