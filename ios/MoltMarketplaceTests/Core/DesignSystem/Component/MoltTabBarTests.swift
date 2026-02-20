import SwiftUI
import Testing
@testable import MoltMarketplace

// MARK: - MoltTabItemTests

@Suite("MoltTabItem Tests")
struct MoltTabItemTests {
    @Test("TabItem stores id correctly")
    func test_init_id_storedCorrectly() {
        let item = MoltTabItem(id: 2, label: "Cart", icon: "cart", selectedIcon: "cart.fill")
        #expect(item.id == 2)
    }

    @Test("TabItem stores label correctly")
    func test_init_label_storedCorrectly() {
        let item = MoltTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill")
        #expect(item.label == "Home")
    }

    @Test("TabItem stores icon correctly")
    func test_init_icon_storedCorrectly() {
        let item = MoltTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill")
        #expect(item.icon == "house")
    }

    @Test("TabItem stores selectedIcon correctly")
    func test_init_selectedIcon_storedCorrectly() {
        let item = MoltTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill")
        #expect(item.selectedIcon == "house.fill")
    }

    @Test("TabItem has no badge count by default")
    func test_init_defaultBadgeCountIsNil() {
        let item = MoltTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill")
        #expect(item.badgeCount == nil)
    }

    @Test("TabItem stores badge count when provided")
    func test_init_withBadgeCount_storedCorrectly() {
        let item = MoltTabItem(
            id: 2,
            label: "Cart",
            icon: "cart",
            selectedIcon: "cart.fill",
            badgeCount: 3
        )
        #expect(item.badgeCount == 3)
    }

    @Test("TabItem with zero badge count stores zero")
    func test_init_zeroBadgeCount_storedAsZero() {
        let item = MoltTabItem(
            id: 0,
            label: "Home",
            icon: "house",
            selectedIcon: "house.fill",
            badgeCount: 0
        )
        #expect(item.badgeCount == 0)
    }
}

// MARK: - MoltTabBarTests

@Suite("MoltTabBar Tests")
struct MoltTabBarTests {
    @Test("TabBar initialises with items and selectedIndex binding")
    func test_init_withItemsAndBinding_initialises() {
        var selectedIndex = 0
        let binding = Binding(get: { selectedIndex }, set: { selectedIndex = $0 })
        let items = [
            MoltTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill"),
            MoltTabItem(id: 1, label: "Cart", icon: "cart", selectedIcon: "cart.fill"),
        ]
        let tabBar = MoltTabBar(items: items, selectedIndex: binding)
        _ = tabBar
        #expect(true)
    }

    @Test("Updating selectedIndex binding reflects new selection")
    func test_selectedIndex_binding_updatesValue() {
        var selectedIndex = 0
        let binding = Binding(get: { selectedIndex }, set: { selectedIndex = $0 })
        binding.wrappedValue = 2
        #expect(selectedIndex == 2)
    }

    @Test("TabBar initialises with single item")
    func test_init_withSingleItem_initialises() {
        var selectedIndex = 0
        let binding = Binding(get: { selectedIndex }, set: { selectedIndex = $0 })
        let items = [
            MoltTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill"),
        ]
        let tabBar = MoltTabBar(items: items, selectedIndex: binding)
        _ = tabBar
        #expect(true)
    }

    @Test("TabBar initialises with badge on item")
    func test_init_withBadgeOnItem_initialises() {
        var selectedIndex = 0
        let binding = Binding(get: { selectedIndex }, set: { selectedIndex = $0 })
        let items = [
            MoltTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill"),
            MoltTabItem(
                id: 1,
                label: "Cart",
                icon: "cart",
                selectedIcon: "cart.fill",
                badgeCount: 5
            ),
        ]
        let tabBar = MoltTabBar(items: items, selectedIndex: binding)
        _ = tabBar
        #expect(items[1].badgeCount == 5)
    }
}
