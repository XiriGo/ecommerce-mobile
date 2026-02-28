import SwiftUI

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

    // MARK: - Init

    init(count: Int) {
        self.count = count
    }

    // MARK: - Internal

    // MARK: - Body

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

    // MARK: - Init

    init(status: XGBadgeStatus, label: String) {
        self.status = status
        self.label = label
    }

    // MARK: - Internal

    // MARK: - Body

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

#Preview("XGCountBadge") {
    HStack(spacing: XGSpacing.base) {
        XGCountBadge(count: 3)
        XGCountBadge(count: 99)
        XGCountBadge(count: 150)
        XGCountBadge(count: 0)
    }
    .padding()
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
}
