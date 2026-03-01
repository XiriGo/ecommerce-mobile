import SwiftUI

// MARK: - XGBadgeVariant

/// Badge style variants matching `components/atoms/xg-badge.json`.
enum XGBadgeVariant {
    /// Primary: brand primary bg, white text.
    case primary
    /// Secondary: brand secondary bg, brand primary text (DAILY DEAL, NEW SEASON).
    case secondary

    // MARK: - Internal

    var backgroundColor: Color {
        switch self {
            case .primary:
                XGColors.badgeBackground
            case .secondary:
                XGColors.badgeSecondaryBackground
        }
    }

    var textColor: Color {
        switch self {
            case .primary:
                XGColors.badgeText
            case .secondary:
                XGColors.badgeSecondaryText
        }
    }
}

// MARK: - XGBadge

/// Inline badge label component.
/// Token source: `components/atoms/xg-badge.json`.
///
/// - Font: 12pt semiBold
/// - Corner radius: 10pt
/// - Horizontal padding: 10pt
/// - Vertical padding: 4pt
struct XGBadge: View {
    // MARK: - Lifecycle

    init(
        label: String,
        variant: XGBadgeVariant = .primary,
    ) {
        self.label = label
        self.variant = variant
    }

    // MARK: - Internal

    var body: some View {
        Text(label)
            .font(XGTypography.captionSemiBold)
            .foregroundStyle(variant.textColor)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(variant.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
            .accessibilityLabel(label)
    }

    // MARK: - Private

    private enum Constants {
        static let fontSize: CGFloat = 12
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 4
    }

    private let label: String
    private let variant: XGBadgeVariant
}

// MARK: - XGBadgeStatus

enum XGBadgeStatus {
    case success
    case warning
    case error
    case info
    case neutral

    // MARK: - Internal

    var backgroundColor: Color {
        switch self {
            case .success: XGColors.success
            case .warning: XGColors.warning
            case .error: XGColors.error
            case .info: XGColors.info
            case .neutral: XGColors.surfaceVariant
        }
    }

    var textColor: Color {
        switch self {
            case .success: XGColors.onSuccess
            case .warning: XGColors.onWarning
            case .error: XGColors.onError
            case .info: XGColors.onInfo
            case .neutral: XGColors.onSurfaceVariant
        }
    }
}

// MARK: - XGCountBadge

struct XGCountBadge: View {
    // MARK: - Lifecycle

    init(count: Int) {
        self.count = count
    }

    // MARK: - Internal

    var body: some View {
        if hasItems {
            Text(displayText)
                .font(XGTypography.labelSmall)
                .foregroundStyle(XGColors.badgeText)
                .padding(.horizontal, XGSpacing.xs)
                .padding(.vertical, XGSpacing.xxs)
                .background(XGColors.badgeBackground)
                .clipShape(Capsule())
                .accessibilityLabel(
                    String(localized: "common_notifications_count \(count)"),
                )
        }
    }

    // MARK: - Private

    private let count: Int

    private var hasItems: Bool {
        count >= 1
    }

    private var displayText: String {
        count >= 100 ? "99+" : "\(count)"
    }
}

// MARK: - XGStatusBadge

struct XGStatusBadge: View {
    // MARK: - Lifecycle

    init(status: XGBadgeStatus, label: String) {
        self.status = status
        self.label = label
    }

    // MARK: - Internal

    var body: some View {
        Text(label)
            .font(XGTypography.labelSmall)
            .foregroundStyle(status.textColor)
            .padding(.horizontal, XGSpacing.sm)
            .padding(.vertical, XGSpacing.xs)
            .background(status.backgroundColor)
            .clipShape(Capsule())
            .accessibilityLabel(label)
    }

    // MARK: - Private

    private let status: XGBadgeStatus
    private let label: String
}

// MARK: - Previews

#Preview("XGBadge") {
    VStack(spacing: XGSpacing.sm) {
        XGBadge(label: "NEW SEASON", variant: .secondary)
        XGBadge(label: "DAILY DEAL", variant: .secondary)
        XGBadge(label: "SALE", variant: .primary)
    }
    .padding()
    .xgTheme()
}

#Preview("XGCountBadge") {
    HStack(spacing: XGSpacing.base) {
        XGCountBadge(count: 3)
        XGCountBadge(count: 99)
        XGCountBadge(count: 150)
        XGCountBadge(count: 0)
    }
    .padding()
    .xgTheme()
}

#Preview("XGStatusBadge") {
    VStack(spacing: XGSpacing.sm) {
        XGStatusBadge(status: .success, label: "In Stock")
        XGStatusBadge(status: .warning, label: "Low Stock")
        XGStatusBadge(status: .error, label: "Out of Stock")
        XGStatusBadge(status: .info, label: "Processing")
        XGStatusBadge(status: .neutral, label: "Draft")
    }
    .padding()
    .xgTheme()
}
