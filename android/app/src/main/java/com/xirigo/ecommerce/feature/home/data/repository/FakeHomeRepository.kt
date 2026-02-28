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
        imageUrl = "https://picsum.photos/seed/deal/400/400",
        price = "89.99",
        originalPrice = "149.99",
        currencyCode = CURRENCY_USD,
        endTime = System.currentTimeMillis() + EIGHT_HOURS_MILLIS,
    )

    override suspend fun getNewArrivals(): List<HomeProduct> = SampleData.NewArrivals

    override suspend fun getFlashSale(): FlashSale = FlashSale(
        id = "flash-1",
        title = "Flash Sale - Up to 70% Off!",
        imageUrl = "https://picsum.photos/seed/flash/700/266",
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
    private const val IMG_BASE = "https://picsum.photos/seed"

    val Banners = listOf(
        HomeBanner(
            id = "banner-1",
            title = "Summer Sale",
            subtitle = "Up to 50% off selected items",
            imageUrl = "$IMG_BASE/banner1/700/384",
            tag = "NEW SEASON",
            actionProductId = null,
            actionCategoryId = "cat-fashion",
        ),
        HomeBanner(
            id = "banner-2",
            title = "New Collection",
            subtitle = "Explore the latest arrivals",
            imageUrl = "$IMG_BASE/banner2/700/384",
            tag = null,
            actionProductId = null,
            actionCategoryId = "cat-electronics",
        ),
        HomeBanner(
            id = "banner-3",
            title = "Free Shipping",
            subtitle = "On orders over \$50",
            imageUrl = "$IMG_BASE/banner3/700/384",
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
            imageUrl = "$IMG_BASE/headphones/400/400",
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
            imageUrl = "$IMG_BASE/sneakers/400/400",
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
            imageUrl = "$IMG_BASE/backpack/400/400",
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
            imageUrl = "$IMG_BASE/watch/400/400",
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
            imageUrl = "$IMG_BASE/speaker/400/400",
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
            imageUrl = "$IMG_BASE/chair/400/400",
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
            imageUrl = "$IMG_BASE/keyboard/400/400",
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
            imageUrl = "$IMG_BASE/jacket/400/400",
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
            imageUrl = "$IMG_BASE/lamp/400/400",
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
            imageUrl = "$IMG_BASE/yoga/400/400",
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
            imageUrl = "$IMG_BASE/mug/400/400",
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
            imageUrl = "$IMG_BASE/charger/400/400",
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
