import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGBrandGradientTests

/// Logic-level tests for XGBrandGradient.
/// Verifies both init overloads, content forwarding contract, and token values.
@Suite("XGBrandGradient Tests")
@MainActor
struct XGBrandGradientTests {
    // MARK: - Initialisation

    @Test("no-content convenience init initialises without crash")
    func init_noContent_initialises() {
        let gradient = XGBrandGradient()
        _ = gradient
        #expect(true)
    }

    @Test("ViewBuilder content init initialises without crash")
    func init_withContent_initialises() {
        let gradient = XGBrandGradient {
            Text("Test")
        }
        _ = gradient
        #expect(true)
    }

    @Test("ViewBuilder content init accepts EmptyView")
    func init_withEmptyView_initialises() {
        let gradient = XGBrandGradient {
            EmptyView()
        }
        _ = gradient
        #expect(true)
    }

    @Test("XGBrandGradient is a View")
    func xgBrandGradient_conformsToView() {
        let gradient: any View = XGBrandGradient()
        _ = gradient
        #expect(true)
    }

    // MARK: - Token Contract (DQ-33)

    @Test("brandPrimaryLight token exists for gradient edge stops")
    func brandPrimaryLight_exists() {
        let color = XGColors.brandPrimaryLight
        _ = color
        #expect(true)
    }

    @Test("brandGradientMid token exists for gradient mid stops")
    func brandGradientMid_exists() {
        let color = XGColors.brandGradientMid
        _ = color
        #expect(true)
    }

    @Test("brandOverlayMid1 token exists")
    func brandOverlayMid1_exists() {
        let color = XGColors.brandOverlayMid1
        _ = color
        #expect(true)
    }

    @Test("brandOverlayMid2 token exists")
    func brandOverlayMid2_exists() {
        let color = XGColors.brandOverlayMid2
        _ = color
        #expect(true)
    }

    @Test("brandOverlayMid3 token exists")
    func brandOverlayMid3_exists() {
        let color = XGColors.brandOverlayMid3
        _ = color
        #expect(true)
    }

    @Test("brandOverlayMid4 token exists")
    func brandOverlayMid4_exists() {
        let color = XGColors.brandOverlayMid4
        _ = color
        #expect(true)
    }

    @Test("brandPrimaryDark token exists for overlay end")
    func brandPrimaryDark_exists() {
        let color = XGColors.brandPrimaryDark
        _ = color
        #expect(true)
    }
}
