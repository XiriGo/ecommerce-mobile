package com.xirigo.ecommerce.core.navigation

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class RouteAuthTest {

    @Test
    fun `Home does not require auth`() {
        assertThat(Route.Home.isAuthRequired).isFalse()
    }

    @Test
    fun `Categories does not require auth`() {
        assertThat(Route.Categories.isAuthRequired).isFalse()
    }

    @Test
    fun `CategoryProducts does not require auth`() {
        assertThat(Route.CategoryProducts("id", "name").isAuthRequired).isFalse()
    }

    @Test
    fun `ProductList does not require auth`() {
        assertThat(Route.ProductList().isAuthRequired).isFalse()
    }

    @Test
    fun `ProductDetail does not require auth`() {
        assertThat(Route.ProductDetail("id").isAuthRequired).isFalse()
    }

    @Test
    fun `ProductSearch does not require auth`() {
        assertThat(Route.ProductSearch.isAuthRequired).isFalse()
    }

    @Test
    fun `VendorStore does not require auth`() {
        assertThat(Route.VendorStore("id").isAuthRequired).isFalse()
    }

    @Test
    fun `ProductReviews does not require auth`() {
        assertThat(Route.ProductReviews("id").isAuthRequired).isFalse()
    }

    @Test
    fun `Cart does not require auth`() {
        assertThat(Route.Cart.isAuthRequired).isFalse()
    }

    @Test
    fun `Profile does not require auth`() {
        assertThat(Route.Profile.isAuthRequired).isFalse()
    }

    @Test
    fun `Login does not require auth`() {
        assertThat(Route.Login().isAuthRequired).isFalse()
    }

    @Test
    fun `Register does not require auth`() {
        assertThat(Route.Register.isAuthRequired).isFalse()
    }

    @Test
    fun `ForgotPassword does not require auth`() {
        assertThat(Route.ForgotPassword.isAuthRequired).isFalse()
    }

    @Test
    fun `Onboarding does not require auth`() {
        assertThat(Route.Onboarding.isAuthRequired).isFalse()
    }

    @Test
    fun `RecentlyViewed does not require auth`() {
        assertThat(Route.RecentlyViewed.isAuthRequired).isFalse()
    }

    @Test
    fun `Checkout requires auth`() {
        assertThat(Route.Checkout.isAuthRequired).isTrue()
    }

    @Test
    fun `CheckoutAddress requires auth`() {
        assertThat(Route.CheckoutAddress.isAuthRequired).isTrue()
    }

    @Test
    fun `CheckoutShipping requires auth`() {
        assertThat(Route.CheckoutShipping.isAuthRequired).isTrue()
    }

    @Test
    fun `CheckoutPayment requires auth`() {
        assertThat(Route.CheckoutPayment.isAuthRequired).isTrue()
    }

    @Test
    fun `OrderConfirmation requires auth`() {
        assertThat(Route.OrderConfirmation("id").isAuthRequired).isTrue()
    }

    @Test
    fun `OrderList requires auth`() {
        assertThat(Route.OrderList.isAuthRequired).isTrue()
    }

    @Test
    fun `OrderDetail requires auth`() {
        assertThat(Route.OrderDetail("id").isAuthRequired).isTrue()
    }

    @Test
    fun `Settings requires auth`() {
        assertThat(Route.Settings.isAuthRequired).isTrue()
    }

    @Test
    fun `AddressManagement requires auth`() {
        assertThat(Route.AddressManagement.isAuthRequired).isTrue()
    }

    @Test
    fun `Wishlist requires auth`() {
        assertThat(Route.Wishlist.isAuthRequired).isTrue()
    }

    @Test
    fun `PaymentMethods requires auth`() {
        assertThat(Route.PaymentMethods.isAuthRequired).isTrue()
    }

    @Test
    fun `Notifications requires auth`() {
        assertThat(Route.Notifications.isAuthRequired).isTrue()
    }

    @Test
    fun `WriteReview requires auth`() {
        assertThat(Route.WriteReview("id").isAuthRequired).isTrue()
    }

    @Test
    fun `PriceAlerts requires auth`() {
        assertThat(Route.PriceAlerts.isAuthRequired).isTrue()
    }
}
