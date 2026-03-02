import SwiftUI

// MARK: - XGTextFieldTokens

/// Token-spec constants for XGTextField.
/// Source: `shared/design-tokens/components/atoms/xg-text-field.json`
/// and `shared/design-tokens/foundations/spacing.json > inputSize.default`.
private enum XGTextFieldTokens {
    /// inputSize.default.height = 52 pt
    static let fieldHeight: CGFloat = 52

    /// default.borderWidth = 1 pt
    static let borderWidth: CGFloat = 1

    /// default.focusBorderWidth = 2 pt
    static let focusBorderWidth: CGFloat = 2

    /// Disabled-state opacity (Material 3 convention: 0.38)
    static let disabledOpacity: Double = 0.38
}

// MARK: - XGTextField

struct XGTextField: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        value: Binding<String>,
        label: String,
        placeholder: String? = nil,
        errorMessage: String? = nil,
        helperText: String? = nil,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        onTrailingIconTap: (() -> Void)? = nil,
        isEnabled: Bool = true,
        isReadOnly: Bool = false,
        isPassword: Bool = false,
        maxLength: Int? = nil,
    ) {
        _value = value
        self.label = label
        self.placeholder = placeholder
        self.errorMessage = errorMessage
        self.helperText = helperText
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.onTrailingIconTap = onTrailingIconTap
        self.isEnabled = isEnabled
        self.isReadOnly = isReadOnly
        self.isPassword = isPassword
        self.maxLength = maxLength
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: XGSpacing.xs) {
            labelView
            inputField
            bottomTextView
        }
        .opacity(isEnabled ? 1.0 : XGTextFieldTokens.disabledOpacity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityHint(errorMessage ?? "")
    }

    // MARK: - Private

    @Binding private var value: String
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible = false

    private let label: String
    private let placeholder: String?
    private let errorMessage: String?
    private let helperText: String?
    private let leadingIcon: String?
    private let trailingIcon: String?
    private let onTrailingIconTap: (() -> Void)?
    private let isEnabled: Bool
    private let isReadOnly: Bool
    private let isPassword: Bool
    private let maxLength: Int?

    // MARK: - Colors

    private var borderColor: Color {
        if errorMessage != nil {
            return XGColors.error
        }
        if isFocused {
            return XGColors.primary
        }
        return XGColors.inputBorder
    }

    private var currentBorderWidth: CGFloat {
        isFocused
            ? XGTextFieldTokens.focusBorderWidth
            : XGTextFieldTokens.borderWidth
    }

    private var labelColor: Color {
        if errorMessage != nil {
            return XGColors.error
        }
        if isFocused {
            return XGColors.primary
        }
        return XGColors.inputLabel
    }

    // MARK: - Subviews

    private var labelView: some View {
        Text(label)
            .font(XGTypography.bodySmall)
            .foregroundStyle(labelColor)
    }

    private var inputField: some View {
        HStack(spacing: XGSpacing.sm) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }

            textField

            trailingIconView
        }
        .padding(.horizontal, XGSpacing.md)
        .frame(minHeight: XGTextFieldTokens.fieldHeight)
        .background(XGColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: XGCornerRadius.medium)
                .stroke(borderColor, lineWidth: currentBorderWidth),
        )
    }

    @ViewBuilder
    private var textField: some View {
        if isPassword, !isPasswordVisible {
            SecureField(placeholder ?? "", text: $value)
                .font(XGTypography.bodyLarge)
                .foregroundStyle(XGColors.onSurface)
                .focused($isFocused)
                .disabled(!isEnabled || isReadOnly)
        } else {
            TextField(placeholder ?? "", text: $value)
                .font(XGTypography.bodyLarge)
                .foregroundStyle(XGColors.onSurface)
                .focused($isFocused)
                .disabled(!isEnabled || isReadOnly)
                .onChange(of: value) { _, newValue in
                    if let maxLength, newValue.count > maxLength {
                        value = String(newValue.prefix(maxLength))
                    }
                }
        }
    }

    @ViewBuilder
    private var trailingIconView: some View {
        if isPassword {
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .font(.system(size: XGSpacing.IconSize.medium))
            }
            .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
            .accessibilityLabel(
                isPasswordVisible
                    ? String(localized: "common_hide_password")
                    : String(localized: "common_show_password"),
            )
        } else if let trailingIcon {
            Button {
                onTrailingIconTap?()
            } label: {
                Image(systemName: trailingIcon)
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }
            .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        }
    }

    private var bottomTextView: some View {
        HStack {
            if let errorMessage {
                Text(errorMessage)
                    .font(XGTypography.bodySmall)
                    .foregroundStyle(XGColors.error)
            } else if let helperText {
                Text(helperText)
                    .font(XGTypography.bodySmall)
                    .foregroundStyle(XGColors.onSurfaceVariant)
            }

            Spacer()

            if let maxLength {
                Text("\(value.count)/\(maxLength)")
                    .font(XGTypography.bodySmall)
                    .foregroundStyle(XGColors.onSurfaceVariant)
            }
        }
    }
}

// MARK: - Previews

#Preview("XGTextField Default") {
    struct PreviewWrapper: View {
        @State var text = ""
        var body: some View {
            XGTextField(
                value: $text,
                label: "Email",
                placeholder: "Enter your email",
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("XGTextField Error") {
    struct PreviewWrapper: View {
        @State var text = "invalid"
        var body: some View {
            XGTextField(
                value: $text,
                label: "Email",
                placeholder: "Enter your email",
                errorMessage: "Invalid email address",
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("XGTextField Password") {
    struct PreviewWrapper: View {
        @State var text = ""
        var body: some View {
            XGTextField(
                value: $text,
                label: "Password",
                placeholder: "Enter password",
                isPassword: true,
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("XGTextField Disabled") {
    struct PreviewWrapper: View {
        @State var text = "Disabled value"
        var body: some View {
            XGTextField(
                value: $text,
                label: "Disabled Field",
                isEnabled: false,
            )
            .padding()
        }
    }
    return PreviewWrapper()
}
