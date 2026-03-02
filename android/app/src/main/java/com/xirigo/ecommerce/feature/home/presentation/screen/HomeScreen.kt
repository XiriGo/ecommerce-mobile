package com.xirigo.ecommerce.feature.home.presentation.screen

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collectLatest
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.MenuBook
import androidx.compose.material.icons.outlined.Checkroom
import androidx.compose.material.icons.outlined.Devices
import androidx.compose.material.icons.outlined.FitnessCenter
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.SportsEsports
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.component.XGCategoryIcon
import com.xirigo.ecommerce.core.designsystem.component.XGDailyDealCard
import com.xirigo.ecommerce.core.designsystem.component.XGErrorView
import com.xirigo.ecommerce.core.designsystem.component.XGFlashSaleBanner
import com.xirigo.ecommerce.core.designsystem.component.XGHeroBanner
import com.xirigo.ecommerce.core.designsystem.component.XGLoadingView
import com.xirigo.ecommerce.core.designsystem.component.XGPaginationDots
import com.xirigo.ecommerce.core.designsystem.component.XGPriceLayout
import com.xirigo.ecommerce.core.designsystem.component.XGPriceSize
import com.xirigo.ecommerce.core.designsystem.component.XGProductCard
import com.xirigo.ecommerce.core.designsystem.component.XGSearchBar
import com.xirigo.ecommerce.core.designsystem.component.XGSectionHeader
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.feature.home.domain.model.DailyDeal
import com.xirigo.ecommerce.feature.home.domain.model.FlashSale
import com.xirigo.ecommerce.feature.home.domain.model.HomeBanner
import com.xirigo.ecommerce.feature.home.domain.model.HomeCategory
import com.xirigo.ecommerce.feature.home.domain.model.HomeProduct
import com.xirigo.ecommerce.feature.home.presentation.state.HomeEvent
import com.xirigo.ecommerce.feature.home.presentation.state.HomeScreenData
import com.xirigo.ecommerce.feature.home.presentation.state.HomeUiState
import com.xirigo.ecommerce.feature.home.presentation.viewmodel.HomeViewModel

// Auto-scroll delay from motion tokens: foundations/motion.json → scroll.autoScrollIntervalMs
private val FeaturedCardWidth = 160.dp
private const val STANDARD_STRIKETHROUGH_FONT_SIZE = 14f

