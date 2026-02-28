package com.xirigo.ecommerce.feature.home.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowForward
import androidx.compose.material.icons.automirrored.outlined.MenuBook
import androidx.compose.material.icons.outlined.Checkroom
import androidx.compose.material.icons.outlined.Devices
import androidx.compose.material.icons.outlined.FitnessCenter
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.SportsEsports
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.component.XGProductCard
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun HomeScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
    ) {
        WelcomeHeader()
        Spacer(modifier = Modifier.height(XGSpacing.Base))
        SearchBarSection()
        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
        FeaturedBannersSection()
        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
        CategoriesRowSection()
        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
        PopularProductsSection()
        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
        NewArrivalsSection()
        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
    }
}

@Composable
private fun WelcomeHeader() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.primaryContainer)
            .padding(
                horizontal = XGSpacing.ScreenPaddingHorizontal,
                vertical = XGSpacing.LG,
            ),
    ) {
        Text(
            text = stringResource(R.string.home_welcome_title),
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onPrimaryContainer,
        )
        Spacer(modifier = Modifier.height(XGSpacing.XS))
        Text(
            text = stringResource(R.string.home_welcome_subtitle),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f),
        )
    }
}

@Composable
private fun SearchBarSection() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = XGSpacing.ScreenPaddingHorizontal)
            .clickable { /* Visual only */ },
        shape = RoundedCornerShape(XGCornerRadius.Large),
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

@Immutable
private data class BannerData(
    val title: String,
    val subtitle: String,
    val gradientStart: Color,
    val gradientEnd: Color,
)

@Composable
private fun FeaturedBannersSection() {
    val banners = listOf(
        BannerData(
            title = stringResource(R.string.home_banner_summer_title),
            subtitle = stringResource(R.string.home_banner_summer_subtitle),
            gradientStart = MaterialTheme.colorScheme.primary,
            gradientEnd = MaterialTheme.colorScheme.tertiary,
        ),
        BannerData(
            title = stringResource(R.string.home_banner_new_title),
            subtitle = stringResource(R.string.home_banner_new_subtitle),
            gradientStart = MaterialTheme.colorScheme.secondary,
            gradientEnd = MaterialTheme.colorScheme.primary,
        ),
        BannerData(
            title = stringResource(R.string.home_banner_free_shipping_title),
            subtitle = stringResource(R.string.home_banner_free_shipping_subtitle),
            gradientStart = MaterialTheme.colorScheme.tertiary,
            gradientEnd = MaterialTheme.colorScheme.secondary,
        ),
    )

    LazyRow(
        contentPadding = PaddingValues(horizontal = XGSpacing.ScreenPaddingHorizontal),
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.MD),
    ) {
        items(banners) { banner ->
            BannerCard(banner = banner)
        }
    }
}

@Composable
private fun BannerCard(banner: BannerData) {
    Box(
        modifier = Modifier
            .width(300.dp)
            .height(150.dp)
            .clip(RoundedCornerShape(XGCornerRadius.Large))
            .background(
                brush = Brush.horizontalGradient(
                    colors = listOf(banner.gradientStart, banner.gradientEnd),
                ),
            )
            .clickable { /* Banner click */ },
        contentAlignment = Alignment.CenterStart,
    ) {
        Column(
            modifier = Modifier.padding(XGSpacing.LG),
        ) {
            Text(
                text = banner.title,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = Color.White,
            )
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            Text(
                text = banner.subtitle,
                style = MaterialTheme.typography.bodyMedium,
                color = Color.White.copy(alpha = 0.9f),
            )
        }
    }
}

@Immutable
private data class CategoryItem(
    val name: String,
    val icon: ImageVector,
)

@Composable
private fun CategoriesRowSection() {
    val categories = listOf(
        CategoryItem(stringResource(R.string.home_category_electronics), Icons.Outlined.Devices),
        CategoryItem(stringResource(R.string.home_category_fashion), Icons.Outlined.Checkroom),
        CategoryItem(stringResource(R.string.home_category_home), Icons.Outlined.Home),
        CategoryItem(stringResource(R.string.home_category_sports), Icons.Outlined.FitnessCenter),
        CategoryItem(stringResource(R.string.home_category_books), Icons.AutoMirrored.Outlined.MenuBook),
        CategoryItem(stringResource(R.string.home_category_gaming), Icons.Outlined.SportsEsports),
    )

    SectionHeader(title = stringResource(R.string.home_section_categories))

    LazyRow(
        contentPadding = PaddingValues(horizontal = XGSpacing.ScreenPaddingHorizontal),
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.Base),
    ) {
        items(categories) { category ->
            CategoryCircleItem(category = category)
        }
    }
}

