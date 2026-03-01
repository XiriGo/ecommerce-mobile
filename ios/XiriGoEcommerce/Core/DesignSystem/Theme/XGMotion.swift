import SwiftUI

/// Motion, animation, and performance tokens for the XiriGo design system.
///
/// All values are sourced from `shared/design-tokens/foundations/motion.json`.
/// Components and feature screens reference these constants instead of hardcoding
/// animation durations, easing curves, or performance thresholds.
enum XGMotion {
    // MARK: - Duration

    /// Standard duration values for animations and transitions (in seconds).
    enum Duration {
        static let instant: TimeInterval = 0.1
        static let fast: TimeInterval = 0.2
        static let normal: TimeInterval = 0.3
        static let slow: TimeInterval = 0.45
        static let pageTransition: TimeInterval = 0.35
    }

    // MARK: - Easing

    /// Easing curves and spring specifications for natural-feeling animations.
    enum Easing {
        /// General-purpose ease-in-out curve.
        static let standard: Animation = .easeInOut

        /// Deceleration curve for elements entering the viewport.
        static let decelerate: Animation = .easeOut

        /// Acceleration curve for elements leaving the viewport.
        static let accelerate: Animation = .easeIn

        /// Physics-based spring with moderate bounce.
        static let spring: Animation = .spring(
            response: springResponse,
            dampingFraction: springDampingFraction,
        )

        /// Spring response duration in seconds.
        static let springResponse: Double = 0.35

        /// Spring damping fraction for moderate bounce.
        static let springDampingFraction: Double = 0.7
    }

    // MARK: - Shimmer

    /// Shimmer animation parameters for loading placeholders.
    ///
    /// All loading placeholders MUST use an animated shimmer gradient sweep,
    /// never a static color.
    enum Shimmer {
        static let duration: TimeInterval = 1.2
        static let angleDegrees: Double = 20

        /// Gradient colors for the shimmer sweep effect (from shimmer.gradientColors).
        static let gradientColors: [Color] = [
            Color(hex: "#E0E0E0"),
            Color(hex: "#F5F5F5"),
            Color(hex: "#E0E0E0"),
        ]
    }

    // MARK: - Crossfade

    /// Crossfade animation durations for image loading and content switching (in seconds).
    enum Crossfade {
        static let imageFadeIn: TimeInterval = 0.3
        static let contentSwitch: TimeInterval = 0.2
    }

    // MARK: - Scroll

    /// Scroll behavior configuration for lazy lists and grids.
    ///
    /// All scrollable lists MUST use lazy rendering (LazyVStack/LazyHStack/LazyVGrid).
    /// Never use VStack inside ScrollView for lists with more than 4 items.
    enum Scroll {
        static let prefetchDistance: Int = 5
        static let scrollRestorationEnabled = true
    }

    // MARK: - EntranceAnimation

    /// Entrance animation parameters for staggered list-item reveals.
    ///
    /// Used only on first screen load, not for paginated items.
    /// Keep animations subtle to avoid distracting the user.
    enum EntranceAnimation {
        static let staggerDelay: TimeInterval = 0.05
        static let maxStaggerItems: Int = 8
        static let fadeFrom: Double = 0
        static let fadeTo: Double = 1
        static let slideOffsetY: CGFloat = 20
    }

    // MARK: - Performance

    /// Performance budget thresholds used for profiling and monitoring.
    ///
    /// Profile with Xcode Instruments. Target zero jank frames during scroll.
    enum Performance {
        static let frameTime: TimeInterval = 0.016
        static let startupCold: TimeInterval = 2.0
        static let screenTransition: TimeInterval = 0.3
        static let listScrollFps: Int = 60
        static let firstContentfulPaint: TimeInterval = 1.0
    }
}
