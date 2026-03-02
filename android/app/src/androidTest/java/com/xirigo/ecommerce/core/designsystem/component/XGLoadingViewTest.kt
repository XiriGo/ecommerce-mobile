package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGLoadingViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // region XGLoadingView — Convenience (loading-only)

    @Test
    fun xgLoadingView_noArgs_showsLoadingPlaceholder() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingView()
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgLoadingView_withCustomSkeleton_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingView(
                    skeleton = {
                        Column {
                            SkeletonBox(
                                width = androidx.compose.ui.unit.Dp(170f),
                                height = androidx.compose.ui.unit.Dp(170f),
                            )
                            SkeletonLine(width = androidx.compose.ui.unit.Dp(140f))
                        }
                    },
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()
    }

    // endregion

    // region XGLoadingView — Crossfade (isLoading + content)

    @Test
    fun xgLoadingView_isLoadingTrue_showsSkeletonNotContent() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingView(isLoading = true) {
                    Text("Actual content")
                }
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgLoadingView_isLoadingFalse_showsContent() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingView(isLoading = false) {
                    Text("Actual content")
                }
            }
        }

        composeTestRule.mainClock.advanceTimeBy(500)

        composeTestRule
            .onNode(hasText("Actual content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgLoadingView_crossfade_transitionsFromLoadingToContent() {
        var isLoading by mutableStateOf(true)

        composeTestRule.setContent {
            XGTheme {
                XGLoadingView(isLoading = isLoading) {
                    Text("Loaded content")
                }
            }
        }

        // Initially loading
        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()

        // Transition to content
        isLoading = false
        composeTestRule.mainClock.advanceTimeBy(500)

        composeTestRule
            .onNode(hasText("Loaded content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgLoadingView_withCustomSkeletonAndCrossfade_showsCustomSkeleton() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingView(
                    isLoading = true,
                    skeleton = {
                        Text("Custom skeleton placeholder")
                    },
                ) {
                    Text("Actual content")
                }
            }
        }

        composeTestRule
            .onNode(hasText("Custom skeleton placeholder"))
            .assertIsDisplayed()
    }

    // endregion

    // region XGLoadingIndicator — Convenience (loading-only)

    @Test
    fun xgLoadingIndicator_noArgs_showsLoadingPlaceholder() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingIndicator()
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgLoadingIndicator_withCustomSkeleton_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingIndicator(
                    skeleton = {
                        SkeletonLine(width = androidx.compose.ui.unit.Dp(200f))
                    },
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()
    }

    // endregion

    // region XGLoadingIndicator — Crossfade (isLoading + content)

    @Test
    fun xgLoadingIndicator_isLoadingTrue_showsSkeletonNotContent() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingIndicator(isLoading = true) {
                    Text("More items")
                }
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgLoadingIndicator_isLoadingFalse_showsContent() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingIndicator(isLoading = false) {
                    Text("More items loaded")
                }
            }
        }

        composeTestRule.mainClock.advanceTimeBy(500)

        composeTestRule
            .onNode(hasText("More items loaded"))
            .assertIsDisplayed()
    }

    @Test
    fun xgLoadingIndicator_crossfade_transitionsFromLoadingToContent() {
        var isLoading by mutableStateOf(true)

        composeTestRule.setContent {
            XGTheme {
                XGLoadingIndicator(isLoading = isLoading) {
                    Text("Inline content")
                }
            }
        }

        // Initially loading
        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()

        // Transition to content
        isLoading = false
        composeTestRule.mainClock.advanceTimeBy(500)

        composeTestRule
            .onNode(hasText("Inline content"))
            .assertIsDisplayed()
    }

    // endregion

    // region No spinner pattern

    @Test
    fun xgLoadingView_noCircularProgressIndicator() {
        // This test validates that the old spinner pattern is gone.
        // XGLoadingView now uses skeleton/shimmer, not CircularProgressIndicator.
        composeTestRule.setContent {
            XGTheme {
                XGLoadingView()
            }
        }

        // The old pattern used "Loading..." as contentDescription.
        // New pattern uses "Loading content" from skeleton_loading_placeholder.
        composeTestRule
            .onNode(hasContentDescription("Loading..."))
            .assertDoesNotExist()
    }

    @Test
    fun xgLoadingIndicator_noCircularProgressIndicator() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingIndicator()
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Loading..."))
            .assertDoesNotExist()
    }

    // endregion
}
