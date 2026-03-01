import SwiftUI

// MARK: - SkeletonConstants

/// Internal constants for skeleton components.
/// Token source: `shared/design-tokens/components.json` (skeleton atom).
private enum SkeletonConstants {
    /// Default height for text-line skeleton placeholders (approximates `bodyMedium` line height).
    static let lineDefaultHeight: CGFloat = 14
}

// MARK: - SkeletonBox

/// Rectangular shimmer placeholder with configurable dimensions and corner radius.
///
/// Individual skeleton shapes are decorative and hidden from the accessibility tree.
/// Use the ``skeleton(visible:placeholder:)`` modifier to wrap skeleton layouts
/// with an accessible "Loading content" label.
///
/// Usage:
/// ```swift
/// SkeletonBox(width: 170, height: 170)
/// SkeletonBox(width: 170, height: 170, cornerRadius: XGCornerRadius.large)
/// ```
struct SkeletonBox: View {
    // MARK: - Lifecycle

    init(
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat = XGCornerRadius.medium,
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    // MARK: - Internal

    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(XGColors.shimmer)
            .frame(width: width, height: height)
            .shimmerEffect()
            .accessibilityHidden(true)
    }
}

// MARK: - SkeletonLine

/// Text-line shimmer placeholder with a fixed small corner radius.
///
/// The default height of 14pt approximates `bodyMedium` line height from the typography scale,
/// making `SkeletonLine` immediately usable for most text placeholders without specifying height.
///
/// The corner radius is fixed at ``XGCornerRadius/small`` (6pt) and is not configurable,
/// ensuring consistent text-line appearance across the app.
///
/// Individual skeleton shapes are decorative and hidden from the accessibility tree.
struct SkeletonLine: View {
    // MARK: - Lifecycle

    init(
        width: CGFloat,
        height: CGFloat = SkeletonConstants.lineDefaultHeight,
    ) {
        self.width = width
        self.height = height
    }

    // MARK: - Internal

    let width: CGFloat
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: XGCornerRadius.small)
            .fill(XGColors.shimmer)
            .frame(width: width, height: height)
            .shimmerEffect()
            .accessibilityHidden(true)
    }
}

// MARK: - SkeletonCircle

/// Circular shimmer placeholder for avatars, icons, and thumbnails.
///
/// Individual skeleton shapes are decorative and hidden from the accessibility tree.
struct SkeletonCircle: View {
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(XGColors.shimmer)
            .frame(width: size, height: size)
            .shimmerEffect()
            .accessibilityHidden(true)
    }
}

// MARK: - SkeletonModifier

/// Content-wrapping modifier that crossfades between a skeleton placeholder and real content.
///
/// When `visible` is `true`, the placeholder is shown with an accessible "Loading content" label.
/// When `visible` transitions to `false`, a crossfade animation reveals the real content.
///
/// The crossfade duration is ``XGMotion/Crossfade/contentSwitch`` (0.2s).
struct SkeletonModifier<Placeholder: View>: ViewModifier {
    let visible: Bool
    let placeholder: Placeholder

    func body(content: Content) -> some View {
        Group {
            if visible {
                placeholder
                    .transition(.opacity)
                    .accessibilityLabel(Text("skeleton_loading_placeholder"))
            } else {
                content
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: XGMotion.Crossfade.contentSwitch),
            value: visible,
        )
    }
}

// MARK: - View Extension

extension View {
    /// Wraps this view with a crossfade skeleton placeholder for loading states.
    ///
    /// When `visible` is `true`, the `placeholder` is displayed instead of the content.
    /// When `visible` transitions to `false`, the real content fades in using the
    /// ``XGMotion/Crossfade/contentSwitch`` duration.
    ///
    /// - Parameters:
    ///   - visible: When `true`, shows the placeholder. When `false`, shows content.
    ///   - placeholder: The skeleton layout to show during loading.
    /// - Returns: A view that crossfades between placeholder and content.
    func skeleton(
        visible: Bool,
        @ViewBuilder placeholder: () -> some View,
    ) -> some View {
        modifier(SkeletonModifier(visible: visible, placeholder: placeholder()))
    }
}

