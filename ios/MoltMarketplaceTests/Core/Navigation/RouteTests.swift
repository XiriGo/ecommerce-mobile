// swiftlint:disable file_length
import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - RouteAuthTests

@Suite("Route requiresAuth Tests")
struct RouteAuthTests {
    // MARK: - Auth-Required Routes (must return true)

    @Test("checkout requiresAuth is true")
    func test_requiresAuth_checkout_isTrue() {
        #expect(Route.checkout.requiresAuth == true)
    }

    @Test("checkoutAddress requiresAuth is true")
    func test_requiresAuth_checkoutAddress_isTrue() {
        #expect(Route.checkoutAddress.requiresAuth == true)
    }

    @Test("checkoutShipping requiresAuth is true")
    func test_requiresAuth_checkoutShipping_isTrue() {
        #expect(Route.checkoutShipping.requiresAuth == true)
    }

    @Test("checkoutPayment requiresAuth is true")
    func test_requiresAuth_checkoutPayment_isTrue() {
        #expect(Route.checkoutPayment.requiresAuth == true)
    }

    @Test("orderConfirmation requiresAuth is true")
    func test_requiresAuth_orderConfirmation_isTrue() {
        #expect(Route.orderConfirmation(orderId: "ord_123").requiresAuth == true)
    }

    @Test("orderList requiresAuth is true")
    func test_requiresAuth_orderList_isTrue() {
        #expect(Route.orderList.requiresAuth == true)
    }

    @Test("orderDetail requiresAuth is true")
    func test_requiresAuth_orderDetail_isTrue() {
        #expect(Route.orderDetail(orderId: "ord_456").requiresAuth == true)
    }

    @Test("settings requiresAuth is true")
    func test_requiresAuth_settings_isTrue() {
        #expect(Route.settings.requiresAuth == true)
    }

    @Test("addressManagement requiresAuth is true")
    func test_requiresAuth_addressManagement_isTrue() {
        #expect(Route.addressManagement.requiresAuth == true)
    }

    @Test("wishlist requiresAuth is true")
    func test_requiresAuth_wishlist_isTrue() {
        #expect(Route.wishlist.requiresAuth == true)
    }

    @Test("paymentMethods requiresAuth is true")
    func test_requiresAuth_paymentMethods_isTrue() {
        #expect(Route.paymentMethods.requiresAuth == true)
    }

    @Test("notifications requiresAuth is true")
    func test_requiresAuth_notifications_isTrue() {
        #expect(Route.notifications.requiresAuth == true)
    }

    @Test("writeReview requiresAuth is true")
    func test_requiresAuth_writeReview_isTrue() {
        #expect(Route.writeReview(productId: "prod_123").requiresAuth == true)
    }

    @Test("priceAlerts requiresAuth is true")
    func test_requiresAuth_priceAlerts_isTrue() {
        #expect(Route.priceAlerts.requiresAuth == true)
    }

    // MARK: - Public Routes (must return false)

    @Test("home requiresAuth is false")
    func test_requiresAuth_home_isFalse() {
        #expect(Route.home.requiresAuth == false)
    }

    @Test("categories requiresAuth is false")
    func test_requiresAuth_categories_isFalse() {
        #expect(Route.categories.requiresAuth == false)
    }

    @Test("categoryProducts requiresAuth is false")
    func test_requiresAuth_categoryProducts_isFalse() {
        #expect(Route.categoryProducts(categoryId: "cat_1", categoryName: "Fashion").requiresAuth == false)
    }

    @Test("productList requiresAuth is false")
    func test_requiresAuth_productList_isFalse() {
        #expect(Route.productList(categoryId: nil, query: nil).requiresAuth == false)
    }

    @Test("productDetail requiresAuth is false")
    func test_requiresAuth_productDetail_isFalse() {
        #expect(Route.productDetail(productId: "prod_1").requiresAuth == false)
    }

    @Test("productSearch requiresAuth is false")
    func test_requiresAuth_productSearch_isFalse() {
        #expect(Route.productSearch.requiresAuth == false)
    }

    @Test("vendorStore requiresAuth is false")
    func test_requiresAuth_vendorStore_isFalse() {
        #expect(Route.vendorStore(vendorId: "v_1").requiresAuth == false)
    }

    @Test("productReviews requiresAuth is false")
    func test_requiresAuth_productReviews_isFalse() {
        #expect(Route.productReviews(productId: "prod_1").requiresAuth == false)
    }

