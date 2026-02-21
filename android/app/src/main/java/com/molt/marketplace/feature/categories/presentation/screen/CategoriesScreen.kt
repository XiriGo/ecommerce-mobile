package com.molt.marketplace.feature.categories.presentation.screen

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
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Checkroom
import androidx.compose.material.icons.outlined.Devices
import androidx.compose.material.icons.outlined.FitnessCenter
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.automirrored.outlined.MenuBook
import androidx.compose.material.icons.outlined.MoreHoriz
import androidx.compose.material.icons.outlined.Pets
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.SportsEsports
import androidx.compose.material.icons.outlined.Toys
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import com.molt.marketplace.R
import com.molt.marketplace.core.designsystem.theme.MoltCornerRadius
import com.molt.marketplace.core.designsystem.theme.MoltElevation
import com.molt.marketplace.core.designsystem.theme.MoltSpacing
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
fun CategoriesScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(top = MoltSpacing.ScreenPaddingVertical),
    ) {
        CategoriesSearchBar()
        Spacer(modifier = Modifier.height(MoltSpacing.Base))
        CategoriesGrid()
    }
}

@Composable
private fun CategoriesSearchBar() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = MoltSpacing.ScreenPaddingHorizontal)
            .clickable { /* Search click */ },
        shape = RoundedCornerShape(MoltCornerRadius.Large),
        elevation = CardDefaults.cardElevation(defaultElevation = MoltElevation.Level1),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant,
        ),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = MoltSpacing.Base, vertical = MoltSpacing.MD),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = Icons.Outlined.Search,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(modifier = Modifier.width(MoltSpacing.SM))
            Text(
                text = stringResource(R.string.categories_search_hint),
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Immutable
private data class CategoryData(
    val name: String,
    val icon: ImageVector,
    val itemCount: Int,
)

@Composable
private fun CategoriesGrid() {
    val categories = listOf(
        CategoryData(stringResource(R.string.home_category_electronics), Icons.Outlined.Devices, 1240),
        CategoryData(stringResource(R.string.home_category_fashion), Icons.Outlined.Checkroom, 3560),
        CategoryData(stringResource(R.string.home_category_home), Icons.Outlined.Home, 890),
        CategoryData(stringResource(R.string.home_category_sports), Icons.Outlined.FitnessCenter, 720),
        CategoryData(stringResource(R.string.home_category_books), Icons.AutoMirrored.Outlined.MenuBook, 2150),
        CategoryData(stringResource(R.string.home_category_gaming), Icons.Outlined.SportsEsports, 560),
        CategoryData(stringResource(R.string.categories_toys), Icons.Outlined.Toys, 430),
        CategoryData(stringResource(R.string.categories_pets), Icons.Outlined.Pets, 310),
        CategoryData(stringResource(R.string.categories_more), Icons.Outlined.MoreHoriz, 0),
    )

    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            horizontal = MoltSpacing.ScreenPaddingHorizontal,
            vertical = MoltSpacing.SM,
        ),
        horizontalArrangement = Arrangement.spacedBy(MoltSpacing.ProductGridSpacing),
        verticalArrangement = Arrangement.spacedBy(MoltSpacing.ProductGridSpacing),
    ) {
        items(categories) { category ->
            CategoryCard(category = category)
        }
    }
}

@Composable
private fun CategoryCard(category: CategoryData) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { /* Category click */ },
        shape = RoundedCornerShape(MoltCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = MoltElevation.Level2),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface,
        ),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(MoltSpacing.Base),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Icon(
                imageVector = category.icon,
                contentDescription = category.name,
                modifier = Modifier.size(MoltSpacing.XXL),
                tint = MaterialTheme.colorScheme.primary,
            )
            Spacer(modifier = Modifier.height(MoltSpacing.MD))
            Text(
                text = category.name,
                style = MaterialTheme.typography.titleSmall,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            if (category.itemCount > 0) {
                Spacer(modifier = Modifier.height(MoltSpacing.XS))
                Text(
                    text = stringResource(R.string.categories_item_count, category.itemCount),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun CategoriesScreenPreview() {
    MoltTheme {
        CategoriesScreen()
    }
}