// MARK: - PreviewConstants

private enum PreviewConstants {
    static let boxWidth: CGFloat = 170
    static let boxHeight: CGFloat = 170
    static let lineWidthLong: CGFloat = 140
    static let lineWidthShort: CGFloat = 80
    static let lineSmallHeight: CGFloat = 12
    static let circleSize: CGFloat = 48
    static let ratingCircleSize: CGFloat = 12
    static let ratingLineWidth: CGFloat = 30
}

// MARK: - SkeletonBox Preview

#Preview("SkeletonBox") {
    VStack(spacing: XGSpacing.sm) {
        SkeletonBox(
            width: PreviewConstants.boxWidth,
            height: PreviewConstants.boxHeight,
        )
        SkeletonBox(
            width: PreviewConstants.boxWidth,
            height: PreviewConstants.boxHeight,
            cornerRadius: XGCornerRadius.large,
        )
    }
    .padding(XGSpacing.base)
    .xgTheme()
}

// MARK: - SkeletonLine Preview

#Preview("SkeletonLine") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        SkeletonLine(width: PreviewConstants.lineWidthLong)
        SkeletonLine(
            width: PreviewConstants.lineWidthShort,
            height: PreviewConstants.lineSmallHeight,
        )
    }
    .padding(XGSpacing.base)
    .xgTheme()
}

// MARK: - SkeletonCircle Preview

#Preview("SkeletonCircle") {
    VStack(spacing: XGSpacing.sm) {
        SkeletonCircle(size: PreviewConstants.circleSize)
        SkeletonCircle(size: PreviewConstants.ratingCircleSize)
    }
    .padding(XGSpacing.base)
    .xgTheme()
}

// MARK: - Product Card Skeleton Preview

#Preview("Product Card Skeleton") {
    VStack(alignment: .leading, spacing: XGSpacing.sm) {
        SkeletonBox(
            width: PreviewConstants.boxWidth,
            height: PreviewConstants.boxHeight,
        )
        SkeletonLine(width: PreviewConstants.lineWidthLong)
        SkeletonLine(
            width: PreviewConstants.lineWidthShort,
            height: PreviewConstants.lineSmallHeight,
        )
        HStack(spacing: XGSpacing.xs) {
            SkeletonCircle(size: PreviewConstants.ratingCircleSize)
            SkeletonLine(
                width: PreviewConstants.ratingLineWidth,
                height: PreviewConstants.lineSmallHeight,
            )
        }
    }
    .padding(XGSpacing.base)
    .xgTheme()
}

// MARK: - SkeletonCrossfadeDemo

/// Interactive demo showing the crossfade transition between skeleton placeholder and real content.
private struct SkeletonCrossfadeDemo: View {
    // MARK: - Internal

    var body: some View {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            // Preview-only label (not user-facing)
            Text(verbatim: "Crossfade Demo (isLoading=\(isLoading))")
                .font(.caption)

            Text(verbatim: "Real content loaded!")
                .skeleton(visible: isLoading) {
                    VStack(alignment: .leading, spacing: XGSpacing.sm) {
                        SkeletonBox(
                            width: PreviewConstants.boxWidth,
                            height: PreviewConstants.boxHeight,
                        )
                        SkeletonLine(width: PreviewConstants.lineWidthLong)
                    }
                }

            Button {
                isLoading.toggle()
            } label: {
                // Preview-only toggle label (not user-facing)
                Text(verbatim: isLoading ? "Show Content" : "Show Skeleton")
            }
        }
        .padding(XGSpacing.base)
    }

    // MARK: - Private

    @State private var isLoading = true
}

#Preview("Skeleton Crossfade") {
    SkeletonCrossfadeDemo()
        .xgTheme()
}
