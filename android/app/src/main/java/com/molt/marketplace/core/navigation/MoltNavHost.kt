package com.molt.marketplace.core.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.material.icons.automirrored.outlined.TrendingUp
import androidx.compose.material.icons.outlined.AccountCircle
import androidx.compose.material.icons.outlined.Category
import androidx.compose.material.icons.outlined.CreditCard
import androidx.compose.material.icons.outlined.EmojiPeople
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.LocalShipping
import androidx.compose.material.icons.outlined.LocationOn
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material.icons.outlined.Notifications
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.PersonAdd
import androidx.compose.material.icons.outlined.RateReview
import androidx.compose.material.icons.outlined.Receipt
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.material.icons.outlined.Star
import androidx.compose.material.icons.outlined.Store
import androidx.compose.material.icons.outlined.Visibility
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.molt.marketplace.R

@Composable
fun MoltNavHost(navController: NavHostController, modifier: Modifier = Modifier) {
    NavHost(
        navController = navController,
        startDestination = Route.Home,
        modifier = modifier,
    ) {
        homeRoutes()
        categoryRoutes()
        sharedRoutes()
        cartRoutes()
        profileRoutes()
        profileSettingsRoutes()
        authRoutes()
        onboardingRoutes()
    }
}

private fun NavGraphBuilder.homeRoutes() {
    composable<Route.Home> {
        PlaceholderScreen(
            title = stringResource(R.string.nav_tab_home),
            icon = Icons.Outlined.Home,
        )
    }
}

private fun NavGraphBuilder.categoryRoutes() {
    composable<Route.Categories> {
        PlaceholderScreen(
            title = stringResource(R.string.nav_tab_categories),
            icon = Icons.Outlined.Category,
        )
    }
    composable<Route.CategoryProducts> {
        PlaceholderScreen(
            title = "Category Products",
            icon = Icons.Outlined.Category,
        )
    }
    composable<Route.ProductList> {
        PlaceholderScreen(
            title = "Products",
            icon = Icons.Outlined.Category,
        )
    }
}

private fun NavGraphBuilder.sharedRoutes() {
    composable<Route.ProductDetail> {
        PlaceholderScreen(
            title = "Product Detail",
            icon = Icons.Outlined.Store,
        )
    }
    composable<Route.ProductSearch> {
        PlaceholderScreen(
            title = "Search",
            icon = Icons.Outlined.Search,
        )
    }
    composable<Route.VendorStore> {
        PlaceholderScreen(
            title = "Vendor Store",
            icon = Icons.Outlined.Store,
        )
    }
    composable<Route.ProductReviews> {
        PlaceholderScreen(
            title = "Reviews",
            icon = Icons.Outlined.Star,
        )
    }
    composable<Route.WriteReview> {
        PlaceholderScreen(
            title = "Write Review",
            icon = Icons.Outlined.RateReview,
        )
    }
}

private fun NavGraphBuilder.cartRoutes() {
    composable<Route.Cart> {
        PlaceholderScreen(
            title = stringResource(R.string.nav_tab_cart),
            icon = Icons.Outlined.ShoppingCart,
        )
    }
    composable<Route.Checkout> {
        PlaceholderScreen(
            title = "Checkout",
            icon = Icons.Outlined.Receipt,
        )
    }
    composable<Route.CheckoutAddress> {
        PlaceholderScreen(
            title = "Shipping Address",
            icon = Icons.Outlined.LocationOn,
        )
    }
    composable<Route.CheckoutShipping> {
        PlaceholderScreen(
            title = "Shipping Method",
            icon = Icons.Outlined.LocalShipping,
        )
    }
    composable<Route.CheckoutPayment> {
        PlaceholderScreen(
            title = "Payment",
            icon = Icons.Outlined.CreditCard,
        )
    }
    composable<Route.OrderConfirmation> {
        PlaceholderScreen(
            title = "Order Confirmed",
            icon = Icons.AutoMirrored.Outlined.ReceiptLong,
        )
    }
}

private fun NavGraphBuilder.profileRoutes() {
    composable<Route.Profile> {
        PlaceholderScreen(
            title = stringResource(R.string.nav_tab_profile),
            icon = Icons.Outlined.Person,
        )
    }
    composable<Route.OrderList> {
        PlaceholderScreen(
            title = "Orders",
            icon = Icons.AutoMirrored.Outlined.ReceiptLong,
        )
    }
    composable<Route.OrderDetail> {
        PlaceholderScreen(
            title = "Order Detail",
            icon = Icons.Outlined.Receipt,
        )
    }
    composable<Route.Settings> {
        PlaceholderScreen(
            title = "Settings",
            icon = Icons.Outlined.Settings,
        )
    }
    composable<Route.AddressManagement> {
        PlaceholderScreen(
            title = "Addresses",
            icon = Icons.Outlined.LocationOn,
        )
    }
}

private fun NavGraphBuilder.profileSettingsRoutes() {
    composable<Route.Wishlist> {
        PlaceholderScreen(
            title = "Wishlist",
            icon = Icons.Outlined.FavoriteBorder,
        )
    }
    composable<Route.PaymentMethods> {
        PlaceholderScreen(
            title = "Payment Methods",
            icon = Icons.Outlined.CreditCard,
        )
    }
    composable<Route.Notifications> {
        PlaceholderScreen(
            title = "Notifications",
            icon = Icons.Outlined.Notifications,
        )
    }
    composable<Route.RecentlyViewed> {
        PlaceholderScreen(
            title = "Recently Viewed",
            icon = Icons.Outlined.Visibility,
        )
    }
    composable<Route.PriceAlerts> {
        PlaceholderScreen(
            title = "Price Alerts",
            icon = Icons.AutoMirrored.Outlined.TrendingUp,
        )
    }
}

private fun NavGraphBuilder.authRoutes() {
    composable<Route.Login> {
        PlaceholderScreen(
            title = "Login",
            icon = Icons.Outlined.Lock,
        )
    }
    composable<Route.Register> {
        PlaceholderScreen(
            title = "Register",
            icon = Icons.Outlined.PersonAdd,
        )
    }
    composable<Route.ForgotPassword> {
        PlaceholderScreen(
            title = "Forgot Password",
            icon = Icons.Outlined.AccountCircle,
        )
    }
}

private fun NavGraphBuilder.onboardingRoutes() {
    composable<Route.Onboarding> {
        PlaceholderScreen(
            title = "Onboarding",
            icon = Icons.Outlined.EmojiPeople,
        )
    }
}
