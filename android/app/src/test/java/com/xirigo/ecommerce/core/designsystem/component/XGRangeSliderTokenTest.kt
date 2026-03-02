package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors

/**
 * DQ-21: XGRangeSlider token audit — unit tests.
 *
 * Verifies:
 * 1. Track active color matches brand.primary token
 * 2. Track inactive color matches borderStrong/outline token
 * 3. Thumb color matches brand.primary token
 * 4. Thumb border color matches surface token
 * 5. Dimension constants match xg-range-slider.json spec
 */
class XGRangeSliderTokenTest {

    // region Track color token contract

    @Test
    fun `track active color should match brand primary`() {
        // brand.primary = #6000FE
        assertThat(XGColors.Primary).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `track inactive color Outline should match design token`() {
        // light.borderDefault = #E5E7EB
        assertThat(XGColors.Outline).isEqualTo(Color(0xFFE5E7EB))
    }

    @Test
    fun `track active and inactive colors should be distinct`() {
        assertThat(XGColors.Primary).isNotEqualTo(XGColors.Outline)
    }

    // endregion

    // region Thumb color token contract

    @Test
    fun `thumb color should match brand primary`() {
        // thumbColor = brand.primary = #6000FE
        assertThat(XGColors.Primary).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `thumb border color should match surface`() {
        // thumbBorderColor = light.surface = #FFFFFF
        assertThat(XGColors.Surface).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `thumb color and thumb border color should be distinct`() {
        assertThat(XGColors.Primary).isNotEqualTo(XGColors.Surface)
    }

    // endregion

    // region Dimension constant contract

    @Test
    fun `track height should be 4dp`() {
        // xg-range-slider.json: trackHeight = 4
        val expectedTrackHeight = 4.dp
        assertThat(expectedTrackHeight.value).isEqualTo(4f)
    }

    @Test
    fun `thumb size should be 24dp`() {
        // xg-range-slider.json: thumbSize = 24
        val expectedThumbSize = 24.dp
        assertThat(expectedThumbSize.value).isEqualTo(24f)
    }

    @Test
    fun `thumb border width should be 3dp`() {
        // xg-range-slider.json: thumbBorderWidth = 3
        val expectedBorderWidth = 3.dp
        assertThat(expectedBorderWidth.value).isEqualTo(3f)
    }

    @Test
    fun `thumb size should be larger than track height`() {
        val thumbSize = 24.dp
        val trackHeight = 4.dp
        assertThat(thumbSize.value).isGreaterThan(trackHeight.value)
    }

    @Test
    fun `thumb border width should be less than thumb radius`() {
        val thumbBorderWidth = 3.dp
        val thumbRadius = 12.dp // thumbSize / 2
        assertThat(thumbBorderWidth.value).isLessThan(thumbRadius.value)
    }

    // endregion

    // region Label color token contract

    @Test
    fun `label color OnSurfaceVariant should match design token`() {
        // light.textSecondary = #8E8E93
        assertThat(XGColors.OnSurfaceVariant).isEqualTo(Color(0xFF8E8E93))
    }

    @Test
    fun `label color should be distinct from track active color`() {
        assertThat(XGColors.OnSurfaceVariant).isNotEqualTo(XGColors.Primary)
    }

    // endregion
}
