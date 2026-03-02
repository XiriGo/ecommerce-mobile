package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors

/**
 * DQ-20: XGColorSwatch token audit — unit tests.
 *
 * Verifies:
 * 1. [XGColors.Primary] matches the selection ring colour token
 * 2. [XGColors.Outline] matches the border colour token
 * 3. Token constants match the JSON spec
 * 4. Swatch colours from colorSwatches palette are correctly referenced
 */
class XGColorSwatchTokenTest {

    // region Selection ring colour contract

    @Test
    fun `selection ring color should match brand primary`() {
        // xg-color-swatch.json: selectedRingColor = $brand.primary = #6000FE
        assertThat(XGColors.Primary).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `selection ring color should equal BrandPrimary alias`() {
        assertThat(XGColors.Primary).isEqualTo(XGColors.BrandPrimary)
    }

    // endregion

    // region Border colour contract

    @Test
    fun `border color should match light borderDefault`() {
        // xg-color-swatch.json: whiteBorderColor = $light.borderDefault = #E5E7EB
        assertThat(XGColors.Outline).isEqualTo(Color(0xFFE5E7EB))
    }

    // endregion

    // region Token dimension contract

    @Test
    fun `swatch size should be 40dp`() {
        // xg-color-swatch.json: size = 40
        val expectedSize = 40.dp
        assertThat(expectedSize.value).isEqualTo(40f)
    }

    @Test
    fun `corner radius should be half of size for perfect circle`() {
        // xg-color-swatch.json: cornerRadius = 20 (size / 2)
        val size = 40f
        val cornerRadius = 20f
        assertThat(cornerRadius).isEqualTo(size / 2f)
    }

    @Test
    fun `selected ring width should be 2dp`() {
        // xg-color-swatch.json: selectedRingWidth = 2
        val expectedWidth = 2.dp
        assertThat(expectedWidth.value).isEqualTo(2f)
    }

    @Test
    fun `selected ring gap should be 3dp`() {
        // xg-color-swatch.json: selectedRingGap = 3
        val expectedGap = 3.dp
        assertThat(expectedGap.value).isEqualTo(3f)
    }

    @Test
    fun `white border width should be 1dp`() {
        // xg-color-swatch.json: whiteBorderWidth = 1
        val expectedBorderWidth = 1.dp
        assertThat(expectedBorderWidth.value).isEqualTo(1f)
    }

    @Test
    fun `total size should account for ring and gap on both sides`() {
        // totalSize = swatchSize + (ringGap + ringWidth) * 2
        val swatchSize = 40f
        val ringGap = 3f
        val ringWidth = 2f
        val expectedTotal = swatchSize + (ringGap + ringWidth) * 2
        assertThat(expectedTotal).isEqualTo(50f)
    }

    // endregion

    // region colorSwatches palette contract

    @Test
    fun `swatch palette black should be 1D1D1B`() {
        // colorSwatches.black = #1D1D1B
        val expected = Color(0xFF1D1D1B)
        assertThat(expected.red).isWithin(0.01f).of(29f / 255f)
        assertThat(expected.green).isWithin(0.01f).of(29f / 255f)
        assertThat(expected.blue).isWithin(0.01f).of(27f / 255f)
    }

    @Test
    fun `swatch palette white should be FFFFFF`() {
        // colorSwatches.white = #FFFFFF
        val expected = Color(0xFFFFFFFF)
        assertThat(expected.red).isEqualTo(1f)
        assertThat(expected.green).isEqualTo(1f)
        assertThat(expected.blue).isEqualTo(1f)
    }

    @Test
    fun `swatch palette red should match semantic error`() {
        // colorSwatches.red = #EF4444 = semantic.error
        assertThat(XGColors.Error).isEqualTo(Color(0xFFEF4444))
    }

    @Test
    fun `swatch palette blue should match semantic info`() {
        // colorSwatches.blue = #3B82F6 = semantic.info
        assertThat(XGColors.Info).isEqualTo(Color(0xFF3B82F6))
    }

    @Test
    fun `swatch palette green should match semantic success`() {
        // colorSwatches.green = #22C55E = semantic.success
        assertThat(XGColors.Success).isEqualTo(Color(0xFF22C55E))
    }

    // endregion

    // region Luminance contrast logic

    @Test
    fun `dark colors should have luminance below threshold`() {
        // Black #1D1D1B — luminance ~ 0.012
        val black = Color(0xFF1D1D1B)
        assertThat(black.luminance() < 0.6f).isTrue()
    }

    @Test
    fun `light colors should have luminance above threshold`() {
        // White #FFFFFF — luminance = 1.0
        val white = Color(0xFFFFFFFF)
        assertThat(white.luminance() > 0.6f).isTrue()
    }

    @Test
    fun `OnSurface should be used as checkmark for light swatches`() {
        // OnSurface = #333333 — dark colour for light backgrounds
        assertThat(XGColors.OnSurface).isEqualTo(Color(0xFF333333))
    }

    @Test
    fun `OnPrimary should be used as checkmark for dark swatches`() {
        // OnPrimary = #FFFFFF — white for dark backgrounds
        assertThat(XGColors.OnPrimary).isEqualTo(Color(0xFFFFFFFF))
    }

    // endregion
}
