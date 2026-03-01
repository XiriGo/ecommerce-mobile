import SwiftUI

// MARK: - ShimmerModifier

/// Applies an animated shimmer gradient sweep to any view shape.
///
/// The linear gradient translates horizontally across the view on an infinite loop,
/// producing a loading-placeholder animation. All timing, angle, and color values
/// come from ``XGMotion/Shimmer`` design tokens -- no hardcoded values.
///
/// Usage:
/// ```swift
/// RoundedRectangle(cornerRadius: XGCornerRadius.medium)
///     .fill(XGMotion.Shimmer.gradientColors.first!)
///     .shimmerEffect()
/// ```
struct ShimmerModifier: ViewModifier {
    // MARK: - Internal

    /// When `false`, the modifier is a no-op and returns the content unchanged.
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content
                .overlay(shimmerOverlay)
                .mask(content)
        } else {
            content
        }
    }

    // MARK: - Private

    /// Multiplier for the total horizontal travel distance.
    private static let travelMultiplier: CGFloat = 2

    @State private var phase: CGFloat = 0

    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            let gradientWidth = geometry.size.width
            LinearGradient(
                colors: XGMotion.Shimmer.gradientColors,
                startPoint: .leading,
                endPoint: .trailing,
            )
            .frame(width: gradientWidth)
            .rotationEffect(.degrees(XGMotion.Shimmer.angleDegrees))
            .offset(x: offsetForPhase(viewWidth: gradientWidth))
            .onAppear {
                withAnimation(
                    .linear(duration: XGMotion.Shimmer.duration)
                        .repeatForever(autoreverses: false),
                ) {
                    phase = 1
                }
            }
        }
        .clipped()
    }

    /// Translates the gradient from off-screen left to off-screen right.
    private func offsetForPhase(viewWidth: CGFloat) -> CGFloat {
        let totalTravel = viewWidth * Self.travelMultiplier
        return -viewWidth + (phase * totalTravel)
    }
}

// MARK: - View Extension

extension View {
    /// Applies an animated shimmer sweep effect for loading placeholders.
    ///
    /// - Parameter active: Pass `false` to disable the animation (renders content as-is).
    /// - Returns: The view with a shimmer gradient overlay when active.
    func shimmerEffect(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}

// MARK: - PreviewConstants

private enum PreviewConstants {
    static let boxHeight: CGFloat = 120
    static let circleSize: CGFloat = 80
    static let textWidthLong: CGFloat = 220
    static let textWidthShort: CGFloat = 160
    static let textHeight: CGFloat = 16
}

// MARK: - ShimmerPreview

private struct ShimmerPreview: View {
    // MARK: - Internal

    var body: some View {
        VStack(spacing: XGSpacing.base) {
            rectanglePlaceholder
            circlePlaceholder
            textPlaceholders
        }
        .padding(XGSpacing.screenPaddingHorizontal)
    }

    // MARK: - Private

    private var rectanglePlaceholder: some View {
        RoundedRectangle(cornerRadius: XGCornerRadius.medium)
            .fill(XGMotion.Shimmer.gradientColors.first ?? XGColors.shimmer)
            .frame(height: PreviewConstants.boxHeight)
            .shimmerEffect()
    }

    private var circlePlaceholder: some View {
        Circle()
            .fill(XGMotion.Shimmer.gradientColors.first ?? XGColors.shimmer)
            .frame(
                width: PreviewConstants.circleSize,
                height: PreviewConstants.circleSize,
            )
            .shimmerEffect()
    }

    private var textPlaceholders: some View {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            RoundedRectangle(cornerRadius: XGCornerRadius.small)
                .fill(XGMotion.Shimmer.gradientColors.first ?? XGColors.shimmer)
                .frame(
                    width: PreviewConstants.textWidthLong,
                    height: PreviewConstants.textHeight,
                )
                .shimmerEffect()

            RoundedRectangle(cornerRadius: XGCornerRadius.small)
                .fill(XGMotion.Shimmer.gradientColors.first ?? XGColors.shimmer)
                .frame(
                    width: PreviewConstants.textWidthShort,
                    height: PreviewConstants.textHeight,
                )
                .shimmerEffect()
        }
    }
}

// MARK: - Previews

#Preview("Shimmer on Shapes") {
    ShimmerPreview()
        .xgTheme()
}

#Preview("Shimmer Disabled") {
    RoundedRectangle(cornerRadius: XGCornerRadius.medium)
        .fill(XGMotion.Shimmer.gradientColors.first ?? XGColors.shimmer)
        .frame(height: PreviewConstants.boxHeight)
        .shimmerEffect(active: false)
        .padding(XGSpacing.screenPaddingHorizontal)
        .xgTheme()
}
