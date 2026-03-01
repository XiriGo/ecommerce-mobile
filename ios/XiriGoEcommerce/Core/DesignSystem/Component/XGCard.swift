import SwiftUI

// MARK: - XGInfoCard

struct XGInfoCard<TrailingContent: View>: View {
    // MARK: - Lifecycle

    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder trailingContent: () -> TrailingContent,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.action = action
        self.trailingContent = trailingContent()
    }

    // MARK: - Internal

    var body: some View {
        let content = HStack(spacing: XGSpacing.md) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: XGSpacing.xxs) {
                Text(title)
                    .font(XGTypography.titleMedium)
                    .foregroundStyle(XGColors.onSurface)

                if let subtitle {
                    Text(subtitle)
                        .font(XGTypography.bodySmall)
                        .foregroundStyle(XGColors.onSurfaceVariant)
                }
            }

            Spacer()

            if let trailingContent {
                trailingContent
            }
        }
        .padding(XGSpacing.cardPadding)
        .background(XGColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .xgElevation(XGElevation.level1)

        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isButton)
        } else {
            content
        }
    }

    // MARK: - Private

    private let title: String
    private let subtitle: String?
    private let leadingIcon: String?
    private let trailingContent: TrailingContent?
    private let action: (() -> Void)?
}

extension XGInfoCard where TrailingContent == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        action: (() -> Void)? = nil,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.action = action
        trailingContent = nil
    }
}

// MARK: - Previews

#Preview("XGInfoCard") {
    VStack(spacing: XGSpacing.sm) {
        XGInfoCard(
            title: "Shipping Address",
            subtitle: "123 Main Street, Valletta",
            leadingIcon: "location",
            action: {},
        )

        XGInfoCard(
            title: "Payment Method",
            subtitle: "Visa ending in 4242",
            leadingIcon: "creditcard",
        ) {
            Image(systemName: "chevron.right")
                .foregroundStyle(XGColors.onSurfaceVariant)
                .accessibilityHidden(true)
        }
    }
    .padding()
    .xgTheme()
}
