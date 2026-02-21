package com.molt.marketplace.core.navigation

import com.google.common.truth.Truth.assertThat
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.junit.Test

/**
 * Tests that every Route variant can be serialized to JSON and deserialized back
 * to an equal value. This validates the @Serializable annotations and ensures
 * that type-safe Compose Navigation can round-trip route data reliably.
 *
 * Each concrete Route subtype is serialized/deserialized using its own serializer
 * (not the polymorphic parent), which is how Compose Navigation 2.8+ uses them
 * internally for back-stack state persistence.
 */
class RouteSerializationTest {

    private val json = Json { ignoreUnknownKeys = true }

    // -------------------------------------------------------------------------
    // data object routes — serialization produces "{}" (empty object)
    // -------------------------------------------------------------------------

    @Test
    fun `Route Home serializes and deserializes correctly`() {
        val original = Route.Home
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Home>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Categories serializes and deserializes correctly`() {
        val original = Route.Categories
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Categories>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Cart serializes and deserializes correctly`() {
        val original = Route.Cart
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Cart>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Profile serializes and deserializes correctly`() {
        val original = Route.Profile
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Profile>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route ProductSearch serializes and deserializes correctly`() {
        val original = Route.ProductSearch
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.ProductSearch>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Checkout serializes and deserializes correctly`() {
        val original = Route.Checkout
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Checkout>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route CheckoutAddress serializes and deserializes correctly`() {
        val original = Route.CheckoutAddress
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.CheckoutAddress>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route CheckoutShipping serializes and deserializes correctly`() {
        val original = Route.CheckoutShipping
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.CheckoutShipping>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route CheckoutPayment serializes and deserializes correctly`() {
        val original = Route.CheckoutPayment
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.CheckoutPayment>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route OrderList serializes and deserializes correctly`() {
        val original = Route.OrderList
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.OrderList>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Settings serializes and deserializes correctly`() {
        val original = Route.Settings
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Settings>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Wishlist serializes and deserializes correctly`() {
        val original = Route.Wishlist
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Wishlist>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Notifications serializes and deserializes correctly`() {
        val original = Route.Notifications
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Notifications>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Register serializes and deserializes correctly`() {
        val original = Route.Register
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Register>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route ForgotPassword serializes and deserializes correctly`() {
        val original = Route.ForgotPassword
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.ForgotPassword>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Onboarding serializes and deserializes correctly`() {
        val original = Route.Onboarding
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Onboarding>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route AddressManagement serializes and deserializes correctly`() {
        val original = Route.AddressManagement
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.AddressManagement>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route PaymentMethods serializes and deserializes correctly`() {
        val original = Route.PaymentMethods
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.PaymentMethods>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route RecentlyViewed serializes and deserializes correctly`() {
        val original = Route.RecentlyViewed
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.RecentlyViewed>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route PriceAlerts serializes and deserializes correctly`() {
        val original = Route.PriceAlerts
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.PriceAlerts>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    // -------------------------------------------------------------------------
    // data class routes — serialization includes all parameter fields
    // -------------------------------------------------------------------------

    @Test
    fun `Route ProductDetail serializes and deserializes with productId`() {
        val original = Route.ProductDetail(productId = "prod_abc123")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.ProductDetail>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route ProductDetail preserves productId value after round-trip`() {
        val productId = "prod_with-special_chars.456"
        val encoded = json.encodeToString(Route.ProductDetail(productId = productId))
        val decoded = json.decodeFromString<Route.ProductDetail>(encoded)
        assertThat(decoded.productId).isEqualTo(productId)
    }

    @Test
    fun `Route CategoryProducts serializes and deserializes with both params`() {
        val original = Route.CategoryProducts(
            categoryId = "cat_001",
            categoryName = "Electronics",
        )
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.CategoryProducts>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route CategoryProducts preserves categoryName with unicode after round-trip`() {
        val original = Route.CategoryProducts(
            categoryId = "cat_mt",
            categoryName = "Elettroniċi",
        )
        val decoded = json.decodeFromString<Route.CategoryProducts>(json.encodeToString(original))
        assertThat(decoded.categoryName).isEqualTo("Elettroniċi")
    }

    @Test
    fun `Route ProductList serializes and deserializes with null params`() {
        val original = Route.ProductList(categoryId = null, query = null)
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.ProductList>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route ProductList serializes and deserializes with all params`() {
        val original = Route.ProductList(categoryId = "cat_002", query = "shoes")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.ProductList>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route ProductList serializes and deserializes with only query`() {
        val original = Route.ProductList(categoryId = null, query = "laptop")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.ProductList>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route ProductList serializes and deserializes with only categoryId`() {
        val original = Route.ProductList(categoryId = "cat_only", query = null)
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.ProductList>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route OrderDetail serializes and deserializes with orderId`() {
        val original = Route.OrderDetail(orderId = "order_XY99")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.OrderDetail>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route OrderConfirmation serializes and deserializes with orderId`() {
        val original = Route.OrderConfirmation(orderId = "order_confirmed_001")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.OrderConfirmation>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Login serializes and deserializes with null returnTo`() {
        val original = Route.Login(returnTo = null)
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Login>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Login serializes and deserializes with returnTo value`() {
        val original = Route.Login(returnTo = "checkout")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.Login>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route Login returnTo is preserved after round-trip`() {
        val returnTo = "order/abc123"
        val decoded = json.decodeFromString<Route.Login>(
            json.encodeToString(Route.Login(returnTo = returnTo)),
        )
        assertThat(decoded.returnTo).isEqualTo(returnTo)
    }

    @Test
    fun `Route VendorStore serializes and deserializes with vendorId`() {
        val original = Route.VendorStore(vendorId = "vendor_999")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.VendorStore>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route ProductReviews serializes and deserializes with productId`() {
        val original = Route.ProductReviews(productId = "prod_review_01")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.ProductReviews>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    @Test
    fun `Route WriteReview serializes and deserializes with productId`() {
        val original = Route.WriteReview(productId = "prod_write_01")
        val encoded = json.encodeToString(original)
        val decoded = json.decodeFromString<Route.WriteReview>(encoded)
        assertThat(decoded).isEqualTo(original)
    }

    // -------------------------------------------------------------------------
    // Serialized JSON structure verification
    // -------------------------------------------------------------------------

    @Test
    fun `Route ProductDetail serialized JSON contains productId key`() {
        val encoded = json.encodeToString(Route.ProductDetail(productId = "test_key"))
        assertThat(encoded).contains("productId")
        assertThat(encoded).contains("test_key")
    }

    @Test
    fun `Route CategoryProducts serialized JSON contains both keys`() {
        val encoded = json.encodeToString(
            Route.CategoryProducts(categoryId = "cat_key", categoryName = "Electronics"),
        )
        assertThat(encoded).contains("categoryId")
        assertThat(encoded).contains("categoryName")
    }

    @Test
    fun `Route ProductList serialized JSON contains query key`() {
        val encoded = json.encodeToString(Route.ProductList(query = "search_term"))
        assertThat(encoded).contains("query")
    }

    @Test
    fun `Route Login serialized JSON contains returnTo key`() {
        val encoded = json.encodeToString(Route.Login(returnTo = "destination"))
        assertThat(encoded).contains("returnTo")
        assertThat(encoded).contains("destination")
    }

    // -------------------------------------------------------------------------
    // Equality checks — data class contract validation
    // -------------------------------------------------------------------------

    @Test
    fun `two ProductDetail routes with same id are equal`() {
        val a = Route.ProductDetail(productId = "same_id")
        val b = Route.ProductDetail(productId = "same_id")
        assertThat(a).isEqualTo(b)
    }

    @Test
    fun `two ProductDetail routes with different ids are not equal`() {
        val a = Route.ProductDetail(productId = "id_one")
        val b = Route.ProductDetail(productId = "id_two")
        assertThat(a).isNotEqualTo(b)
    }

    @Test
    fun `two ProductList routes with same params are equal`() {
        val a = Route.ProductList(categoryId = "cat_1", query = "q")
        val b = Route.ProductList(categoryId = "cat_1", query = "q")
        assertThat(a).isEqualTo(b)
    }

    @Test
    fun `ProductList with different query values are not equal`() {
        val a = Route.ProductList(query = "shoes")
        val b = Route.ProductList(query = "boots")
        assertThat(a).isNotEqualTo(b)
    }

    @Test
    fun `two Login routes with same returnTo are equal`() {
        val a = Route.Login(returnTo = "checkout")
        val b = Route.Login(returnTo = "checkout")
        assertThat(a).isEqualTo(b)
    }

    @Test
    fun `Login with null returnTo differs from Login with non-null returnTo`() {
        val a = Route.Login(returnTo = null)
        val b = Route.Login(returnTo = "checkout")
        assertThat(a).isNotEqualTo(b)
    }

    @Test
    fun `two OrderDetail routes with same orderId are equal`() {
        val a = Route.OrderDetail(orderId = "order_1")
        val b = Route.OrderDetail(orderId = "order_1")
        assertThat(a).isEqualTo(b)
    }

    @Test
    fun `Home data object is a singleton - same reference`() {
        val a: Route = Route.Home
        val b: Route = Route.Home
        assertThat(a).isSameInstanceAs(b)
    }

    @Test
    fun `Cart data object is a singleton - same reference`() {
        val a: Route = Route.Cart
        val b: Route = Route.Cart
        assertThat(a).isSameInstanceAs(b)
    }
}
