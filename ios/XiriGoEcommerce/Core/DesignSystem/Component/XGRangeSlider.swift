import SwiftUI

// MARK: - XGRangeSlider

/// Dual-thumb range slider for selecting a numeric range.
/// Token source: `components/atoms/xg-range-slider.json`.
///
/// - Track height: 4pt
/// - Thumb size: 24pt diameter
/// - Thumb border: 3pt, surface color
/// - Active track: brand primary
/// - Inactive track: borderStrong
struct XGRangeSlider: View {
    // MARK: - Lifecycle

    init(
        min: Binding<Double>,
        max: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 0,
        showLabels: Bool = true,
        labelFormatter: @escaping (Double) -> String = { "\(Int($0))" },
        onRangeChange: @escaping (Double, Double) -> Void = { _, _ in },
    ) {
        _min = min
        _max = max
        self.range = range
        self.step = step
        self.showLabels = showLabels
        self.labelFormatter = labelFormatter
        self.onRangeChange = onRangeChange
    }

    // MARK: - Internal

    var body: some View {
        VStack(spacing: Constants.labelTopPadding) {
            sliderTrack
            if showLabels {
                labelsRow
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Private

    private enum Constants {
        static let trackHeight: CGFloat = 4
        static let thumbSize: CGFloat = 24
        static let thumbBorderWidth: CGFloat = 3
        static let labelFontSize: CGFloat = 12
        static let labelTopPadding: CGFloat = 8
        static let sliderHeight: CGFloat = 48
    }

    private enum DraggingThumb {
        case none
        case low
        case high
    }

    @Binding private var min: Double
    @Binding private var max: Double
    @State private var draggingThumb: DraggingThumb = .none

    private let range: ClosedRange<Double>
    private let step: Double
    private let showLabels: Bool
    private let labelFormatter: (Double) -> String
    private let onRangeChange: (Double, Double) -> Void

    private var accessibilityDescription: String {
        String(
            localized: "common_range_slider_description \(labelFormatter(min)) \(labelFormatter(max))",
        )
    }

    private var totalRange: Double {
        range.upperBound - range.lowerBound
    }

    private var sliderTrack: some View {
        GeometryReader { geometry in
            let layout = TrackLayout(
                geometry: geometry,
                minValue: min,
                maxValue: max,
                range: range,
                totalRange: totalRange,
            )
            trackContent(layout: layout)
        }
        .frame(height: Constants.sliderHeight)
    }

    private var labelsRow: some View {
        HStack {
            Text(labelFormatter(min))
                .font(XGTypography.caption)
                .foregroundStyle(XGColors.onSurfaceVariant)
            Spacer()
            Text(labelFormatter(max))
                .font(XGTypography.caption)
                .foregroundStyle(XGColors.onSurfaceVariant)
        }
    }

    private func trackContent(layout: TrackLayout) -> some View {
        ZStack {
            inactiveTrackView(layout: layout)
            activeTrackShape(lowX: layout.lowX, highX: layout.highX, centerY: layout.centerY)
            lowThumbView(layout: layout)
            highThumbView(layout: layout)
        }
    }

    private func inactiveTrackView(layout: TrackLayout) -> some View {
        Capsule()
            .fill(XGColors.borderStrong)
            .frame(width: layout.trackWidth, height: Constants.trackHeight)
            .position(x: layout.canvasWidth / 2, y: layout.centerY)
    }

    private func lowThumbView(layout: TrackLayout) -> some View {
        thumbView()
            .position(x: layout.lowX, y: layout.centerY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newValue = valueForPosition(
                            value.location.x,
                            trackWidth: layout.trackWidth,
                            thumbRadius: layout.thumbRadius,
                        )
                        min = Swift.min(newValue, max)
                        onRangeChange(min, max)
                    },
            )
    }

    private func highThumbView(layout: TrackLayout) -> some View {
        thumbView()
            .position(x: layout.highX, y: layout.centerY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newValue = valueForPosition(
                            value.location.x,
                            trackWidth: layout.trackWidth,
                            thumbRadius: layout.thumbRadius,
                        )
                        max = Swift.max(newValue, min)
                        onRangeChange(min, max)
                    },
            )
    }

    @ViewBuilder
    private func activeTrackShape(
        lowX: Double,
        highX: Double,
        centerY: Double,
    ) -> some View {
        let width = highX - lowX
        if width > 0 {
            Capsule()
                .fill(XGColors.primary)
                .frame(
                    width: width,
                    height: Constants.trackHeight,
                )
                .position(
                    x: lowX + width / 2,
                    y: centerY,
                )
        }
    }

    private func thumbView() -> some View {
        Circle()
            .fill(XGColors.primary)
            .frame(
                width: Constants.thumbSize,
                height: Constants.thumbSize,
            )
            .overlay(
                Circle()
                    .stroke(
                        XGColors.surface,
                        lineWidth: Constants.thumbBorderWidth,
                    ),
            )
    }

    private func valueForPosition(
        _ positionX: Double,
        trackWidth: Double,
        thumbRadius: Double,
    ) -> Double {
        let fraction = (positionX - thumbRadius) / trackWidth
        let clampedFraction = Swift.min(Swift.max(fraction, 0), 1)
        let rawValue = range.lowerBound + clampedFraction * totalRange
        return snapToStep(rawValue)
    }

    private func snapToStep(_ value: Double) -> Double {
        guard step > 0 else {
            return value.clamped(to: range)
        }
        let steps = ((value - range.lowerBound) / step).rounded()
        return (range.lowerBound + steps * step).clamped(to: range)
    }
}

// MARK: - TrackLayout

/// Pre-computed layout values for the slider track, derived from GeometryProxy.
private struct TrackLayout {
    // MARK: - Lifecycle

