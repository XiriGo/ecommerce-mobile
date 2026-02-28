package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGQuantityStepperTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltQuantityStepper_displaysCurrentQuantity() {
        composeTestRule.setContent {
            XGTheme {
                XGQuantityStepper(
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
            XGTheme {
                XGQuantityStepper(
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
            XGTheme {
                XGQuantityStepper(
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
            XGTheme {
                XGQuantityStepper(
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
            XGTheme {
                XGQuantityStepper(
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
            XGTheme {
                XGQuantityStepper(
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
            XGTheme {
                XGQuantityStepper(
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
            XGTheme {
                XGQuantityStepper(
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
            XGTheme {
                XGQuantityStepper(
                    quantity = 1,
                    onQuantityChange = {},
                )
            }
        }

        composeTestRule.onNodeWithText("1").assertExists()
    }
}
