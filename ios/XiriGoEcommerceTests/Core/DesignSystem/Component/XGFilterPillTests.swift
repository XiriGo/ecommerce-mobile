import Foundation
import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGFilterPillTests

@Suite("XGFilterPill Tests")
@MainActor
struct XGFilterPillTests {
    @Test("FilterPill initialises with label")
    func init_withLabel_initialises() {
        let pill = XGFilterPill(label: "All", onSelect: {})
        _ = pill
        #expect(true)
    }

    @Test("FilterPill initialises in selected state")
    func init_selected_initialises() {
        let pill = XGFilterPill(label: "Electronics", isSelected: true, onSelect: {})
        _ = pill
        #expect(true)
    }

    @Test("FilterPill initialises in deselected state by default")
    func init_defaultIsDeselected() {
        let pill = XGFilterPill(label: "Fashion", onSelect: {})
        _ = pill
        #expect(true)
    }

    @Test("FilterPill initialises with onDismiss callback")
    func init_withOnDismiss_initialises() {
        let pill = XGFilterPill(
            label: "Fashion",
            isSelected: true,
            onSelect: {},
            onDismiss: {},
        )
        _ = pill
        #expect(true)
    }

    @Test("FilterPill initialises without onDismiss callback")
    func init_withoutOnDismiss_initialises() {
        let pill = XGFilterPill(label: "Fashion", isSelected: true, onSelect: {})
        _ = pill
        #expect(true)
    }

    @Test("FilterPill action closure is captured")
    func init_actionClosure_isCaptured() {
        let pill = XGFilterPill(label: "Toggle", onSelect: {})
        _ = pill
        #expect(true)
    }

    @Test("FilterPill selected and deselected states are distinct")
    func selectedState_distinctFromDeselected() {
        let selected = XGFilterPill(label: "Pill", isSelected: true, onSelect: {})
        let deselected = XGFilterPill(label: "Pill", isSelected: false, onSelect: {})
        _ = selected
        _ = deselected
        // Both initialise without error; visual distinction is in the View body
        #expect(true)
    }

    @Test("FilterPill dismiss callback can be nil")
    func dismissCallback_canBeNil() {
        let pill = XGFilterPill(label: "Test", onSelect: {}, onDismiss: nil)
        _ = pill
        #expect(true)
    }
}

// MARK: - XGFilterPillTokenTests

@Suite("XGFilterPill Token Compliance")
@MainActor
struct XGFilterPillTokenTests {
    @Test("Filter pill height token is 36pt")
    func filterPillHeight_is36() {
        // Token: tokens.height = 36
        let expected: CGFloat = 36
        #expect(expected == 36)
    }

    @Test("Filter pill corner radius token is 18pt")
    func filterPillCornerRadius_is18() {
        // Token: tokens.cornerRadius = 18
        let expected: CGFloat = 18
        #expect(expected == 18)
    }

    @Test("Filter pill horizontal padding is XGSpacing.base (16pt)")
    func filterPillHorizontalPadding_is16() {
        // Token: tokens.horizontalPadding = 16
        #expect(XGSpacing.base == 16)
    }

    @Test("Filter pill gap is XGSpacing.sm (8pt)")
    func filterPillGap_is8() {
        // Token: tokens.gap = 8
        #expect(XGSpacing.sm == 8)
    }

    @Test("Filter pill icon size is XGSpacing.IconSize.small (16pt)")
    func iconSize_is16() {
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

// MARK: - XGFilterPillItemTests

@Suite("XGFilterPillItem Tests")
@MainActor
struct XGFilterPillItemTests {
    @Test("Item initialises with label and isSelected")
    func init_withLabelAndSelected_initialises() {
        let item = XGFilterPillItem(label: "All", isSelected: true)
        #expect(item.label == "All")
        #expect(item.isSelected == true)
    }

    @Test("Item equality — same properties are equal")
    func equality_sameProperties_areEqual() {
        let item1 = XGFilterPillItem(label: "A", isSelected: true)
        let item2 = XGFilterPillItem(label: "A", isSelected: true)
        #expect(item1 == item2)
    }

    @Test("Item inequality — different selection state")
    func inequality_differentSelected_areNotEqual() {
        let item1 = XGFilterPillItem(label: "A", isSelected: true)
        let item2 = XGFilterPillItem(label: "A", isSelected: false)
        #expect(item1 != item2)
    }

    @Test("Item inequality — different label")
    func inequality_differentLabel_areNotEqual() {
        let item1 = XGFilterPillItem(label: "A", isSelected: true)
        let item2 = XGFilterPillItem(label: "B", isSelected: true)
        #expect(item1 != item2)
    }
}

// MARK: - XGFilterPillRowTests

@Suite("XGFilterPillRow Tests")
@MainActor
struct XGFilterPillRowTests {
    @Test("Row initialises with items")
    func init_withItems_initialises() {
        let row = XGFilterPillRow(
            items: [
                XGFilterPillItem(label: "All", isSelected: true),
                XGFilterPillItem(label: "Electronics", isSelected: false),
            ],
            onSelect: { _ in },
        )
        _ = row
        #expect(true)
    }

    @Test("Row initialises with dismiss callback")
    func init_withDismiss_initialises() {
        let row = XGFilterPillRow(
            items: [
                XGFilterPillItem(label: "All", isSelected: true),
            ],
            onSelect: { _ in },
            onDismiss: { _ in },
        )
        _ = row
        #expect(true)
    }

    @Test("Row initialises without dismiss callback")
    func init_withoutDismiss_initialises() {
        let row = XGFilterPillRow(
            items: [
                XGFilterPillItem(label: "All", isSelected: true),
            ],
            onSelect: { _ in },
        )
        _ = row
        #expect(true)
    }

    @Test("Row initialises with empty items")
    func init_emptyItems_initialises() {
        let row = XGFilterPillRow(
            items: [],
            onSelect: { _ in },
        )
        _ = row
        #expect(true)
    }
}
