import SwiftUI

// MARK: - FilterPillTokens

// Token source: shared/design-tokens/components/molecules/xg-filter-pill.json

private enum FilterPillTokens {
    /// Height from token `tokens.height` = 36.
    static let height: CGFloat = 36

    /// Corner radius from token `tokens.cornerRadius` = 18.
    static let cornerRadius: CGFloat = 18

    /// Horizontal padding from token `tokens.horizontalPadding` = 16.
    static let horizontalPadding: CGFloat = XGSpacing.base

    /// Gap between icon and text from token `tokens.gap` = 8.
    static let gap: CGFloat = XGSpacing.sm
}

// MARK: - XGFilterPillItem

/// Data model for a single filter pill.
struct XGFilterPillItem: Equatable, Sendable {
    let label: String
    let isSelected: Bool
}

// MARK: - XGFilterPill

/// A single filter pill with optional dismiss (X) button.
///
/// Wraps ``XGFilterChip`` with filter-specific behavior:
/// - **Selected state**: filled background + leading checkmark icon
/// - **Unselected state**: outlined border + inactive colors
/// - **Dismiss**: trailing X icon when `isSelected` is `true` AND `onDismiss` is provided
struct XGFilterPill: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        label: String,
        isSelected: Bool = false,
        onSelect: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil,
    ) {
        self.label = label
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onDismiss = onDismiss
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: FilterPillTokens.gap) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: XGSpacing.IconSize.small))
                }

                Text(label)
                    .font(XGTypography.bodyMedium)

                if isSelected, let onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: XGSpacing.IconSize.small))
                    }
                    .accessibilityLabel(
                        String(
                            localized: "common_filter_pill_dismiss_a11y \(label)",
                        ),
                    )
                }
            }
            .padding(.horizontal, FilterPillTokens.horizontalPadding)
            .frame(height: FilterPillTokens.height)
            .foregroundStyle(pillForeground)
            .background(pillBackground)
            .clipShape(RoundedRectangle(cornerRadius: FilterPillTokens.cornerRadius))
            .overlay(pillBorder)
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Private

    private let label: String
    private let isSelected: Bool
    private let onSelect: () -> Void
    private let onDismiss: (() -> Void)?

    private var pillForeground: Color {
        isSelected ? XGColors.filterPillTextActive : XGColors.filterPillText
    }

    private var pillBackground: Color {
        isSelected ? XGColors.filterPillBackgroundActive : XGColors.filterPillBackground
    }

    @ViewBuilder
    private var pillBorder: some View {
        if !isSelected {
            RoundedRectangle(cornerRadius: FilterPillTokens.cornerRadius)
                .stroke(XGColors.outline, lineWidth: 1)
        }
    }
}

// MARK: - XGFilterPillRow

/// Horizontally scrollable row of ``XGFilterPill`` items.
struct XGFilterPillRow: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        items: [XGFilterPillItem],
        onSelect: @escaping (Int) -> Void,
        onDismiss: ((Int) -> Void)? = nil,
    ) {
        self.items = items
        self.onSelect = onSelect
        self.onDismiss = onDismiss
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FilterPillTokens.gap) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    XGFilterPill(
                        label: item.label,
                        isSelected: item.isSelected,
                        onSelect: { onSelect(index) },
                        onDismiss: onDismiss.map { callback in { callback(index) } },
                    )
                }
            }
            .padding(.horizontal, XGSpacing.base)
        }
    }

    // MARK: - Private

    private let items: [XGFilterPillItem]
    private let onSelect: (Int) -> Void
    private let onDismiss: ((Int) -> Void)?
}

// MARK: - Previews

#Preview("XGFilterPill — Unselected") {
    XGFilterPill(label: "Electronics", onSelect: {})
        .padding()
}

#Preview("XGFilterPill — Selected") {
    XGFilterPill(label: "Electronics", isSelected: true, onSelect: {})
        .padding()
}

#Preview("XGFilterPill — Selected with Dismiss") {
    XGFilterPill(label: "Electronics", isSelected: true, onSelect: {}, onDismiss: {})
        .padding()
}

#Preview("XGFilterPillRow") {
    XGFilterPillRow(
        items: [
            XGFilterPillItem(label: "All", isSelected: true),
            XGFilterPillItem(label: "Electronics", isSelected: false),
            XGFilterPillItem(label: "Fashion", isSelected: true),
            XGFilterPillItem(label: "Home", isSelected: false),
            XGFilterPillItem(label: "Sports", isSelected: false),
        ],
        onSelect: { _ in },
        onDismiss: { _ in },
    )
    .padding(.vertical)
}
