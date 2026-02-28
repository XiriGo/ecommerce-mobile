package com.xirigo.ecommerce.core.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.navigation.NavDestination.Companion.hasRoute
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.xirigo.ecommerce.core.designsystem.component.MoltBottomBar
import com.xirigo.ecommerce.core.designsystem.component.MoltTabItem
import com.xirigo.ecommerce.core.designsystem.theme.MoltTheme

private val bottomBarHiddenRoutes: Set<String> = setOf(
    Route.Login::class.qualifiedName.orEmpty(),
    Route.Register::class.qualifiedName.orEmpty(),
    Route.ForgotPassword::class.qualifiedName.orEmpty(),
    Route.Onboarding::class.qualifiedName.orEmpty(),
    Route.CheckoutAddress::class.qualifiedName.orEmpty(),
    Route.CheckoutShipping::class.qualifiedName.orEmpty(),
    Route.CheckoutPayment::class.qualifiedName.orEmpty(),
    Route.OrderConfirmation::class.qualifiedName.orEmpty(),
)

@Composable
fun MoltAppScaffold(modifier: Modifier = Modifier) {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    val selectedTabIndex by remember(currentDestination) {
        derivedStateOf {
            TopLevelDestination.entries.indexOfFirst { destination ->
                currentDestination?.hasRoute(destination.route::class) == true
            }.coerceAtLeast(0)
        }
    }

    val shouldShowBottomBar by remember(currentDestination) {
        derivedStateOf {
            val routeClass = currentDestination?.route?.let { it::class.qualifiedName }
            routeClass !in bottomBarHiddenRoutes
        }
    }

    // Cart badge count: hardcoded to 0 until M2-01 provides the cart state
    val cartBadgeCount = 0

    Scaffold(
        modifier = modifier,
        bottomBar = {
            if (shouldShowBottomBar) {
                val tabItems = TopLevelDestination.entries.map { destination ->
                    MoltTabItem(
                        label = stringResource(destination.labelResId),
                        icon = destination.unselectedIcon,
                        selectedIcon = destination.selectedIcon,
                        badgeCount = if (destination == TopLevelDestination.CART && cartBadgeCount > 0) {
                            cartBadgeCount
                        } else {
                            null
                        },
                    )
                }

                MoltBottomBar(
                    items = tabItems,
                    selectedIndex = selectedTabIndex,
                    onTabSelected = { index ->
                        val destination = TopLevelDestination.entries[index]
                        navController.navigateToTopLevel(destination)
                    },
                )
            }
        },
    ) { innerPadding ->
        MoltNavHost(
            navController = navController,
            modifier = Modifier.padding(innerPadding),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltAppScaffoldPreview() {
    MoltTheme {
        MoltAppScaffold()
    }
}
