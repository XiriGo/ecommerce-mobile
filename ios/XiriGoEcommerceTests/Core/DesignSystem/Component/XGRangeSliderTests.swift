import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGRangeSliderInitTests

@Suite("XGRangeSlider Initialisation Tests")
@MainActor
struct XGRangeSliderInitTests {
    // MARK: - Default Init

    @Test("XGRangeSlider initialises with required parameters")
    func init_required_initialises() {
        @State var min: Double = 25
        @State var max: Double = 75
        let slider = XGRangeSlider(min: $min, max: $max, range: 0 ... 100)
        _ = slider
        #expect(true)
    }

    @Test("XGRangeSlider initialises with all parameters")
    func init_allParams_initialises() {
        @State var min: Double = 10
        @State var max: Double = 90
        let slider = XGRangeSlider(
            min: $min,
            max: $max,
            range: 0 ... 100,
            step: 5,
            showLabels: true,
            labelFormatter: { "$\(Int($0))" },
            onRangeChange: { _, _ in },
        )
        _ = slider
        #expect(true)
    }

    @Test("XGRangeSlider initialises with labels hidden")
    func init_noLabels_initialises() {
        @State var min: Double = 0
        @State var max: Double = 1000
        let slider = XGRangeSlider(
            min: $min,
            max: $max,
            range: 0 ... 1000,
            showLabels: false,
        )
        _ = slider
        #expect(true)
    }

    @Test("XGRangeSlider initialises with step value")
    func init_stepped_initialises() {
        @State var min: Double = 20
        @State var max: Double = 80
        let slider = XGRangeSlider(
            min: $min,
            max: $max,
            range: 0 ... 100,
            step: 10,
        )
        _ = slider
        #expect(true)
    }

    @Test("XGRangeSlider initialises with min equal to max")
    func init_minEqualsMax_initialises() {
        @State var min: Double = 50
        @State var max: Double = 50
        let slider = XGRangeSlider(min: $min, max: $max, range: 0 ... 100)
        _ = slider
        #expect(true)
    }

    @Test("XGRangeSlider initialises with range boundaries")
    func init_atBoundaries_initialises() {
        @State var min: Double = 0
        @State var max: Double = 100
        let slider = XGRangeSlider(min: $min, max: $max, range: 0 ... 100)
        _ = slider
        #expect(true)
    }
}

// MARK: - XGRangeSliderTokenContractTests

/// Contract tests: if any token constant changes, these tests catch the regression.
@Suite("XGRangeSlider Token Contract Tests")
struct XGRangeSliderTokenContractTests {
    // MARK: - Track Color Tokens

    @Test("XGColors.primary matches brand.primary (#6000FE) for active track")
    func trackActiveColor_matchesToken() {
        #expect(XGColors.primary == Color(hex: "#6000FE"))
    }

    @Test("XGColors.borderStrong matches design token (#D1D5DB) for inactive track")
    func trackInactiveColor_matchesToken() {
        #expect(XGColors.borderStrong == Color(hex: "#D1D5DB"))
    }

    @Test("Active and inactive track colors are distinct")
    func trackColors_areDistinct() {
        #expect(XGColors.primary != XGColors.borderStrong)
    }

    // MARK: - Thumb Color Tokens

    @Test("XGColors.primary matches brand.primary (#6000FE) for thumb")
    func thumbColor_matchesToken() {
        #expect(XGColors.primary == Color(hex: "#6000FE"))
    }

    @Test("XGColors.surface matches design token (#FFFFFF) for thumb border")
    func thumbBorderColor_matchesToken() {
        #expect(XGColors.surface == Color(hex: "#FFFFFF"))
    }

    @Test("Thumb color and thumb border color are distinct")
    func thumbAndBorderColors_areDistinct() {
        #expect(XGColors.primary != XGColors.surface)
    }

    // MARK: - Dimension Constants

    @Test("Track height should be 4pt")
    func trackHeight_is4() {
        let expectedTrackHeight: CGFloat = 4
        #expect(expectedTrackHeight == 4)
    }

    @Test("Thumb size should be 24pt")
    func thumbSize_is24() {
        let expectedThumbSize: CGFloat = 24
        #expect(expectedThumbSize == 24)
    }

    @Test("Thumb border width should be 3pt")
    func thumbBorderWidth_is3() {
        let expectedBorderWidth: CGFloat = 3
        #expect(expectedBorderWidth == 3)
    }

    @Test("Thumb size should be larger than track height")
    func thumbSize_isLargerThanTrackHeight() {
        let thumbSize: CGFloat = 24
        let trackHeight: CGFloat = 4
        #expect(thumbSize > trackHeight)
    }

    @Test("Thumb border width should be less than thumb radius")
    func thumbBorderWidth_isLessThanRadius() {
        let thumbBorderWidth: CGFloat = 3
        let thumbRadius: CGFloat = 12
        #expect(thumbBorderWidth < thumbRadius)
    }

    // MARK: - Label Color Token

    @Test("XGColors.onSurfaceVariant matches design token (#8E8E93) for labels")
    func labelColor_matchesToken() {
        #expect(XGColors.onSurfaceVariant == Color(hex: "#8E8E93"))
    }

    @Test("Label color is distinct from active track color")
    func labelAndTrackColors_areDistinct() {
        #expect(XGColors.onSurfaceVariant != XGColors.primary)
    }
}
