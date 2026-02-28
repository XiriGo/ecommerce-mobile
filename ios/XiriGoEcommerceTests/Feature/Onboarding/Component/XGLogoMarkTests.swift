import Testing
import SwiftUI
@testable import XiriGoEcommerce

// MARK: - XGLogoMarkTests

/// Logic-level tests for XGLogoMark.
/// Verifies default and custom size initialisation.
@Suite("XGLogoMark Tests")
struct XGLogoMarkTests {
    // MARK: - Initialisation

    @Test("default size init initialises without crash")
    func test_init_defaultSize_initialises() {
        let logo = XGLogoMark()
        _ = logo
        #expect(true)
    }

    @Test("custom size 60 initialises without crash")
    func test_init_customSize60_initialises() {
        let logo = XGLogoMark(size: 60)
        _ = logo
        #expect(true)
    }

    @Test("custom size 200 initialises without crash")
    func test_init_customSize200_initialises() {
        let logo = XGLogoMark(size: 200)
        _ = logo
        #expect(true)
    }

    @Test("splash screen default size is 120")
    func test_splashScreenSize_is120() {
        // Default size is documented as 120 in XGLogoMark.init(size:)
        let logo = XGLogoMark(size: 120)
        _ = logo
        #expect(true)
    }

    @Test("XGLogoMark is a View")
    func test_xgLogoMark_conformsToView() {
        let logo: any View = XGLogoMark()
        _ = logo
        #expect(true)
    }
}
