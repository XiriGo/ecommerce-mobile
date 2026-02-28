package com.xirigo.ecommerce.core.designsystem.theme

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.unit.dp

class XGElevationTest {

    @Test
    fun `elevation values should match design tokens`() {
        assertThat(XGElevation.Level0).isEqualTo(0.dp)
        assertThat(XGElevation.Level1).isEqualTo(1.dp)
        assertThat(XGElevation.Level2).isEqualTo(3.dp)
        assertThat(XGElevation.Level3).isEqualTo(6.dp)
        assertThat(XGElevation.Level4).isEqualTo(8.dp)
        assertThat(XGElevation.Level5).isEqualTo(12.dp)
    }

    @Test
    fun `elevation levels should be in ascending order`() {
        assertThat(XGElevation.Level0.value).isLessThan(XGElevation.Level1.value)
        assertThat(XGElevation.Level1.value).isLessThan(XGElevation.Level2.value)
        assertThat(XGElevation.Level2.value).isLessThan(XGElevation.Level3.value)
        assertThat(XGElevation.Level3.value).isLessThan(XGElevation.Level4.value)
        assertThat(XGElevation.Level4.value).isLessThan(XGElevation.Level5.value)
    }

    @Test
    fun `Level0 elevation should be zero`() {
        assertThat(XGElevation.Level0.value).isEqualTo(0f)
    }

    @Test
    fun `Level1 should be suitable for cards`() {
        assertThat(XGElevation.Level1.value).isGreaterThan(0f)
    }
}
