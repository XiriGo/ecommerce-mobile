package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/**
 * Bottom navigation bar with tab items and optional badge counts.
 *
 * Custom composable (NOT Material 3 NavigationBar) that uses XG design tokens
 * for all visual properties: colors from [XGColors], spacing from [XGSpacing],
 * typography from [XGTypography], and motion from [XGMotion].
 *
 * Token source: `shared/design-tokens/components/molecules/xg-bottom-bar.json`
 */
@Composable
fun XGBottomBar(
    items: List<XGTabItem>,
    selectedIndex: Int,
    onTabSelected: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier.fillMaxWidth()) {
        // Top border — 0.5dp borderSubtle divider
        HorizontalDivider(
            thickness = TOP_BORDER_WIDTH,
            color = XGColors.OutlineVariant,
        )

        // Tab items row — 75dp height, bottomNav.background
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(BAR_HEIGHT)
                .background(XGColors.BottomNavBackground),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            items.forEachIndexed { index, item ->
                val isSelected = selectedIndex == index
                BottomBarTab(
                    item = item,
                    isSelected = isSelected,
                    onClick = { onTabSelected(index) },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

@Composable
private fun BottomBarTab(
    item: XGTabItem,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val tintColor by animateColorAsState(
        targetValue = if (isSelected) {
            XGColors.BottomNavIconActive
        } else {
            XGColors.BottomNavIconInactive
        },
        animationSpec = XGMotion.Easing.standardTween(XGMotion.Duration.FAST),
        label = "bottomBarTint",
    )

    Column(
        modifier = modifier
            .height(BAR_HEIGHT)
            .clickable(
                onClick = onClick,
                role = Role.Tab,
                indication = null,
                interactionSource = remember { MutableInteractionSource() },
            )
            .semantics { selected = isSelected },
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        BottomBarItemIcon(
            item = item,
            isSelected = isSelected,
            tintColor = tintColor,
        )
    }
}

@Composable
private fun BottomBarItemIcon(
    item: XGTabItem,
    isSelected: Boolean,
    tintColor: Color,
) {
    val icon = if (isSelected) item.selectedIcon else item.icon
    val badgeCount = item.badgeCount

    if (badgeCount != null && badgeCount > 0) {
        Box {
            Icon(
                imageVector = icon,
                contentDescription = item.label,
                tint = tintColor,
                modifier = Modifier.size(ICON_SIZE),
            )
            BottomBarBadge(
                count = badgeCount,
                modifier = Modifier.align(Alignment.TopEnd),
            )
        }
    } else {
        Icon(
            imageVector = icon,
            contentDescription = item.label,
            tint = tintColor,
            modifier = Modifier.size(ICON_SIZE),
        )
    }
}

@Composable
private fun BottomBarBadge(count: Int, modifier: Modifier = Modifier) {
    val displayText = if (count >= BADGE_MAX_DISPLAY) BADGE_OVERFLOW_TEXT else count.toString()

    Text(
        text = displayText,
        style = XGTypography.labelSmall,
        color = XGColors.BadgeText,
        modifier = modifier
            .background(
                color = XGColors.BadgeBackground,
                shape = androidx.compose.foundation.shape.CircleShape,
            )
            .then(
                Modifier
                    .size(BADGE_SIZE),
            ),
        textAlign = androidx.compose.ui.text.style.TextAlign.Center,
    )
}

// region Constants — all from design tokens

/** Bar height — from spacing.json: bottomNavigation.height = 75 */
private val BAR_HEIGHT = 75.dp

/** Icon size — from spacing.json: layout.iconSize.medium = 24 */
private val ICON_SIZE = 24.dp

/** Top border width — from xg-bottom-bar.json: topBorderWidth = 0.5 */
private val TOP_BORDER_WIDTH = 0.5.dp

/** Badge size — compact circle badge */
private val BADGE_SIZE = 16.dp

/** Badge text overflow threshold */
private const val BADGE_MAX_DISPLAY = 100

/** Badge overflow display text */
private const val BADGE_OVERFLOW_TEXT = "99+"

// endregion

// region Previews

@Preview(showBackground = true)
@Composable
private fun XGBottomBarPreview() {
    XGTheme {
        XGBottomBar(
            items = listOf(
                XGTabItem(
                    label = "Home",
                    icon = Icons.Outlined.Home,
                    selectedIcon = Icons.Filled.Home,
                ),
                XGTabItem(
                    label = "Search",
                    icon = Icons.Outlined.Search,
                    selectedIcon = Icons.Filled.Search,
                ),
                XGTabItem(
                    label = "Cart",
                    icon = Icons.Outlined.ShoppingCart,
                    selectedIcon = Icons.Filled.ShoppingCart,
                    badgeCount = 3,
                ),
                XGTabItem(
                    label = "Wishlist",
                    icon = Icons.Outlined.FavoriteBorder,
                    selectedIcon = Icons.Filled.FavoriteBorder,
                ),
                XGTabItem(
                    label = "Profile",
                    icon = Icons.Outlined.Person,
                    selectedIcon = Icons.Filled.Person,
                ),
            ),
            selectedIndex = 0,
            onTabSelected = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGBottomBarCartSelectedPreview() {
    XGTheme {
        XGBottomBar(
            items = listOf(
                XGTabItem(
                    label = "Home",
                    icon = Icons.Outlined.Home,
                    selectedIcon = Icons.Filled.Home,
                ),
                XGTabItem(
                    label = "Search",
                    icon = Icons.Outlined.Search,
                    selectedIcon = Icons.Filled.Search,
                ),
                XGTabItem(
                    label = "Cart",
                    icon = Icons.Outlined.ShoppingCart,
                    selectedIcon = Icons.Filled.ShoppingCart,
                    badgeCount = 99,
                ),
                XGTabItem(
                    label = "Wishlist",
                    icon = Icons.Outlined.FavoriteBorder,
                    selectedIcon = Icons.Filled.FavoriteBorder,
                ),
                XGTabItem(
                    label = "Profile",
                    icon = Icons.Outlined.Person,
                    selectedIcon = Icons.Filled.Person,
                ),
            ),
            selectedIndex = 2,
            onTabSelected = {},
        )
    }
}

// endregion
