package com.molt.marketplace.core.designsystem.component

import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.google.common.truth.Truth.assertThat
import com.molt.marketplace.core.designsystem.theme.MoltTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MoltQuantityStepperTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltQuantityStepper_displaysCurrentQuantity() {
        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 3,
                    onQuantityChange = {},
                )
            }
        }

        composeTestRule.onNodeWithText("3").assertExists()
    }

    @Test
    fun moltQuantityStepper_increaseButton_firesCallbackWithIncrementedValue() {
        var newQuantity = 3

        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 3,
                    onQuantityChange = { newQuantity = it },
                )
            }
        }

        composeTestRule.onNode(hasContentDescription("Increase quantity")).performClick()
        assertThat(newQuantity).isEqualTo(4)
    }

    @Test
    fun moltQuantityStepper_decreaseButton_firesCallbackWithDecrementedValue() {
        var newQuantity = 3

        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 3,
                    onQuantityChange = { newQuantity = it },
                )
            }
        }

        composeTestRule.onNode(hasContentDescription("Decrease quantity")).performClick()
        assertThat(newQuantity).isEqualTo(2)
    }

    @Test
    fun moltQuantityStepper_atMinQuantity_decreaseButtonDisabled() {
        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 1,
                    onQuantityChange = {},
                    minQuantity = 1,
                )
            }
        }

        composeTestRule.onNode(hasContentDescription("Decrease quantity")).assertIsNotEnabled()
    }

    @Test
    fun moltQuantityStepper_atMaxQuantity_increaseButtonDisabled() {
        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 99,
                    onQuantityChange = {},
                    maxQuantity = 99,
                )
            }
        }

        composeTestRule.onNode(hasContentDescription("Increase quantity")).assertIsNotEnabled()
    }

    @Test
    fun moltQuantityStepper_aboveMin_decreaseButtonEnabled() {
        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 5,
                    onQuantityChange = {},
                    minQuantity = 1,
                )
            }
        }

        composeTestRule.onNode(hasContentDescription("Decrease quantity")).assertIsEnabled()
    }

    @Test
    fun moltQuantityStepper_belowMax_increaseButtonEnabled() {
        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 5,
                    onQuantityChange = {},
                    maxQuantity = 99,
                )
            }
        }

        composeTestRule.onNode(hasContentDescription("Increase quantity")).assertIsEnabled()
    }

    @Test
    fun moltQuantityStepper_customMinMax_enforcedCorrectly() {
        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 2,
                    onQuantityChange = {},
                    minQuantity = 2,
                    maxQuantity = 10,
                )
            }
        }

        // At min=2, decrease should be disabled
        composeTestRule.onNode(hasContentDescription("Decrease quantity")).assertIsNotEnabled()
        // Below max=10, increase should be enabled
        composeTestRule.onNode(hasContentDescription("Increase quantity")).assertIsEnabled()
    }

    @Test
    fun moltQuantityStepper_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltQuantityStepper(
                    quantity = 1,
                    onQuantityChange = {},
                )
            }
        }

        composeTestRule.onNodeWithText("1").assertExists()
    }
}
