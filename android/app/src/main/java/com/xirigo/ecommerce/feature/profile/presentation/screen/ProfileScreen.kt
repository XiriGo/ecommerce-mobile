package com.xirigo.ecommerce.feature.profile.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.material.icons.outlined.CreditCard
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.LocationOn
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.component.XGButton
import com.xirigo.ecommerce.core.designsystem.component.XGButtonStyle
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun ProfileScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
    ) {
        GuestHeader()
        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
        ProfileMenuSection()
        Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
    }
}

@Composable
private fun GuestHeader() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .padding(XGSpacing.LG),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            modifier = Modifier
                .size(80.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.secondaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = Icons.Outlined.Person,
                contentDescription = null,
                modifier = Modifier.size(XGSpacing.XXL),
                tint = MaterialTheme.colorScheme.onSecondaryContainer,
            )
        }

        Spacer(modifier = Modifier.height(XGSpacing.Base))

        Text(
            text = stringResource(R.string.nav_profile_guest_title),
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )

        Spacer(modifier = Modifier.height(XGSpacing.Base))

        XGButton(
            text = stringResource(R.string.nav_profile_guest_login_button),
            onClick = { /* Navigate to login */ },
            style = XGButtonStyle.Primary,
        )

        Spacer(modifier = Modifier.height(XGSpacing.SM))

        XGButton(
            text = stringResource(R.string.nav_profile_guest_register_button),
            onClick = { /* Navigate to register */ },
            style = XGButtonStyle.Secondary,
        )
    }
}

@Immutable
private data class ProfileMenuItem(
    val title: String,
    val icon: ImageVector,
)

@Composable
private fun ProfileMenuSection() {
    val menuItems = listOf(
        ProfileMenuItem(
            title = stringResource(R.string.profile_menu_orders),
            icon = Icons.AutoMirrored.Outlined.ReceiptLong,
        ),
        ProfileMenuItem(
            title = stringResource(R.string.profile_menu_wishlist),
            icon = Icons.Outlined.FavoriteBorder,
        ),
        ProfileMenuItem(
            title = stringResource(R.string.profile_menu_addresses),
            icon = Icons.Outlined.LocationOn,
        ),
        ProfileMenuItem(
            title = stringResource(R.string.profile_menu_payment_methods),
            icon = Icons.Outlined.CreditCard,
        ),
        ProfileMenuItem(
            title = stringResource(R.string.profile_menu_settings),
            icon = Icons.Outlined.Settings,
        ),
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(XGCornerRadius.Large),
        elevation = CardDefaults.cardElevation(defaultElevation = XGElevation.Level1),
    ) {
        Column {
            menuItems.forEachIndexed { index, item ->
                ProfileMenuRow(item = item)
                if (index < menuItems.lastIndex) {
                    HorizontalDivider(
                        modifier = Modifier.padding(horizontal = XGSpacing.Base),
                        color = MaterialTheme.colorScheme.outlineVariant,
                    )
                }
            }
        }
    }
}

@Composable
private fun ProfileMenuRow(item: ProfileMenuItem) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                horizontal = XGSpacing.Base,
                vertical = XGSpacing.MD,
            ),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            imageVector = item.icon,
            contentDescription = null,
            modifier = Modifier.size(XGSpacing.LG),
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(modifier = Modifier.width(XGSpacing.Base))
        Text(
            text = item.title,
            style = MaterialTheme.typography.bodyLarge,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.weight(1f),
        )
        Icon(
            imageVector = Icons.AutoMirrored.Outlined.KeyboardArrowRight,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun ProfileScreenPreview() {
    XGTheme {
        ProfileScreen()
    }
}
