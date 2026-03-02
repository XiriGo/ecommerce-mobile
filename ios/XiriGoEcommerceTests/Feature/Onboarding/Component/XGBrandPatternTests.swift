import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGBrandPatternTests

/// Logic-level tests for XGBrandPattern.
/// Verifies initialisation, View protocol conformance, and token values.
@Suite("XGBrandPattern Tests")
@MainActor
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

    // MARK: - Token Contract (DQ-33)

    @Test("brandPatternOpacity should be 0.06 per design token")
    func brandPatternOpacity_matchesToken() {
        #expect(XGColors.brandPatternOpacity == 0.06)
    }

    @Test("brandPatternOpacity should be positive")
    func brandPatternOpacity_isPositive() {
        #expect(XGColors.brandPatternOpacity > 0)
    }

    @Test("brandPatternOpacity should be at most 1")
    func brandPatternOpacity_isAtMostOne() {
        #expect(XGColors.brandPatternOpacity <= 1.0)
    }

    @Test("brandPatternOpacity should be subtle below 10 percent")
    func brandPatternOpacity_isSubtle() {
        #expect(XGColors.brandPatternOpacity < 0.10)
    }
}
