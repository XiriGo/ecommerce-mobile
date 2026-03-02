package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/**
 * DQ-32: XGSocialLoginButton token audit -- unit tests.
 *
 * Verifies:
 * 1. Social auth color tokens match design-token hex values
 * 2. Typography token (labelLarge) matches spec (14sp Medium)
 * 3. SocialLoginProvider enum holds correct string resource IDs
 * 4. Provider enum has exactly two entries (Google, Apple)
 */
class XGSocialLoginButtonTokenTest {

    // region Social auth color tokens

    @Test
    fun `SocialGoogleBlue should match design token`() {
        assertThat(XGColors.SocialGoogleBlue).isEqualTo(Color(0xFF4285F4))
    }

    @Test
    fun `SocialGoogleGreen should match design token`() {
        assertThat(XGColors.SocialGoogleGreen).isEqualTo(Color(0xFF34A853))
    }

    @Test
    fun `SocialGoogleYellow should match design token`() {
        assertThat(XGColors.SocialGoogleYellow).isEqualTo(Color(0xFFFBBC05))
    }

    @Test
    fun `SocialGoogleRed should match design token`() {
        assertThat(XGColors.SocialGoogleRed).isEqualTo(Color(0xFFEA4335))
    }

    @Test
    fun `SocialAppleBlack should match design token`() {
        assertThat(XGColors.SocialAppleBlack).isEqualTo(Color(0xFF000000))
    }

    // endregion

    // region Surface and outline tokens used by the button

    @Test
    fun `Surface color should match design token`() {
        assertThat(XGColors.Surface).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `Outline color should match design token for border`() {
        assertThat(XGColors.Outline).isEqualTo(Color(0xFFE5E7EB))
    }

    @Test
    fun `OnSurface color should match design token for text`() {
        assertThat(XGColors.OnSurface).isEqualTo(Color(0xFF333333))
    }

    // endregion

    // region Typography token

    @Test
    fun `labelLarge fontSize should be 14sp`() {
        assertThat(XGTypography.labelLarge.fontSize).isEqualTo(14.sp)
    }

    @Test
    fun `labelLarge fontWeight should be Medium`() {
        assertThat(XGTypography.labelLarge.fontWeight).isEqualTo(FontWeight.Medium)
    }

    @Test
    fun `labelLarge lineHeight should be 20sp`() {
        assertThat(XGTypography.labelLarge.lineHeight).isEqualTo(20.sp)
    }

    // endregion

    // region SocialLoginProvider enum

    @Test
    fun `SocialLoginProvider should have exactly two entries`() {
        assertThat(SocialLoginProvider.entries).hasSize(2)
    }

    @Test
    fun `Google provider should reference correct string resource`() {
        assertThat(SocialLoginProvider.Google.labelRes)
            .isEqualTo(R.string.auth_social_continue_google)
    }

    @Test
    fun `Apple provider should reference correct string resource`() {
        assertThat(SocialLoginProvider.Apple.labelRes)
            .isEqualTo(R.string.auth_social_continue_apple)
    }

    // endregion
}
