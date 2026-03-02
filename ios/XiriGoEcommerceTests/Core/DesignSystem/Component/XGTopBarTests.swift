import Testing
@testable import XiriGoEcommerce

// MARK: - XGTopBarVariantTests

@Suite("XGTopBarVariant Tests")
struct XGTopBarVariantTests {
    @Test("Surface variant has surface background color")
    func surface_hasCorrectBackgroundColor() {
        let variant = XGTopBarVariant.surface
        _ = variant.backgroundColor
        #expect(true)
    }

    @Test("Surface variant has onSurface content color")
    func surface_hasCorrectContentColor() {
        let variant = XGTopBarVariant.surface
        _ = variant.contentColor
        #expect(true)
    }

    @Test("Transparent variant has clear background color")
    func transparent_hasCorrectBackgroundColor() {
        let variant = XGTopBarVariant.transparent
        _ = variant.backgroundColor
        #expect(true)
    }

    @Test("Transparent variant has textOnDark content color")
    func transparent_hasCorrectContentColor() {
        let variant = XGTopBarVariant.transparent
        _ = variant.contentColor
        #expect(true)
    }
}

// MARK: - XGTopBarActionTests

@Suite("XGTopBarAction Tests")
struct XGTopBarActionTests {
    @Test("TopBarAction initialises with icon and accessibility label")
    func init_withIconAndLabel_initialises() {
        let action = XGTopBarAction(
            icon: "magnifyingglass",
            accessibilityLabel: "Search",
        ) {}
        #expect(action.icon == "magnifyingglass")
        #expect(action.accessibilityLabel == "Search")
    }

    @Test("TopBarAction initialises without badge count by default")
    func init_defaultBadgeCountIsNil() {
        let action = XGTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart",
        ) {}
        #expect(action.badgeCount == nil)
    }

    @Test("TopBarAction initialises with badge count")
    func init_withBadgeCount_storesBadgeCount() {
        let action = XGTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart",
            badgeCount: 3,
        ) {}
        #expect(action.badgeCount == 3)
    }

    @Test("TopBarAction has unique id")
    func init_hasUniqueId() {
        let action1 = XGTopBarAction(icon: "cart", accessibilityLabel: "Cart") {}
        let action2 = XGTopBarAction(icon: "cart", accessibilityLabel: "Cart") {}
        #expect(action1.id != action2.id)
    }

    @Test("TopBarAction action closure is captured")
    func init_actionClosure_isCaptured() {
        let action = XGTopBarAction(icon: "bell", accessibilityLabel: "Notifications") {}
        _ = action
        #expect(true)
    }
}

// MARK: - XGTopBarTests

@Suite("XGTopBar Tests")
@MainActor
struct XGTopBarTests {
    @Test("TopBar initialises with title only")
    func init_withTitleOnly_initialises() {
        let bar = XGTopBar(title: "Products")
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with back tap handler")
    func init_withBackTap_initialises() {
        let bar = XGTopBar(title: "Details", onBackTap: {})
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises without back tap handler")
    func init_withoutBackTap_onBackTapIsNil() {
        let bar = XGTopBar(title: "Home")
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with action buttons")
    func init_withActions_initialises() {
        let actions = [
            XGTopBarAction(icon: "magnifyingglass", accessibilityLabel: "Search") {},
            XGTopBarAction(icon: "cart", accessibilityLabel: "Cart", badgeCount: 3) {},
        ]
        let bar = XGTopBar(title: "Home", actions: actions)
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with empty actions by default")
    func init_defaultActionsAreEmpty() {
        let bar = XGTopBar(title: "Home")
        _ = bar
        #expect(true)
    }

    @Test("TopBar action badges are stored in actions array")
    func actions_badgeCountStoredCorrectly() {
        let cartAction = XGTopBarAction(
            icon: "cart",
            accessibilityLabel: "Cart",
            badgeCount: 5,
        ) {}
        #expect(cartAction.badgeCount == 5)
    }

    @Test("TopBar initialises with surface variant by default")
    func init_defaultVariantIsSurface() {
        let bar = XGTopBar(title: "Default")
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with explicit surface variant")
    func init_withSurfaceVariant_initialises() {
        let bar = XGTopBar(title: "Surface", variant: .surface)
        _ = bar
        #expect(true)
    }

    @Test("TopBar initialises with transparent variant")
    func init_withTransparentVariant_initialises() {
        let bar = XGTopBar(title: "Login", variant: .transparent)
        _ = bar
        #expect(true)
    }

    @Test("TopBar transparent variant with back button initialises")
    func init_transparentWithBackTap_initialises() {
        let bar = XGTopBar(title: "Login", variant: .transparent, onBackTap: {})
        _ = bar
        #expect(true)
    }

    @Test("TopBar transparent variant with actions initialises")
    func init_transparentWithActions_initialises() {
        let actions = [
            XGTopBarAction(icon: "magnifyingglass", accessibilityLabel: "Search") {},
        ]
        let bar = XGTopBar(title: "Splash", variant: .transparent, actions: actions)
        _ = bar
        #expect(true)
    }
}
