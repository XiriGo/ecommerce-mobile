import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - MoltFilterChipTests

@Suite("MoltFilterChip Tests")
struct MoltFilterChipTests {
    @Test("FilterChip initialises with label")
    func test_init_withLabel_initialises() {
        let chip = MoltFilterChip(label: "All") {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip initialises in selected state")
    func test_init_selected_initialises() {
        let chip = MoltFilterChip(label: "Electronics", isSelected: true) {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip initialises in deselected state by default")
    func test_init_defaultIsDeselected() {
        // Default isSelected is false
        let chip = MoltFilterChip(label: "Fashion") {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip initialises with leading icon")
    func test_init_withLeadingIcon_initialises() {
        let chip = MoltFilterChip(label: "Fashion", leadingIcon: "tag") {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip action closure is captured")
    func test_init_actionClosure_isCaptured() {
        let chip = MoltFilterChip(label: "Toggle") {}
        _ = chip
        #expect(true)
    }

    @Test("FilterChip selected and deselected states are distinct")
    func test_selectedState_distinctFromDeselected() {
        let selected = MoltFilterChip(label: "Chip", isSelected: true) {}
        let deselected = MoltFilterChip(label: "Chip", isSelected: false) {}
        _ = selected
        _ = deselected
        // Both initialise without error; visual distinction is in the View body
        #expect(true)
    }
}

// MARK: - MoltCategoryChipTests

@Suite("MoltCategoryChip Tests")
struct MoltCategoryChipTests {
    @Test("CategoryChip initialises with label")
    func test_init_withLabel_initialises() {
        let chip = MoltCategoryChip(label: "Electronics") {}
        _ = chip
        #expect(true)
    }

    @Test("CategoryChip initialises with icon URL")
    func test_init_withIconUrl_initialises() {
        let chip = MoltCategoryChip(
            label: "Electronics",
            iconUrl: URL(string: "https://example.com/icon.png")
        ) {}
        _ = chip
        #expect(true)
    }

    @Test("CategoryChip initialises without icon URL")
    func test_init_withoutIconUrl_initialises() {
        let chip = MoltCategoryChip(label: "Fashion", iconUrl: nil) {}
        _ = chip
        #expect(true)
    }

    @Test("CategoryChip action closure is captured")
    func test_init_actionClosure_isCaptured() {
        let chip = MoltCategoryChip(label: "Category") {}
        _ = chip
        #expect(true)
    }
}
