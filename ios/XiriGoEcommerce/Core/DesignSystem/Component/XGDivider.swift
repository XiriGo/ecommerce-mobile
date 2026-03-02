import SwiftUI

// MARK: - XGDivider

/// Design-system divider component.
///
/// Token source: `components/atoms/xg-divider.json`.
/// - Default color: `XGColors.divider` (`#E5E7EB`)
/// - Default thickness: 1 pt
///
/// Feature screens **must** use this instead of raw `Divider()`.
struct XGDivider: View {
    // MARK: - Lifecycle

    init(
        color: Color = XGColors.divider,
        thickness: CGFloat = Constants.defaultThickness,
    ) {
        self.color = color
        self.thickness = thickness
    }

    // MARK: - Internal

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: thickness)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }

    // MARK: - Private

    private let color: Color
    private let thickness: CGFloat
}

// MARK: - XGLabeledDivider

/// Divider with a centered text label (line -- label -- line).
///
/// Token source: `components/atoms/xg-divider.json` (withLabel variant).
/// - Label font: `XGTypography.captionMedium` (Poppins Medium 12pt)
/// - Label color: `XGColors.textTertiary` (`#9CA3AF`)
/// - Label horizontal padding: 16pt
/// - Line color: `XGColors.divider` (`#E5E7EB`)
///
/// Usage: "OR CONTINUE WITH" on the Login screen.
struct XGLabeledDivider: View {
    // MARK: - Lifecycle

    init(
        label: String,
        color: Color = XGColors.divider,
        thickness: CGFloat = Constants.defaultThickness,
    ) {
        self.label = label
        self.color = color
        self.thickness = thickness
    }

    // MARK: - Internal

    var body: some View {
        HStack {
            XGDivider(color: color, thickness: thickness)
            Text(label)
                .font(XGTypography.captionMedium)
                .foregroundStyle(XGColors.textTertiary)
                .padding(.horizontal, Constants.labelHorizontalPadding)
            XGDivider(color: color, thickness: thickness)
        }
    }

    // MARK: - Private

    private let label: String
    private let color: Color
    private let thickness: CGFloat
}

// MARK: - Constants

private enum Constants {
    static let defaultThickness: CGFloat = 1
    static let labelHorizontalPadding: CGFloat = 16
}

// MARK: - Previews

#Preview("XGDivider") {
    VStack(spacing: XGSpacing.base) {
        XGDivider()
        XGDivider(color: XGColors.outline)
    }
    .padding()
    .xgTheme()
}

#Preview("XGLabeledDivider") {
    XGLabeledDivider(label: "OR CONTINUE WITH")
        .padding()
        .xgTheme()
}
