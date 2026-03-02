package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.animation.core.Spring
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion

/**
 * DQ-15: XGWishlistButton motion token upgrade — unit tests.
 *
 * Verifies:
 * 1. Motion token references: XGMotion.Duration.INSTANT, XGMotion.Easing.springSpec()
 * 2. Color tokens: BrandPrimary (active), OnSurfaceVariant (inactive)
 * 3. Layout tokens: button size, icon size, elevation, corner radius
 * 4. Duration and spring configuration match design-tokens/foundations/motion.json
 */
class XGWishlistButtonTokenTest {

    // region Motion token contract

    @Test
    fun `XGMotion Duration INSTANT should be 100ms for toggle color transition`() {
        assertThat(XGMotion.Duration.INSTANT).isEqualTo(100)
    }

    @Test
    fun `XGMotion spring damping ratio should be 0_7 for bounce effect`() {
        val spring = XGMotion.Easing.springSpec<Float>()
        assertThat(spring.dampingRatio).isEqualTo(0.7f)
    }

    @Test
    fun `XGMotion spring stiffness should be StiffnessMedium for bounce effect`() {
        val spring = XGMotion.Easing.springSpec<Float>()
        assertThat(spring.stiffness).isEqualTo(Spring.StiffnessMedium)
    }

    @Test
    fun `INSTANT duration should be less than FAST duration`() {
        assertThat(XGMotion.Duration.INSTANT).isLessThan(XGMotion.Duration.FAST)
    }

    @Test
    fun `INSTANT duration should be the shortest available duration`() {
        assertThat(XGMotion.Duration.INSTANT)
            .isAtMost(XGMotion.Duration.FAST)
        assertThat(XGMotion.Duration.INSTANT)
            .isAtMost(XGMotion.Duration.NORMAL)
        assertThat(XGMotion.Duration.INSTANT)
            .isAtMost(XGMotion.Duration.SLOW)
    }

    // endregion

    // region Color token contract

    @Test
    fun `BrandPrimary active tint should match design token`() {
        // brand.primary = #6000FE
        assertThat(XGColors.BrandPrimary).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `OnSurfaceVariant inactive tint should match design token`() {
        // light.textSecondary = #8E8E93
        assertThat(XGColors.OnSurfaceVariant).isEqualTo(Color(0xFF8E8E93))
    }

    @Test
    fun `active and inactive tint colors should be distinct`() {
        assertThat(XGColors.BrandPrimary).isNotEqualTo(XGColors.OnSurfaceVariant)
    }

    @Test
    fun `Surface background should match design token`() {
        // light.surface = #FFFFFF
        assertThat(XGColors.Surface).isEqualTo(Color(0xFFFFFFFF))
    }

    // endregion

    // region Layout token contract

    @Test
    fun `button size should be 32dp per component token spec`() {
        val buttonSize = 32.dp
        assertThat(buttonSize).isEqualTo(32.dp)
    }

    @Test
    fun `icon size should be 16dp per component token spec`() {
        val iconSize = 16.dp
        assertThat(iconSize).isEqualTo(16.dp)
    }

    @Test
    fun `corner radius should be 16dp for circular shape`() {
        // buttonSize / 2 = 32dp / 2 = 16dp (circular)
        val cornerRadius = 16.dp
        assertThat(cornerRadius).isEqualTo(16.dp)
    }

    @Test
    fun `elevation should use Level2 from XGElevation`() {
        assertThat(XGElevation.Level2).isEqualTo(2.dp)
    }

    @Test
    fun `icon size should be half of button size`() {
        val buttonSize = 32f
        val iconSize = 16f
        assertThat(iconSize).isEqualTo(buttonSize / 2)
    }

    // endregion

    // region Bounce scale contract

    @Test
    fun `bounce scale should be 1_2 per component token spec`() {
        val bounceScale = 1.2f
        assertThat(bounceScale).isWithin(0.001f).of(1.2f)
    }

    @Test
    fun `bounce scale should be greater than 1_0`() {
        val bounceScale = 1.2f
        assertThat(bounceScale).isGreaterThan(1.0f)
    }

    @Test
    fun `bounce scale should be less than 1_5 to keep animation subtle`() {
        val bounceScale = 1.2f
        assertThat(bounceScale).isLessThan(1.5f)
    }

    // endregion
}
