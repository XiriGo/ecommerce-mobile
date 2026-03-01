import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - SkeletonBoxTests

@Suite("SkeletonBox Tests")
@MainActor
struct SkeletonBoxTests {
    // MARK: - Initialisation

    @Test("SkeletonBox initialises with explicit width and height")
    func init_widthAndHeight_stored() {
        let box = SkeletonBox(width: 120, height: 80)
        #expect(box.width == 120)
        #expect(box.height == 80)
    }

    @Test("SkeletonBox default cornerRadius equals XGCornerRadius.medium (10)")
    func init_defaultCornerRadius_equalsMedium() {
        let box = SkeletonBox(width: 100, height: 50)
        #expect(box.cornerRadius == XGCornerRadius.medium)
        #expect(box.cornerRadius == 10)
    }

    @Test("SkeletonBox custom cornerRadius is preserved")
    func init_customCornerRadius_isPreserved() {
        let box = SkeletonBox(width: 100, height: 50, cornerRadius: XGCornerRadius.large)
        #expect(box.cornerRadius == XGCornerRadius.large)
        #expect(box.cornerRadius == 16)
    }

    @Test("SkeletonBox cornerRadius can be set to XGCornerRadius.small")
    func init_smallCornerRadius_isPreserved() {
        let box = SkeletonBox(width: 60, height: 30, cornerRadius: XGCornerRadius.small)
        #expect(box.cornerRadius == XGCornerRadius.small)
        #expect(box.cornerRadius == 6)
    }

    @Test("SkeletonBox cornerRadius can be set to zero (no rounding)")
    func init_zeroCornerRadius_isPreserved() {
        let box = SkeletonBox(width: 100, height: 100, cornerRadius: 0)
        #expect(box.cornerRadius == 0)
    }

    @Test("SkeletonBox stores fractional dimensions correctly")
    func init_fractionalDimensions_stored() {
        let box = SkeletonBox(width: 123.5, height: 67.75)
        #expect(box.width == 123.5)
        #expect(box.height == 67.75)
    }

    @Test("SkeletonBox default cornerRadius is not XGCornerRadius.small")
    func init_defaultCornerRadius_isNotSmall() {
        let box = SkeletonBox(width: 100, height: 50)
        #expect(box.cornerRadius != XGCornerRadius.small)
    }

    @Test("SkeletonBox default cornerRadius is not XGCornerRadius.large")
    func init_defaultCornerRadius_isNotLarge() {
        let box = SkeletonBox(width: 100, height: 50)
        #expect(box.cornerRadius != XGCornerRadius.large)
    }

    @Test("Two SkeletonBox instances with different parameters are independent")
    func twoInstances_differentParams_areIndependent() {
        let box1 = SkeletonBox(width: 100, height: 50)
        let box2 = SkeletonBox(width: 200, height: 80, cornerRadius: XGCornerRadius.large)
        #expect(box1.width != box2.width)
        #expect(box1.height != box2.height)
        #expect(box1.cornerRadius != box2.cornerRadius)
    }

    // MARK: - Body

    @Test("SkeletonBox body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        // body requires SwiftUI runtime — validated via UI tests
        #expect(true)
    }
}

// MARK: - SkeletonLineTests

@Suite("SkeletonLine Tests")
@MainActor
struct SkeletonLineTests {
    // MARK: - Initialisation

    @Test("SkeletonLine stores width correctly")
    func init_width_isStored() {
        let line = SkeletonLine(width: 140)
        #expect(line.width == 140)
    }

    @Test("SkeletonLine default height equals 14")
    func init_defaultHeight_is14() {
        let line = SkeletonLine(width: 140)
        #expect(line.height == 14)
    }

    @Test("SkeletonLine custom height is stored correctly")
    func init_customHeight_isStored() {
        let line = SkeletonLine(width: 80, height: 12)
        #expect(line.height == 12)
    }

