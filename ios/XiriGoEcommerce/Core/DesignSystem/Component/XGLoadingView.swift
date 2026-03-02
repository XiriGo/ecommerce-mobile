import SwiftUI

// MARK: - DefaultSkeletonConstants

/// Internal constants for default skeleton placeholders.
private enum DefaultSkeletonConstants {
    static let boxHeight: CGFloat = 200
    static let lineHeight: CGFloat = 14
    static let inlineLineHeight: CGFloat = 24
    static let longLineFraction: CGFloat = 0.7
    static let shortLineFraction: CGFloat = 0.5
    static let lineBlockRowCount: CGFloat = 3
}

// MARK: - XGLoadingView

/// Skeleton-aware full-screen loading view.
///
/// Crossfades between a skeleton placeholder and real content using
/// ``XGMotion/Crossfade/contentSwitch`` (0.2s). When no skeleton slot is provided,
/// a default full-width shimmer layout is shown.
///
/// Usage with crossfade:
/// ```swift
/// XGLoadingView(isLoading: viewModel.isLoading) {
///     SkeletonBox(width: 170, height: 170)
///     SkeletonLine(width: 140)
/// } content: {
///     ProductDetailContent(product: product)
/// }
/// ```
///
/// Usage without content (loading-only, backward compatible):
/// ```swift
/// XGLoadingView()
/// ```
struct XGLoadingView<Skeleton: View, Content: View>: View {
    // MARK: - Lifecycle

    /// Creates a skeleton-aware loading view with crossfade transition.
    ///
    /// - Parameters:
    ///   - isLoading: When `true`, shows the skeleton. When `false`, shows content.
    ///   - skeleton: The skeleton placeholder to show during loading.
    ///   - content: The real content to reveal when loading completes.
    init(
        isLoading: Bool,
        @ViewBuilder skeleton: () -> Skeleton,
        @ViewBuilder content: () -> Content,
    ) {
        self.isLoading = isLoading
        self.skeleton = skeleton()
        self.content = content()
    }

    // MARK: - Internal

    let isLoading: Bool
    let skeleton: Skeleton
    let content: Content

    var body: some View {
        Group {
            if isLoading {
                skeleton
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .transition(.opacity)
                    .accessibilityLabel(Text("skeleton_loading_placeholder"))
            } else {
                content
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: XGMotion.Crossfade.contentSwitch),
            value: isLoading,
        )
    }
}

// MARK: - XGLoadingView convenience (no skeleton)

extension XGLoadingView where Skeleton == DefaultFullScreenSkeleton {
    /// Creates a skeleton-aware loading view with a default shimmer placeholder.
    ///
    /// - Parameters:
    ///   - isLoading: When `true`, shows default shimmer. When `false`, shows content.
    ///   - content: The real content to reveal when loading completes.
    init(
        isLoading: Bool,
        @ViewBuilder content: () -> Content,
    ) {
        self.isLoading = isLoading
        skeleton = DefaultFullScreenSkeleton()
        self.content = content()
    }
}

extension XGLoadingView where Skeleton == DefaultFullScreenSkeleton, Content == EmptyView {
    /// Creates a loading-only view with the default shimmer placeholder (no content slot).
    ///
    /// Use this for backward compatibility where the caller switches on UI state
    /// and renders content in a different branch.
    init() {
        isLoading = true
        skeleton = DefaultFullScreenSkeleton()
        content = EmptyView()
    }
}

// MARK: - XGLoadingView convenience (custom skeleton, no content)

extension XGLoadingView where Content == EmptyView {
    /// Creates a loading-only view with a custom skeleton placeholder.
    ///
    /// - Parameter skeleton: The skeleton placeholder to display.
    init(@ViewBuilder skeleton: () -> Skeleton) {
        isLoading = true
        self.skeleton = skeleton()
        content = EmptyView()
    }
}

// MARK: - XGLoadingIndicator

/// Skeleton-aware inline loading indicator for list footers and sections.
///
/// Crossfades between a skeleton placeholder and real content using
/// ``XGMotion/Crossfade/contentSwitch`` (0.2s). When no skeleton slot is provided,
/// a default full-width shimmer line is shown.
struct XGLoadingIndicator<Skeleton: View, Content: View>: View {
    // MARK: - Lifecycle

    /// Creates a skeleton-aware inline loading indicator with crossfade transition.
    ///
    /// - Parameters:
    ///   - isLoading: When `true`, shows the skeleton. When `false`, shows content.
    ///   - skeleton: The skeleton placeholder to show during loading.
    ///   - content: The real content to reveal when loading completes.
    init(
        isLoading: Bool,
        @ViewBuilder skeleton: () -> Skeleton,
        @ViewBuilder content: () -> Content,
    ) {
        self.isLoading = isLoading
        self.skeleton = skeleton()
        self.content = content()
    }

    // MARK: - Internal

    let isLoading: Bool
    let skeleton: Skeleton
    let content: Content

    var body: some View {
        Group {
            if isLoading {
                skeleton
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XGSpacing.base)
                    .transition(.opacity)
                    .accessibilityLabel(Text("skeleton_loading_placeholder"))
            } else {
                content
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: XGMotion.Crossfade.contentSwitch),
            value: isLoading,
        )
    }
}

// MARK: - XGLoadingIndicator convenience (no skeleton)

extension XGLoadingIndicator where Skeleton == DefaultInlineSkeleton {
    /// Creates an inline loading indicator with a default shimmer line.
    ///
    /// - Parameters:
    ///   - isLoading: When `true`, shows default shimmer. When `false`, shows content.
    ///   - content: The real content to reveal when loading completes.
    init(
        isLoading: Bool,
        @ViewBuilder content: () -> Content,
    ) {
        self.isLoading = isLoading
        skeleton = DefaultInlineSkeleton()
        self.content = content()
    }
}

