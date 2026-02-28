package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private val ActiveDotWidth = 18.dp
private val InactiveDotWidth = 6.dp
private val DotHeight = 6.dp
private val DotCornerRadius = 3.dp
private val DotGap = 4.dp
private const val ANIMATION_DURATION_MS = 300

@Composable
fun XGPaginationDots(
    totalPages: Int,
    currentPage: Int,
    modifier: Modifier = Modifier,
    activeColor: Color = XGColors.PaginationDotsActive,
    inactiveColor: Color = XGColors.PaginationDotsInactive,
) {
    Row(
        modifier = modifier.semantics {
            contentDescription = "Page ${currentPage + 1} of $totalPages"
        },
        horizontalArrangement = Arrangement.spacedBy(DotGap),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        repeat(totalPages) { index ->
            val isActive = index == currentPage
            val animatedWidth by animateDpAsState(
                targetValue = if (isActive) ActiveDotWidth else InactiveDotWidth,
                animationSpec = tween(durationMillis = ANIMATION_DURATION_MS),
                label = "dotWidth$index",
            )

            Box(
                modifier = Modifier
                    .width(animatedWidth)
                    .height(DotHeight)
                    .clip(RoundedCornerShape(DotCornerRadius))
                    .background(if (isActive) activeColor else inactiveColor),
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPaginationDotsPreview() {
    XGTheme {
        XGPaginationDots(totalPages = 4, currentPage = 1)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPaginationDotsFirstPagePreview() {
    XGTheme {
        XGPaginationDots(totalPages = 4, currentPage = 0)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPaginationDotsLastPagePreview() {
    XGTheme {
        XGPaginationDots(totalPages = 4, currentPage = 3)
    }
}
