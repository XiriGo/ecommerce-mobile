package com.xirigo.ecommerce.core.designsystem.theme

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.unit.dp

class XGSpacingTest {

    @Test
    fun `base spacing values should match design tokens`() {
        assertThat(XGSpacing.XXS).isEqualTo(2.dp)
        assertThat(XGSpacing.XS).isEqualTo(4.dp)
        assertThat(XGSpacing.SM).isEqualTo(8.dp)
        assertThat(XGSpacing.MD).isEqualTo(12.dp)
        assertThat(XGSpacing.Base).isEqualTo(16.dp)
        assertThat(XGSpacing.LG).isEqualTo(20.dp)
        assertThat(XGSpacing.XL).isEqualTo(24.dp)
        assertThat(XGSpacing.XXL).isEqualTo(32.dp)
        assertThat(XGSpacing.XXXL).isEqualTo(48.dp)
    }

    @Test
    fun `layout spacing values should match design tokens`() {
        assertThat(XGSpacing.ScreenPaddingHorizontal).isEqualTo(20.dp)
        assertThat(XGSpacing.ScreenPaddingVertical).isEqualTo(16.dp)
        assertThat(XGSpacing.CardPadding).isEqualTo(12.dp)
        assertThat(XGSpacing.ListItemSpacing).isEqualTo(10.dp)
        assertThat(XGSpacing.SectionSpacing).isEqualTo(24.dp)
        assertThat(XGSpacing.ProductGridSpacing).isEqualTo(10.dp)
    }

    @Test
    fun `minimum touch target should meet accessibility standards`() {
        assertThat(XGSpacing.MinTouchTarget).isEqualTo(48.dp)
    }

    @Test
    fun `spacing values should be in ascending order`() {
        assertThat(XGSpacing.XXS.value).isLessThan(XGSpacing.XS.value)
        assertThat(XGSpacing.XS.value).isLessThan(XGSpacing.SM.value)
        assertThat(XGSpacing.SM.value).isLessThan(XGSpacing.MD.value)
        assertThat(XGSpacing.MD.value).isLessThan(XGSpacing.Base.value)
        assertThat(XGSpacing.Base.value).isLessThan(XGSpacing.LG.value)
        assertThat(XGSpacing.LG.value).isLessThan(XGSpacing.XL.value)
        assertThat(XGSpacing.XL.value).isLessThan(XGSpacing.XXL.value)
        assertThat(XGSpacing.XXL.value).isLessThan(XGSpacing.XXXL.value)
    }
}
