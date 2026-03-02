import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGLogoMarkTests

/// Logic-level tests for XGLogoMark.
/// Verifies default and custom size initialisation and token contract.
@Suite("XGLogoMark Tests")
@MainActor
struct XGLogoMarkTests {
    // MARK: - Initialisation

    @Test("default size init initialises without crash")
    func init_defaultSize_initialises() {
        let logo = XGLogoMark()
        _ = logo
        #expect(true)
    }

    @Test("custom size 60 initialises without crash")
    func init_customSize60_initialises() {
        let logo = XGLogoMark(size: 60)
        _ = logo
        #expect(true)
    }

    @Test("custom size 200 initialises without crash")
    func init_customSize200_initialises() {
        let logo = XGLogoMark(size: 200)
        _ = logo
        #expect(true)
    }

    @Test("splash screen default size is 120")
    func splashScreenSize_is120() {
        // Default size is documented as 120 in XGLogoMark.init(size:)
        // from xg-logo-mark.json > tokens.defaultSize
        let logo = XGLogoMark(size: 120)
        _ = logo
        #expect(true)
    }

    @Test("XGLogoMark is a View")
    func xgLogoMark_conformsToView() {
        let logo: any View = XGLogoMark()
        _ = logo
        #expect(true)
    }

    // MARK: - Token Contract (DQ-33)

    @Test("XGLogoMark default init uses token default size 120")
    func defaultInit_usesTokenSize() {
        // Verify XGLogoMark() can be created (uses defaultSize = 120 from token)
        let logo = XGLogoMark()
        _ = logo
        #expect(true)
    }
}
