package com.molt.marketplace.core.network

data class PaginationMeta(
    val count: Int,
    val limit: Int,
    val offset: Int,
) {
    val hasMore: Boolean
        get() = offset + limit < count
}
