import SwiftUI

// MARK: - MoltQuantityStepper

struct MoltQuantityStepper: View {
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
        HStack(spacing: MoltSpacing.md) {
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
                .font(.system(size: MoltSpacing.IconSize.medium))
                .foregroundStyle(canDecrease ? MoltColors.onSurface : MoltColors.onSurfaceVariant)
        }
        .frame(minWidth: MoltSpacing.minTouchTarget, minHeight: MoltSpacing.minTouchTarget)
        .background(MoltColors.surfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.medium))
        .disabled(!canDecrease)
        .opacity(canDecrease ? 1.0 : 0.38)
        .accessibilityLabel(String(localized: "common_decrease_quantity"))
    }

    private var quantityLabel: some View {
        Text("\(quantity)")
            .font(MoltTypography.titleMedium)
            .foregroundStyle(MoltColors.onSurface)
            .frame(minWidth: MoltSpacing.xl)
            .accessibilityLabel(
                String(localized: "common_quantity_value \(quantity)")
            )
    }

    private var increaseButton: some View {
        Button(action: increaseQuantity) {
            Image(systemName: "plus")
                .font(.system(size: MoltSpacing.IconSize.medium))
                .foregroundStyle(canIncrease ? MoltColors.onSurface : MoltColors.onSurfaceVariant)
        }
        .frame(minWidth: MoltSpacing.minTouchTarget, minHeight: MoltSpacing.minTouchTarget)
        .background(MoltColors.surfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.medium))
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

#Preview("MoltQuantityStepper") {
    struct PreviewWrapper: View {
        @State var quantity = 3

        var body: some View {
            MoltQuantityStepper(
                quantity: $quantity,
                onQuantityChange: { _ in }
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("MoltQuantityStepper Min") {
    struct PreviewWrapper: View {
        @State var quantity = 1

        var body: some View {
            MoltQuantityStepper(
                quantity: $quantity,
                onQuantityChange: { _ in }
            )
            .padding()
        }
    }
    return PreviewWrapper()
}

#Preview("MoltQuantityStepper Max") {
    struct PreviewWrapper: View {
        @State var quantity = 99

        var body: some View {
            MoltQuantityStepper(
                quantity: $quantity,
                onQuantityChange: { _ in }
            )
            .padding()
        }
    }
    return PreviewWrapper()
}
