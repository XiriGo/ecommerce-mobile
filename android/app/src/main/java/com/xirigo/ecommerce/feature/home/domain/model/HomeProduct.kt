package com.xirigo.ecommerce.feature.home.domain.model

data class HomeProduct(
    val id: String,
    val title: String,
    val imageUrl: String?,
    val price: String,
    val currencyCode: String,
    val originalPrice: String?,
    val vendor: String,
    val rating: Float?,
    val reviewCount: Int?,
    val isNew: Boolean,
)
