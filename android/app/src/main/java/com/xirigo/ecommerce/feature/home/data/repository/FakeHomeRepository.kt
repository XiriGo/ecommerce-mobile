package com.xirigo.ecommerce.feature.home.data.repository

import javax.inject.Inject
import com.xirigo.ecommerce.feature.home.domain.model.DailyDeal
import com.xirigo.ecommerce.feature.home.domain.model.FlashSale
import com.xirigo.ecommerce.feature.home.domain.model.HomeBanner
import com.xirigo.ecommerce.feature.home.domain.model.HomeCategory
import com.xirigo.ecommerce.feature.home.domain.model.HomeProduct
import com.xirigo.ecommerce.feature.home.domain.repository.HomeRepository

class FakeHomeRepository @Inject constructor() : HomeRepository {

    override suspend fun getBanners(): List<HomeBanner> = SampleData.Banners

    override suspend fun getCategories(): List<HomeCategory> = SampleData.Categories

    override suspend fun getPopularProducts(): List<HomeProduct> = SampleData.PopularProducts

    override suspend fun getDailyDeal(): DailyDeal = DailyDeal(
        productId = "prod-deal-1",
        title = "Nike Air Zoom Pegasus",
        imageUrl = null,
        price = "89.99",
        originalPrice = "149.99",
        currencyCode = CURRENCY_USD,
        endTime = System.currentTimeMillis() + EIGHT_HOURS_MILLIS,
    )

    override suspend fun getNewArrivals(): List<HomeProduct> = SampleData.NewArrivals

    override suspend fun getFlashSale(): FlashSale = FlashSale(
        id = "flash-1",
        title = "Flash Sale - Up to 70% Off!",
        imageUrl = null,
        actionUrl = null,
    )

    private companion object {
        const val EIGHT_HOURS_MILLIS = 8 * 60 * 60 * 1000L
        const val CURRENCY_USD = "usd"
    }
}

private object SampleData {
    private const val CURRENCY_USD = "usd"
    private const val VENDOR_TECH_STORE = "TechStore"
    private const val VENDOR_SPORT_ZONE = "SportZone"
    private const val VENDOR_HOME_DECOR = "HomeDecor"

    val Banners = listOf(
        HomeBanner(
            id = "banner-1",
            title = "Summer Sale",
            subtitle = "Up to 50% off selected items",
            imageUrl = null,
            tag = "NEW SEASON",
            actionProductId = null,
            actionCategoryId = "cat-fashion",
        ),
        HomeBanner(
            id = "banner-2",
            title = "New Collection",
            subtitle = "Explore the latest arrivals",
            imageUrl = null,
            tag = null,
            actionProductId = null,
            actionCategoryId = "cat-electronics",
        ),
        HomeBanner(
            id = "banner-3",
            title = "Free Shipping",
            subtitle = "On orders over \$50",
            imageUrl = null,
            tag = "LIMITED TIME",
            actionProductId = null,
            actionCategoryId = null,
        ),
    )

    val Categories = listOf(
        HomeCategory("cat-electronics", "Electronics", "electronics", "Devices", "#37B4F2"),
        HomeCategory("cat-fashion", "Fashion", "fashion", "Checkroom", "#FE75D4"),
        HomeCategory("cat-home", "Home", "home-garden", "Home", "#FDF29C"),
        HomeCategory("cat-sports", "Sports", "sports", "FitnessCenter", "#90D3B1"),
        HomeCategory("cat-books", "Books", "books", "MenuBook", "#FEF170"),
        HomeCategory("cat-gaming", "Gaming", "gaming", "SportsEsports", "#37B4F2"),
    )