    @Test("cart requiresAuth is false")
    func test_requiresAuth_cart_isFalse() {
        #expect(Route.cart.requiresAuth == false)
    }

    @Test("profile requiresAuth is false")
    func test_requiresAuth_profile_isFalse() {
        #expect(Route.profile.requiresAuth == false)
    }

    @Test("login requiresAuth is false")
    func test_requiresAuth_login_isFalse() {
        #expect(Route.login(returnTo: nil).requiresAuth == false)
    }

    @Test("login with returnTo requiresAuth is false")
    func test_requiresAuth_loginWithReturnTo_isFalse() {
        #expect(Route.login(returnTo: "checkout").requiresAuth == false)
    }

    @Test("register requiresAuth is false")
    func test_requiresAuth_register_isFalse() {
        #expect(Route.register.requiresAuth == false)
    }

    @Test("forgotPassword requiresAuth is false")
    func test_requiresAuth_forgotPassword_isFalse() {
        #expect(Route.forgotPassword.requiresAuth == false)
    }

    @Test("onboarding requiresAuth is false")
    func test_requiresAuth_onboarding_isFalse() {
        #expect(Route.onboarding.requiresAuth == false)
    }

    @Test("recentlyViewed requiresAuth is false")
    func test_requiresAuth_recentlyViewed_isFalse() {
        #expect(Route.recentlyViewed.requiresAuth == false)
    }

    // MARK: - Auth-required routes count

