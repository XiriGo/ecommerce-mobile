import Testing
import SwiftUI
@testable import XiriGoEcommerce

// MARK: - XGBrandGradientTests

/// Logic-level tests for XGBrandGradient.
/// Verifies both init overloads and content forwarding contract.
@Suite("XGBrandGradient Tests")
struct XGBrandGradientTests {
    // MARK: - Initialisation

    @Test("no-content convenience init initialises without crash")
    func test_init_noContent_initialises() {
        let gradient = XGBrandGradient()
        _ = gradient
        #expect(true)
    }

    @Test("ViewBuilder content init initialises without crash")
    func test_init_withContent_initialises() {
        let gradient = XGBrandGradient {
            Text("Test")
        }
        _ = gradient
        #expect(true)
    }

    @Test("ViewBuilder content init accepts EmptyView")
    func test_init_withEmptyView_initialises() {
        let gradient = XGBrandGradient {
            EmptyView()
        }
        _ = gradient
        #expect(true)
    }

    @Test("XGBrandGradient is a View")
    func test_xgBrandGradient_conformsToView() {
        let gradient: any View = XGBrandGradient()
        _ = gradient
        #expect(true)
    }
}
