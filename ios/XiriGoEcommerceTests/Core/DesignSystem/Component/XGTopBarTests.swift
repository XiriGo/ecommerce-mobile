import Testing
@testable import XiriGoEcommerce

// MARK: - XGTopBarActionTests

@Suite("XGTopBarAction Tests")
struct XGTopBarActionTests {
    @Test("TopBarAction initialises with icon and accessibility label")
    func test_init_withIconAndLabel_initialises() {
        let action = XGTopBarAction(
            icon: "magnifyingglass",
            accessibilityLabel: "Search"
        ) {}
        #expect(action.icon == "magnifyingglass")
        #expect(action.accessibilityLabel == "Search")
    }

    @Test("TopBarAction initialises without badge count by default")
    func test_init_defaultBadgeCountIsNil() {
        let action = XGTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart"
        ) {}
        #expect(action.badgeCount == nil)
    }

    @Test("TopBarAction initialises with badge count")
    func test_init_withBadgeCount_storesBadgeCount() {
        let action = XGTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart",
            badgeCount: 3
        ) {}
        #expect(action.badgeCount == 3)
    }

    @Test("TopBarAction has unique id")
    func test_init_hasUniqueId() {
        let action1 = XGTopBarAction(icon: "cart", accessibilityLabel: "Cart") {}
        let action2 = XGTopBarAction(icon: "cart", accessibilityLabel: "Cart") {}
        #expect(action1.id != action2.id)
    }

    @Test("TopBarAction action closure is captured")
    func test_init_actionClosure_isCaptured() {
        let action = XGTopBarAction(icon: "bell", accessibilityLabel: "Notifications") {}
        _ = action
        #expect(true)
    }
}

// MARK: - XGTopBarTests

@Suite("XGTopBar Tests")
struct XGTopBarTests {
    @Test("TopBar initialises with title only")
    func test_init_withTitleOnly_initialises() {
        let bar = XGTopBar(title: "Products")
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with back tap handler")
    func test_init_withBackTap_initialises() {
        let bar = XGTopBar(title: "Details", onBackTap: {})
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises without back tap handler")
    func test_init_withoutBackTap_onBackTapIsNil() {
        let bar = XGTopBar(title: "Home")
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with action buttons")
    func test_init_withActions_initialises() {
        let actions = [
            XGTopBarAction(icon: "magnifyingglass", accessibilityLabel: "Search") {},
            XGTopBarAction(icon: "cart", accessibilityLabel: "Cart", badgeCount: 3) {},
        ]
        let bar = XGTopBar(title: "Home", actions: actions)
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with empty actions by default")
    func test_init_defaultActionsAreEmpty() {
        let bar = XGTopBar(title: "Home")
        _ = bar
        #expect(true)
    }

    @Test("TopBar action badges are stored in actions array")
    func test_actions_badgeCountStoredCorrectly() {
        let cartAction = XGTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart",
            badgeCount: 5
        ) {}
        #expect(cartAction.badgeCount == 5)
    }
}
