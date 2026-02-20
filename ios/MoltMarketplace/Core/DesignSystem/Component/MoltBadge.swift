// swiftlint:disable no_magic_numbers
import SwiftUI

// MARK: - MoltBadgeStatus

enum MoltBadgeStatus {
    case success
    case warning
    case error
    case info
    case neutral

    var backgroundColor: Color {
        switch self {
        case .success: return MoltColors.success
        case .warning: return MoltColors.warning
        case .error: return MoltColors.error
        case .info: return MoltColors.info
        case .neutral: return MoltColors.surfaceVariant
        }
    }

    var textColor: Color {
        switch self {
        case .success: return MoltColors.onSuccess
        case .warning: return MoltColors.onWarning
        case .error: return MoltColors.onError
        case .info: return MoltColors.onInfo
        case .neutral: return MoltColors.onSurfaceVariant
        }
    }
}

// MARK: - MoltCountBadge

struct MoltCountBadge: View {
    // MARK: - Properties

    private let count: Int

    // MARK: - Init

    init(count: Int) {
        self.count = count
    }

    // MARK: - Body

    var body: some View {
        if count > 0 {
            Text(displayText)
                .font(MoltTypography.labelSmall)
                .foregroundStyle(MoltColors.badgeText)
                .padding(.horizontal, MoltSpacing.xs)
                .padding(.vertical, MoltSpacing.xxs)
                .background(MoltColors.badgeBackground)
                .clipShape(Capsule())
                .accessibilityLabel(
                    String(localized: "common_notifications_count \(count)")
                )
        }
    }

    // MARK: - Private

    private var displayText: String {
        count >= 100 ? "99+" : "\(count)"
    }
}

// MARK: - MoltStatusBadge

struct MoltStatusBadge: View {
    // MARK: - Properties

    private let status: MoltBadgeStatus
    private let label: String

    // MARK: - Init

    init(status: MoltBadgeStatus, label: String) {
        self.status = status
        self.label = label
    }

    // MARK: - Body

    var body: some View {
        Text(label)
            .font(MoltTypography.labelSmall)
            .foregroundStyle(status.textColor)
            .padding(.horizontal, MoltSpacing.sm)
            .padding(.vertical, MoltSpacing.xs)
            .background(status.backgroundColor)
            .clipShape(Capsule())
            .accessibilityLabel(label)
    }
}

// MARK: - Previews

#Preview("MoltCountBadge") {
    HStack(spacing: MoltSpacing.base) {
        MoltCountBadge(count: 3)
        MoltCountBadge(count: 99)
        MoltCountBadge(count: 150)
        MoltCountBadge(count: 0)
    }
    .padding()
}

#Preview("MoltStatusBadge") {
    VStack(spacing: MoltSpacing.sm) {
        MoltStatusBadge(status: .success, label: "In Stock")
        MoltStatusBadge(status: .warning, label: "Low Stock")
        MoltStatusBadge(status: .error, label: "Out of Stock")
        MoltStatusBadge(status: .info, label: "Processing")
        MoltStatusBadge(status: .neutral, label: "Draft")
    }
    .padding()
}

// swiftlint:enable no_magic_numbers
