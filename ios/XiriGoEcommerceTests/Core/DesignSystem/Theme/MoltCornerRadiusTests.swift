import Testing
@testable import XiriGoEcommerce

// MARK: - MoltCornerRadiusTests

@Suite("MoltCornerRadius Tests")
struct MoltCornerRadiusTests {
    @Test("None corner radius is zero")
    func test_none_value_isZero() {
        #expect(MoltCornerRadius.none == 0)
    }

    @Test("Small corner radius is 4 points")
    func test_small_value_is4() {
        #expect(MoltCornerRadius.small == 4)
    }

    @Test("Medium corner radius is 8 points")
    func test_medium_value_is8() {
        #expect(MoltCornerRadius.medium == 8)
    }

    @Test("Large corner radius is 12 points")
    func test_large_value_is12() {
        #expect(MoltCornerRadius.large == 12)
    }

    @Test("ExtraLarge corner radius is 16 points")
    func test_extraLarge_value_is16() {
        #expect(MoltCornerRadius.extraLarge == 16)
    }

    @Test("Full corner radius is 999 for pill/capsule shapes")
    func test_full_value_is999() {
        #expect(MoltCornerRadius.full == 999)
    }

    @Test("Corner radius values are in ascending order")
    func test_values_areAscending() {
        #expect(MoltCornerRadius.none < MoltCornerRadius.small)
        #expect(MoltCornerRadius.small < MoltCornerRadius.medium)
        #expect(MoltCornerRadius.medium < MoltCornerRadius.large)
        #expect(MoltCornerRadius.large < MoltCornerRadius.extraLarge)
        #expect(MoltCornerRadius.extraLarge < MoltCornerRadius.full)
    }
}
