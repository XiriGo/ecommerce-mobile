package com.molt.marketplace.core.designsystem.theme

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.unit.dp

class MoltSpacingTest {

    @Test
    fun `base spacing values should match design tokens`() {
        assertThat(MoltSpacing.XXS).isEqualTo(2.dp)
        assertThat(MoltSpacing.XS).isEqualTo(4.dp)
        assertThat(MoltSpacing.SM).isEqualTo(8.dp)
        assertThat(MoltSpacing.MD).isEqualTo(12.dp)
        assertThat(MoltSpacing.Base).isEqualTo(16.dp)
        assertThat(MoltSpacing.LG).isEqualTo(24.dp)
        assertThat(MoltSpacing.XL).isEqualTo(32.dp)
        assertThat(MoltSpacing.XXL).isEqualTo(48.dp)
        assertThat(MoltSpacing.XXXL).isEqualTo(64.dp)
    }

    @Test
    fun `layout spacing values should match design tokens`() {
        assertThat(MoltSpacing.ScreenPaddingHorizontal).isEqualTo(16.dp)
        assertThat(MoltSpacing.ScreenPaddingVertical).isEqualTo(16.dp)
        assertThat(MoltSpacing.CardPadding).isEqualTo(12.dp)
        assertThat(MoltSpacing.ListItemSpacing).isEqualTo(8.dp)
        assertThat(MoltSpacing.SectionSpacing).isEqualTo(24.dp)
        assertThat(MoltSpacing.ProductGridSpacing).isEqualTo(8.dp)
    }

    @Test
    fun `minimum touch target should meet accessibility standards`() {
        assertThat(MoltSpacing.MinTouchTarget).isEqualTo(48.dp)
    }

    @Test
    fun `spacing values should be in ascending order`() {
        assertThat(MoltSpacing.XXS.value).isLessThan(MoltSpacing.XS.value)
        assertThat(MoltSpacing.XS.value).isLessThan(MoltSpacing.SM.value)
        assertThat(MoltSpacing.SM.value).isLessThan(MoltSpacing.MD.value)
        assertThat(MoltSpacing.MD.value).isLessThan(MoltSpacing.Base.value)
        assertThat(MoltSpacing.Base.value).isLessThan(MoltSpacing.LG.value)
        assertThat(MoltSpacing.LG.value).isLessThan(MoltSpacing.XL.value)
        assertThat(MoltSpacing.XL.value).isLessThan(MoltSpacing.XXL.value)
        assertThat(MoltSpacing.XXL.value).isLessThan(MoltSpacing.XXXL.value)
    }
}