/** Home screen entry point that connects ViewModel to content. */
@Composable
fun HomeScreen(modifier: Modifier = Modifier, viewModel: HomeViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    HomeScreenContent(
        uiState = uiState,
        onEvent = viewModel::onEvent,
        modifier = modifier,
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun HomeScreenContent(
    uiState: HomeUiState,
    onEvent: (HomeEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    when (uiState) {
        is HomeUiState.Loading -> {
            XGLoadingView(modifier = modifier)
        }
        is HomeUiState.Error -> {
            XGErrorView(
                message = stringResource(uiState.messageResId),
                onRetry = { onEvent(HomeEvent.RetryTapped) },
                modifier = modifier,
            )
        }
        is HomeUiState.Success -> {
            PullToRefreshBox(
                isRefreshing = uiState.isRefreshing,
                onRefresh = { onEvent(HomeEvent.Refresh) },
                modifier = modifier.fillMaxSize(),
            ) {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(XGSpacing.SectionSpacing),
                    contentPadding = PaddingValues(
                        top = XGSpacing.Base,
                        bottom = XGSpacing.SectionSpacing,
                    ),
                ) {
                    item(key = "search_bar") {
                        XGSearchBar(
                            hint = stringResource(R.string.home_search_hint),
                            onClick = { onEvent(HomeEvent.SearchBarTapped) },
                            modifier = Modifier.padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
                        )
                    }
                    item(key = "hero_banners") {
                        HeroBannerSection(banners = uiState.data.banners, onEvent = onEvent)
                    }
                    item(key = "categories") {
                        CategoriesSection(
                            categories = uiState.data.categories,
                            onEvent = onEvent,
                        )
                    }
                    item(key = "popular_products") {
                        PopularProductsSection(
                            products = uiState.data.popularProducts,
                            wishedProductIds = uiState.data.wishedProductIds,
                            onEvent = onEvent,
                        )
                    }
                    if (uiState.data.dailyDeal != null) {
                        item(key = "daily_deal") {
                            DailyDealSection(
                                deal = uiState.data.dailyDeal,
                                onEvent = onEvent,
                            )
                        }
                    }
                    item(key = "new_arrivals") {
                        NewArrivalsSection(
                            products = uiState.data.newArrivals,
                            wishedProductIds = uiState.data.wishedProductIds,
                            onEvent = onEvent,
                        )
                    }
                    if (uiState.data.flashSale != null) {
                        item(key = "flash_sale") {
                            FlashSaleSection(flashSale = uiState.data.flashSale)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun HeroBannerSection(banners: List<HomeBanner>, onEvent: (HomeEvent) -> Unit) {
    if (banners.isEmpty()) return

    val pagerState = rememberPagerState(pageCount = { banners.size })

    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.isScrollInProgress }.collectLatest { isScrolling ->
            if (!isScrolling) {
                while (true) {
                    delay(XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS)
                    val nextPage = (pagerState.currentPage + 1) % banners.size
                    pagerState.animateScrollToPage(nextPage)
                }
            }
        }
    }

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        HorizontalPager(
            state = pagerState,
            contentPadding = PaddingValues(horizontal = XGSpacing.ScreenPaddingHorizontal),
            pageSpacing = XGSpacing.MD,
        ) { page ->
            val banner = banners[page]
            XGHeroBanner(
                title = banner.title,
                subtitle = banner.subtitle,
                imageUrl = banner.imageUrl,
                tag = banner.tag,
                onClick = { onEvent(HomeEvent.BannerTapped(banner)) },
            )
        }
        Spacer(modifier = Modifier.height(XGSpacing.MD))
        XGPaginationDots(
            totalPages = banners.size,
            currentPage = pagerState.currentPage,
        )
    }
}

@Composable
private fun CategoriesSection(categories: List<HomeCategory>, onEvent: (HomeEvent) -> Unit) {
    if (categories.isEmpty()) return

    XGSectionHeader(title = stringResource(R.string.home_section_categories))
    Spacer(modifier = Modifier.height(XGSpacing.SM))
    LazyRow(
        contentPadding = PaddingValues(horizontal = XGSpacing.ScreenPaddingHorizontal),
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.Base),
    ) {
        items(categories, key = { it.id }) { category ->
            XGCategoryIcon(
                name = category.name,
                icon = mapCategoryIcon(category.iconName),
                backgroundColor = parseHexColor(category.colorHex),
                onClick = { onEvent(HomeEvent.CategoryTapped(category)) },
            )
        }
    }
}

@Composable
private fun PopularProductsSection(
    products: List<HomeProduct>,
    wishedProductIds: Set<String>,
    onEvent: (HomeEvent) -> Unit,
) {
    if (products.isEmpty()) return

    XGSectionHeader(
        title = stringResource(R.string.home_section_popular),
    )
    Spacer(modifier = Modifier.height(XGSpacing.SM))
    LazyRow(
        contentPadding = PaddingValues(horizontal = XGSpacing.ScreenPaddingHorizontal),
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.ProductGridSpacing),
    ) {
        items(products, key = { it.id }) { product ->
            XGProductCard(
                imageUrl = product.imageUrl,
                title = product.title,
                price = product.price,
                originalPrice = product.originalPrice,
                rating = product.rating,
                reviewCount = product.reviewCount,
                isWishlisted = product.id in wishedProductIds,
                onWishlistToggle = { onEvent(HomeEvent.WishlistToggled(product.id)) },
                onClick = { onEvent(HomeEvent.ProductTapped(product.id)) },
                priceSize = XGPriceSize.Default,
                priceLayout = XGPriceLayout.Stacked,
                showRatingAbovePrice = true,
                modifier = Modifier.width(FeaturedCardWidth),
            )
        }
    }
}

@Composable
private fun DailyDealSection(deal: DailyDeal, onEvent: (HomeEvent) -> Unit) {
    XGSectionHeader(title = stringResource(R.string.home_section_daily_deal))
    Spacer(modifier = Modifier.height(XGSpacing.SM))
    XGDailyDealCard(
        title = deal.title,
        price = deal.price,
        originalPrice = deal.originalPrice,
        endTime = deal.endTime,
        imageUrl = deal.imageUrl,
        onClick = { onEvent(HomeEvent.DailyDealTapped(deal.productId)) },
        modifier = Modifier.padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
    )
}

@Composable
private fun NewArrivalsSection(
    products: List<HomeProduct>,
    wishedProductIds: Set<String>,
    onEvent: (HomeEvent) -> Unit,
) {
    if (products.isEmpty()) return

    XGSectionHeader(
        title = stringResource(R.string.home_section_new_arrivals),
        onSeeAllClick = { onEvent(HomeEvent.SeeAllNewArrivalsTapped) },
    )
    Spacer(modifier = Modifier.height(XGSpacing.SM))
    ProductGrid(
        products = products,
        wishedProductIds = wishedProductIds,
        onEvent = onEvent,
    )
}

@Composable
private fun ProductGrid(
    products: List<HomeProduct>,
    wishedProductIds: Set<String>,
    onEvent: (HomeEvent) -> Unit,
) {
    val deliveryText = stringResource(R.string.home_delivery_badge, "23:59", "Monday")
    val rows = products.chunked(2)
    Column(
        modifier = Modifier.padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
        verticalArrangement = Arrangement.spacedBy(XGSpacing.ProductGridSpacing),
    ) {
        rows.forEach { rowProducts ->
            ProductGridRow(
                rowProducts = rowProducts,
                wishedProductIds = wishedProductIds,
                onEvent = onEvent,
                deliveryLabel = deliveryText,
            )
        }
    }
}

@Composable
private fun ProductGridRow(
    rowProducts: List<HomeProduct>,
    wishedProductIds: Set<String>,
    onEvent: (HomeEvent) -> Unit,
    deliveryLabel: String,
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.ProductGridSpacing),
    ) {
        rowProducts.forEach { product ->
            XGProductCard(
                imageUrl = product.imageUrl,
                title = product.title,
                price = product.price,
                originalPrice = product.originalPrice,
                rating = product.rating,
                reviewCount = product.reviewCount,
                isWishlisted = product.id in wishedProductIds,
                onWishlistToggle = { onEvent(HomeEvent.WishlistToggled(product.id)) },
                deliveryLabel = deliveryLabel,
                // TODO(https://github.com/xirigo/ecommerce-mobile/issues/100): implement add to cart
                onAddToCartClick = {},
                onClick = { onEvent(HomeEvent.ProductTapped(product.id)) },
                priceSize = XGPriceSize.Standard,
                strikethroughFontSize = STANDARD_STRIKETHROUGH_FONT_SIZE,
                priceLayout = XGPriceLayout.Stacked,
                showRatingAbovePrice = true,
                showDeliveryAbovePrice = true,
                modifier = Modifier
                    .weight(1f),
            )
        }
        if (rowProducts.size == 1) {
            Spacer(modifier = Modifier.weight(1f))
        }
    }
}

@Composable
private fun FlashSaleSection(flashSale: FlashSale) {
    XGSectionHeader(title = stringResource(R.string.home_section_flash_sale))
    Spacer(modifier = Modifier.height(XGSpacing.SM))
    XGFlashSaleBanner(
        title = flashSale.title,
        imageUrl = flashSale.imageUrl,
        onClick = { /* Flash sale navigation */ },
        modifier = Modifier.padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
    )
}

private fun mapCategoryIcon(iconName: String): ImageVector = when (iconName) {
    "Devices" -> Icons.Outlined.Devices
    "Checkroom" -> Icons.Outlined.Checkroom
    "Home" -> Icons.Outlined.Home
    "FitnessCenter" -> Icons.Outlined.FitnessCenter
    "MenuBook" -> Icons.AutoMirrored.Outlined.MenuBook
    "SportsEsports" -> Icons.Outlined.SportsEsports
    else -> Icons.Outlined.Devices
}

private fun parseHexColor(hex: String): Color {
    val colorInt = android.graphics.Color.parseColor(hex)
    return Color(colorInt)
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun HomeScreenLoadingPreview() {
    XGTheme {
        HomeScreenContent(
            uiState = HomeUiState.Loading,
            onEvent = {},
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun HomeScreenErrorPreview() {
    XGTheme {
        HomeScreenContent(
            uiState = HomeUiState.Error(messageResId = R.string.common_error_network),
            onEvent = {},
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun HomeScreenSuccessPreview() {
    XGTheme {
        HomeScreenContent(
            uiState = HomeUiState.Success(
                data = HomeScreenData(
                    banners = listOf(
                        HomeBanner(
                            id = "1",
                            title = "Summer Sale",
                            subtitle = "Up to 50% off",
                            imageUrl = null,
                            tag = "NEW SEASON",
                            actionProductId = null,
                            actionCategoryId = null,
                        ),
                    ),
                    categories = listOf(
                        HomeCategory("1", "Electronics", "electronics", "Devices", "#37B4F2"),
                        HomeCategory("2", "Fashion", "fashion", "Checkroom", "#FE75D4"),
                    ),
                    popularProducts = listOf(
                        HomeProduct(
                            id = "1",
                            title = "Wireless Headphones",
                            imageUrl = null,
                            price = "79.99",
                            currencyCode = "usd",
                            originalPrice = "129.99",
                            vendor = "TechStore",
                            rating = 4.5f,
                            reviewCount = 234,
                            isNew = false,
                        ),
                        HomeProduct(
                            id = "2",
                            title = "Running Sneakers",
                            imageUrl = null,
                            price = "59.99",
                            currencyCode = "usd",
                            originalPrice = null,
                            vendor = "SportZone",
                            rating = 4.2f,
                            reviewCount = 89,
                            isNew = false,
                        ),
                    ),
                    dailyDeal = DailyDeal(
                        productId = "deal-1",
                        title = "Nike Air Zoom",
                        imageUrl = null,
                        price = "$89.99",
                        originalPrice = "$149.99",
                        currencyCode = "usd",
                        endTime = System.currentTimeMillis() + 28_800_000L,
                    ),
                    newArrivals = listOf(
                        HomeProduct(
                            id = "3",
                            title = "Gaming Keyboard",
                            imageUrl = null,
                            price = "89.99",
                            currencyCode = "usd",
                            originalPrice = null,
                            vendor = "TechStore",
                            rating = 4.6f,
                            reviewCount = 67,
                            isNew = true,
                        ),
                        HomeProduct(
                            id = "4",
                            title = "Winter Jacket",
                            imageUrl = null,
                            price = "119.99",
                            currencyCode = "usd",
                            originalPrice = "159.99",
                            vendor = "UrbanStyle",
                            rating = 4.3f,
                            reviewCount = 42,
                            isNew = true,
                        ),
                    ),
                    flashSale = FlashSale(
                        id = "flash-1",
                        title = "Flash Sale - 70% Off!",
                        imageUrl = null,
                        actionUrl = null,
                    ),
                    wishedProductIds = setOf("1"),
                ),
            ),
            onEvent = {},
        )
    }
}
