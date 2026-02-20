@file:Suppress("MatchingDeclarationName")

package com.molt.marketplace.core.designsystem.component

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
import androidx.compose.runtime.Stable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Stable
data class MoltTabItem(
    val label: String,
    val icon: ImageVector,
    val selectedIcon: ImageVector,
    val badgeCount: Int? = null,
)

@Composable
@Suppress("ktlint:standard:function-naming", "CognitiveComplexMethod")
fun MoltBottomBar(
    items: List<MoltTabItem>,
    selectedIndex: Int,
    onTabSelected: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    NavigationBar(modifier = modifier) {
        items.forEachIndexed { index, item ->
            NavigationBarItem(
                selected = selectedIndex == index,
                onClick = { onTabSelected(index) },
                icon = {
                    val icon = if (selectedIndex == index) item.selectedIcon else item.icon

                    if (item.badgeCount != null && item.badgeCount > 0) {
                        BadgedBox(
                            badge = {
                                Badge {
                                    Text(
                                        text = if (item.badgeCount >= 100) {
                                            "99+"
                                        } else {
                                            item.badgeCount.toString()
                                        },
                                        style = MaterialTheme.typography.labelSmall,
                                    )
                                }
                            },
                        ) {
                            Icon(
                                imageVector = icon,
                                contentDescription = item.label,
                            )
                        }
                    } else {
                        Icon(
                            imageVector = icon,
                            contentDescription = item.label,
                        )
                    }
                },
                label = { Text(text = item.label) },
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltBottomBarPreview() {
    MoltTheme {
        MoltBottomBar(
            items = listOf(
                MoltTabItem(
                    label = "Home",
                    icon = Icons.Outlined.Home,
                    selectedIcon = Icons.Filled.Home,
                ),
                MoltTabItem(
                    label = "Cart",
                    icon = Icons.Outlined.ShoppingCart,
                    selectedIcon = Icons.Filled.ShoppingCart,
                    badgeCount = 3,
                ),
                MoltTabItem(
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
@Suppress("ktlint:standard:function-naming")
private fun MoltBottomBarCartSelectedPreview() {
    MoltTheme {
        MoltBottomBar(
            items = listOf(
                MoltTabItem(
                    label = "Home",
                    icon = Icons.Outlined.Home,
                    selectedIcon = Icons.Filled.Home,
                ),
                MoltTabItem(
                    label = "Cart",
                    icon = Icons.Outlined.ShoppingCart,
                    selectedIcon = Icons.Filled.ShoppingCart,
                    badgeCount = 99,
                ),
                MoltTabItem(
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
