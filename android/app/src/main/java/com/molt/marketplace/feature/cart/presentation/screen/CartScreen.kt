package com.molt.marketplace.feature.cart.presentation.screen

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import com.molt.marketplace.R
import com.molt.marketplace.core.designsystem.component.MoltEmptyView
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
fun CartScreen(modifier: Modifier = Modifier) {
    MoltEmptyView(
        message = stringResource(R.string.cart_empty_message),
        icon = Icons.Outlined.ShoppingCart,
        actionLabel = stringResource(R.string.cart_start_shopping),
        onAction = { /* Navigate to home / shopping */ },
        modifier = modifier,
    )
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun CartScreenPreview() {
    MoltTheme {
        CartScreen()
    }
}
