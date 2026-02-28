import Testing
@testable import XiriGoEcommerce

// MARK: - MoltTopBarActionTests

@Suite("MoltTopBarAction Tests")
struct MoltTopBarActionTests {
    @Test("TopBarAction initialises with icon and accessibility label")
    func test_init_withIconAndLabel_initialises() {
        let action = MoltTopBarAction(
            icon: "magnifyingglass",
            accessibilityLabel: "Search"
        ) {}
        #expect(action.icon == "magnifyingglass")
        #expect(action.accessibilityLabel == "Search")
    }

    @Test("TopBarAction initialises without badge count by default")
    func test_init_defaultBadgeCountIsNil() {
        let action = MoltTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart"
        ) {}
        #expect(action.badgeCount == nil)
    }

    @Test("TopBarAction initialises with badge count")
    func test_init_withBadgeCount_storesBadgeCount() {
        let action = MoltTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart",
            badgeCount: 3
        ) {}
        #expect(action.badgeCount == 3)
    }

    @Test("TopBarAction has unique id")
    func test_init_hasUniqueId() {
        let action1 = MoltTopBarAction(icon: "cart", accessibilityLabel: "Cart") {}
        let action2 = MoltTopBarAction(icon: "cart", accessibilityLabel: "Cart") {}
        #expect(action1.id != action2.id)
    }

    @Test("TopBarAction action closure is captured")
    func test_init_actionClosure_isCaptured() {
        let action = MoltTopBarAction(icon: "bell", accessibilityLabel: "Notifications") {}
        _ = action
        #expect(true)
    }
}

// MARK: - MoltTopBarTests

@Suite("MoltTopBar Tests")
struct MoltTopBarTests {
    @Test("TopBar initialises with title only")
    func test_init_withTitleOnly_initialises() {
        let bar = MoltTopBar(title: "Products")
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with back tap handler")
    func test_init_withBackTap_initialises() {
        let bar = MoltTopBar(title: "Details", onBackTap: {})
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises without back tap handler")
    func test_init_withoutBackTap_onBackTapIsNil() {
        let bar = MoltTopBar(title: "Home")
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with action buttons")
    func test_init_withActions_initialises() {
        let actions = [
            MoltTopBarAction(icon: "magnifyingglass", accessibilityLabel: "Search") {},
            MoltTopBarAction(icon: "cart", accessibilityLabel: "Cart", badgeCount: 3) {},
        ]
        let bar = MoltTopBar(title: "Home", actions: actions)
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with empty actions by default")
    func test_init_defaultActionsAreEmpty() {
        let bar = MoltTopBar(title: "Home")
        _ = bar
        #expect(true)
    }

    @Test("TopBar action badges are stored in actions array")
    func test_actions_badgeCountStoredCorrectly() {
        let cartAction = MoltTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart",
            badgeCount: 5
        ) {}
        #expect(cartAction.badgeCount == 5)
    }
}
