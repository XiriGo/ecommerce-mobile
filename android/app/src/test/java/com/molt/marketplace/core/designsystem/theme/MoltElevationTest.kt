package com.molt.marketplace.core.designsystem.theme

import androidx.compose.ui.unit.dp
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class MoltElevationTest {

    @Test
    fun `elevation values should match design tokens`() {
        assertThat(MoltElevation.Level0).isEqualTo(0.dp)
        assertThat(MoltElevation.Level1).isEqualTo(1.dp)
        assertThat(MoltElevation.Level2).isEqualTo(3.dp)
        assertThat(MoltElevation.Level3).isEqualTo(6.dp)
        assertThat(MoltElevation.Level4).isEqualTo(8.dp)
        assertThat(MoltElevation.Level5).isEqualTo(12.dp)
    }

    @Test
    fun `elevation levels should be in ascending order`() {
        assertThat(MoltElevation.Level0.value).isLessThan(MoltElevation.Level1.value)
        assertThat(MoltElevation.Level1.value).isLessThan(MoltElevation.Level2.value)
        assertThat(MoltElevation.Level2.value).isLessThan(MoltElevation.Level3.value)
        assertThat(MoltElevation.Level3.value).isLessThan(MoltElevation.Level4.value)
        assertThat(MoltElevation.Level4.value).isLessThan(MoltElevation.Level5.value)
    }

    @Test
    fun `Level0 elevation should be zero`() {
        assertThat(MoltElevation.Level0.value).isEqualTo(0f)
    }

    @Test
    fun `Level1 should be suitable for cards`() {
        assertThat(MoltElevation.Level1.value).isGreaterThan(0f)
    }
}
