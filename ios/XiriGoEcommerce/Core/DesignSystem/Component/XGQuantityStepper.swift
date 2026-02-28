import SwiftUI

// MARK: - XGQuantityStepper

struct XGQuantityStepper: View {
    // MARK: - Properties

    @Binding private var quantity: Int
    private let minQuantity: Int
    private let maxQuantity: Int
    private let onQuantityChange: (Int) -> Void

    // MARK: - Init

    init(
        quantity: Binding<Int>,
        minQuantity: Int = 1,
        maxQuantity: Int = 99,
        onQuantityChange: @escaping (Int) -> Void
    ) {
        self._quantity = quantity
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.onQuantityChange = onQuantityChange
    }

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

    // MARK: - Subviews

    private var decreaseButton: some View {
        Button(action: decreaseQuantity) {
            Image(systemName: "minus")
                .font(.system(size: XGSpacing.IconSize.medium))
                .foregroundStyle(canDecrease ? XGColors.onSurface : XGColors.onSurfaceVariant)
        }
        .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        .background(XGColors.surfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .disabled(!canDecrease)
        .opacity(canDecrease ? 1.0 : 0.38)
        .accessibilityLabel(String(localized: "common_decrease_quantity"))
    }

    private var quantityLabel: some View {
        Text("\(quantity)")
            .font(XGTypography.titleMedium)
            .foregroundStyle(XGColors.onSurface)
            .frame(minWidth: XGSpacing.xl)
            .accessibilityLabel(
                String(localized: "common_quantity_value \(quantity)")
            )
    }

    private var increaseButton: some View {
        Button(action: increaseQuantity) {
            Image(systemName: "plus")
                .font(.system(size: XGSpacing.IconSize.medium))
                .foregroundStyle(canIncrease ? XGColors.onSurface : XGColors.onSurfaceVariant)
        }
        .frame(minWidth: XGSpacing.minTouchTarget, minHeight: XGSpacing.minTouchTarget)
        .background(XGColors.surfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .disabled(!canIncrease)
        .opacity(canIncrease ? 1.0 : 0.38)
        .accessibilityLabel(String(localized: "common_increase_quantity"))
    }

    // MARK: - Private

    private var canDecrease: Bool {
        quantity > minQuantity
    }

    private var canIncrease: Bool {
        quantity < maxQuantity
    }

    private func decreaseQuantity() {
        guard canDecrease else { return }
        quantity -= 1
        onQuantityChange(quantity)
    }

    private func increaseQuantity() {
        guard canIncrease else { return }
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
                onQuantityChange: { _ in }
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
                onQuantityChange: { _ in }
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
                onQuantityChange: { _ in }
            )
            .padding()
        }
    }
    return PreviewWrapper()
}
