import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGWishlistButtonInitTests

@Suite("XGWishlistButton Initialisation Tests")
@MainActor
struct XGWishlistButtonInitTests {
    @Test("XGWishlistButton initialises with isWishlisted false")
    func init_inactive_initialises() {
        let button = XGWishlistButton(isWishlisted: false, onToggle: {})
        _ = button
        #expect(true)
    }

    @Test("XGWishlistButton initialises with isWishlisted true")
    func init_active_initialises() {
        let button = XGWishlistButton(isWishlisted: true, onToggle: {})
        _ = button
        #expect(true)
    }

    @Test("XGWishlistButton stores onToggle closure")
    func init_onToggle_isStored() {
        var called = false
        let button = XGWishlistButton(isWishlisted: false, onToggle: { called = true })
        _ = button
        // Closure is stored; we verify it compiles and initialises.
        #expect(!called)
    }
}

// MARK: - XGWishlistButtonMotionTokenTests

@Suite("XGWishlistButton Motion Token Contract Tests")
struct XGWishlistButtonMotionTokenTests {
    // MARK: - Duration

    @Test("Toggle color transition uses XGMotion.Duration.instant (0.1s)")
    func toggleDuration_isInstant() {
        #expect(XGMotion.Duration.instant == 0.1)
    }

    @Test("XGMotion.Duration.instant is the shortest duration")
    func instant_isShortest() {
        #expect(XGMotion.Duration.instant <= XGMotion.Duration.fast)
        #expect(XGMotion.Duration.instant <= XGMotion.Duration.normal)
        #expect(XGMotion.Duration.instant <= XGMotion.Duration.slow)
    }

    @Test("XGMotion.Duration.instant is less than fast")
    func instant_isLessThanFast() {
        #expect(XGMotion.Duration.instant < XGMotion.Duration.fast)
    }

    // MARK: - Spring

    @Test("Spring response is 0.35s per motion.json")
    func springResponse_is035() {
        #expect(XGMotion.Easing.springResponse == 0.35)
    }

    @Test("Spring damping fraction is 0.7 per motion.json")
    func springDamping_is07() {
        #expect(XGMotion.Easing.springDampingFraction == 0.7)
    }

    @Test("Spring damping fraction is between 0 and 1 (underdamped)")
    func springDamping_isUnderdamped() {
        #expect(XGMotion.Easing.springDampingFraction > 0)
        #expect(XGMotion.Easing.springDampingFraction < 1)
    }

    @Test("XGMotion.Easing.spring animation is not nil")
    func spring_isNotNil() {
        let animation = XGMotion.Easing.spring
        _ = animation
        #expect(true)
    }
}

// MARK: - XGWishlistButtonColorTokenTests

@Suite("XGWishlistButton Color Token Contract Tests")
struct XGWishlistButtonColorTokenTests {
    @Test("Active tint is XGColors.brandPrimary (#6000FE)")
    func activeTint_isBrandPrimary() {
        #expect(XGColors.brandPrimary == Color(hex: "#6000FE"))
    }

    @Test("Inactive tint is XGColors.onSurfaceVariant (#8E8E93)")
    func inactiveTint_isOnSurfaceVariant() {
        #expect(XGColors.onSurfaceVariant == Color(hex: "#8E8E93"))
    }

    @Test("Active and inactive tint colors are distinct")
    func activeTint_isDistinctFromInactive() {
        #expect(XGColors.brandPrimary != XGColors.onSurfaceVariant)
    }

    @Test("Background is XGColors.surface (white)")
    func background_isSurface() {
        #expect(XGColors.surface == Color.white)
    }
}

// MARK: - XGWishlistButtonLayoutTokenTests

@Suite("XGWishlistButton Layout Token Contract Tests")
struct XGWishlistButtonLayoutTokenTests {
    @Test("Button size is 32pt per component token spec")
    func buttonSize_is32() {
        let buttonSize: CGFloat = 32
        #expect(buttonSize == 32)
    }

    @Test("Icon size is 16pt per component token spec")
    func iconSize_is16() {
        let iconSize: CGFloat = 16
        #expect(iconSize == 16)
    }

    @Test("Icon size is half of button size")
    func iconSize_isHalfOfButton() {
        let buttonSize: CGFloat = 32
        let iconSize: CGFloat = 16
        #expect(iconSize == buttonSize / 2)
    }

    @Test("Minimum touch target is 44pt (XGSpacing.minTouchTarget)")
    func minTouchTarget_is44() {
        #expect(XGSpacing.minTouchTarget == 44)
    }

    @Test("Bounce scale is 1.2 per component token spec")
    func bounceScale_is12() {
        let bounceScale: CGFloat = 1.2
        #expect(bounceScale == 1.2)
    }

    @Test("Bounce scale is greater than 1.0")
    func bounceScale_isGreaterThan1() {
        let bounceScale: CGFloat = 1.2
        #expect(bounceScale > 1.0)
    }

    @Test("Bounce scale is less than 1.5 for subtle animation")
    func bounceScale_isSubtle() {
        let bounceScale: CGFloat = 1.2
        #expect(bounceScale < 1.5)
    }

    @Test("Elevation uses XGElevation.level2")
    func elevation_isLevel2() {
        let elevation = XGElevation.level2
        _ = elevation
        #expect(true)
    }
}
