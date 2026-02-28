import Testing
@testable import XiriGoEcommerce

// MARK: - XGCornerRadiusTests

@Suite("XGCornerRadius Tests")
struct XGCornerRadiusTests {
    @Test("None corner radius is zero")
    func none_value_isZero() {
        #expect(XGCornerRadius.none == 0)
    }

    @Test("Small corner radius is 4 points")
    func small_value_is4() {
        #expect(XGCornerRadius.small == 4)
    }

    @Test("Medium corner radius is 8 points")
    func medium_value_is8() {
        #expect(XGCornerRadius.medium == 8)
    }

    @Test("Large corner radius is 12 points")
    func large_value_is12() {
        #expect(XGCornerRadius.large == 12)
    }

    @Test("ExtraLarge corner radius is 16 points")
    func extraLarge_value_is16() {
        #expect(XGCornerRadius.extraLarge == 16)
    }

    @Test("Full corner radius is 999 for pill/capsule shapes")
    func full_value_is999() {
        #expect(XGCornerRadius.full == 999)
    }

    @Test("Corner radius values are in ascending order")
    func values_areAscending() {
        #expect(XGCornerRadius.none < XGCornerRadius.small)
        #expect(XGCornerRadius.small < XGCornerRadius.medium)
        #expect(XGCornerRadius.medium < XGCornerRadius.large)
        #expect(XGCornerRadius.large < XGCornerRadius.extraLarge)
        #expect(XGCornerRadius.extraLarge < XGCornerRadius.full)
    }
}
