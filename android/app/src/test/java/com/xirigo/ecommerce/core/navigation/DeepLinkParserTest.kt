package com.xirigo.ecommerce.core.navigation

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import android.net.Uri

@RunWith(RobolectricTestRunner::class)
class DeepLinkParserTest {

    @Test
    fun `parse molt product deep link returns ProductDetail`() {
        val uri = Uri.parse("xirigo://product/prod_123")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.ProductDetail(productId = "prod_123"))
    }

    @Test
    fun `parse https product deep link returns ProductDetail`() {
        val uri = Uri.parse("https://xirigo.com/product/prod_456")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.ProductDetail(productId = "prod_456"))
    }

    @Test
    fun `parse molt category deep link returns CategoryProducts`() {
        val uri = Uri.parse("xirigo://category/cat_789")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.CategoryProducts(categoryId = "cat_789", categoryName = ""))
    }

    @Test
    fun `parse https category deep link returns CategoryProducts`() {
        val uri = Uri.parse("https://xirigo.com/category/cat_abc")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.CategoryProducts(categoryId = "cat_abc", categoryName = ""))
    }

    @Test
    fun `parse molt cart deep link returns Cart`() {
        val uri = Uri.parse("xirigo://cart")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.Cart)
    }

    @Test
    fun `parse molt order deep link returns OrderDetail`() {
        val uri = Uri.parse("xirigo://order/order_001")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.OrderDetail(orderId = "order_001"))
    }

    @Test
    fun `parse molt profile deep link returns Profile`() {
        val uri = Uri.parse("xirigo://profile")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.Profile)
    }

    @Test
    fun `parse unknown route returns null`() {
        val uri = Uri.parse("xirigo://unknown/path")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse product without id returns null`() {
        val uri = Uri.parse("xirigo://product")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse product with empty id returns null`() {
        val uri = Uri.parse("xirigo://product/")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse category without id returns null`() {
        val uri = Uri.parse("xirigo://category")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse order without id returns null`() {
        val uri = Uri.parse("xirigo://order")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse wrong host for https returns null`() {
        val uri = Uri.parse("https://other.com/product/123")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse unsupported scheme returns null`() {
        val uri = Uri.parse("ftp://xirigo.com/product/123")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse empty uri returns null`() {
        val uri = Uri.parse("")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }
}
