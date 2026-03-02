package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.error
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * Token-spec constants for XGTextField.
 * Source: `shared/design-tokens/components/atoms/xg-text-field.json`
 * and `shared/design-tokens/foundations/spacing.json > inputSize.default`.
 */
private object XGTextFieldTokens {
    /** inputSize.default.height = 52 dp */
    val FieldHeight = 52.dp

    /** default.borderWidth = 1 dp */
    val BorderWidth = 1.dp

    /** default.focusBorderWidth = 2 dp */
    val FocusBorderWidth = 2.dp

    /** Disabled-state opacity (Material 3 convention: 0.38f) */
    const val DISABLED_OPACITY = 0.38f
}

/** Outlined text field with label, validation error, helper text, and password mode. */
@Composable
fun XGTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    placeholder: String? = null,
    errorMessage: String? = null,
    helperText: String? = null,
    leadingIcon: ImageVector? = null,
    trailingIcon: ImageVector? = null,
    onTrailingIconClick: (() -> Unit)? = null,
    enabled: Boolean = true,
    readOnly: Boolean = false,
    keyboardType: KeyboardType = KeyboardType.Text,
    isPassword: Boolean = false,
    singleLine: Boolean = true,
    maxLength: Int? = null,
) {
    var passwordVisible by rememberSaveable { mutableStateOf(false) }

    val semanticsModifier = if (errorMessage != null) {
        modifier.semantics { error(errorMessage) }
    } else {
        modifier
    }

    Column(
        modifier = semanticsModifier
            .alpha(if (enabled) 1f else XGTextFieldTokens.DISABLED_OPACITY),
    ) {
        XGOutlinedTextFieldContent(
            value = value,
            onValueChange = onValueChange,
            label = label,
            placeholder = placeholder,
            leadingIcon = leadingIcon,
            trailingIcon = trailingIcon,
            onTrailingIconClick = onTrailingIconClick,
            enabled = enabled,
            readOnly = readOnly,
            errorMessage = errorMessage,
            isPassword = isPassword,
            passwordVisible = passwordVisible,
            onPasswordToggle = { passwordVisible = !passwordVisible },
            keyboardType = keyboardType,
            singleLine = singleLine,
            maxLength = maxLength,
        )

        XGTextFieldSupportingText(
            errorMessage = errorMessage,
            helperText = helperText,
        )

        XGTextFieldCharacterCount(
            value = value,
            maxLength = maxLength,
        )
    }
}

@Composable
private fun XGOutlinedTextFieldContent(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    placeholder: String?,
    leadingIcon: ImageVector?,
    trailingIcon: ImageVector?,
    onTrailingIconClick: (() -> Unit)?,
    enabled: Boolean,
    readOnly: Boolean,
    errorMessage: String?,
    isPassword: Boolean,
    passwordVisible: Boolean,
    onPasswordToggle: () -> Unit,
    keyboardType: KeyboardType,
    singleLine: Boolean,
    maxLength: Int?,
) {
    OutlinedTextField(
        value = if (maxLength != null) value.take(maxLength) else value,
        onValueChange = { newValue ->
            if (maxLength == null || newValue.length <= maxLength) {
                onValueChange(newValue)
            }
        },
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = XGTextFieldTokens.FieldHeight),
        label = {
            Text(
                text = label,
                style = MaterialTheme.typography.bodySmall,
            )
        },
        placeholder = placeholder?.let {
            {
                Text(
                    text = it,
                    style = MaterialTheme.typography.bodyLarge,
                )
            }
        },
        leadingIcon = leadingIcon?.let {
            {
                Icon(
                    imageVector = it,
                    contentDescription = null,
                )
            }
        },
        trailingIcon = resolveTrailingIcon(
            isPassword = isPassword,
            passwordVisible = passwordVisible,
            onPasswordToggle = onPasswordToggle,
            trailingIcon = trailingIcon,
            onTrailingIconClick = onTrailingIconClick,
        ),
        enabled = enabled,
        readOnly = readOnly,
        isError = errorMessage != null,
        visualTransformation = if (isPassword && !passwordVisible) {
            PasswordVisualTransformation()
        } else {
            VisualTransformation.None
        },
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        singleLine = singleLine,
        textStyle = MaterialTheme.typography.bodyLarge,
        shape = RoundedCornerShape(XGCornerRadius.Medium),
        colors = OutlinedTextFieldDefaults.colors(
            // Text colors
            focusedTextColor = XGColors.OnSurface,
            unfocusedTextColor = XGColors.OnSurface,
            disabledTextColor = XGColors.OnSurface,
            errorTextColor = XGColors.OnSurface,
            // Container / background
            focusedContainerColor = XGColors.InputBackground,
            unfocusedContainerColor = XGColors.InputBackground,
            disabledContainerColor = XGColors.InputBackground,
            errorContainerColor = XGColors.InputBackground,
            // Border — default
            unfocusedBorderColor = XGColors.InputBorder,
            // Border — focused (brand primary)
            focusedBorderColor = XGColors.Primary,
            // Border — error
            errorBorderColor = XGColors.Error,
            // Border — disabled
            disabledBorderColor = XGColors.InputBorder,
            // Label
            focusedLabelColor = XGColors.Primary,
            unfocusedLabelColor = XGColors.InputPlaceholder,
            disabledLabelColor = XGColors.InputPlaceholder,
            errorLabelColor = XGColors.Error,
            // Placeholder
            focusedPlaceholderColor = XGColors.InputPlaceholder,
            unfocusedPlaceholderColor = XGColors.InputPlaceholder,
            disabledPlaceholderColor = XGColors.InputPlaceholder,
            errorPlaceholderColor = XGColors.InputPlaceholder,
        ),
    )
}

