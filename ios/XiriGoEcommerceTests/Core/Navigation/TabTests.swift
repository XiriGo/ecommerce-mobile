import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - TabTests

@Suite("Tab Tests")
struct TabTests {
    // MARK: - CaseIterable

    @Test("Tab has exactly four cases")
    func allCases_count_isFour() {
        #expect(Tab.allCases.count == 4)
    }

    @Test("Tab cases are home, categories, cart, profile in order")
    func allCases_order_matchesSpec() {
        let cases = Tab.allCases
        #expect(cases[0] == .home)
        #expect(cases[1] == .categories)
        #expect(cases[2] == .cart)
        #expect(cases[3] == .profile)
    }

    // MARK: - Identifiable

    @Test("home tab id equals rawValue")
    func id_home_equalsRawValue() {
        #expect(Tab.home.id == Tab.home.rawValue)
    }

    @Test("categories tab id equals rawValue")
    func id_categories_equalsRawValue() {
        #expect(Tab.categories.id == Tab.categories.rawValue)
    }

    @Test("cart tab id equals rawValue")
    func id_cart_equalsRawValue() {
        #expect(Tab.cart.id == Tab.cart.rawValue)
    }

    @Test("profile tab id equals rawValue")
    func id_profile_equalsRawValue() {
        #expect(Tab.profile.id == Tab.profile.rawValue)
    }

    @Test("all tab ids are unique")
    func allCases_ids_areUnique() {
        let ids = Tab.allCases.map(\.id)
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }

    // MARK: - Indices (position in allCases)

    @Test("home tab is at index 0")
    func index_home_isZero() {
        #expect(Tab.allCases.firstIndex(of: .home) == 0)
    }

    @Test("categories tab is at index 1")
    func index_categories_isOne() {
        #expect(Tab.allCases.firstIndex(of: .categories) == 1)
    }

    @Test("cart tab is at index 2")
    func index_cart_isTwo() {
        #expect(Tab.allCases.firstIndex(of: .cart) == 2)
    }

    @Test("profile tab is at index 3")
    func index_profile_isThree() {
        #expect(Tab.allCases.firstIndex(of: .profile) == 3)
    }

    // MARK: - systemImage (unselected icons)

    @Test("home tab has correct unselected SF Symbol")
    func systemImage_home_isHouse() {
        #expect(Tab.home.systemImage == "house")
    }

    @Test("categories tab has correct unselected SF Symbol")
    func systemImage_categories_isSquareGrid() {
        #expect(Tab.categories.systemImage == "square.grid.2x2")
    }

    @Test("cart tab has correct unselected SF Symbol")
    func systemImage_cart_isCart() {
        #expect(Tab.cart.systemImage == "cart")
    }

    @Test("profile tab has correct unselected SF Symbol")
    func systemImage_profile_isPerson() {
        #expect(Tab.profile.systemImage == "person")
    }

    // MARK: - selectedSystemImage (selected/filled icons)

    @Test("home tab has correct selected SF Symbol")
    func selectedSystemImage_home_isHouseFill() {
        #expect(Tab.home.selectedSystemImage == "house.fill")
    }

    @Test("categories tab has correct selected SF Symbol")
    func selectedSystemImage_categories_isSquareGridFill() {
        #expect(Tab.categories.selectedSystemImage == "square.grid.2x2.fill")
    }

    @Test("cart tab has correct selected SF Symbol")
    func selectedSystemImage_cart_isCartFill() {
        #expect(Tab.cart.selectedSystemImage == "cart.fill")
    }

    @Test("profile tab has correct selected SF Symbol")
    func selectedSystemImage_profile_isPersonFill() {
        #expect(Tab.profile.selectedSystemImage == "person.fill")
    }

    // MARK: - Unselected and selected icons differ

    @Test("all tabs have different unselected and selected icons")
    func systemImages_allTabs_selectedDiffersFromUnselected() {
        for tab in Tab.allCases {
            #expect(
                tab.systemImage != tab.selectedSystemImage,
                "Tab \(tab) should have different unselected and selected icons",
            )
        }
    }

    // MARK: - title

    @Test("home tab title is non-empty")
    func title_home_isNonEmpty() {
        #expect(!Tab.home.title.isEmpty)
    }

    @Test("categories tab title is non-empty")
    func title_categories_isNonEmpty() {
        #expect(!Tab.categories.title.isEmpty)
    }

    @Test("cart tab title is non-empty")
    func title_cart_isNonEmpty() {
        #expect(!Tab.cart.title.isEmpty)
    }

    @Test("profile tab title is non-empty")
    func title_profile_isNonEmpty() {
        #expect(!Tab.profile.title.isEmpty)
    }

    @Test("all tabs have unique titles")
    func titles_allTabs_areUnique() {
        let titles = Tab.allCases.map(\.title)
        let uniqueTitles = Set(titles)
        #expect(titles.count == uniqueTitles.count)
    }

    // MARK: - Sendable conformance (compile-time)

    @Test("Tab is Sendable and can be used across concurrency boundaries")
    func sendable_allCases_canBePassedAcrossBoundaries() async {
        let tabs = Tab.allCases
        let result = await Task.detached {
            tabs.map(\.id)
        }.value
        #expect(result.count == 4)
    }
}
