package com.xirigo.ecommerce.core.navigation

import android.net.Uri

/**
 * Parses deep link URIs (xirigo:// and https://xirigo.com/) into Route objects.
 * Returns null for invalid or unrecognized links.
 */
object DeepLinkParser {

    fun parse(uri: Uri): Route? {
        val segments = extractPathSegments(uri) ?: return null
        return resolveRoute(segments)
    }

    private fun extractPathSegments(uri: Uri): List<String>? {
        val scheme = uri.scheme ?: return null
        return when (scheme) {
            "xirigo" -> uri.host?.let { host -> listOf(host) + uri.pathSegments }
            "https", "http" -> uri.host?.takeIf { it == "xirigo.com" }?.let { uri.pathSegments }
            else -> null
        }
    }

    private fun resolveRoute(segments: List<String>): Route? {
        if (segments.isEmpty()) return null
        val id = segments.getOrNull(1)?.takeIf { it.isNotBlank() }
        return when (segments.first()) {
            "product" -> id?.let { Route.ProductDetail(productId = it) }
            "category" -> id?.let { Route.CategoryProducts(categoryId = it, categoryName = "") }
            "cart" -> Route.Cart
            "order" -> id?.let { Route.OrderDetail(orderId = it) }
            "profile" -> Route.Profile
            else -> null
        }
    }
}
