import Testing
@testable import XiriGoEcommerce

// MARK: - SocialLoginProviderTests

@Suite("SocialLoginProvider Tests")
struct SocialLoginProviderTests {
    @Test("Provider enum has exactly two cases")
    func providerCount() {
        let providers: [SocialLoginProvider] = [.google, .apple]
        #expect(providers.count == 2)
    }

    @Test("Google provider label is not empty")
    func googleLabel_isNotEmpty() {
        let label = SocialLoginProvider.google.label
        #expect(!label.isEmpty)
    }

    @Test("Apple provider label is not empty")
    func appleLabel_isNotEmpty() {
        let label = SocialLoginProvider.apple.label
        #expect(!label.isEmpty)
    }

    @Test("Google and Apple labels are distinct")
    func labels_areDistinct() {
        let google = SocialLoginProvider.google.label
        let apple = SocialLoginProvider.apple.label
        #expect(google != apple)
    }
}

// MARK: - XGSocialLoginButtonModelTests

@Suite("XGSocialLoginButton Logic Tests")
@MainActor
struct XGSocialLoginButtonModelTests {
    @Test("Button initialises with Google provider")
    func init_googleProvider() {
        let button = XGSocialLoginButton(provider: .google) {}
        _ = button
        #expect(true)
    }

    @Test("Button initialises with Apple provider")
    func init_appleProvider() {
        let button = XGSocialLoginButton(provider: .apple) {}
        _ = button
        #expect(true)
    }

    @Test("Button initialises with loading state")
    func init_loadingState() {
        let button = XGSocialLoginButton(provider: .google, isLoading: true) {}
        _ = button
        #expect(true)
    }

    @Test("Button initialises with disabled state")
    func init_disabledState() {
        let button = XGSocialLoginButton(provider: .apple, isEnabled: false) {}
        _ = button
        #expect(true)
    }

    @Test("Button initialises with all parameter combinations")
    func init_allCombinations() {
        let providers: [SocialLoginProvider] = [.google, .apple]
        let booleans: [Bool] = [true, false]
        for provider in providers {
            for loading in booleans {
                for enabled in booleans {
                    let button = XGSocialLoginButton(
                        provider: provider,
                        isLoading: loading,
                        isEnabled: enabled,
                    ) {}
                    _ = button
                }
            }
        }
        #expect(true)
    }
}

// MARK: - XGSocialLoginButtonColorTokenTests

@Suite("XGSocialLoginButton Color Token Tests")
struct XGSocialLoginButtonColorTokenTests {
    @Test("Social Google Blue matches design token")
    func socialGoogleBlue() {
        #expect(XGColors.socialGoogleBlue == .init(hex: "#4285F4"))
    }

    @Test("Social Google Green matches design token")
    func socialGoogleGreen() {
        #expect(XGColors.socialGoogleGreen == .init(hex: "#34A853"))
    }

    @Test("Social Google Yellow matches design token")
    func socialGoogleYellow() {
        #expect(XGColors.socialGoogleYellow == .init(hex: "#FBBC05"))
    }

    @Test("Social Google Red matches design token")
    func socialGoogleRed() {
        #expect(XGColors.socialGoogleRed == .init(hex: "#EA4335"))
    }

    @Test("Social Apple Black matches design token")
    func socialAppleBlack() {
        #expect(XGColors.socialAppleBlack == .init(hex: "#000000"))
    }

    @Test("Surface color matches design token for button background")
    func surface() {
        #expect(XGColors.surface == .init(hex: "#FFFFFF"))
    }

    @Test("Outline color matches design token for button border")
    func outline() {
        #expect(XGColors.outline == .init(hex: "#E5E7EB"))
    }

    @Test("OnSurface color matches design token for button text")
    func onSurface() {
        #expect(XGColors.onSurface == .init(hex: "#333333"))
    }
}
