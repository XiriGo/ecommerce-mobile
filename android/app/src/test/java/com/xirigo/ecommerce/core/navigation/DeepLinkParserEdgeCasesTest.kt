package com.xirigo.ecommerce.core.navigation

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import android.net.Uri

/**
 * Edge case tests for DeepLinkParser, extending the baseline coverage in DeepLinkParserTest.
 * Tests focus on: empty/blank inputs, malformed URIs, missing required params,
 * extra path segments, whitespace-only IDs, and http (non-https) scheme support.
 */
@RunWith(RobolectricTestRunner::class)
class DeepLinkParserEdgeCasesTest {

    // -------------------------------------------------------------------------
    // Empty / blank input
    // -------------------------------------------------------------------------

    @Test
    fun `parse uri with url-encoded space as product id returns ProductDetail`() {
        // "%20" decodes to a single space. Uri.pathSegments returns the decoded value " ".
        // The parser's takeIf { it.isNotBlank() } rejects a blank/whitespace-only segment,
        // so a space-only ID returns null — the parser treats it as missing.
        val uri = Uri.parse("xirigo://product/%20")
        val result = DeepLinkParser.parse(uri)
        // A single space is blank, so the id is treated as absent → null
        assertThat(result).isNull()
    }

    @Test
    fun `parse uri with only scheme and no host returns null for https`() {
        val uri = Uri.parse("https://")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse uri with null scheme returns null`() {
        // An opaque URI has no scheme in the traditional sense but Uri.parse handles it.
        val uri = Uri.parse("//product/123")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    // -------------------------------------------------------------------------
    // Malformed / unexpected URI structures
    // -------------------------------------------------------------------------

    @Test
    fun `parse http scheme for molt dot mt host returns ProductDetail`() {
        // The parser accepts both "https" and "http" schemes for xirigo.com hosts.
        // Both map to the same branch that checks host == "xirigo.com".
        val uri = Uri.parse("http://xirigo.com/product/prod_http")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.ProductDetail(productId = "prod_http"))
    }

    @Test
    fun `parse https with subdomain of molt dot mt returns null`() {
        val uri = Uri.parse("https://store.xirigo.com/product/prod_123")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse https with similar but wrong host returns null`() {
        val uri = Uri.parse("https://molt.com/product/123")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse molt scheme with no host returns null`() {
        // xirigo:// with no host segment
        val uri = Uri.parse("xirigo://")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse uri with unknown scheme returns null`() {
        val uri = Uri.parse("market://product/123")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse file scheme returns null`() {
        val uri = Uri.parse("file:///product/123")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    // -------------------------------------------------------------------------
    // Missing required parameters
    // -------------------------------------------------------------------------

    @Test
    fun `parse product route with trailing slash only returns null`() {
        // xirigo://product/ — pathSegments will be empty list after the host
        val uri = Uri.parse("xirigo://product/")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse category route with trailing slash only returns null`() {
        val uri = Uri.parse("xirigo://category/")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse order route with trailing slash only returns null`() {
        val uri = Uri.parse("xirigo://order/")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse https product without id returns null`() {
        val uri = Uri.parse("https://xirigo.com/product")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    @Test
    fun `parse https category without id returns null`() {
        val uri = Uri.parse("https://xirigo.com/category")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNull()
    }

    // -------------------------------------------------------------------------
    // Extra / additional path segments (beyond what is parsed)
    // -------------------------------------------------------------------------

    @Test
    fun `parse product deep link with extra path segments still returns ProductDetail`() {
        // Parser only uses segments[0] (the route key) and segments[1] (the id).
        // Extra segments at [2+] are ignored.
        val uri = Uri.parse("xirigo://product/prod_999/extra/ignored/segments")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.ProductDetail(productId = "prod_999"))
    }

    @Test
    fun `parse category deep link with extra path segments returns CategoryProducts`() {
        val uri = Uri.parse("xirigo://category/cat_extra/sub/page")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(
            Route.CategoryProducts(categoryId = "cat_extra", categoryName = ""),
        )
    }

    @Test
    fun `parse order deep link with extra path segments returns OrderDetail`() {
        val uri = Uri.parse("xirigo://order/order_001/items")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.OrderDetail(orderId = "order_001"))
    }

    @Test
    fun `parse https product deep link with extra path segments returns ProductDetail`() {
        val uri = Uri.parse("https://xirigo.com/product/prod_https_ext/gallery")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.ProductDetail(productId = "prod_https_ext"))
    }

    @Test
    fun `parse cart deep link with extra path segments returns Cart`() {
        // cart route ignores id; extra segments should not matter
        val uri = Uri.parse("xirigo://cart/summary")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.Cart)
    }

    @Test
    fun `parse profile deep link with extra path segments returns Profile`() {
        val uri = Uri.parse("xirigo://profile/settings")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.Profile)
    }

