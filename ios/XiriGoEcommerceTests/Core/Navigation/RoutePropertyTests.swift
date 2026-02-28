import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - RouteAssociatedValuesTests

@Suite("Route Associated Values Tests")
struct RouteAssociatedValuesTests {
    // MARK: - productDetail

    @Test("productDetail stores productId correctly")
    func productDetail_productId_isAccessible() {
        let route = Route.productDetail(productId: "prod_abc")
        if case let .productDetail(id) = route {
            #expect(id == "prod_abc")
        } else {
            Issue.record("Expected productDetail case")
        }
    }

    // MARK: - categoryProducts

    @Test("categoryProducts stores categoryId and categoryName")
    func categoryProducts_associatedValues_areAccessible() {
        let route = Route.categoryProducts(categoryId: "cat_1", categoryName: "Electronics")
        if case let .categoryProducts(id, name) = route {
            #expect(id == "cat_1")
            #expect(name == "Electronics")
        } else {
            Issue.record("Expected categoryProducts case")
        }
    }

    // MARK: - productList

    @Test("productList stores optional categoryId and query")
    func productList_withCategoryIdAndQuery_associatedValuesAreAccessible() {
        let route = Route.productList(categoryId: "cat_2", query: "sneakers")
        if case let .productList(catId, query) = route {
            #expect(catId == "cat_2")
            #expect(query == "sneakers")
        } else {
            Issue.record("Expected productList case")
        }
    }

    @Test("productList allows nil categoryId and query")
    func productList_withNilValues_associatedValuesAreNil() {
        let route = Route.productList(categoryId: nil, query: nil)
        if case let .productList(catId, query) = route {
            #expect(catId == nil)
            #expect(query == nil)
        } else {
            Issue.record("Expected productList case")
        }
    }

    // MARK: - orderConfirmation

    @Test("orderConfirmation stores orderId correctly")
    func orderConfirmation_orderId_isAccessible() {
        let route = Route.orderConfirmation(orderId: "ord_xyz")
        if case let .orderConfirmation(id) = route {
            #expect(id == "ord_xyz")
        } else {
            Issue.record("Expected orderConfirmation case")
        }
    }

    // MARK: - orderDetail

    @Test("orderDetail stores orderId correctly")
    func orderDetail_orderId_isAccessible() {
        let route = Route.orderDetail(orderId: "ord_999")
        if case let .orderDetail(id) = route {
            #expect(id == "ord_999")
        } else {
            Issue.record("Expected orderDetail case")
        }
    }

    // MARK: - vendorStore

    @Test("vendorStore stores vendorId correctly")
    func vendorStore_vendorId_isAccessible() {
        let route = Route.vendorStore(vendorId: "vendor_42")
        if case let .vendorStore(id) = route {
            #expect(id == "vendor_42")
        } else {
            Issue.record("Expected vendorStore case")
        }
    }

    // MARK: - productReviews

    @Test("productReviews stores productId correctly")
    func productReviews_productId_isAccessible() {
        let route = Route.productReviews(productId: "prod_rev_1")
        if case let .productReviews(id) = route {
            #expect(id == "prod_rev_1")
        } else {
            Issue.record("Expected productReviews case")
        }
    }

    // MARK: - writeReview

    @Test("writeReview stores productId correctly")
    func writeReview_productId_isAccessible() {
        let route = Route.writeReview(productId: "prod_wr_1")
        if case let .writeReview(id) = route {
            #expect(id == "prod_wr_1")
        } else {
            Issue.record("Expected writeReview case")
        }
    }

    @Test("login stores optional returnTo string")
    func login_withReturnTo_associatedValueIsAccessible() {
        let route = Route.login(returnTo: "checkout")
        if case let .login(returnTo) = route {
            #expect(returnTo == "checkout")
        } else {
            Issue.record("Expected login case")
        }
    }

    @Test("login allows nil returnTo")
    func login_withNilReturnTo_associatedValueIsNil() {
        let route = Route.login(returnTo: nil)
        if case let .login(returnTo) = route {
            #expect(returnTo == nil)
        } else {
            Issue.record("Expected login case")
        }
    }

    // MARK: - Hashable conformance

    @Test("same routes with same associated values are equal")
    func hashable_sameRouteSameValues_areEqual() {
        let productDetailA = Route.productDetail(productId: "p1")
        let productDetailB = Route.productDetail(productId: "p1")
        #expect(productDetailA == productDetailB)

        let orderDetailA = Route.orderDetail(orderId: "o1")
        let orderDetailB = Route.orderDetail(orderId: "o1")
        #expect(orderDetailA == orderDetailB)

        let loginA = Route.login(returnTo: "checkout")
        let loginB = Route.login(returnTo: "checkout")
        #expect(loginA == loginB)
    }

    @Test("routes with different associated values are not equal")
    func hashable_sameRouteDifferentValues_areNotEqual() {
        #expect(Route.productDetail(productId: "p1") != Route.productDetail(productId: "p2"))
        #expect(Route.orderDetail(orderId: "o1") != Route.orderDetail(orderId: "o2"))
    }

    @Test("different route cases are not equal")
    func hashable_differentCases_areNotEqual() {
        #expect(Route.home != Route.categories)
        #expect(Route.cart != Route.profile)
        #expect(Route.checkout != Route.checkoutAddress)
    }

    @Test("routes can be used as dictionary keys")
    func hashable_routeAsKey_worksCorrectly() {
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
    func title_home_isNonEmpty() {
        #expect(!Route.home.title.isEmpty)
    }

    @Test("categories title is non-empty")
    func title_categories_isNonEmpty() {
        #expect(!Route.categories.title.isEmpty)
    }

    @Test("cart title is non-empty")
    func title_cart_isNonEmpty() {
        #expect(!Route.cart.title.isEmpty)
    }

    @Test("profile title is non-empty")
    func title_profile_isNonEmpty() {
        #expect(!Route.profile.title.isEmpty)
    }

    @Test("categoryProducts with non-empty name uses categoryName as title")
    func title_categoryProducts_withName_usesCategoryName() {
        let route = Route.categoryProducts(categoryId: "cat_1", categoryName: "Electronics")
        #expect(route.title == "Electronics")
    }

    @Test("categoryProducts with empty name falls back to Category")
    func title_categoryProducts_emptyName_fallsBackToCategory() {
        let route = Route.categoryProducts(categoryId: "cat_1", categoryName: "")
        #expect(route.title == "Category")
    }

    @Test("productDetail title is non-empty")
    func title_productDetail_isNonEmpty() {
        #expect(!Route.productDetail(productId: "p1").title.isEmpty)
    }

    @Test("orderDetail title is non-empty")
    func title_orderDetail_isNonEmpty() {
        #expect(!Route.orderDetail(orderId: "o1").title.isEmpty)
    }

    @Test("login title is non-empty")
    func title_login_isNonEmpty() {
        #expect(!Route.login(returnTo: nil).title.isEmpty)
    }
}