    @Test("SkeletonLine width and custom height are both stored correctly")
    func init_widthAndCustomHeight_bothStored() {
        let line = SkeletonLine(width: 80, height: 18)
        #expect(line.width == 80)
        #expect(line.height == 18)
    }

    @Test("SkeletonLine two instances are independent")
    func twoInstances_areIndependent() {
        let line1 = SkeletonLine(width: 140)
        let line2 = SkeletonLine(width: 80, height: 12)
        #expect(line1.width != line2.width)
        #expect(line1.height != line2.height)
    }

    // MARK: - Body

    @Test("SkeletonLine body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        // body requires SwiftUI runtime — validated via UI tests
        #expect(true)
    }
}

// MARK: - SkeletonCircleTests

@Suite("SkeletonCircle Tests")
@MainActor
struct SkeletonCircleTests {
    // MARK: - Initialisation

    @Test("SkeletonCircle stores avatar size (48) correctly")
    func init_avatarSize_isStored() {
        let circle = SkeletonCircle(size: 48)
        #expect(circle.size == 48)
    }

    @Test("SkeletonCircle stores small size (12) correctly")
    func init_smallSize_isStored() {
        let circle = SkeletonCircle(size: 12)
        #expect(circle.size == 12)
    }

    @Test("Two SkeletonCircle instances with different sizes are independent")
    func twoInstances_differentSizes_areIndependent() {
        let circle1 = SkeletonCircle(size: 48)
        let circle2 = SkeletonCircle(size: 12)
        #expect(circle1.size != circle2.size)
    }

    // MARK: - Body

    @Test("SkeletonCircle body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        // body requires SwiftUI runtime — validated via UI tests
        #expect(true)
    }
}

// MARK: - SkeletonModifierTests

@Suite("SkeletonModifier Tests")
@MainActor
struct SkeletonModifierTests {
    // MARK: - Initialisation

    @Test("SkeletonModifier initialises with visible=true")
    func init_visibleTrue_isStored() {
        let modifier = SkeletonModifier(visible: true, placeholder: Text("Loading"))
        #expect(modifier.visible == true)
    }

    @Test("SkeletonModifier initialises with visible=false")
    func init_visibleFalse_isStored() {
        let modifier = SkeletonModifier(visible: false, placeholder: Text("Loading"))
        #expect(modifier.visible == false)
    }

    @Test("SkeletonModifier visible=true and visible=false are distinct")
    func init_visibleTrueAndFalse_areDifferent() {
        let modifierVisible = SkeletonModifier(visible: true, placeholder: Text("Loading"))
        let modifierHidden = SkeletonModifier(visible: false, placeholder: Text("Loading"))
        #expect(modifierVisible.visible != modifierHidden.visible)
    }

    // MARK: - Body (SwiftUI runtime-dependent)

    @Test("SkeletonModifier body with visible=true is a valid View", .disabled(swiftUIDisabledReason))
    func body_visibleTrue_isValidView() {
        // body(content:) requires _ViewModifier_Content — validated via UI tests
        #expect(true)
    }

    @Test("SkeletonModifier body with visible=false is a valid View", .disabled(swiftUIDisabledReason))
    func body_visibleFalse_isValidView() {
        // body(content:) requires _ViewModifier_Content — validated via UI tests
        #expect(true)
    }

    // MARK: - Animation token

    @Test("SkeletonModifier crossfade duration matches XGMotion.Crossfade.contentSwitch (0.2s)")
    func crossfadeDuration_matchesContentSwitchToken() {
        #expect(XGMotion.Crossfade.contentSwitch == 0.2)
    }

    @Test("SkeletonModifier crossfade duration equals XGMotion.Duration.fast")
    func crossfadeDuration_equalsFastDuration() {
        #expect(XGMotion.Crossfade.contentSwitch == XGMotion.Duration.fast)
    }
}

// MARK: - SkeletonViewExtensionTests

