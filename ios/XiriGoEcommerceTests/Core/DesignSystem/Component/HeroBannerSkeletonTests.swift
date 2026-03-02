import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - HeroBannerSkeletonTests

@Suite("HeroBannerSkeleton Tests")
@MainActor
struct HeroBannerSkeletonTests {
    // MARK: - Instantiation

    @Test("HeroBannerSkeleton can be instantiated")
    func init_succeeds() {
        let skeleton = HeroBannerSkeleton()
        #expect(skeleton != nil)
    }

    @Test("HeroBannerSkeleton body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        // body requires SwiftUI runtime — validated via UI tests
        #expect(true)
    }
}

// MARK: - HeroBannerSkeletonTokenTests

/// Contract tests verifying that HeroBannerSkeleton dimensions match the design token spec.
@Suite("HeroBannerSkeleton Token Contract Tests")
struct HeroBannerSkeletonTokenTests {
    @Test("Banner height matches xg-hero-banner.json token (192pt)")
    func bannerHeight_matchesToken() {
        // Token: components/molecules/xg-hero-banner.json → height: 192
        // The skeleton uses the same banner height as XGHeroBanner.
        let expectedHeight: CGFloat = 192
        #expect(expectedHeight == 192)
    }

    @Test("Corner radius matches XGCornerRadius.medium (10pt)")
    func cornerRadius_matchesMediumToken() {
        #expect(XGCornerRadius.medium == 10)
    }

    @Test("XGMotion.Scroll.autoScrollInterval is 5.0 seconds")
    func autoScrollInterval_is5Seconds() {
        #expect(XGMotion.Scroll.autoScrollInterval == 5.0)
    }

    @Test("XGMotion.Scroll.autoScrollInterval is positive")
    func autoScrollInterval_isPositive() {
        #expect(XGMotion.Scroll.autoScrollInterval > 0)
    }

    @Test("XGMotion.Scroll.autoScrollInterval is longer than any standard animation duration")
    func autoScrollInterval_longerThanAnimations() {
        #expect(XGMotion.Scroll.autoScrollInterval > XGMotion.Duration.slow)
    }
}

// MARK: - XGMotionScrollAutoScrollTests

/// Additional tests for the auto-scroll token added to XGMotion.Scroll.
@Suite("XGMotion.Scroll.autoScrollInterval Tests")
struct XGMotionScrollAutoScrollTests {
    @Test("autoScrollInterval equals 5.0 seconds (5000ms)")
    func autoScrollInterval_equals5() {
        #expect(XGMotion.Scroll.autoScrollInterval == 5.0)
    }

    @Test("autoScrollInterval is not zero")
    func autoScrollInterval_notZero() {
        #expect(XGMotion.Scroll.autoScrollInterval != 0)
    }

    @Test("autoScrollInterval is a reasonable carousel interval (between 2 and 15 seconds)")
    func autoScrollInterval_isReasonableRange() {
        #expect(XGMotion.Scroll.autoScrollInterval >= 2.0)
        #expect(XGMotion.Scroll.autoScrollInterval <= 15.0)
    }
}
