package com.xirigo.ecommerce.feature.profile.presentation.screen

import androidx.compose.foundation.background
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.component.XGButton
import com.xirigo.ecommerce.core.designsystem.component.XGButtonStyle
import com.xirigo.ecommerce.core.designsystem.component.XGDivider
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/** Screen-level constants extracted from magic numbers per coding standards. */
private object ProfileConstants {
    /** Avatar circle diameter in the guest header (design spec: 80dp). */
    val GuestAvatarSize = XGSpacing.XXL + XGSpacing.XXXL // 32 + 48 = 80dp
}

@Composable
fun ProfileScreen(modifier: Modifier = Modifier) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
    ) {
        item(key = "guest_header") {
            GuestHeader()
        }
        item(key = "section_spacer_top") {
            Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
        }
        item(key = "menu_section") {
            ProfileMenuSection()
        }
        item(key = "section_spacer_bottom") {
            Spacer(modifier = Modifier.height(XGSpacing.SectionSpacing))
        }
    }
}

@Composable
private fun GuestHeader() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(XGColors.SurfaceVariant)
            .padding(XGSpacing.LG),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            modifier = Modifier
                .size(ProfileConstants.GuestAvatarSize)
                .clip(CircleShape)
                .background(XGColors.SecondaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = Icons.Outlined.Person,
                contentDescription = null,
                modifier = Modifier.size(XGSpacing.XXL),
                tint = XGColors.OnSecondaryContainer,
            )
        }

        Spacer(modifier = Modifier.height(XGSpacing.Base))

        Text(
            text = stringResource(R.string.nav_profile_guest_title),
            style = MaterialTheme.typography.bodyLarge,
            color = XGColors.OnSurfaceVariant,
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
        shape = RoundedCornerShape(XGCornerRadius.Large),
        elevation = CardDefaults.cardElevation(defaultElevation = XGElevation.Level1),
        colors = CardDefaults.cardColors(containerColor = XGColors.Surface),
    ) {
        Column {
            menuItems.forEachIndexed { index, item ->
                ProfileMenuRow(item = item)
                if (index < menuItems.lastIndex) {
                    XGDivider(
                        modifier = Modifier.padding(horizontal = XGSpacing.Base),
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
            tint = XGColors.OnSurfaceVariant,
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
            tint = XGColors.OnSurfaceVariant,
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
