package com.xirigo.ecommerce.feature.home.presentation.screen

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collectLatest
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.MenuBook
import androidx.compose.material.icons.outlined.Checkroom
import androidx.compose.material.icons.outlined.Devices
import androidx.compose.material.icons.outlined.FitnessCenter
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.SportsEsports
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
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
import com.xirigo.ecommerce.core.designsystem.component.XGProductCard
import com.xirigo.ecommerce.core.designsystem.component.XGSectionHeader
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
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

private const val AUTO_SCROLL_DELAY_MS = 5000L

@Composable
fun HomeScreen(modifier: Modifier = Modifier, viewModel: HomeViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val isRefreshing by viewModel.isRefreshing.collectAsStateWithLifecycle()

    HomeScreenContent(
        uiState = uiState,
        isRefreshing = isRefreshing,
        onEvent = viewModel::onEvent,
        modifier = modifier,
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun HomeScreenContent(
    uiState: HomeUiState,
    isRefreshing: Boolean,
    onEvent: (HomeEvent) -> Unit,
    modifier: Modifier = Modifier,
) {
    when (uiState) {
        is HomeUiState.Loading -> {
            XGLoadingView(modifier = modifier)
        }
        is HomeUiState.Error -> {
            XGErrorView(
                message = uiState.message,
                onRetry = { onEvent(HomeEvent.RetryTapped) },
                modifier = modifier,
            )
        }
        is HomeUiState.Success -> {
            PullToRefreshBox(
                isRefreshing = isRefreshing,
                onRefresh = { onEvent(HomeEvent.Refresh) },
                modifier = modifier.fillMaxSize(),
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(rememberScrollState()),
                ) {
                    Spacer(modifier = Modifier.height(XGSpacing.Base))
                    SearchBarSection(onSearchClick = { onEvent(HomeEvent.SearchBarTapped) })
                    Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
                    HeroBannerSection(banners = uiState.data.banners, onEvent = onEvent)
                    Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
                    CategoriesSection(
                        categories = uiState.data.categories,
                        onEvent = onEvent,
                    )
                    Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
                    PopularProductsSection(
                        products = uiState.data.popularProducts,
                        wishedProductIds = uiState.data.wishedProductIds,
                        onEvent = onEvent,
                    )
                    if (uiState.data.dailyDeal != null) {
                        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
                        DailyDealSection(
                            deal = uiState.data.dailyDeal,
                            onEvent = onEvent,
                        )
                    }
                    Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
                    NewArrivalsSection(
                        products = uiState.data.newArrivals,
                        wishedProductIds = uiState.data.wishedProductIds,
                        onEvent = onEvent,
                    )
                    if (uiState.data.flashSale != null) {
                        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
                        FlashSaleSection(flashSale = uiState.data.flashSale)
                    }
                    Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
                }
            }
        }
    }
}

@Composable
private fun SearchBarSection(onSearchClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = XGSpacing.ScreenPaddingHorizontal)
            .clickable(onClick = onSearchClick),
        shape = RoundedCornerShape(XGCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = XGElevation.Level1),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant,
        ),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = XGSpacing.Base, vertical = XGSpacing.MD),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = Icons.Outlined.Search,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(modifier = Modifier.width(XGSpacing.SM))
            Text(
                text = stringResource(R.string.home_search_hint),
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
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
                    delay(AUTO_SCROLL_DELAY_MS)
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
    ProductGrid(
        products = products,
        wishedProductIds = wishedProductIds,
        onEvent = onEvent,
        showDelivery = false,
    )
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
        showDelivery = true,
    )
}

@Composable
private fun ProductGrid(
    products: List<HomeProduct>,
    wishedProductIds: Set<String>,
    onEvent: (HomeEvent) -> Unit,
    showDelivery: Boolean,
) {
    val deliveryText: String? = if (showDelivery) {
        stringResource(R.string.home_delivery_badge, "23:59", "Monday")
    } else {
        null
    }
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
                showAddToCart = showDelivery,
            )
        }
    }
}

@Composable
private fun ProductGridRow(
    rowProducts: List<HomeProduct>,
    wishedProductIds: Set<String>,
    onEvent: (HomeEvent) -> Unit,
    deliveryLabel: String?,
    showAddToCart: Boolean,
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
                onAddToCartClick = if (showAddToCart) {
                    {}
                } else {
                    null
                },
                onClick = { onEvent(HomeEvent.ProductTapped(product.id)) },
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
            isRefreshing = false,
            onEvent = {},
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun HomeScreenErrorPreview() {
    XGTheme {
        HomeScreenContent(
            uiState = HomeUiState.Error(message = "Something went wrong"),
            isRefreshing = false,
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
            isRefreshing = false,
            onEvent = {},
        )
    }
}
