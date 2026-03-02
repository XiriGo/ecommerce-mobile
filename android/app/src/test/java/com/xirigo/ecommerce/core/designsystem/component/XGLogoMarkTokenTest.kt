package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.unit.dp

/**
 * DQ-33: XGLogoMark token audit -- unit tests.
 *
 * Verifies:
 * 1. Default logo size matches `xg-logo-mark.json > tokens.defaultSize` (120)
 * 2. DEFAULT_LOGO_SIZE constant has correct value
 */
class XGLogoMarkTokenTest {

    // region Logo size token contract

    @Test
    fun `DEFAULT_LOGO_SIZE should be 120dp per design token`() {
        assertThat(DEFAULT_LOGO_SIZE).isEqualTo(120.dp)
    }

    @Test
    fun `DEFAULT_LOGO_SIZE should be positive`() {
        assertThat(DEFAULT_LOGO_SIZE.value).isGreaterThan(0f)
    }

    @Test
    fun `DEFAULT_LOGO_SIZE should be reasonable for a logo`() {
        assertThat(DEFAULT_LOGO_SIZE.value).isAtLeast(48f)
        assertThat(DEFAULT_LOGO_SIZE.value).isAtMost(300f)
    }

    // endregion
}
