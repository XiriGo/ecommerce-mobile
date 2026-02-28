import Foundation
import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - AppRouterStateTests

@Suite("AppRouter State Tests")
@MainActor
struct AppRouterStateTests {
    // MARK: - Initial State

    @Test("initial selectedTab is home")
    func init_selectedTab_isHome() {
        let router = AppRouter()
        #expect(router.selectedTab == .home)
    }

    @Test("initial homePath is empty")
    func init_homePath_isEmpty() {
        let router = AppRouter()
        #expect(router.homePath.isEmpty)
    }

    @Test("initial categoriesPath is empty")
    func init_categoriesPath_isEmpty() {
        let router = AppRouter()
        #expect(router.categoriesPath.isEmpty)
    }

    @Test("initial cartPath is empty")
    func init_cartPath_isEmpty() {
        let router = AppRouter()
        #expect(router.cartPath.isEmpty)
    }

    @Test("initial profilePath is empty")
    func init_profilePath_isEmpty() {
        let router = AppRouter()
        #expect(router.profilePath.isEmpty)
    }

    @Test("initial presentedAuth is nil")
    func init_presentedAuth_isNil() {
        let router = AppRouter()
        #expect(router.presentedAuth == nil)
    }

    @Test("initial cartBadgeCount is zero")
    func init_cartBadgeCount_isZero() {
        let router = AppRouter()
        #expect(router.cartBadgeCount == 0)
    }

    // MARK: - selectTab

    @Test("selectTab changes selectedTab to new tab")
    func selectTab_differentTab_changesSelectedTab() {
        let router = AppRouter()
        router.selectTab(.categories)
        #expect(router.selectedTab == .categories)
    }

    @Test("selectTab to cart changes selectedTab to cart")
    func selectTab_cart_setsSelectedTabToCart() {
        let router = AppRouter()
        router.selectTab(.cart)
        #expect(router.selectedTab == .cart)
    }

    @Test("selectTab to profile changes selectedTab to profile")
    func selectTab_profile_setsSelectedTabToProfile() {
        let router = AppRouter()
        router.selectTab(.profile)
        #expect(router.selectedTab == .profile)
    }

    @Test("selectTab same tab pops to root when stack is non-empty")
    func selectTab_sameTab_withNonEmptyPath_popsToRoot() {
        let router = AppRouter()
        // Navigate to a public route to add to home path
        router.navigate(to: .productSearch)
        #expect(!router.homePath.isEmpty)

        // Select home again — should pop to root
        router.selectTab(.home)
        #expect(router.homePath.isEmpty)
    }

    @Test("selectTab same tab when path is empty stays on root")
    func selectTab_sameTab_emptyPath_staysOnRoot() {
        let router = AppRouter()
        router.selectTab(.home) // already home, empty path
        #expect(router.selectedTab == .home)
        #expect(router.homePath.isEmpty)
    }

    // MARK: - presentLogin / dismissAuth

    @Test("presentLogin sets presentedAuth to login route")
    func presentLogin_noReturnTo_setsLoginRouteWithNilReturnTo() {
        let router = AppRouter()
        router.presentLogin()
        if case let .login(returnTo) = router.presentedAuth {
            #expect(returnTo == nil)
        } else {
            Issue.record("Expected presentedAuth to be .login")
        }
    }

    @Test("presentLogin with returnTo sets presentedAuth with serialized returnTo")
    func presentLogin_withReturnTo_setsLoginRouteWithReturnToString() {
        let router = AppRouter()
        router.presentLogin(returnTo: .checkout)
        if case let .login(returnTo) = router.presentedAuth {
            #expect(returnTo != nil)
            #expect(returnTo == "checkout")
        } else {
            Issue.record("Expected presentedAuth to be .login")
        }
    }

    @Test("dismissAuth sets presentedAuth to nil")
    func dismissAuth_presentedAuth_becomesNil() {
        let router = AppRouter()
        router.presentLogin()
        #expect(router.presentedAuth != nil)
        router.dismissAuth()
        #expect(router.presentedAuth == nil)
    }

    @Test("dismissAuth when no auth presented does nothing")
    func dismissAuth_noAuthPresented_remainsNil() {
        let router = AppRouter()
        router.dismissAuth() // should not crash
        #expect(router.presentedAuth == nil)
    }

    // MARK: - cartBadgeCount

    @Test("cartBadgeCount can be set to non-zero value")
    func cartBadgeCount_setToFive_isUpdated() {
        let router = AppRouter()
        router.cartBadgeCount = 5
        #expect(router.cartBadgeCount == 5)
    }

    @Test("cartBadgeCount can be reset to zero")
    func cartBadgeCount_resetToZero_isZero() {
        let router = AppRouter()
        router.cartBadgeCount = 10
        router.cartBadgeCount = 0
        #expect(router.cartBadgeCount == 0)
    }
}
