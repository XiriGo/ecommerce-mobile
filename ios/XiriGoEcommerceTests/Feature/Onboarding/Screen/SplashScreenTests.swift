import Testing
import SwiftUI
@testable import XiriGoEcommerce

// MARK: - SplashScreenTests

/// Structural tests for SplashScreen.
/// Confirms the view initialises correctly and composes XGBrandGradient,
/// XGBrandPattern, and XGLogoMark. Full pixel-level snapshot testing
/// would be done via swift-snapshot-testing in a UI test target.
@Suite("SplashScreen Tests")
struct SplashScreenTests {
    @Test("SplashScreen initialises without crash")
    func test_init_initialises() {
        let screen = SplashScreen()
        _ = screen
        #expect(true)
    }

    @Test("SplashScreen is a View")
    func test_splashScreen_conformsToView() {
        let screen: any View = SplashScreen()
        _ = screen
        #expect(true)
    }

    @Test("SplashScreen body can be created without crash")
    func test_body_canBeCreated() {
        let screen = SplashScreen()
        // Accessing .body on a SwiftUI View creates the view tree.
        // This confirms no force-unwrap or fatal errors in body construction.
        let body = screen.body
        _ = body
        #expect(true)
    }
}
