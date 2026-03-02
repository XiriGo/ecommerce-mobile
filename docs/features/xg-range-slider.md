# XGRangeSlider

## Overview

Dual-thumb range slider component for selecting a numeric range. Part of the XiriGo design system atom layer. Used by Product Search (M1-08) price filter and any future filter screens.

## Token Source

`shared/design-tokens/components/atoms/xg-range-slider.json`

## API

### Android (Kotlin + Jetpack Compose)

```kotlin
@Composable
fun XGRangeSlider(
    min: Float,
    max: Float,
    range: ClosedFloatingPointRange<Float>,
    onRangeChange: (Float, Float) -> Unit,
    modifier: Modifier = Modifier,
    step: Float = 0f,
    showLabels: Boolean = true,
    labelFormatter: (Float) -> String = { it.roundToInt().toString() },
)
```

### iOS (Swift + SwiftUI)

```swift
struct XGRangeSlider: View {
    init(
        min: Binding<Double>,
        max: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 0,
        showLabels: Bool = true,
        labelFormatter: @escaping (Double) -> String = { "\(Int($0))" },
        onRangeChange: @escaping (Double, Double) -> Void = { _, _ in }
    )
}
```

## Design Tokens

| Token | Value | Android | iOS |
|-------|-------|---------|-----|
| trackHeight | 4 | 4.dp | 4pt |
| trackActiveColor | brand.primary | XGColors.Primary | XGColors.primary |
| trackInactiveColor | borderStrong | XGColors.Outline | XGColors.borderStrong |
| thumbSize | 24 | 24.dp | 24pt |
| thumbColor | brand.primary | XGColors.Primary | XGColors.primary |
| thumbBorderColor | surface | XGColors.Surface | XGColors.surface |
| thumbBorderWidth | 3 | 3.dp | 3pt |

## Files

### Android
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGRangeSlider.kt`
- `android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/component/XGRangeSliderTokenTest.kt`

### iOS
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGRangeSlider.swift`
- `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGRangeSliderTests.swift`

## Test Coverage

- Android: 11 token contract tests
- iOS: 15 tests (6 init + 9 token contract)

## Usage Example

### Android

```kotlin
var min by remember { mutableFloatStateOf(25f) }
var max by remember { mutableFloatStateOf(75f) }

XGRangeSlider(
    min = min,
    max = max,
    range = 0f..100f,
    onRangeChange = { newMin, newMax ->
        min = newMin
        max = newMax
    },
    labelFormatter = { "$${it.roundToInt()}" },
)
```

### iOS

```swift
@State private var min: Double = 25
@State private var max: Double = 75

XGRangeSlider(
    min: $min,
    max: $max,
    range: 0...100,
    labelFormatter: { "$\(Int($0))" }
)
```
