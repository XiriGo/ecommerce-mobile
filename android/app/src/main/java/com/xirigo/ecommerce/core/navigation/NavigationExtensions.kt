package com.xirigo.ecommerce.core.navigation

import androidx.navigation.NavController
import androidx.navigation.NavGraph.Companion.findStartDestination

/**
 * Navigate to a top-level tab destination with save/restore state behavior.
 * Pops up to the start destination, saves state for the current tab,
 * and restores state for the target tab.
 */
fun NavController.navigateToTopLevel(destination: TopLevelDestination) {
    navigate(destination.route) {
        popUpTo(graph.findStartDestination().id) {
            saveState = true
        }
        launchSingleTop = true
        restoreState = true
    }
}

/**
 * Navigate to a Route, pushing it onto the current tab's back stack.
 */
fun NavController.navigateToRoute(route: Route) {
    navigate(route) {
        launchSingleTop = true
    }
}
