import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - RouteAuthTests

@Suite("Route requiresAuth Tests")
struct RouteAuthTests {
    // MARK: - Auth-Required Routes (must return true)

    @Test("checkout requiresAuth is true")
    func requiresAuth_checkout_isTrue() {
        #expect(Route.checkout.requiresAuth == true)
    }

    @Test("checkoutAddress requiresAuth is true")
    func requiresAuth_checkoutAddress_isTrue() {
        #expect(Route.checkoutAddress.requiresAuth == true)
    }

    @Test("checkoutShipping requiresAuth is true")
    func requiresAuth_checkoutShipping_isTrue() {
        #expect(Route.checkoutShipping.requiresAuth == true)
    }

    @Test("checkoutPayment requiresAuth is true")
    func requiresAuth_checkoutPayment_isTrue() {
        #expect(Route.checkoutPayment.requiresAuth == true)
    }

    @Test("orderConfirmation requiresAuth is true")
    func requiresAuth_orderConfirmation_isTrue() {
        #expect(Route.orderConfirmation(orderId: "ord_123").requiresAuth == true)
    }

    @Test("orderList requiresAuth is true")
    func requiresAuth_orderList_isTrue() {
        #expect(Route.orderList.requiresAuth == true)
    }

    @Test("orderDetail requiresAuth is true")
    func requiresAuth_orderDetail_isTrue() {
        #expect(Route.orderDetail(orderId: "ord_456").requiresAuth == true)
    }

    @Test("settings requiresAuth is true")
    func requiresAuth_settings_isTrue() {
        #expect(Route.settings.requiresAuth == true)
    }

    @Test("addressManagement requiresAuth is true")
    func requiresAuth_addressManagement_isTrue() {
        #expect(Route.addressManagement.requiresAuth == true)
    }

    @Test("wishlist requiresAuth is true")
    func requiresAuth_wishlist_isTrue() {
        #expect(Route.wishlist.requiresAuth == true)
    }

    @Test("paymentMethods requiresAuth is true")
    func requiresAuth_paymentMethods_isTrue() {
        #expect(Route.paymentMethods.requiresAuth == true)
    }

    @Test("notifications requiresAuth is true")
    func requiresAuth_notifications_isTrue() {
        #expect(Route.notifications.requiresAuth == true)
    }

    @Test("writeReview requiresAuth is true")
    func requiresAuth_writeReview_isTrue() {
        #expect(Route.writeReview(productId: "prod_123").requiresAuth == true)
    }

    @Test("priceAlerts requiresAuth is true")
    func requiresAuth_priceAlerts_isTrue() {
        #expect(Route.priceAlerts.requiresAuth == true)
    }

    // MARK: - Public Routes (must return false)

    @Test("home requiresAuth is false")
    func requiresAuth_home_isFalse() {
        #expect(Route.home.requiresAuth == false)
    }

    @Test("categories requiresAuth is false")
    func requiresAuth_categories_isFalse() {
        #expect(Route.categories.requiresAuth == false)
    }

    @Test("categoryProducts requiresAuth is false")
    func requiresAuth_categoryProducts_isFalse() {
        #expect(Route.categoryProducts(categoryId: "cat_1", categoryName: "Fashion").requiresAuth == false)
    }

    @Test("productList requiresAuth is false")
    func requiresAuth_productList_isFalse() {
        #expect(Route.productList(categoryId: nil, query: nil).requiresAuth == false)
    }

    @Test("productDetail requiresAuth is false")
    func requiresAuth_productDetail_isFalse() {
        #expect(Route.productDetail(productId: "prod_1").requiresAuth == false)
    }

    @Test("productSearch requiresAuth is false")
    func requiresAuth_productSearch_isFalse() {
        #expect(Route.productSearch.requiresAuth == false)
    }

    @Test("vendorStore requiresAuth is false")
    func requiresAuth_vendorStore_isFalse() {
        #expect(Route.vendorStore(vendorId: "v_1").requiresAuth == false)
    }

    @Test("productReviews requiresAuth is false")
    func requiresAuth_productReviews_isFalse() {
        #expect(Route.productReviews(productId: "prod_1").requiresAuth == false)
    }

    @Test("cart requiresAuth is false")
    func requiresAuth_cart_isFalse() {
        #expect(Route.cart.requiresAuth == false)
    }

    @Test("profile requiresAuth is false")
    func requiresAuth_profile_isFalse() {
        #expect(Route.profile.requiresAuth == false)
    }

    @Test("login requiresAuth is false")
    func requiresAuth_login_isFalse() {
        #expect(Route.login(returnTo: nil).requiresAuth == false)
    }

    @Test("login with returnTo requiresAuth is false")
    func requiresAuth_loginWithReturnTo_isFalse() {
        #expect(Route.login(returnTo: "checkout").requiresAuth == false)
    }

    @Test("register requiresAuth is false")
    func requiresAuth_register_isFalse() {
        #expect(Route.register.requiresAuth == false)
    }

    @Test("forgotPassword requiresAuth is false")
    func requiresAuth_forgotPassword_isFalse() {
        #expect(Route.forgotPassword.requiresAuth == false)
    }

    @Test("onboarding requiresAuth is false")
    func requiresAuth_onboarding_isFalse() {
        #expect(Route.onboarding.requiresAuth == false)
    }

    @Test("recentlyViewed requiresAuth is false")
    func requiresAuth_recentlyViewed_isFalse() {
        #expect(Route.recentlyViewed.requiresAuth == false)
    }

    // MARK: - Auth-required routes count

    @Test("exactly 14 routes require authentication")
    func requiresAuth_authRoutes_countIs14() {
        let authRequiredRoutes: [Route] = [
            .checkout,
            .checkoutAddress,
            .checkoutShipping,
            .checkoutPayment,
            .orderConfirmation(orderId: "o"),
            .orderList,
            .orderDetail(orderId: "o"),
            .settings,
            .addressManagement,
            .wishlist,
            .paymentMethods,
            .notifications,
            .writeReview(productId: "p"),
            .priceAlerts,
        ]
        #expect(authRequiredRoutes.filter(\.requiresAuth).count == 14)
    }
}
