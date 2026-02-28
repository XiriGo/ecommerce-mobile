import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGBrandPatternTests

/// Logic-level tests for XGBrandPattern.
/// Verifies initialisation and View protocol conformance.
@Suite("XGBrandPattern Tests")
struct XGBrandPatternTests {
    @Test("XGBrandPattern initialises without crash")
    func init_initialises() {
        let pattern = XGBrandPattern()
        _ = pattern
        #expect(true)
    }

    @Test("XGBrandPattern is a View")
    func xgBrandPattern_conformsToView() {
        let pattern: any View = XGBrandPattern()
        _ = pattern
        #expect(true)
    }
}
