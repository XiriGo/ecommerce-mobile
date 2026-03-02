import SwiftUI

// MARK: - XGColorSwatch

/// Circular color swatch with optional selection state.
///
/// When `isSelected` is `true`, a branded ring surrounds the swatch and a
/// checkmark icon is overlaid at the centre. The checkmark colour adapts
/// automatically based on the luminance of `color` so it remains visible
/// against both light and dark swatches.
///
/// Token source: `shared/design-tokens/components/atoms/xg-color-swatch.json`
struct XGColorSwatch: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        color: Color,
        isSelected: Bool = false,
        colorName: String,
        action: @escaping () -> Void,
    ) {
        self.color = color
        self.isSelected = isSelected
        self.colorName = colorName
        self.action = action
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            ZStack {
                // Selection ring (outer circle)
                Circle()
                    .stroke(
                        XGColors.primary,
                        lineWidth: Constants.selectedRingWidth,
                    )
                    .frame(width: Constants.totalSize, height: Constants.totalSize)
                    .opacity(isSelected ? 1 : 0)

                // Swatch circle with border
                Circle()
                    .fill(color)
                    .frame(width: Constants.swatchSize, height: Constants.swatchSize)
                    .overlay(
                        Circle()
                            .stroke(XGColors.outline, lineWidth: Constants.whiteBorderWidth),
                    )
                    .overlay {
                        // Checkmark overlay
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: Constants.checkmarkSize, weight: .bold))
                                .foregroundStyle(checkmarkColor)
                        }
                    }
            }
            .frame(width: Constants.totalSize, height: Constants.totalSize)
        }
        .buttonStyle(.plain)
        .animation(XGMotion.Easing.standard, value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Private

    private enum Constants {
        /// Overall diameter of the swatch circle (token `size` = 40).
        static let swatchSize: CGFloat = 40

        /// Stroke width of the selection ring (token `selectedRingWidth` = 2).
        static let selectedRingWidth: CGFloat = 2

        /// Gap between the swatch edge and the selection ring (token `selectedRingGap` = 3).
        static let selectedRingGap: CGFloat = 3

        /// Width of the always-visible border (token `whiteBorderWidth` = 1).
        static let whiteBorderWidth: CGFloat = 1

        /// Icon size for the checkmark overlay.
        static let checkmarkSize: CGFloat = 14

        /// Luminance threshold for choosing dark vs light checkmark.
        static let luminanceThreshold: CGFloat = 0.6

        /// Total size including ring and gap.
        static let totalSize: CGFloat = swatchSize + (selectedRingGap + selectedRingWidth) * 2
    }

    private let color: Color
    private let isSelected: Bool
    private let colorName: String
    private let action: () -> Void

    private var checkmarkColor: Color {
        color.luminance > Constants.luminanceThreshold
            ? XGColors.onSurface
            : XGColors.brandOnPrimary
    }

    private var accessibilityDescription: String {
        if isSelected {
            String(localized: "common_color_swatch_selected_a11y \(colorName)")
        } else {
            colorName
        }
    }
}

// MARK: - Color Luminance Extension

private extension Color {
    /// Approximate relative luminance using sRGB coefficients.
    var luminance: CGFloat {
        guard let components = cgColor?.components, components.count >= 3 else {
            return 0
        }
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue
    }
}

// MARK: - Previews

#Preview("XGColorSwatch Unselected") {
    HStack(spacing: XGSpacing.sm) {
        XGColorSwatch(color: Color(hex: "#1D1D1B"), colorName: "Black") {}
        XGColorSwatch(color: Color(hex: "#EF4444"), colorName: "Red") {}
        XGColorSwatch(color: .white, colorName: "White") {}
        XGColorSwatch(color: Color(hex: "#3B82F6"), colorName: "Blue") {}
        XGColorSwatch(color: Color(hex: "#22C55E"), colorName: "Green") {}
    }
    .padding()
    .xgTheme()
}

#Preview("XGColorSwatch Selected Dark") {
    HStack(spacing: XGSpacing.sm) {
        XGColorSwatch(color: Color(hex: "#1D1D1B"), isSelected: true, colorName: "Black") {}
        XGColorSwatch(color: Color(hex: "#3B82F6"), isSelected: true, colorName: "Blue") {}
        XGColorSwatch(color: Color(hex: "#EF4444"), isSelected: true, colorName: "Red") {}
    }
    .padding()
    .xgTheme()
}

#Preview("XGColorSwatch Selected Light") {
    HStack(spacing: XGSpacing.sm) {
        XGColorSwatch(color: .white, isSelected: true, colorName: "White") {}
        XGColorSwatch(color: Color(hex: "#22C55E"), isSelected: true, colorName: "Green") {}
    }
    .padding()
    .xgTheme()
}