    @Test("exactly 14 routes require authentication")
    func test_requiresAuth_authRoutes_countIs14() {
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

// MARK: - RouteAssociatedValuesTests

@Suite("Route Associated Values Tests")
struct RouteAssociatedValuesTests {
    // MARK: - productDetail

    @Test("productDetail stores productId correctly")
    func test_productDetail_productId_isAccessible() {
        let route = Route.productDetail(productId: "prod_abc")
        if case .productDetail(let id) = route {
            #expect(id == "prod_abc")
        } else {
            Issue.record("Expected productDetail case")
        }
    }

    // MARK: - categoryProducts

    @Test("categoryProducts stores categoryId and categoryName")
    func test_categoryProducts_associatedValues_areAccessible() {
        let route = Route.categoryProducts(categoryId: "cat_1", categoryName: "Electronics")
        if case .categoryProducts(let id, let name) = route {
            #expect(id == "cat_1")
            #expect(name == "Electronics")
        } else {
            Issue.record("Expected categoryProducts case")
        }
    }

    // MARK: - productList

    @Test("productList stores optional categoryId and query")
    func test_productList_withCategoryIdAndQuery_associatedValuesAreAccessible() {
        let route = Route.productList(categoryId: "cat_2", query: "sneakers")
        if case .productList(let catId, let query) = route {
            #expect(catId == "cat_2")
            #expect(query == "sneakers")
        } else {
            Issue.record("Expected productList case")
        }
    }

    @Test("productList allows nil categoryId and query")
    func test_productList_withNilValues_associatedValuesAreNil() {
        let route = Route.productList(categoryId: nil, query: nil)
        if case .productList(let catId, let query) = route {
            #expect(catId == nil)
            #expect(query == nil)
        } else {
            Issue.record("Expected productList case")
        }
    }

    // MARK: - orderConfirmation

    @Test("orderConfirmation stores orderId correctly")
    func test_orderConfirmation_orderId_isAccessible() {
        let route = Route.orderConfirmation(orderId: "ord_xyz")
        if case .orderConfirmation(let id) = route {
            #expect(id == "ord_xyz")
        } else {
            Issue.record("Expected orderConfirmation case")
        }
    }

    // MARK: - orderDetail

    @Test("orderDetail stores orderId correctly")
    func test_orderDetail_orderId_isAccessible() {
        let route = Route.orderDetail(orderId: "ord_999")
        if case .orderDetail(let id) = route {
            #expect(id == "ord_999")
        } else {
            Issue.record("Expected orderDetail case")
        }
    }

    // MARK: - vendorStore

    @Test("vendorStore stores vendorId correctly")
    func test_vendorStore_vendorId_isAccessible() {
        let route = Route.vendorStore(vendorId: "vendor_42")
        if case .vendorStore(let id) = route {
            #expect(id == "vendor_42")
        } else {
            Issue.record("Expected vendorStore case")
        }
    }

    // MARK: - productReviews

    @Test("productReviews stores productId correctly")
    func test_productReviews_productId_isAccessible() {
        let route = Route.productReviews(productId: "prod_rev_1")
        if case .productReviews(let id) = route {
            #expect(id == "prod_rev_1")
        } else {
            Issue.record("Expected productReviews case")
        }
    }

    // MARK: - writeReview

    @Test("writeReview stores productId correctly")
    func test_writeReview_productId_isAccessible() {
        let route = Route.writeReview(productId: "prod_wr_1")
        if case .writeReview(let id) = route {
            #expect(id == "prod_wr_1")
        } else {
            Issue.record("Expected writeReview case")
        }
    }

    // MARK: - login

    @Test("login stores optional returnTo string")
    func test_login_withReturnTo_associatedValueIsAccessible() {
        let route = Route.login(returnTo: "checkout")
        if case .login(let returnTo) = route {
            #expect(returnTo == "checkout")
        } else {
            Issue.record("Expected login case")
        }
    }

    @Test("login allows nil returnTo")
    func test_login_withNilReturnTo_associatedValueIsNil() {
        let route = Route.login(returnTo: nil)
        if case .login(let returnTo) = route {
            #expect(returnTo == nil)
        } else {
            Issue.record("Expected login case")
        }
    }

    // MARK: - Hashable conformance

    @Test("same routes with same associated values are equal")
    func test_hashable_sameRouteSameValues_areEqual() {
        // swiftlint:disable:next identical_operands
        #expect(Route.productDetail(productId: "p1") == Route.productDetail(productId: "p1"))
        // swiftlint:disable:next identical_operands
        #expect(Route.orderDetail(orderId: "o1") == Route.orderDetail(orderId: "o1"))
        // swiftlint:disable:next identical_operands
        #expect(Route.login(returnTo: "checkout") == Route.login(returnTo: "checkout"))
    }

    @Test("routes with different associated values are not equal")
    func test_hashable_sameRouteDifferentValues_areNotEqual() {
        #expect(Route.productDetail(productId: "p1") != Route.productDetail(productId: "p2"))
        #expect(Route.orderDetail(orderId: "o1") != Route.orderDetail(orderId: "o2"))
    }

    @Test("different route cases are not equal")
    func test_hashable_differentCases_areNotEqual() {
        #expect(Route.home != Route.categories)
        #expect(Route.cart != Route.profile)
        #expect(Route.checkout != Route.checkoutAddress)
    }

    @Test("routes can be used as dictionary keys")
    func test_hashable_routeAsKey_worksCorrectly() {
        var map: [Route: String] = [:]
        map[.home] = "Home Screen"
        map[.productDetail(productId: "abc")] = "Product abc"
        #expect(map[.home] == "Home Screen")
        #expect(map[.productDetail(productId: "abc")] == "Product abc")
        #expect(map[.productDetail(productId: "xyz")] == nil)
    }
}

// MARK: - RouteTitleTests

@Suite("Route title Tests")
struct RouteTitleTests {
    @Test("home title is non-empty")
    func test_title_home_isNonEmpty() {
        #expect(!Route.home.title.isEmpty)
    }

    @Test("categories title is non-empty")
    func test_title_categories_isNonEmpty() {
        #expect(!Route.categories.title.isEmpty)
    }

    @Test("cart title is non-empty")
    func test_title_cart_isNonEmpty() {
        #expect(!Route.cart.title.isEmpty)
    }

    @Test("profile title is non-empty")
    func test_title_profile_isNonEmpty() {
        #expect(!Route.profile.title.isEmpty)
    }

    @Test("categoryProducts with non-empty name uses categoryName as title")
    func test_title_categoryProducts_withName_usesCategoryName() {
        let route = Route.categoryProducts(categoryId: "cat_1", categoryName: "Electronics")
        #expect(route.title == "Electronics")
    }

    @Test("categoryProducts with empty name falls back to Category")
    func test_title_categoryProducts_emptyName_fallsBackToCategory() {
        let route = Route.categoryProducts(categoryId: "cat_1", categoryName: "")
        #expect(route.title == "Category")
    }

    @Test("productDetail title is non-empty")
    func test_title_productDetail_isNonEmpty() {
        #expect(!Route.productDetail(productId: "p1").title.isEmpty)
    }

    @Test("orderDetail title is non-empty")
    func test_title_orderDetail_isNonEmpty() {
        #expect(!Route.orderDetail(orderId: "o1").title.isEmpty)
    }

    @Test("login title is non-empty")
    func test_title_login_isNonEmpty() {
        #expect(!Route.login(returnTo: nil).title.isEmpty)
    }
}