    init(
        geometry: GeometryProxy,
        minValue: Double,
        maxValue: Double,
        range: ClosedRange<Double>,
        totalRange: Double,
    ) {
        let thumbSize: Double = 24
        canvasWidth = geometry.size.width
        trackWidth = canvasWidth - thumbSize
        thumbRadius = thumbSize / 2
        centerY = geometry.size.height / 2

        let lowFraction = totalRange > 0
            ? (minValue - range.lowerBound) / totalRange
            : 0
        let highFraction = totalRange > 0
            ? (maxValue - range.lowerBound) / totalRange
            : 1

        lowX = thumbRadius + lowFraction * trackWidth
        highX = thumbRadius + highFraction * trackWidth
    }

    // MARK: - Internal

    let trackWidth: Double
    let thumbRadius: Double
    let lowX: Double
    let highX: Double
    let centerY: Double
    let canvasWidth: Double
}

// MARK: - Comparable Extension

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Previews

#Preview("XGRangeSlider Default") {
    struct PreviewWrapper: View {
        @State var min: Double = 25
        @State var max: Double = 75

        var body: some View {
            XGRangeSlider(
                min: $min,
                max: $max,
                range: 0 ... 100,
            )
            .padding()
        }
    }
    return PreviewWrapper()
        .xgTheme()
}

#Preview("XGRangeSlider No Labels") {
    struct PreviewWrapper: View {
        @State var min: Double = 200
        @State var max: Double = 800

        var body: some View {
            XGRangeSlider(
                min: $min,
                max: $max,
                range: 0 ... 1000,
                showLabels: false,
            )
            .padding()
        }
    }
    return PreviewWrapper()
        .xgTheme()
}

#Preview("XGRangeSlider Stepped") {
    struct PreviewWrapper: View {
        @State var min: Double = 20
        @State var max: Double = 80

        var body: some View {
            XGRangeSlider(
                min: $min,
                max: $max,
                range: 0 ... 100,
                step: 10,
                labelFormatter: { "$\(Int($0))" },
            )
            .padding()
        }
    }
    return PreviewWrapper()
        .xgTheme()
}