@Composable
private fun CategoryCircleItem(category: CategoryItem) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.clickable { /* Category click */ },
    ) {
        Box(
            modifier = Modifier
                .size(64.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.secondaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = category.icon,
                contentDescription = category.name,
                modifier = Modifier.size(XGSpacing.XL),
                tint = MaterialTheme.colorScheme.onSecondaryContainer,
            )
        }
        Spacer(modifier = Modifier.height(XGSpacing.SM))
        Text(
            text = category.name,
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurface,
        )
    }
}

@Immutable
private data class ProductSample(
    val title: String,
    val price: String,
    val originalPrice: String?,
    val vendor: String,
    val rating: Float,
    val reviewCount: Int,
)

private val popularProducts: List<ProductSample>
    @Composable
    get() = listOf(
        ProductSample(
            title = stringResource(R.string.home_product_headphones),
            price = "$79.99",
            originalPrice = "$129.99",
            vendor = "TechStore",
            rating = 4.5f,
            reviewCount = 234,
        ),
        ProductSample(
            title = stringResource(R.string.home_product_sneakers),
            price = "$59.99",
            originalPrice = null,
            vendor = "SportZone",
            rating = 4.2f,
            reviewCount = 89,
        ),
        ProductSample(
            title = stringResource(R.string.home_product_backpack),
            price = "$34.99",
            originalPrice = "$49.99",
            vendor = "TravelGear",
            rating = 4.7f,
            reviewCount = 156,
        ),
        ProductSample(
            title = stringResource(R.string.home_product_watch),
            price = "$199.99",
            originalPrice = "$249.99",
            vendor = "WatchWorld",
            rating = 4.8f,
            reviewCount = 412,
        ),
    )

@Composable
private fun PopularProductsSection() {
    val products = popularProducts

    SectionHeader(title = stringResource(R.string.home_section_popular))

    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        modifier = Modifier
            .fillMaxWidth()
            .height(600.dp)
            .padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.ProductGridSpacing),
        verticalArrangement = Arrangement.spacedBy(XGSpacing.ProductGridSpacing),
        userScrollEnabled = false,
    ) {
        items(products) { product ->
            XGProductCard(
                imageUrl = null,
                title = product.title,
                price = product.price,
                originalPrice = product.originalPrice,
                vendorName = product.vendor,
                rating = product.rating,
                reviewCount = product.reviewCount,
                onClick = { /* Product click */ },
            )
        }
    }
}

@Composable
private fun NewArrivalsSection() {
    val newProducts = listOf(
        ProductSample(
            title = stringResource(R.string.home_product_keyboard),
            price = "$89.99",
            originalPrice = null,
            vendor = "TechStore",
            rating = 4.6f,
            reviewCount = 67,
        ),
        ProductSample(
            title = stringResource(R.string.home_product_jacket),
            price = "$119.99",
            originalPrice = "$159.99",
            vendor = "UrbanStyle",
            rating = 4.3f,
            reviewCount = 42,
        ),
        ProductSample(
            title = stringResource(R.string.home_product_lamp),
            price = "$44.99",
            originalPrice = null,
            vendor = "HomeDecor",
            rating = 4.4f,
            reviewCount = 98,
        ),
    )

    SectionHeader(title = stringResource(R.string.home_section_new_arrivals))

    LazyRow(
        contentPadding = PaddingValues(horizontal = XGSpacing.ScreenPaddingHorizontal),
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.MD),
    ) {
        items(newProducts) { product ->
            XGProductCard(
                imageUrl = null,
                title = product.title,
                price = product.price,
                originalPrice = product.originalPrice,
                vendorName = product.vendor,
                rating = product.rating,
                reviewCount = product.reviewCount,
                onClick = { /* Product click */ },
                modifier = Modifier.width(200.dp),
            )
        }
    }
}

@Composable
private fun SectionHeader(title: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                horizontal = XGSpacing.ScreenPaddingHorizontal,
                vertical = XGSpacing.SM,
            ),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
        )
        Icon(
            imageVector = Icons.AutoMirrored.Outlined.ArrowForward,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun HomeScreenPreview() {
    XGTheme {
        HomeScreen()
    }
}
