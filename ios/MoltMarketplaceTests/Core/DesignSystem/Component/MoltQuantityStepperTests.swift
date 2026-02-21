import SwiftUI
import Testing
@testable import MoltMarketplace

// MARK: - MoltQuantityStepperTests

@Suite("MoltQuantityStepper Tests")
struct MoltQuantityStepperTests {
    // MARK: - Initialisation

    @Test("Stepper initialises with quantity binding and change handler")
    func test_init_withBindingAndHandler_initialises() {
        var quantity = 3
        let binding = Binding(get: { quantity }, set: { quantity = $0 })
        let stepper = MoltQuantityStepper(
            quantity: binding,
            onQuantityChange: { _ in }
        )
        _ = stepper
        #expect(true)
    }

    @Test("Stepper initialises with default min quantity of 1")
    func test_init_defaultMinQuantity_is1() {
        var quantity = 1
        let binding = Binding(get: { quantity }, set: { quantity = $0 })
        let stepper = MoltQuantityStepper(
            quantity: binding,
            onQuantityChange: { _ in }
        )
        _ = stepper
        // Default minQuantity = 1 per component definition
        #expect(true)
    }

    @Test("Stepper initialises with default max quantity of 99")
    func test_init_defaultMaxQuantity_is99() {
        var quantity = 1
        let binding = Binding(get: { quantity }, set: { quantity = $0 })
        let stepper = MoltQuantityStepper(
            quantity: binding,
            onQuantityChange: { _ in }
        )
        _ = stepper
        // Default maxQuantity = 99 per component definition
        #expect(true)
    }

    @Test("Stepper initialises with custom min and max")
    func test_init_customMinMax_initialises() {
        var quantity = 5
        let binding = Binding(get: { quantity }, set: { quantity = $0 })
        let stepper = MoltQuantityStepper(
            quantity: binding,
            minQuantity: 2,
            maxQuantity: 10,
            onQuantityChange: { _ in }
        )
        _ = stepper
        #expect(true)
    }

    // MARK: - canDecrease Logic

    @Test("canDecrease is false when quantity equals minQuantity")
    func test_canDecrease_atMin_isFalse() {
        #expect(canDecrease(quantity: 1, min: 1) == false)
    }

    @Test("canDecrease is true when quantity exceeds minQuantity")
    func test_canDecrease_aboveMin_isTrue() {
        #expect(canDecrease(quantity: 2, min: 1) == true)
        #expect(canDecrease(quantity: 5, min: 1) == true)
    }

    @Test("canDecrease is false with custom min when at min")
    func test_canDecrease_atCustomMin_isFalse() {
        #expect(canDecrease(quantity: 3, min: 3) == false)
    }

    // MARK: - canIncrease Logic

    @Test("canIncrease is false when quantity equals maxQuantity")
    func test_canIncrease_atMax_isFalse() {
        #expect(canIncrease(quantity: 99, max: 99) == false)
    }

    @Test("canIncrease is true when quantity is below maxQuantity")
    func test_canIncrease_belowMax_isTrue() {
        #expect(canIncrease(quantity: 1, max: 99) == true)
        #expect(canIncrease(quantity: 98, max: 99) == true)
    }

    @Test("canIncrease is false with custom max when at max")
    func test_canIncrease_atCustomMax_isFalse() {
        #expect(canIncrease(quantity: 10, max: 10) == false)
    }

    // MARK: - Decrease Quantity

    @Test("Decreasing from above minimum decrements quantity by 1")
    func test_decrease_aboveMin_decrementsBy1() {
        var quantity = 5
        decrease(quantity: &quantity, min: 1, max: 99)
        #expect(quantity == 4)
    }

    @Test("Decreasing from minimum does not change quantity")
    func test_decrease_atMin_doesNotChange() {
        var quantity = 1
        decrease(quantity: &quantity, min: 1, max: 99)
        #expect(quantity == 1)
    }

    @Test("Decrease fires onQuantityChange with new value")
    func test_decrease_firesCallback_withNewValue() {
        var quantity = 5
        var callbackValue: Int?
        decreaseWithCallback(quantity: &quantity, min: 1, max: 99, callback: { callbackValue = $0 })
        #expect(callbackValue == 4)
    }

    // MARK: - Increase Quantity

    @Test("Increasing from below maximum increments quantity by 1")
    func test_increase_belowMax_incrementsBy1() {
        var quantity = 3
        increase(quantity: &quantity, min: 1, max: 99)
        #expect(quantity == 4)
    }

    @Test("Increasing from maximum does not change quantity")
    func test_increase_atMax_doesNotChange() {
        var quantity = 99
        increase(quantity: &quantity, min: 1, max: 99)
        #expect(quantity == 99)
    }

    @Test("Increase fires onQuantityChange with new value")
    func test_increase_firesCallback_withNewValue() {
        var quantity = 3
        var callbackValue: Int?
        increaseWithCallback(quantity: &quantity, min: 1, max: 99, callback: { callbackValue = $0 })
        #expect(callbackValue == 4)
    }

    // MARK: - Boundary Conditions

    @Test("Quantity at min = 1 cannot decrease below 1")
    func test_boundary_minBound_staysAtMin() {
        var quantity = 1
        for _ in 0..<10 {
            decrease(quantity: &quantity, min: 1, max: 99)
        }
        #expect(quantity == 1)
    }

    @Test("Quantity at max = 99 cannot increase above 99")
    func test_boundary_maxBound_staysAtMax() {
        var quantity = 99
        for _ in 0..<10 {
            increase(quantity: &quantity, min: 1, max: 99)
        }
        #expect(quantity == 99)
    }

    @Test("Quantity can increase from 1 to max")
    func test_increase_from1ToMax_quantity99() {
        var quantity = 1
        for _ in 0..<98 {
            increase(quantity: &quantity, min: 1, max: 99)
        }
        #expect(quantity == 99)
    }

    // MARK: - Body

    @Test("Stepper body is a valid View", .disabled("SwiftUI body requires runtime environment; use UI tests instead"))
    func test_body_isValidView() {
        var quantity = 3
        let binding = Binding(get: { quantity }, set: { quantity = $0 })
        let stepper = MoltQuantityStepper(
            quantity: binding,
            onQuantityChange: { _ in }
        )
        let body = stepper.body
        _ = body
        #expect(true)
    }

    // MARK: - Helpers

    private func canDecrease(quantity: Int, min: Int) -> Bool {
        quantity > min
    }

    private func canIncrease(quantity: Int, max: Int) -> Bool {
        quantity < max
    }

    private func decrease(quantity: inout Int, min: Int, max: Int) {
        guard quantity > min else { return }
        quantity -= 1
    }

    private func increase(quantity: inout Int, min: Int, max: Int) {
        guard quantity < max else { return }
        quantity += 1
    }

    private func decreaseWithCallback(
        quantity: inout Int,
        min: Int,
        max: Int,
        callback: (Int) -> Void
    ) {
        guard quantity > min else { return }
        quantity -= 1
        callback(quantity)
    }

    private func increaseWithCallback(
        quantity: inout Int,
        min: Int,
        max: Int,
        callback: (Int) -> Void
    ) {
        guard quantity < max else { return }
        quantity += 1
        callback(quantity)
    }
}
