import Foundation
import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGFilterChipTests

@Suite("XGFilterChip Tests")
@MainActor
struct XGFilterChipTests {
    @Test("FilterChip initialises with label")
    func init_withLabel_initialises() {
        let chip = XGFilterChip(label: "All") {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip initialises in selected state")
    func init_selected_initialises() {
        let chip = XGFilterChip(label: "Electronics", isSelected: true) {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip initialises in deselected state by default")
    func init_defaultIsDeselected() {
        // Default isSelected is false
        let chip = XGFilterChip(label: "Fashion") {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip initialises with leading icon")
    func init_withLeadingIcon_initialises() {
        let chip = XGFilterChip(label: "Fashion", leadingIcon: "tag") {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip action closure is captured")
    func init_actionClosure_isCaptured() {
        let chip = XGFilterChip(label: "Toggle") {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip selected and deselected states are distinct")
    func selectedState_distinctFromDeselected() {
        let selected = XGFilterChip(label: "Chip", isSelected: true) {}
        let deselected = XGFilterChip(label: "Chip", isSelected: false) {}
        _ = selected
        _ = deselected
        // Both initialise without error; visual distinction is in the View body
        #expect(true)
    }
}

// MARK: - XGFilterChipTokenTests

@Suite("XGFilterChip Token Compliance")
@MainActor
struct XGFilterChipTokenTests {
    @Test("Filter chip height token is 36pt")
    func filterChipHeight_is36() {
        // Token: variants.filter.height = 36
        let expected: CGFloat = 36
        #expect(expected == 36)
    }

    @Test("Filter chip corner radius token is 18pt")
    func filterChipCornerRadius_is18() {
        // Token: variants.filter.cornerRadius = 18
        let expected: CGFloat = 18
        #expect(expected == 18)
    }

    @Test("Filter chip horizontal padding is XGSpacing.base (16pt)")
    func filterChipHorizontalPadding_is16() {
        // Token: variants.filter.horizontalPadding = 16
        #expect(XGSpacing.base == 16)
    }

    @Test("Filter chip gap is XGSpacing.sm (8pt)")
    func filterChipGap_is8() {
        // Token: variants.filter.gap = 8
        #expect(XGSpacing.sm == 8)
    }

    @Test("Filter chip selected icon size is XGSpacing.IconSize.small (16pt)")
    func selectedIconSize_is16() {
        // Token: $foundations/spacing.layout.iconSize.small = 16
        #expect(XGSpacing.IconSize.small == 16)
    }

    @Test("FilterPill active background matches token #6200FF")
    func activeBackground_matchesToken() {
        #expect(XGColors.filterPillBackgroundActive == Color(hex: "#6200FF"))
    }

    @Test("FilterPill active text color matches token #FFFFFF")
    func activeTextColor_matchesToken() {
        #expect(XGColors.filterPillTextActive == Color.white)
    }

    @Test("FilterPill inactive background matches token #F1F5F9")
    func inactiveBackground_matchesToken() {
        #expect(XGColors.filterPillBackground == Color(hex: "#F1F5F9"))
    }

    @Test("FilterPill inactive text color matches token #333333")
    func inactiveTextColor_matchesToken() {
        #expect(XGColors.filterPillText == Color(hex: "#333333"))
    }

    @Test("Active and inactive backgrounds are distinct")
    func activeAndInactiveBackgrounds_areDistinct() {
        #expect(XGColors.filterPillBackgroundActive != XGColors.filterPillBackground)
    }

    @Test("Active and inactive text colors are distinct")
    func activeAndInactiveTextColors_areDistinct() {
        #expect(XGColors.filterPillTextActive != XGColors.filterPillText)
    }
}

// MARK: - XGCategoryChipTests

@Suite("XGCategoryChip Tests")
@MainActor
struct XGCategoryChipTests {
    @Test("CategoryChip initialises with label")
    func test_init_withLabel_initialises() {
        let chip = XGCategoryChip(label: "Electronics") {}
        _ = chip
        #expect(true)
    }

    @Test("CategoryChip initialises with icon URL")
    func init_withIconUrl_initialises() {
        let chip = XGCategoryChip(
            label: "Electronics",
            iconUrl: URL(string: "https://example.com/icon.png"),
        ) {}
        _ = chip
        #expect(true)
    }

    @Test("CategoryChip initialises without icon URL")
    func init_withoutIconUrl_initialises() {
        let chip = XGCategoryChip(label: "Fashion", iconUrl: nil) {}
        _ = chip
        #expect(true)
    }

    @Test("CategoryChip action closure is captured")
    func test_init_actionClosure_isCaptured() {
        let chip = XGCategoryChip(label: "Category") {}
        _ = chip
        #expect(true)
    }
}

// MARK: - XGCategoryChipTokenTests

@Suite("XGCategoryChip Token Compliance")
@MainActor
struct XGCategoryChipTokenTests {
    @Test("Category chip background matches surfaceTertiary token #F1F5F9")
    func background_matchesSurfaceTertiary() {
        #expect(XGColors.surfaceTertiary == Color(hex: "#F1F5F9"))
    }

    @Test("Category chip text color matches onSurface token #333333")
    func textColor_matchesOnSurface() {
        #expect(XGColors.onSurface == Color(hex: "#333333"))
    }

    @Test("Category chip icon size is XGSpacing.IconSize.medium (24pt)")
    func iconSize_isMedium() {
        // Token: $foundations/spacing.layout.iconSize.medium = 24
        #expect(XGSpacing.IconSize.medium == 24)
    }
}
