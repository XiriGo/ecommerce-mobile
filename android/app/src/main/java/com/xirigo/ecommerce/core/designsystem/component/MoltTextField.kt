package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.error
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.core.designsystem.theme.MoltCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.MoltSpacing
import com.xirigo.ecommerce.core.designsystem.theme.MoltTheme

@Composable
fun MoltTextField(
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

    Column(modifier = semanticsModifier) {
        MoltOutlinedTextFieldContent(
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

        MoltTextFieldSupportingText(
            errorMessage = errorMessage,
            helperText = helperText,
        )

        MoltTextFieldCharacterCount(
            value = value,
            maxLength = maxLength,
        )
    }
}

@Composable
private fun MoltOutlinedTextFieldContent(
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
        modifier = Modifier.fillMaxWidth(),
        label = { Text(text = label) },
        placeholder = placeholder?.let { { Text(text = it) } },
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
        shape = RoundedCornerShape(MoltCornerRadius.Medium),
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
private fun MoltTextFieldSupportingText(errorMessage: String?, helperText: String?) {
    val supportingText = errorMessage ?: helperText
    if (supportingText != null) {
        Text(
            text = supportingText,
            modifier = Modifier.padding(
                start = MoltSpacing.Base,
                top = MoltSpacing.XS,
            ),
            color = if (errorMessage != null) {
                MaterialTheme.colorScheme.error
            } else {
                MaterialTheme.colorScheme.onSurfaceVariant
            },
            style = MaterialTheme.typography.bodySmall,
        )
    }
}

@Composable
private fun MoltTextFieldCharacterCount(value: String, maxLength: Int?) {
    if (maxLength != null) {
        Text(
            text = "${value.length}/$maxLength",
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    end = MoltSpacing.Base,
                    top = MoltSpacing.XS,
                ),
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            style = MaterialTheme.typography.bodySmall,
            textAlign = androidx.compose.ui.text.style.TextAlign.End,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltTextFieldDefaultPreview() {
    MoltTheme {
        MoltTextField(
            value = "",
            onValueChange = {},
            label = "Email",
            placeholder = "Enter your email",
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltTextFieldErrorPreview() {
    MoltTheme {
        MoltTextField(
            value = "invalid",
            onValueChange = {},
            label = "Email",
            errorMessage = "Invalid email address",
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltTextFieldPasswordPreview() {
    MoltTheme {
        MoltTextField(
            value = "password123",
            onValueChange = {},
            label = "Password",
            isPassword = true,
        )
    }
}
