import SwiftUI

// MARK: - StepperConstants

/// Component-level constants from `xg-quantity-stepper.json` token spec.
private enum StepperConstants {
    /// Opacity applied to buttons when disabled (spec: 0.38).
    static let disabledOpacity: Double = 0.38
}

// MARK: - XGQuantityStepper

/// Increment/decrement stepper for item quantity selection.
///
/// Token source: `components/atoms/xg-quantity-stepper.json`.
/// - Button size: `XGSpacing.minTouchTarget` (48pt)
/// - Button background: `XGColors.surfaceTertiary`
/// - Button corner radius: `XGCornerRadius.medium` (10pt)
/// - Icon size: `XGSpacing.IconSize.medium` (24pt)
/// - Disabled opacity: `StepperConstants.disabledOpacity` (0.38)
/// - Quantity font: `XGTypography.titleMedium` (16pt Medium)
/// - Quantity min width: `XGSpacing.xl` (24pt)
/// - Spacing: `XGSpacing.md` (12pt)
struct XGQuantityStepper: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        quantity: Binding<Int>,
        minQuantity: Int = 1,
        maxQuantity: Int = 99,
        onQuantityChange: @escaping (Int) -> Void,
    ) {
        _quantity = quantity
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.onQuantityChange = onQuantityChange
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        HStack(spacing: XGSpacing.md) {
            decreaseButton
            quantityLabel
            increaseButton
        }
        .accessibilityElement(children: .combine)
        .accessibilityAdjustableAction { direction in
            switch direction {
                case .increment:
                    increaseQuantity()

                case .decrement:
                    decreaseQuantity()

                @unknown default:
                    break
            }
        }
    }

    // MARK: - Private

    @Binding private var quantity: Int

    private let minQuantity: Int
    private let maxQuantity: Int
    private let onQuantityChange: (Int) -> Void

    private var canDecrease: Bool {
        quantity > minQuantity
    }

    private var canIncrease: Bool {
        quantity < maxQuantity
    }

    // MARK: - Subviews

    private var decreaseButton: some View {
        Button(action: decreaseQuantity) {
            Image(systemName: "minus")
                .font(.system(size: XGSpacing.IconSize.medium))
                .foregroundStyle(canDecrease ? XGColors.onSurface : XGColors.onSurfaceVariant)
        }
        .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        .background(XGColors.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .disabled(!canDecrease)
        .opacity(canDecrease ? 1.0 : StepperConstants.disabledOpacity)
        .accessibilityLabel(String(localized: "common_decrease_quantity"))
    }

    private var quantityLabel: some View {
        Text("\(quantity)")
            .font(XGTypography.titleMedium)
            .foregroundStyle(XGColors.onSurface)
            .frame(minWidth: XGSpacing.xl)
            .accessibilityLabel(
                String(localized: "common_quantity_value \(quantity)"),
            )
    }

    private var increaseButton: some View {
        Button(action: increaseQuantity) {
            Image(systemName: "plus")
                .font(.system(size: XGSpacing.IconSize.medium))
                .foregroundStyle(canIncrease ? XGColors.onSurface : XGColors.onSurfaceVariant)
        }
        .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        .background(XGColors.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .disabled(!canIncrease)
        .opacity(canIncrease ? 1.0 : StepperConstants.disabledOpacity)
        .accessibilityLabel(String(localized: "common_increase_quantity"))
    }

    private func decreaseQuantity() {
        guard canDecrease else {
            return
        }
        quantity -= 1
        onQuantityChange(quantity)
    }

    private func increaseQuantity() {
        guard canIncrease else {
            return
        }
        quantity += 1
        onQuantityChange(quantity)
    }
}

// MARK: - Previews

#Preview("XGQuantityStepper") {
    struct PreviewWrapper: View {
        @State var quantity = 3

        var body: some View {
            XGQuantityStepper(
                quantity: $quantity,
                onQuantityChange: { _ in },
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("XGQuantityStepper Min") {
    struct PreviewWrapper: View {
        @State var quantity = 1

        var body: some View {
            XGQuantityStepper(
                quantity: $quantity,
                onQuantityChange: { _ in },
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("XGQuantityStepper Max") {
    struct PreviewWrapper: View {
        @State var quantity = 99

        var body: some View {
            XGQuantityStepper(
                quantity: $quantity,
                onQuantityChange: { _ in },
            )
            .padding()
        }
    }
    return PreviewWrapper()
}