@Composable
private fun resolveTrailingIcon(
    isPassword: Boolean,
    passwordVisible: Boolean,
    onPasswordToggle: () -> Unit,
    trailingIcon: ImageVector?,
    onTrailingIconClick: (() -> Unit)?,
): (@Composable () -> Unit)? = when {
    isPassword -> passwordToggleIcon(
        passwordVisible = passwordVisible,
        onToggle = onPasswordToggle,
    )
    trailingIcon != null -> standardTrailingIcon(
        icon = trailingIcon,
        onClick = onTrailingIconClick,
    )
    else -> null
}

private fun passwordToggleIcon(passwordVisible: Boolean, onToggle: () -> Unit): @Composable () -> Unit = {
    IconButton(onClick = onToggle) {
        Text(
            text = if (passwordVisible) "H" else "S",
            style = MaterialTheme.typography.labelSmall,
        )
    }
}

private fun standardTrailingIcon(icon: ImageVector, onClick: (() -> Unit)?): @Composable () -> Unit = {
    if (onClick != null) {
        IconButton(onClick = onClick) {
            Icon(imageVector = icon, contentDescription = null)
        }
    } else {
        Icon(imageVector = icon, contentDescription = null)
    }
}

@Composable
private fun XGTextFieldSupportingText(errorMessage: String?, helperText: String?) {
    val supportingText = errorMessage ?: helperText
    if (supportingText != null) {
        Text(
            text = supportingText,
            modifier = Modifier.padding(
                start = XGSpacing.Base,
                top = XGSpacing.XS,
            ),
            color = if (errorMessage != null) {
                XGColors.Error
            } else {
                XGColors.OnSurfaceVariant
            },
            style = MaterialTheme.typography.bodySmall,
        )
    }
}

@Composable
private fun XGTextFieldCharacterCount(value: String, maxLength: Int?) {
    if (maxLength != null) {
        Text(
            text = "${value.length}/$maxLength",
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    end = XGSpacing.Base,
                    top = XGSpacing.XS,
                ),
            color = XGColors.OnSurfaceVariant,
            style = MaterialTheme.typography.bodySmall,
            textAlign = androidx.compose.ui.text.style.TextAlign.End,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGTextFieldDefaultPreview() {
    XGTheme {
        XGTextField(
            value = "",
            onValueChange = {},
            label = "Email",
            placeholder = "Enter your email",
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGTextFieldErrorPreview() {
    XGTheme {
        XGTextField(
            value = "invalid",
            onValueChange = {},
            label = "Email",
            errorMessage = "Invalid email address",
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGTextFieldPasswordPreview() {
    XGTheme {
        XGTextField(
            value = "password123",
            onValueChange = {},
            label = "Password",
            isPassword = true,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGTextFieldDisabledPreview() {
    XGTheme {
        XGTextField(
            value = "Disabled value",
            onValueChange = {},
            label = "Disabled Field",
            enabled = false,
        )
    }
}
