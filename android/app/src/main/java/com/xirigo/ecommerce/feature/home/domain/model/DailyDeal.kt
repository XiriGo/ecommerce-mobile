package com.xirigo.ecommerce.feature.home.domain.model

data class DailyDeal(
    val productId: String,
    val title: String,
    val imageUrl: String?,
    val price: String,
    val originalPrice: String,
    val currencyCode: String,
    val endTime: Long,
)
