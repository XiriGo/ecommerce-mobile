import SwiftUI

// MARK: - MoltTextField

struct MoltTextField: View {
    // MARK: - Properties

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

    @Binding private var value: String
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible = false

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
        maxLength: Int? = nil
    ) {
        self._value = value
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

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: MoltSpacing.xs) {
            labelView
            inputField
            bottomTextView
        }
        .opacity(isEnabled ? 1.0 : 0.38)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityHint(errorMessage ?? "")
    }

    // MARK: - Subviews

    private var labelView: some View {
        Text(label)
            .font(MoltTypography.bodySmall)
            .foregroundStyle(labelColor)
    }

    private var inputField: some View {
        HStack(spacing: MoltSpacing.sm) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .foregroundStyle(MoltColors.onSurfaceVariant)
                    .font(.system(size: MoltSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }

            textField

            trailingIconView
        }
        .padding(.horizontal, MoltSpacing.md)
        .padding(.vertical, MoltSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: MoltCornerRadius.medium)
                .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
        )
    }

    @ViewBuilder
    private var textField: some View {
        if isPassword && !isPasswordVisible {
            SecureField(placeholder ?? "", text: $value)
                .font(MoltTypography.bodyLarge)
                .focused($isFocused)
                .disabled(!isEnabled || isReadOnly)
        } else {
            TextField(placeholder ?? "", text: $value)
                .font(MoltTypography.bodyLarge)
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
                    .foregroundStyle(MoltColors.onSurfaceVariant)
                    .font(.system(size: MoltSpacing.IconSize.medium))
            }
            .frame(minWidth: MoltSpacing.minTouchTarget, minHeight: MoltSpacing.minTouchTarget)
            .accessibilityLabel(
                isPasswordVisible
                    ? String(localized: "common_hide_password")
                    : String(localized: "common_show_password")
            )
        } else if let trailingIcon {
            Button {
                onTrailingIconTap?()
            } label: {
                Image(systemName: trailingIcon)
                    .foregroundStyle(MoltColors.onSurfaceVariant)
                    .font(.system(size: MoltSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }
            .frame(minWidth: MoltSpacing.minTouchTarget, minHeight: MoltSpacing.minTouchTarget)
        }
    }

    @ViewBuilder
    private var bottomTextView: some View {
        HStack {
            if let errorMessage {
                Text(errorMessage)
                    .font(MoltTypography.bodySmall)
                    .foregroundStyle(MoltColors.error)
            } else if let helperText {
                Text(helperText)
                    .font(MoltTypography.bodySmall)
                    .foregroundStyle(MoltColors.onSurfaceVariant)
            }

            Spacer()

            if let maxLength {
                Text("\(value.count)/\(maxLength)")
                    .font(MoltTypography.bodySmall)
                    .foregroundStyle(MoltColors.onSurfaceVariant)
            }
        }
    }

    // MARK: - Colors

    private var borderColor: Color {
        if errorMessage != nil {
            return MoltColors.error
        }
        if isFocused {
            return MoltColors.primary
        }
        return MoltColors.outline
    }

    private var labelColor: Color {
        if errorMessage != nil {
            return MoltColors.error
        }
        if isFocused {
            return MoltColors.primary
        }
        return MoltColors.onSurfaceVariant
    }
}

// MARK: - Previews

#Preview("MoltTextField Default") {
    struct PreviewWrapper: View {
        @State var text = ""
        var body: some View {
            MoltTextField(
                value: $text,
                label: "Email",
                placeholder: "Enter your email"
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("MoltTextField Error") {
    struct PreviewWrapper: View {
        @State var text = "invalid"
        var body: some View {
            MoltTextField(
                value: $text,
                label: "Email",
                placeholder: "Enter your email",
                errorMessage: "Invalid email address"
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("MoltTextField Password") {
    struct PreviewWrapper: View {
        @State var text = ""
        var body: some View {
            MoltTextField(
                value: $text,
                label: "Password",
                placeholder: "Enter password",
                isPassword: true
            )
            .padding()
        }
    }
    return PreviewWrapper()
}
