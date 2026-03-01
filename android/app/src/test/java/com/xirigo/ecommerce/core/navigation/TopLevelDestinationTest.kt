package com.xirigo.ecommerce.core.navigation

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import com.xirigo.ecommerce.R

class TopLevelDestinationTest {

    @Test
    fun `all four top level destinations exist`() {
        assertThat(TopLevelDestination.entries).hasSize(4)
    }

    @Test
    fun `HOME has correct route`() {
        assertThat(TopLevelDestination.HOME.route).isEqualTo(Route.Home)
    }

    @Test
    fun `CATEGORIES has correct route`() {
        assertThat(TopLevelDestination.CATEGORIES.route).isEqualTo(Route.Categories)
    }

    @Test
    fun `CART has correct route`() {
        assertThat(TopLevelDestination.CART.route).isEqualTo(Route.Cart)
    }

    @Test
    fun `PROFILE has correct route`() {
        assertThat(TopLevelDestination.PROFILE.route).isEqualTo(Route.Profile)
    }

    @Test
    fun `HOME has correct label resource`() {
        assertThat(TopLevelDestination.HOME.labelResId).isEqualTo(R.string.nav_tab_home)
    }

    @Test
    fun `CATEGORIES has correct label resource`() {
        assertThat(TopLevelDestination.CATEGORIES.labelResId).isEqualTo(R.string.nav_tab_categories)
    }

    @Test
    fun `CART has correct label resource`() {
        assertThat(TopLevelDestination.CART.labelResId).isEqualTo(R.string.nav_tab_cart)
    }

    @Test
    fun `PROFILE has correct label resource`() {
        assertThat(TopLevelDestination.PROFILE.labelResId).isEqualTo(R.string.nav_tab_profile)
    }

    @Test
    fun `each destination has distinct selected and unselected icons`() {
        TopLevelDestination.entries.forEach { destination ->
            assertThat(destination.selectedIcon).isNotEqualTo(destination.unselectedIcon)
        }
    }

    @Test
    fun `destinations are in correct order`() {
        val names = TopLevelDestination.entries.map { it.name }
        assertThat(names).containsExactly("HOME", "CATEGORIES", "CART", "PROFILE").inOrder()
    }
}
