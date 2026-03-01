package com.xirigo.ecommerce.feature.home.repository

import java.io.IOException
import com.xirigo.ecommerce.feature.home.domain.model.DailyDeal
import com.xirigo.ecommerce.feature.home.domain.model.FlashSale
import com.xirigo.ecommerce.feature.home.domain.model.HomeBanner
import com.xirigo.ecommerce.feature.home.domain.model.HomeCategory
import com.xirigo.ecommerce.feature.home.domain.model.HomeProduct
import com.xirigo.ecommerce.feature.home.domain.repository.HomeRepository

class FakeHomeRepository : HomeRepository {

    var shouldThrow: IOException? = null

    var banners: List<HomeBanner> = listOf(
        HomeBanner(
            id = "banner-1",
            title = "Summer Sale",
            subtitle = "Up to 50% off",
            imageUrl = "https://example.com/banner1.jpg",
            tag = "NEW",
            actionProductId = null,
            actionCategoryId = "cat-1",
        ),
        HomeBanner(
            id = "banner-2",
            title = "New Collection",
            subtitle = "Latest arrivals",
            imageUrl = "https://example.com/banner2.jpg",
            tag = null,
            actionProductId = null,
            actionCategoryId = "cat-2",
        ),
    )

    var categories: List<HomeCategory> = listOf(
        HomeCategory("cat-1", "Electronics", "electronics", "Devices", "#37B4F2"),
        HomeCategory("cat-2", "Fashion", "fashion", "Checkroom", "#FE75D4"),
    )

    var popularProducts: List<HomeProduct> = listOf(
        HomeProduct(
            id = "prod-1",
            title = "Headphones",
            imageUrl = "https://example.com/prod1.jpg",
            price = "79.99",
            currencyCode = "usd",
            originalPrice = "129.99",
            vendor = "TechStore",
            rating = 4.5f,
            reviewCount = 234,
            isNew = false,
        ),
        HomeProduct(
            id = "prod-2",
            title = "Sneakers",
            imageUrl = "https://example.com/prod2.jpg",
            price = "59.99",
            currencyCode = "usd",
            originalPrice = null,
            vendor = "SportZone",
            rating = 4.2f,
            reviewCount = 89,
            isNew = false,
        ),
    )

    var dailyDeal: DailyDeal? = DailyDeal(
        productId = "prod-deal-1",
        title = "Nike Air Zoom",
        imageUrl = "https://example.com/deal.jpg",
        price = "89.99",
        originalPrice = "149.99",
        currencyCode = "usd",
        endTime = System.currentTimeMillis() + 8 * 60 * 60 * 1000L,
    )

    var newArrivals: List<HomeProduct> = listOf(
        HomeProduct(
            id = "prod-new-1",
            title = "Gaming Keyboard",
            imageUrl = "https://example.com/keyboard.jpg",
            price = "89.99",
            currencyCode = "usd",
            originalPrice = null,
            vendor = "TechStore",
            rating = 4.6f,
            reviewCount = 67,
            isNew = true,
        ),
    )

    var flashSale: FlashSale? = FlashSale(
        id = "flash-1",
        title = "Flash Sale - Up to 70% Off!",
        imageUrl = "https://example.com/flash.jpg",
        actionUrl = null,
    )

    override suspend fun getBanners(): List<HomeBanner> {
        shouldThrow?.let { throw it }
        return banners
    }

    override suspend fun getCategories(): List<HomeCategory> {
        shouldThrow?.let { throw it }
        return categories
    }

    override suspend fun getPopularProducts(): List<HomeProduct> {
        shouldThrow?.let { throw it }
        return popularProducts
    }

    override suspend fun getDailyDeal(): DailyDeal? {
        shouldThrow?.let { throw it }
        return dailyDeal
    }

    override suspend fun getNewArrivals(): List<HomeProduct> {
        shouldThrow?.let { throw it }
        return newArrivals
    }

    override suspend fun getFlashSale(): FlashSale? {
        shouldThrow?.let { throw it }
        return flashSale
    }
}