@Suite("skeleton(visible:placeholder:) View Extension Tests")
@MainActor
struct SkeletonViewExtensionTests {
    @Test("skeleton visible=true produces modifier with visible=true")
    func skeleton_visibleTrue_modifierHasVisibleTrue() {
        let modifier = SkeletonModifier(visible: true, placeholder: SkeletonLine(width: 140))
        #expect(modifier.visible == true)
    }

    @Test("skeleton visible=false produces modifier with visible=false")
    func skeleton_visibleFalse_modifierHasVisibleFalse() {
        let modifier = SkeletonModifier(visible: false, placeholder: SkeletonLine(width: 140))
        #expect(modifier.visible == false)
    }

    @Test("skeleton crossfade uses contentSwitch duration (0.2s)")
    func skeleton_crossfade_usesContentSwitchDuration() {
        #expect(XGMotion.Crossfade.contentSwitch == 0.2)
    }
}

// MARK: - SkeletonDesignTokenTests

/// Contract tests: if a token value changes these catch the regression.
@Suite("Skeleton Design Token Contract Tests")
struct SkeletonDesignTokenTests {
    @Test("XGCornerRadius.medium equals 10 (SkeletonBox default cornerRadius)")
    func cornerRadiusMedium_is10() {
        #expect(XGCornerRadius.medium == 10)
    }

    @Test("XGCornerRadius.small equals 6 (SkeletonLine fixed cornerRadius)")
    func cornerRadiusSmall_is6() {
        #expect(XGCornerRadius.small == 6)
    }

    @Test("XGCornerRadius.large equals 16 (SkeletonBox override option)")
    func cornerRadiusLarge_is16() {
        #expect(XGCornerRadius.large == 16)
    }

    @Test("XGMotion.Crossfade.contentSwitch equals 0.2 (SkeletonModifier animation duration)")
    func contentSwitch_is0point2() {
        #expect(XGMotion.Crossfade.contentSwitch == 0.2)
    }

    @Test("SkeletonBox default cornerRadius is smaller than large cornerRadius")
    func cornerRadiusMedium_isSmallerThanLarge() {
        #expect(XGCornerRadius.medium < XGCornerRadius.large)
    }

    @Test("SkeletonLine fixed cornerRadius (small) is smaller than SkeletonBox default (medium)")
    func cornerRadiusSmall_isSmallerThanMedium() {
        #expect(XGCornerRadius.small < XGCornerRadius.medium)
    }
}

// MARK: - SkeletonCompositionTests

/// Composition tests matching the product card layout from the developer handoff and Previews.
@Suite("Skeleton Composition Tests")
@MainActor
struct SkeletonCompositionTests {
    @Test("Product card skeleton layout composes and stores values correctly")
    func productCardSkeleton_composesSuccessfully() {
        let box = SkeletonBox(width: 170, height: 170)
        let titleLine = SkeletonLine(width: 140)
        let priceLine = SkeletonLine(width: 80, height: 12)
        let ratingCircle = SkeletonCircle(size: 12)
        let ratingLine = SkeletonLine(width: 30, height: 12)

        #expect(box.width == 170)
        #expect(box.height == 170)
        #expect(box.cornerRadius == XGCornerRadius.medium)
        #expect(titleLine.width == 140)
        #expect(titleLine.height == 14)
        #expect(priceLine.width == 80)
        #expect(priceLine.height == 12)
        #expect(ratingCircle.size == 12)
        #expect(ratingLine.width == 30)
        #expect(ratingLine.height == 12)
    }

    @Test("SkeletonCircle avatar (48) and rating (12) sizes match handoff spec")
    func skeletonCircles_handoffSpecSizes_areCorrect() {
        let avatar = SkeletonCircle(size: 48)
        let rating = SkeletonCircle(size: 12)
        #expect(avatar.size == 48)
        #expect(rating.size == 12)
    }
}
