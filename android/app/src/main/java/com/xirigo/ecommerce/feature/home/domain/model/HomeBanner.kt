package com.xirigo.ecommerce.feature.home.domain.model

data class HomeBanner(
    val id: String,
    val title: String,
    val subtitle: String,
    val imageUrl: String?,
    val tag: String?,
    val actionProductId: String?,
    val actionCategoryId: String?,
)
