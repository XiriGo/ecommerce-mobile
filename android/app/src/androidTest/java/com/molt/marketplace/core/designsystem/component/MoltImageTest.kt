package com.molt.marketplace.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.layout.size
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@RunWith(AndroidJUnit4::class)
class MoltImageTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltImage_nullUrl_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltImage(
                    url = null,
                    contentDescription = "Product image",
                    modifier = Modifier.size(200.dp),
                )
            }
        }

        // Null URL renders a shimmer box — no async image, no crash
        composeTestRule.onNodeWithContentDescription("Product image").assertDoesNotExist()
    }

    @Test
    fun moltImage_withUrl_rendersAsyncImage() {
        composeTestRule.setContent {
            MoltTheme {
                MoltImage(
                    url = "https://example.com/product.jpg",
                    contentDescription = "Product thumbnail",
                    modifier = Modifier.size(200.dp),
                )
            }
        }

        // AsyncImage rendered — content description is set on the async image
        composeTestRule.onNodeWithContentDescription("Product thumbnail").assertIsDisplayed()
    }

    @Test
    fun moltImage_nullUrl_withNullContentDescription_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltImage(
                    url = null,
                    contentDescription = null,
                    modifier = Modifier.size(100.dp),
                )
            }
        }

        // Should not crash — Box with shimmer background
    }

    @Test
    fun moltImage_withUrl_withNullContentDescription_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltImage(
                    url = "https://example.com/image.jpg",
                    contentDescription = null,
                    modifier = Modifier.size(100.dp),
                )
            }
        }

        // Should not crash — async image without content description
    }
}
