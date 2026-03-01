import Testing
@testable import XiriGoEcommerce

// MARK: - XGCornerRadiusTests

@Suite("XGCornerRadius Tests")
struct XGCornerRadiusTests {
    @Test("None corner radius is zero")
    func none_value_isZero() {
        #expect(XGCornerRadius.none == 0)
    }

    @Test("Small corner radius is 6 points")
    func small_value_is6() {
        #expect(XGCornerRadius.small == 6)
    }

    @Test("Medium corner radius is 10 points")
    func medium_value_is10() {
        #expect(XGCornerRadius.medium == 10)
    }

    @Test("Large corner radius is 16 points")
    func large_value_is16() {
        #expect(XGCornerRadius.large == 16)
    }

    @Test("Pill corner radius is 28 points")
    func pill_value_is28() {
        #expect(XGCornerRadius.pill == 28)
    }

    @Test("Toggle corner radius is 22 points")
    func toggle_value_is22() {
        #expect(XGCornerRadius.toggle == 22)
    }

    @Test("Full corner radius is 999 for circle shapes")
    func full_value_is999() {
        #expect(XGCornerRadius.full == 999)
    }

    @Test("Corner radius values are in ascending order")
    func values_areAscending() {
        #expect(XGCornerRadius.none < XGCornerRadius.small)
        #expect(XGCornerRadius.small < XGCornerRadius.medium)
        #expect(XGCornerRadius.medium < XGCornerRadius.large)
        #expect(XGCornerRadius.large < XGCornerRadius.toggle)
        #expect(XGCornerRadius.toggle < XGCornerRadius.pill)
        #expect(XGCornerRadius.pill < XGCornerRadius.full)
    }
}