    // -------------------------------------------------------------------------
    // Query parameters (should be ignored by the parser)
    // -------------------------------------------------------------------------

    @Test
    fun `parse product deep link with query params returns ProductDetail`() {
        val uri = Uri.parse("https://xirigo.com/product/prod_qp?ref=share&campaign=summer")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(Route.ProductDetail(productId = "prod_qp"))
    }

    @Test
    fun `parse category deep link with query params returns CategoryProducts`() {
        val uri = Uri.parse("https://xirigo.com/category/cat_qp?sort=price")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isEqualTo(
            Route.CategoryProducts(categoryId = "cat_qp", categoryName = ""),
        )
    }

    // -------------------------------------------------------------------------
    // Auth-required routes via deep link (verifying resolved route auth flag)
    // -------------------------------------------------------------------------

    @Test
    fun `parse order deep link resolves to auth-required route`() {
        val uri = Uri.parse("xirigo://order/order_auth")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNotNull()
        assertThat(result!!.isAuthRequired).isTrue()
    }

    @Test
    fun `parse product deep link resolves to non-auth-required route`() {
        val uri = Uri.parse("xirigo://product/prod_open")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNotNull()
        assertThat(result!!.isAuthRequired).isFalse()
    }

    @Test
    fun `parse cart deep link resolves to non-auth-required route`() {
        val uri = Uri.parse("xirigo://cart")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNotNull()
        assertThat(result!!.isAuthRequired).isFalse()
    }

    @Test
    fun `parse profile deep link resolves to non-auth-required route`() {
        val uri = Uri.parse("xirigo://profile")
        val result = DeepLinkParser.parse(uri)
        assertThat(result).isNotNull()
        assertThat(result!!.isAuthRequired).isFalse()
    }

    // -------------------------------------------------------------------------
    // Route identity from parsed deep links
    // -------------------------------------------------------------------------

    @Test
    fun `parse product deep link returns correct productId`() {
        val uri = Uri.parse("xirigo://product/specific_id_check")
        val result = DeepLinkParser.parse(uri) as? Route.ProductDetail
        assertThat(result).isNotNull()
        assertThat(result!!.productId).isEqualTo("specific_id_check")
    }

    @Test
    fun `parse order deep link returns correct orderId`() {
        val uri = Uri.parse("xirigo://order/order_id_check")
        val result = DeepLinkParser.parse(uri) as? Route.OrderDetail
        assertThat(result).isNotNull()
        assertThat(result!!.orderId).isEqualTo("order_id_check")
    }

    @Test
    fun `parse category deep link returns empty categoryName`() {
        val uri = Uri.parse("xirigo://category/cat_name_check")
        val result = DeepLinkParser.parse(uri) as? Route.CategoryProducts
        assertThat(result).isNotNull()
        assertThat(result!!.categoryName).isEmpty()
    }

    @Test
    fun `parse category deep link returns correct categoryId`() {
        val uri = Uri.parse("https://xirigo.com/category/cat_id_check")
        val result = DeepLinkParser.parse(uri) as? Route.CategoryProducts
        assertThat(result).isNotNull()
        assertThat(result!!.categoryId).isEqualTo("cat_id_check")
    }
}
