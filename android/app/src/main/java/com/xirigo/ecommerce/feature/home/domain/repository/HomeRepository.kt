package com.xirigo.ecommerce.feature.home.domain.repository

import com.xirigo.ecommerce.feature.home.domain.model.DailyDeal
import com.xirigo.ecommerce.feature.home.domain.model.FlashSale
import com.xirigo.ecommerce.feature.home.domain.model.HomeBanner
import com.xirigo.ecommerce.feature.home.domain.model.HomeCategory
import com.xirigo.ecommerce.feature.home.domain.model.HomeProduct

interface HomeRepository {
    suspend fun getBanners(): List<HomeBanner>
    suspend fun getCategories(): List<HomeCategory>
    suspend fun getPopularProducts(): List<HomeProduct>
    suspend fun getDailyDeal(): DailyDeal?
    suspend fun getNewArrivals(): List<HomeProduct>
    suspend fun getFlashSale(): FlashSale?
}
