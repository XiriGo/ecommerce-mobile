package com.molt.marketplace.core.navigation

import kotlinx.serialization.Serializable

/**
 * Sealed interface defining all type-safe routes in the Molt Marketplace app.
 * Routes span milestones M0 through M4. Unimplemented routes render placeholder screens.
 */
sealed interface Route {

    // Home tab (M1-04)
    @Serializable
    data object Home : Route

    // Categories tab (M1-05)
    @Serializable
    data object Categories : Route

    @Serializable
    data class CategoryProducts(
        val categoryId: String,
        val categoryName: String,
    ) : Route

    @Serializable
    data class ProductList(
        val categoryId: String? = null,
        val query: String? = null,
    ) : Route

    // Shared (any tab)
    @Serializable
    data class ProductDetail(val productId: String) : Route

    @Serializable
    data object ProductSearch : Route

    @Serializable
    data class VendorStore(val vendorId: String) : Route

    @Serializable
    data class ProductReviews(val productId: String) : Route

    @Serializable
    data class WriteReview(val productId: String) : Route

    // Cart tab (M2)
    @Serializable
    data object Cart : Route

    @Serializable
    data object Checkout : Route

    @Serializable
    data object CheckoutAddress : Route

    @Serializable
    data object CheckoutShipping : Route

    @Serializable
    data object CheckoutPayment : Route

    @Serializable
    data class OrderConfirmation(val orderId: String) : Route

    // Profile tab (M3)
    @Serializable
    data object Profile : Route

    @Serializable
    data object OrderList : Route

    @Serializable
    data class OrderDetail(val orderId: String) : Route

    @Serializable
    data object Settings : Route

    @Serializable
    data object AddressManagement : Route

    @Serializable
    data object Wishlist : Route

    @Serializable
    data object PaymentMethods : Route

    @Serializable
    data object Notifications : Route

    @Serializable
    data object RecentlyViewed : Route

    @Serializable
    data object PriceAlerts : Route

    // Auth (modal / fullscreen)
    @Serializable
    data class Login(val returnTo: String? = null) : Route

    @Serializable
    data object Register : Route

    @Serializable
    data object ForgotPassword : Route

    // Onboarding (fullscreen)
    @Serializable
    data object Onboarding : Route
}

val Route.isAuthRequired: Boolean
    get() = when (this) {
        is Route.Checkout,
        is Route.CheckoutAddress,
        is Route.CheckoutShipping,
        is Route.CheckoutPayment,
        is Route.OrderConfirmation,
        is Route.OrderList,
        is Route.OrderDetail,
        is Route.Settings,
        is Route.AddressManagement,
        is Route.Wishlist,
        is Route.PaymentMethods,
        is Route.Notifications,
        is Route.WriteReview,
        is Route.PriceAlerts,
        -> true

        is Route.Home,
        is Route.Categories,
        is Route.CategoryProducts,
        is Route.ProductList,
        is Route.ProductDetail,
        is Route.ProductSearch,
        is Route.VendorStore,
        is Route.ProductReviews,
        is Route.Cart,
        is Route.Profile,
        is Route.Login,
        is Route.Register,
        is Route.ForgotPassword,
        is Route.Onboarding,
        is Route.RecentlyViewed,
        -> false
    }
