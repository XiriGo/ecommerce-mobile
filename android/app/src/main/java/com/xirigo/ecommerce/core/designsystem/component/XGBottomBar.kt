package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.material3.Badge
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun XGBottomBar(
    items: List<XGTabItem>,
    selectedIndex: Int,
    onTabSelected: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    NavigationBar(modifier = modifier) {
        items.forEachIndexed { index, item ->
            val isSelected = selectedIndex == index
            NavigationBarItem(
                selected = isSelected,
                onClick = { onTabSelected(index) },
                icon = {
                    BottomBarItemIcon(item = item, isSelected = isSelected)
                },
                label = { Text(text = item.label) },
            )
        }
    }
}

@Composable
private fun BottomBarItemIcon(item: XGTabItem, isSelected: Boolean) {
    val icon = if (isSelected) item.selectedIcon else item.icon
    val badgeCount = item.badgeCount

    if (badgeCount != null && badgeCount > 0) {
        BadgedBox(
            badge = { BottomBarBadge(count = badgeCount) },
        ) {
            Icon(imageVector = icon, contentDescription = item.label)
        }
    } else {
        Icon(imageVector = icon, contentDescription = item.label)
    }
}

@Composable
private fun BottomBarBadge(count: Int) {
    Badge {
        Text(
            text = if (count >= 100) "99+" else count.toString(),
            style = MaterialTheme.typography.labelSmall,
        )
    }
}

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
                    label = "Cart",
                    icon = Icons.Outlined.ShoppingCart,
                    selectedIcon = Icons.Filled.ShoppingCart,
                    badgeCount = 3,
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
                    label = "Cart",
                    icon = Icons.Outlined.ShoppingCart,
                    selectedIcon = Icons.Filled.ShoppingCart,
                    badgeCount = 99,
                ),
                XGTabItem(
                    label = "Profile",
                    icon = Icons.Outlined.Person,
                    selectedIcon = Icons.Filled.Person,
                ),
            ),
            selectedIndex = 1,
            onTabSelected = {},
        )
    }
}
