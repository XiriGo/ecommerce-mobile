package com.xirigo.ecommerce.core.designsystem.theme

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.unit.dp

class XGCornerRadiusTest {

    @Test
    fun `corner radius values should match design tokens`() {
        assertThat(XGCornerRadius.None).isEqualTo(0.dp)
        assertThat(XGCornerRadius.Small).isEqualTo(6.dp)
        assertThat(XGCornerRadius.Medium).isEqualTo(10.dp)
        assertThat(XGCornerRadius.Large).isEqualTo(16.dp)
        assertThat(XGCornerRadius.Pill).isEqualTo(28.dp)
        assertThat(XGCornerRadius.Toggle).isEqualTo(22.dp)
        assertThat(XGCornerRadius.Full).isEqualTo(999.dp)
    }

    @Test
    fun `corner radius values should be in ascending order`() {
        assertThat(XGCornerRadius.None.value).isLessThan(XGCornerRadius.Small.value)
        assertThat(XGCornerRadius.Small.value).isLessThan(XGCornerRadius.Medium.value)
        assertThat(XGCornerRadius.Medium.value).isLessThan(XGCornerRadius.Large.value)
        assertThat(XGCornerRadius.Large.value).isLessThan(XGCornerRadius.Pill.value)
        assertThat(XGCornerRadius.Pill.value).isLessThan(XGCornerRadius.Full.value)
    }

    @Test
    fun `None corner radius should be zero`() {
        assertThat(XGCornerRadius.None.value).isEqualTo(0f)
    }

    @Test
    fun `Full corner radius should be large enough for circle shape`() {
        assertThat(XGCornerRadius.Full.value).isAtLeast(100f)
    }
}