extension XGLoadingIndicator where Skeleton == DefaultInlineSkeleton, Content == EmptyView {
    /// Creates a loading-only inline indicator with the default shimmer line.
    init() {
        isLoading = true
        skeleton = DefaultInlineSkeleton()
        content = EmptyView()
    }
}

// MARK: - DefaultFullScreenSkeleton

/// Default full-screen shimmer placeholder: a shimmer box with shimmer lines below.
struct DefaultFullScreenSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            RoundedRectangle(cornerRadius: XGCornerRadius.medium)
                .fill(XGColors.shimmer)
                .frame(height: DefaultSkeletonConstants.boxHeight)
                .shimmerEffect()

            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: XGSpacing.sm) {
                    RoundedRectangle(cornerRadius: XGCornerRadius.small)
                        .fill(XGColors.shimmer)
                        .frame(
                            width: geometry.size.width * DefaultSkeletonConstants.longLineFraction,
                            height: DefaultSkeletonConstants.lineHeight,
                        )
                        .shimmerEffect()

                    RoundedRectangle(cornerRadius: XGCornerRadius.small)
                        .fill(XGColors.shimmer)
                        .frame(
                            width: geometry.size.width * DefaultSkeletonConstants.shortLineFraction,
                            height: DefaultSkeletonConstants.lineHeight,
                        )
                        .shimmerEffect()
                }
            }
            .frame(height: DefaultSkeletonConstants.lineHeight * DefaultSkeletonConstants.lineBlockRowCount)
        }
        .padding(XGSpacing.base)
    }
}

// MARK: - DefaultInlineSkeleton

/// Default inline shimmer placeholder: a full-width shimmer line.
struct DefaultInlineSkeleton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: XGCornerRadius.small)
            .fill(XGColors.shimmer)
            .frame(maxWidth: .infinity)
            .frame(height: DefaultSkeletonConstants.inlineLineHeight)
            .shimmerEffect()
    }
}

// MARK: - PreviewConstants

private enum PreviewConstants {
    static let skeletonBoxSize: CGFloat = 170
    static let skeletonLineWidthLong: CGFloat = 140
    static let skeletonLineWidthShort: CGFloat = 80
    static let indicatorLineWidth: CGFloat = 200
}

// MARK: - Previews

#Preview("XGLoadingView — Default Skeleton") {
    XGLoadingView()
        .xgTheme()
}

#Preview("XGLoadingView — Custom Skeleton") {
    XGLoadingView {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            SkeletonBox(
                width: PreviewConstants.skeletonBoxSize,
                height: PreviewConstants.skeletonBoxSize,
            )
            SkeletonLine(width: PreviewConstants.skeletonLineWidthLong)
            SkeletonLine(width: PreviewConstants.skeletonLineWidthShort)
        }
        .padding(XGSpacing.base)
    }
    .xgTheme()
}

#Preview("XGLoadingView — Crossfade Loading") {
    XGLoadingView(isLoading: true) {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            SkeletonBox(
                width: PreviewConstants.skeletonBoxSize,
                height: PreviewConstants.skeletonBoxSize,
            )
            SkeletonLine(width: PreviewConstants.skeletonLineWidthLong)
        }
        .padding(XGSpacing.base)
    } content: {
        Text(verbatim: "Content loaded!")
            .padding(XGSpacing.base)
    }
    .xgTheme()
}

#Preview("XGLoadingView — Crossfade Content") {
    XGLoadingView(isLoading: false) {
        Text(verbatim: "Content loaded!")
            .padding(XGSpacing.base)
    }
    .xgTheme()
}

#Preview("XGLoadingIndicator — Default Skeleton") {
    VStack {
        Text(verbatim: "List content above")
        XGLoadingIndicator()
    }
    .xgTheme()
}

#Preview("XGLoadingIndicator — Custom Skeleton") {
    VStack {
        Text(verbatim: "List content above")
        XGLoadingIndicator(isLoading: true) {
            SkeletonLine(width: PreviewConstants.indicatorLineWidth)
        } content: {
            Text(verbatim: "More items loaded")
        }
    }
    .xgTheme()
}

// MARK: - XGLoadingViewInteractiveDemo

/// Interactive demo showing the crossfade transition between skeleton and content.
private struct XGLoadingViewInteractiveDemo: View {
    // MARK: - Internal

    var body: some View {
        VStack {
            XGLoadingView(isLoading: isLoading) {
                VStack(alignment: .leading, spacing: XGSpacing.sm) {
                    SkeletonBox(
                        width: PreviewConstants.skeletonBoxSize,
                        height: PreviewConstants.skeletonBoxSize,
                    )
                    SkeletonLine(width: PreviewConstants.skeletonLineWidthLong)
                    SkeletonLine(width: PreviewConstants.skeletonLineWidthShort)
                }
                .padding(XGSpacing.base)
            } content: {
                Text(verbatim: "Real content loaded!")
                    .padding(XGSpacing.base)
            }

            Button {
                isLoading.toggle()
            } label: {
                Text(verbatim: isLoading ? "Show Content" : "Show Skeleton")
            }
            .padding(XGSpacing.base)
        }
    }

    // MARK: - Private

    @State private var isLoading = true
}

#Preview("XGLoadingView — Interactive Toggle") {
    XGLoadingViewInteractiveDemo()
        .xgTheme()
}
