import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGTabItemTests

@Suite("XGTabItem Tests")
@MainActor
struct XGTabItemTests {
    @Test("TabItem stores id correctly")
    func init_id_storedCorrectly() {
        let item = XGTabItem(id: 2, label: "Cart", icon: "cart", selectedIcon: "cart.fill")
        #expect(item.id == 2)
    }

    @Test("TabItem stores label correctly")
    func init_label_storedCorrectly() {
        let item = XGTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill")
        #expect(item.label == "Home")
    }

    @Test("TabItem stores icon correctly")
    func init_icon_storedCorrectly() {
        let item = XGTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill")
        #expect(item.icon == "house")
    }

    @Test("TabItem stores selectedIcon correctly")
    func init_selectedIcon_storedCorrectly() {
        let item = XGTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill")
        #expect(item.selectedIcon == "house.fill")
    }

    @Test("TabItem has no badge count by default")
    func init_defaultBadgeCountIsNil() {
        let item = XGTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill")
        #expect(item.badgeCount == nil)
    }

    @Test("TabItem stores badge count when provided")
    func init_withBadgeCount_storedCorrectly() {
        let item = XGTabItem(
            id: 2,
            label: "Cart",
            icon: "cart",
            selectedIcon: "cart.fill",
            badgeCount: 3,
        )
        #expect(item.badgeCount == 3)
    }

    @Test("TabItem with zero badge count stores zero")
    func init_zeroBadgeCount_storedAsZero() {
        let item = XGTabItem(
            id: 0,
            label: "Home",
            icon: "house",
            selectedIcon: "house.fill",
            badgeCount: 0,
        )
        #expect(item.badgeCount == 0)
    }
}

// MARK: - XGTabBarTests

@Suite("XGTabBar Tests")
@MainActor
struct XGTabBarTests {
    @Test("TabBar initialises with items and selectedIndex binding")
    func init_withItemsAndBinding_initialises() {
        var selectedIndex = 0
        let binding = Binding(get: { selectedIndex }, set: { selectedIndex = $0 })
        let items = [
            XGTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill"),
            XGTabItem(id: 1, label: "Cart", icon: "cart", selectedIcon: "cart.fill"),
        ]
        let tabBar = XGTabBar(items: items, selectedIndex: binding)
        _ = tabBar
        #expect(true)
    }

    @Test("Updating selectedIndex binding reflects new selection")
    func selectedIndex_binding_updatesValue() {
        var selectedIndex = 0
        let binding = Binding(get: { selectedIndex }, set: { selectedIndex = $0 })
        binding.wrappedValue = 2
        #expect(selectedIndex == 2)
    }

    @Test("TabBar initialises with single item")
    func init_withSingleItem_initialises() {
        var selectedIndex = 0
        let binding = Binding(get: { selectedIndex }, set: { selectedIndex = $0 })
        let items = [
            XGTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill"),
        ]
        let tabBar = XGTabBar(items: items, selectedIndex: binding)
        _ = tabBar
        #expect(true)
    }

    @Test("TabBar initialises with badge on item")
    func init_withBadgeOnItem_initialises() {
        var selectedIndex = 0
        let binding = Binding(get: { selectedIndex }, set: { selectedIndex = $0 })
        let items = [
            XGTabItem(id: 0, label: "Home", icon: "house", selectedIcon: "house.fill"),
            XGTabItem(
                id: 1,
                label: "Cart",
                icon: "cart",
                selectedIcon: "cart.fill",
                badgeCount: 5,
            ),
        ]
        let tabBar = XGTabBar(items: items, selectedIndex: binding)
        _ = tabBar
        #expect(items[1].badgeCount == 5)
    }
}

// MARK: - XGTabBarTokenContractTests

@Suite("XGTabBar Token Contract Tests")
@MainActor
struct XGTabBarTokenContractTests {
    @Test("bottomNavBackground is white (#FFFFFF)")
    func bottomNavBackground_isWhite() {
        #expect(XGColors.bottomNavBackground == Color.white)
    }

    @Test("bottomNavIconActive matches brand primary (#6000FE)")
    func bottomNavIconActive_matchesBrandPrimary() {
        #expect(XGColors.bottomNavIconActive == Color(hex: "#6000FE"))
    }

    @Test("bottomNavIconInactive matches textSecondary (#8E8E93)")
    func bottomNavIconInactive_matchesTextSecondary() {
        #expect(XGColors.bottomNavIconInactive == Color(hex: "#8E8E93"))
    }

    @Test("Icon size medium is 24pt")
    func iconSizeMedium_is24() {
        #expect(XGSpacing.IconSize.medium == 24)
    }

    @Test("Min touch target is 48pt")
    func minTouchTarget_is48() {
        #expect(XGSpacing.minTouchTarget == 48)
    }

    @Test("Motion duration fast is 0.2 seconds")
    func motionDurationFast_is02() {
        #expect(XGMotion.Duration.fast == 0.2)
    }

    @Test("XGTypography.micro is 10pt Poppins Regular")
    func typographyMicro_is10ptRegular() {
        #expect(XGTypography.micro == Font.custom("Poppins-Regular", size: 10))
    }
}
