package com.xirigo.ecommerce.core.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Category
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.outlined.Category
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.ui.graphics.vector.ImageVector
import com.xirigo.ecommerce.R

enum class TopLevelDestination(
    val route: Route,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val labelResId: Int,
) {
    HOME(
        route = Route.Home,
        selectedIcon = Icons.Filled.Home,
        unselectedIcon = Icons.Outlined.Home,
        labelResId = R.string.nav_tab_home,
    ),
    CATEGORIES(
        route = Route.Categories,
        selectedIcon = Icons.Filled.Category,
        unselectedIcon = Icons.Outlined.Category,
        labelResId = R.string.nav_tab_categories,
    ),
    CART(
        route = Route.Cart,
        selectedIcon = Icons.Filled.ShoppingCart,
        unselectedIcon = Icons.Outlined.ShoppingCart,
        labelResId = R.string.nav_tab_cart,
    ),
    PROFILE(
        route = Route.Profile,
        selectedIcon = Icons.Filled.Person,
        unselectedIcon = Icons.Outlined.Person,
        labelResId = R.string.nav_tab_profile,
    ),
}
