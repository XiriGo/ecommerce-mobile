package com.molt.marketplace.core.navigation

import android.net.Uri

/**
 * Parses deep link URIs (molt:// and https://molt.mt/) into Route objects.
 * Returns null for invalid or unrecognized links.
 */
object DeepLinkParser {

    fun parse(uri: Uri): Route? {
        val segments = extractPathSegments(uri) ?: return null
        return resolveRoute(segments)
    }

    @Suppress("ReturnCount")
    private fun extractPathSegments(uri: Uri): List<String>? {
        val scheme = uri.scheme ?: return null
        return when (scheme) {
            "molt" -> {
                val host = uri.host ?: return null
                listOf(host) + uri.pathSegments
            }
            "https", "http" -> {
                val host = uri.host ?: return null
                if (host != "molt.mt") return null
                uri.pathSegments
            }
            else -> {
                null
            }
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
