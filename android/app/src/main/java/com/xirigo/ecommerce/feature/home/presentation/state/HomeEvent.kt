package com.xirigo.ecommerce.feature.home.presentation.state

import com.xirigo.ecommerce.feature.home.domain.model.HomeBanner
import com.xirigo.ecommerce.feature.home.domain.model.HomeCategory

sealed interface HomeEvent {
    data object Refresh : HomeEvent
    data class BannerTapped(val banner: HomeBanner) : HomeEvent
    data class CategoryTapped(val category: HomeCategory) : HomeEvent
    data class ProductTapped(val productId: String) : HomeEvent
    data class WishlistToggled(val productId: String) : HomeEvent
    data class DailyDealTapped(val productId: String) : HomeEvent
    data object SeeAllPopularTapped : HomeEvent
    data object SeeAllNewArrivalsTapped : HomeEvent
    data object SearchBarTapped : HomeEvent
    data object RetryTapped : HomeEvent
}
