import SwiftUI

// MARK: - SocialLoginProvider

/// Social authentication provider identifiers.
///
/// Each case maps to a localized label key and provides the icon
/// sourced from `foundations/colors.json > socialAuth`.
enum SocialLoginProvider {
    case google
    case apple

    // MARK: - Internal

    var label: String {
        switch self {
            case .google:
                String(localized: "auth_social_continue_google")

            case .apple:
                String(localized: "auth_social_continue_apple")
        }
    }
}

// MARK: - XGSocialLoginButton

/// Social login button for the authentication screen.
///
/// Renders a provider icon and localized label inside an outlined surface button.
/// Width is intentionally flexible: callers should use `.frame(maxWidth: .infinity)`
/// or place buttons in an `HStack` so they share available width equally.
///
/// Token reference: `components/molecules/xg-social-login-button.json`
struct XGSocialLoginButton: View {
    // MARK: - Lifecycle

    init(
        provider: SocialLoginProvider,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void,
    ) {
        self.provider = provider
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    // MARK: - Internal

    var body: some View {
        Button(action: buttonAction) {
            HStack(spacing: XGSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .frame(
                            width: Constants.iconSize,
                            height: Constants.iconSize,
                        )
                        .tint(XGColors.onSurface)
                } else {
                    providerIcon
                        .frame(
                            width: Constants.iconSize,
                            height: Constants.iconSize,
                        )
                }

                Text(provider.label)
                    .font(XGTypography.labelLarge)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.buttonHeight)
        }
        .buttonStyle(SocialLoginButtonStyle())
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : Constants.disabledAlpha)
        .accessibilityLabel(provider.label)
        .accessibilityValue(
            isLoading ? String(localized: "common_loading") : "",
        )
    }

    // MARK: - Private

    private enum Constants {
        static let buttonHeight: CGFloat = 44
        static let iconSize: CGFloat = 20
        static let borderWidth: CGFloat = 1
        static let disabledAlpha: Double = 0.38
    }

    private let provider: SocialLoginProvider
    private let isLoading: Bool
    private let isEnabled: Bool
    private let action: () -> Void

    private var buttonAction: () -> Void {
        (isLoading || !isEnabled) ? {} : action
    }

    @ViewBuilder
    private var providerIcon: some View {
        switch provider {
            case .google:
                GoogleIcon()

            case .apple:
                Image(systemName: "apple.logo")
                    .font(.system(size: Constants.iconSize * 0.8))
                    .foregroundStyle(XGColors.socialAppleBlack)
                    .accessibilityHidden(true)
        }
    }
}

// MARK: - SocialLoginButtonStyle

private struct SocialLoginButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(XGColors.onSurface)
            .background(
                RoundedRectangle(cornerRadius: XGCornerRadius.medium)
                    .fill(XGColors.surface),
            )
            .overlay(
                RoundedRectangle(cornerRadius: XGCornerRadius.medium)
                    .stroke(XGColors.outline, lineWidth: 1),
            )
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
            .opacity(configuration.isPressed ? 0.88 : 1.0)
    }
}

// MARK: - GoogleIcon

/// Multi-color Google "G" icon using `Shape` overlays.
///
/// Colors from `socialAuth` tokens via `XGColors`:
/// googleBlue, googleGreen, googleYellow, googleRed.
private struct GoogleIcon: View {
    // MARK: - Internal

    var body: some View {
        GeometryReader { geometry in
            let metrics = GoogleIconMetrics(size: geometry.size)
            ZStack {
                googleArc(metrics: metrics, start: -45, end: 45, color: XGColors.socialGoogleBlue)
                googleArc(metrics: metrics, start: 45, end: 135, color: XGColors.socialGoogleGreen)
                googleArc(metrics: metrics, start: 135, end: 225, color: XGColors.socialGoogleYellow)
                googleArc(metrics: metrics, start: 225, end: 315, color: XGColors.socialGoogleRed)
                googleBar(metrics: metrics)
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: - Private

    private func googleArc(
        metrics: GoogleIconMetrics,
        start: Double,
        end: Double,
        color: Color,
    ) -> some View {
        GoogleArcShape(center: metrics.center, radius: metrics.radius, start: start, end: end)
            .stroke(color, lineWidth: metrics.strokeWidth)
    }

    private func googleBar(metrics: GoogleIconMetrics) -> some View {
        Path { path in
            path.move(to: metrics.center)
            path.addLine(to: CGPoint(
                x: metrics.center.x + metrics.radius + metrics.strokeWidth / 2,
                y: metrics.center.y,
            ))
        }
        .stroke(XGColors.socialGoogleBlue, lineWidth: metrics.strokeWidth)
    }
}

// MARK: - GoogleIconMetrics

private struct GoogleIconMetrics {
    // MARK: - Lifecycle

    init(size: CGSize) {
        center = CGPoint(x: size.width / 2, y: size.height / 2)
        radius = size.width * 0.45
        strokeWidth = size.width * 0.18
    }

    // MARK: - Internal

    let center: CGPoint
    let radius: CGFloat
    let strokeWidth: CGFloat
}

// MARK: - GoogleArcShape

private struct GoogleArcShape: Shape {
    let center: CGPoint
    let radius: CGFloat
    let start: Double
    let end: Double

    func path(in _: CGRect) -> Path {
        var arcPath = Path()
        arcPath.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(start),
            endAngle: .degrees(end),
            clockwise: false,
        )
        return arcPath
    }
}

// MARK: - Previews

#Preview("XGSocialLoginButton Google") {
    XGSocialLoginButton(provider: .google) {}
        .padding()
        .xgTheme()
}

#Preview("XGSocialLoginButton Apple") {
    XGSocialLoginButton(provider: .apple) {}
        .padding()
        .xgTheme()
}

#Preview("XGSocialLoginButton Row") {
    HStack(spacing: XGSpacing.sm) {
        XGSocialLoginButton(provider: .google) {}
        XGSocialLoginButton(provider: .apple) {}
    }
    .padding()
    .xgTheme()
}

#Preview("XGSocialLoginButton Loading") {
    HStack(spacing: XGSpacing.sm) {
        XGSocialLoginButton(provider: .google, isLoading: true) {}
        XGSocialLoginButton(provider: .apple, isLoading: true) {}
    }
    .padding()
    .xgTheme()
}

#Preview("XGSocialLoginButton Disabled") {
    HStack(spacing: XGSpacing.sm) {
        XGSocialLoginButton(provider: .google, isEnabled: false) {}
        XGSocialLoginButton(provider: .apple, isEnabled: false) {}
    }
    .padding()
    .xgTheme()
}
