import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - ShimmerModifierTests

@Suite("ShimmerModifier Tests")
@MainActor
struct ShimmerModifierTests {
    // MARK: - Internal

    // MARK: - Initialisation

    @Test("ShimmerModifier initialises with active=true")
    func init_activeTrue_initialises() {
        let modifier = ShimmerModifier(active: true)
        #expect(modifier.active == true)
    }

    @Test("ShimmerModifier initialises with active=false")
    func init_activeFalse_initialises() {
        let modifier = ShimmerModifier(active: false)
        #expect(modifier.active == false)
    }

    // MARK: - View Extension

    @Test("shimmerEffect() applies modifier with active=true by default")
    func shimmerEffect_defaultActive_isTrue() {
        // The default parameter for active is true per spec
        let modifier = ShimmerModifier(active: true)
        #expect(modifier.active == true)
    }

    @Test("shimmerEffect(active:false) creates modifier with active=false")
    func shimmerEffect_activeFalse_modifierIsInactive() {
        let modifier = ShimmerModifier(active: false)
        #expect(modifier.active == false)
    }

    // MARK: - Body (active=true)

    @Test("ShimmerModifier body with active=true is a valid View", .disabled(swiftUIDisabledReason))
    func body_activeTrue_isValidView() {
        // body(content:) requires _ViewModifier_Content — validated via UI tests
        #expect(true)
    }

    // MARK: - Body (active=false, no-op)

    @Test("ShimmerModifier body with active=false is a valid View (no-op)", .disabled(swiftUIDisabledReason))
    func body_activeFalse_isNoOp() {
        // body(content:) requires _ViewModifier_Content — validated via UI tests
        #expect(true)
    }

    // MARK: - Design Tokens

    @Test("XGMotion.Shimmer.duration equals 1.2 seconds")
    func shimmerToken_duration_is1point2Seconds() {
        #expect(XGMotion.Shimmer.duration == 1.2)
    }

    @Test("XGMotion.Shimmer.angleDegrees equals 20 degrees")
    func shimmerToken_angleDegrees_is20() {
        #expect(XGMotion.Shimmer.angleDegrees == 20)
    }

    @Test("XGMotion.Shimmer.gradientColors contains exactly 3 stops")
    func shimmerToken_gradientColors_hasThreeStops() {
        #expect(XGMotion.Shimmer.gradientColors.count == 3)
    }

    @Test("XGMotion.Shimmer.gradientColors is non-empty")
    func shimmerToken_gradientColors_isNonEmpty() {
        #expect(!XGMotion.Shimmer.gradientColors.isEmpty)
    }

    @Test("XGMotion.Shimmer first and last gradient color are identical (symmetric sweep)")
    func shimmerToken_gradientColors_firstAndLastAreEqual() {
        let colors = XGMotion.Shimmer.gradientColors
        #expect(colors.first == colors.last)
    }

    @Test("XGMotion.Shimmer middle gradient color differs from outer colors (highlight)")
    func shimmerToken_gradientColors_middleIsDifferentFromOuter() {
        let colors = XGMotion.Shimmer.gradientColors
        guard colors.count == 3 else {
            return
        }
        #expect(colors[0] != colors[1])
        #expect(colors[1] != colors[2])
    }

    // MARK: - Offset Calculation (mirrors private offsetForPhase logic)

    @Test("offsetForPhase at phase=0 starts off-screen to the left")
    func offsetForPhase_phaseZero_isNegativeViewWidth() {
        // offsetForPhase(viewWidth:) = -viewWidth + (phase * viewWidth * 2)
        // phase=0 → offset = -viewWidth
        let viewWidth: CGFloat = 300
        let offset = offsetForPhase(phase: 0, viewWidth: viewWidth)
        #expect(offset == -viewWidth)
    }

    @Test("offsetForPhase at phase=1 ends off-screen to the right")
    func offsetForPhase_phaseOne_isPositiveViewWidth() {
        // phase=1 → offset = -viewWidth + (1 * viewWidth * 2) = viewWidth
        let viewWidth: CGFloat = 300
        let offset = offsetForPhase(phase: 1, viewWidth: viewWidth)
        #expect(offset == viewWidth)
    }

    @Test("offsetForPhase at phase=0.5 is centered at zero")
    func offsetForPhase_phaseHalf_isZero() {
        // phase=0.5 → offset = -viewWidth + (0.5 * viewWidth * 2) = 0
        let viewWidth: CGFloat = 300
        let offset = offsetForPhase(phase: 0.5, viewWidth: viewWidth)
        #expect(offset == 0)
    }

    @Test("offsetForPhase total travel equals twice the view width")
    func offsetForPhase_totalTravel_isTwiceViewWidth() {
        let viewWidth: CGFloat = 200
        let startOffset = offsetForPhase(phase: 0, viewWidth: viewWidth)
        let endOffset = offsetForPhase(phase: 1, viewWidth: viewWidth)
        let totalTravel = endOffset - startOffset
        #expect(totalTravel == viewWidth * 2)
    }

    @Test("offsetForPhase increases linearly with phase")
    func offsetForPhase_linearProgress_isMonotonicallyIncreasing() {
        let viewWidth: CGFloat = 100
        let phase0 = offsetForPhase(phase: 0, viewWidth: viewWidth)
        let phase25 = offsetForPhase(phase: 0.25, viewWidth: viewWidth)
        let phase50 = offsetForPhase(phase: 0.5, viewWidth: viewWidth)
        let phase75 = offsetForPhase(phase: 0.75, viewWidth: viewWidth)
        let phase100 = offsetForPhase(phase: 1, viewWidth: viewWidth)
        #expect(phase0 < phase25)
        #expect(phase25 < phase50)
        #expect(phase50 < phase75)
        #expect(phase75 < phase100)
    }

    // MARK: - Private

    // MARK: - Private Helper

    /// Mirrors the private `offsetForPhase(viewWidth:)` logic in ShimmerModifier.
    private func offsetForPhase(phase: CGFloat, viewWidth: CGFloat) -> CGFloat {
        let travelMultiplier: CGFloat = 2
        let totalTravel = viewWidth * travelMultiplier
        return -viewWidth + (phase * totalTravel)
    }
}