    val PopularProducts = listOf(
        HomeProduct(
            id = "prod-1",
            title = "Wireless Noise-Cancelling Headphones",
            imageUrl = null,
            price = "79.99",
            currencyCode = CURRENCY_USD,
            originalPrice = "129.99",
            vendor = VENDOR_TECH_STORE,
            rating = 4.5f,
            reviewCount = 234,
            isNew = false,
        ),
        HomeProduct(
            id = "prod-2",
            title = "Running Sneakers Pro",
            imageUrl = null,
            price = "59.99",
            currencyCode = CURRENCY_USD,
            originalPrice = null,
            vendor = VENDOR_SPORT_ZONE,
            rating = 4.2f,
            reviewCount = 89,
            isNew = false,
        ),
        HomeProduct(
            id = "prod-3",
            title = "Travel Backpack Waterproof",
            imageUrl = null,
            price = "34.99",
            currencyCode = CURRENCY_USD,
            originalPrice = "49.99",
            vendor = "TravelGear",
            rating = 4.7f,
            reviewCount = 156,
            isNew = false,
        ),
        HomeProduct(
            id = "prod-4",
            title = "Smart Watch Series X",
            imageUrl = null,
            price = "199.99",
            currencyCode = CURRENCY_USD,
            originalPrice = "249.99",
            vendor = "WatchWorld",
            rating = 4.8f,
            reviewCount = 412,
            isNew = false,
        ),
        HomeProduct(
            id = "prod-5",
            title = "Premium Bluetooth Speaker",
            imageUrl = null,
            price = "49.99",
            currencyCode = CURRENCY_USD,
            originalPrice = null,
            vendor = "AudioMax",
            rating = 4.3f,
            reviewCount = 178,
            isNew = false,
        ),
        HomeProduct(
            id = "prod-6",
            title = "Ergonomic Office Chair",
            imageUrl = null,
            price = "299.99",
            currencyCode = CURRENCY_USD,
            originalPrice = "399.99",
            vendor = VENDOR_HOME_DECOR,
            rating = 4.6f,
            reviewCount = 312,
            isNew = false,
        ),
    )

    val NewArrivals = listOf(
        HomeProduct(
            id = "prod-new-1",
            title = "Mechanical Gaming Keyboard",
            imageUrl = null,
            price = "89.99",
            currencyCode = CURRENCY_USD,
            originalPrice = null,
            vendor = VENDOR_TECH_STORE,
            rating = 4.6f,
            reviewCount = 67,
            isNew = true,
        ),
        HomeProduct(
            id = "prod-new-2",
            title = "Premium Winter Jacket",
            imageUrl = null,
            price = "119.99",
            currencyCode = CURRENCY_USD,
            originalPrice = "159.99",
            vendor = "UrbanStyle",
            rating = 4.3f,
            reviewCount = 42,
            isNew = true,
        ),
        HomeProduct(
            id = "prod-new-3",
            title = "Modern Desk Lamp LED",
            imageUrl = null,
            price = "44.99",
            currencyCode = CURRENCY_USD,
            originalPrice = null,
            vendor = VENDOR_HOME_DECOR,
            rating = 4.4f,
            reviewCount = 98,
            isNew = true,
        ),
        HomeProduct(
            id = "prod-new-4",
            title = "Yoga Mat Premium",
            imageUrl = null,
            price = "29.99",
            currencyCode = CURRENCY_USD,
            originalPrice = "39.99",
            vendor = VENDOR_SPORT_ZONE,
            rating = 4.5f,
            reviewCount = 53,
            isNew = true,
        ),
        HomeProduct(
            id = "prod-new-5",
            title = "Ceramic Coffee Mug Set",
            imageUrl = null,
            price = "24.99",
            currencyCode = CURRENCY_USD,
            originalPrice = null,
            vendor = VENDOR_HOME_DECOR,
            rating = 4.1f,
            reviewCount = 31,
            isNew = true,
        ),
        HomeProduct(
            id = "prod-new-6",
            title = "Wireless Charging Pad",
            imageUrl = null,
            price = "19.99",
            currencyCode = CURRENCY_USD,
            originalPrice = "29.99",
            vendor = VENDOR_TECH_STORE,
            rating = 4.0f,
            reviewCount = 76,
            isNew = true,
        ),
    )
}
