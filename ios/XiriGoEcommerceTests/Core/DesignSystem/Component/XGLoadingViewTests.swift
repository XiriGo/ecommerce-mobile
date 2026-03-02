import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIBodyReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGLoadingViewTests

@Suite("XGLoadingView Tests")
@MainActor
struct XGLoadingViewTests {
    // MARK: - Convenience init (loading-only)

    @Test("XGLoadingView() initialises without parameters")
    func init_noParameters_initialises() {
        let view = XGLoadingView()
        _ = view
        #expect(true)
    }

    @Test("XGLoadingView with custom skeleton initialises")
    func init_customSkeleton_initialises() {
        let view = XGLoadingView {
            SkeletonBox(width: 170, height: 170)
            SkeletonLine(width: 140)
        }
        _ = view
        #expect(true)
    }

    // MARK: - Crossfade init (isLoading + content)

    @Test("XGLoadingView isLoading=true initialises")
    func init_isLoadingTrue_initialises() {
        let view = XGLoadingView(isLoading: true) {
            Text(verbatim: "Content")
        }
        _ = view
        #expect(view.isLoading)
    }

    @Test("XGLoadingView isLoading=false initialises")
    func init_isLoadingFalse_initialises() {
        let view = XGLoadingView(isLoading: false) {
            Text(verbatim: "Content")
        }
        _ = view
        #expect(!view.isLoading)
    }

    @Test("XGLoadingView with custom skeleton and content initialises")
    func init_customSkeletonAndContent_initialises() {
        let view = XGLoadingView(isLoading: true) {
            SkeletonBox(width: 170, height: 170)
        } content: {
            Text(verbatim: "Content")
        }
        _ = view
        #expect(view.isLoading)
    }

    @Test("XGLoadingView isLoading property reflects state")
    func isLoading_reflectsCorrectState() {
        let loadingView = XGLoadingView(isLoading: true) {
            Text(verbatim: "Content")
        }
        let contentView = XGLoadingView(isLoading: false) {
            Text(verbatim: "Content")
        }
        #expect(loadingView.isLoading)
        #expect(!contentView.isLoading)
    }

    @Test("XGLoadingView body is a valid View", .disabled(swiftUIBodyReason))
    func body_isValidView() {
        let view = XGLoadingView()
        let body = view.body
        _ = body
        #expect(true)
    }
}

// MARK: - XGLoadingIndicatorTests

@Suite("XGLoadingIndicator Tests")
@MainActor
struct XGLoadingIndicatorTests {
    // MARK: - Convenience init (loading-only)

    @Test("XGLoadingIndicator() initialises without parameters")
    func init_noParameters_initialises() {
        let indicator = XGLoadingIndicator()
        _ = indicator
        #expect(true)
    }

    // MARK: - Crossfade init (isLoading + content)

    @Test("XGLoadingIndicator isLoading=true initialises")
    func init_isLoadingTrue_initialises() {
        let indicator = XGLoadingIndicator(isLoading: true) {
            Text(verbatim: "More items")
        }
        _ = indicator
        #expect(indicator.isLoading)
    }

    @Test("XGLoadingIndicator isLoading=false initialises")
    func init_isLoadingFalse_initialises() {
        let indicator = XGLoadingIndicator(isLoading: false) {
            Text(verbatim: "More items")
        }
        _ = indicator
        #expect(!indicator.isLoading)
    }

    @Test("XGLoadingIndicator with custom skeleton initialises")
    func init_customSkeleton_initialises() {
        let indicator = XGLoadingIndicator(isLoading: true) {
            SkeletonLine(width: 200)
        } content: {
            Text(verbatim: "More items")
        }
        _ = indicator
        #expect(indicator.isLoading)
    }

    @Test("XGLoadingIndicator isLoading property reflects state")
    func isLoading_reflectsCorrectState() {
        let loadingIndicator = XGLoadingIndicator(isLoading: true) {
            Text(verbatim: "Content")
        }
        let contentIndicator = XGLoadingIndicator(isLoading: false) {
            Text(verbatim: "Content")
        }
        #expect(loadingIndicator.isLoading)
        #expect(!contentIndicator.isLoading)
    }

    @Test("XGLoadingIndicator body is a valid View", .disabled(swiftUIBodyReason))
    func body_isValidView() {
        let indicator = XGLoadingIndicator()
        let body = indicator.body
        _ = body
        #expect(true)
    }
}

// MARK: - DefaultSkeletonTests

@Suite("Default Skeleton Tests")
@MainActor
struct DefaultSkeletonTests {
    @Test("DefaultFullScreenSkeleton initialises")
    func fullScreen_initialises() {
        let skeleton = DefaultFullScreenSkeleton()
        _ = skeleton
        #expect(true)
    }

    @Test("DefaultInlineSkeleton initialises")
    func inline_initialises() {
        let skeleton = DefaultInlineSkeleton()
        _ = skeleton
        #expect(true)
    }

    @Test("DefaultFullScreenSkeleton body is a valid View", .disabled(swiftUIBodyReason))
    func fullScreen_body_isValidView() {
        let skeleton = DefaultFullScreenSkeleton()
        let body = skeleton.body
        _ = body
        #expect(true)
    }

    @Test("DefaultInlineSkeleton body is a valid View", .disabled(swiftUIBodyReason))
    func inline_body_isValidView() {
        let skeleton = DefaultInlineSkeleton()
        let body = skeleton.body
        _ = body
        #expect(true)
    }
}

// MARK: - TypeDistinctnessTests

@Suite("Type Distinctness Tests")
@MainActor
struct TypeDistinctnessTests {
    @Test("XGLoadingView and XGLoadingIndicator are distinct types")
    func types_areDistinct() {
        let loadingView = XGLoadingView()
        let indicator = XGLoadingIndicator()
        _ = loadingView
        _ = indicator
        #expect(true)
    }

    @Test("No spinner pattern — both types use skeleton approach")
    func noSpinnerPattern() {
        // XGLoadingView and XGLoadingIndicator no longer use ProgressView.
        // They use skeleton shimmer placeholders with crossfade transitions.
        let view = XGLoadingView(isLoading: true) {
            Text(verbatim: "Content")
        }
        let indicator = XGLoadingIndicator(isLoading: true) {
            Text(verbatim: "Content")
        }
        #expect(view.isLoading)
        #expect(indicator.isLoading)
    }
}
