package com.molt.marketplace.core.designsystem.theme

import androidx.compose.ui.unit.dp
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class MoltCornerRadiusTest {

    @Test
    fun `corner radius values should match design tokens`() {
        assertThat(MoltCornerRadius.None).isEqualTo(0.dp)
        assertThat(MoltCornerRadius.Small).isEqualTo(4.dp)
        assertThat(MoltCornerRadius.Medium).isEqualTo(8.dp)
        assertThat(MoltCornerRadius.Large).isEqualTo(12.dp)
        assertThat(MoltCornerRadius.ExtraLarge).isEqualTo(16.dp)
        assertThat(MoltCornerRadius.Full).isEqualTo(999.dp)
    }

    @Test
    fun `corner radius values should be in ascending order`() {
        assertThat(MoltCornerRadius.None.value).isLessThan(MoltCornerRadius.Small.value)
        assertThat(MoltCornerRadius.Small.value).isLessThan(MoltCornerRadius.Medium.value)
        assertThat(MoltCornerRadius.Medium.value).isLessThan(MoltCornerRadius.Large.value)
        assertThat(MoltCornerRadius.Large.value).isLessThan(MoltCornerRadius.ExtraLarge.value)
        assertThat(MoltCornerRadius.ExtraLarge.value).isLessThan(MoltCornerRadius.Full.value)
    }

    @Test
    fun `None corner radius should be zero`() {
        assertThat(MoltCornerRadius.None.value).isEqualTo(0f)
    }

    @Test
    fun `Full corner radius should be large enough for pill shape`() {
        assertThat(MoltCornerRadius.Full.value).isAtLeast(100f)
    }
}
