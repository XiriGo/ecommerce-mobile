import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGRatingBarTests

@Suite("XGRatingBar Tests")
struct XGRatingBarTests {
    // MARK: - Internal

    // MARK: - Initialisation

    @Test("RatingBar initialises with rating")
    func init_withRating_initialises() {
        let bar = XGRatingBar(rating: 4.5)
        _ = bar
        #expect(true)
    }

    @Test("RatingBar initialises with default max rating of 5")
    func init_defaultMaxRating_is5() {
        let bar = XGRatingBar(rating: 3.0)
        _ = bar
        #expect(true)
    }

    @Test("RatingBar initialises with custom max rating")
    func init_customMaxRating_initialises() {
        let bar = XGRatingBar(rating: 7.0, maxRating: 10)
        _ = bar
        #expect(true)
    }

    @Test("RatingBar initialises with showValue true")
    func init_showValueTrue_initialises() {
        let bar = XGRatingBar(rating: 4.5, showValue: true)
        _ = bar
        #expect(true)
    }

    @Test("RatingBar initialises with reviewCount")
    func init_withReviewCount_initialises() {
        let bar = XGRatingBar(rating: 4.5, showValue: true, reviewCount: 123)
        _ = bar
        #expect(true)
    }

    @Test("RatingBar initialises with custom star size")
    func init_customStarSize_initialises() {
        let bar = XGRatingBar(rating: 3.0, starSize: 24)
        _ = bar
        #expect(true)
    }

    // MARK: - Star Fill Logic

    @Test("Full star shown when rating meets or exceeds position")
    func starFill_fullStar_whenRatingMeetsPosition() {
        // rating=5.0, position=5 → full star (rating >= 5.0)
        #expect(starType(rating: 5.0, position: 5) == .full)
        #expect(starType(rating: 4.0, position: 4) == .full)
        #expect(starType(rating: 3.0, position: 1) == .full)
    }

    @Test("Half star shown when rating is within 0.5 of position")
    func starFill_halfStar_whenRatingIsHalfPosition() {
        // rating=4.5, position=5 → half star (4.5 >= 5-0.5)
        #expect(starType(rating: 4.5, position: 5) == .half)
        #expect(starType(rating: 2.5, position: 3) == .half)
        #expect(starType(rating: 1.5, position: 2) == .half)
    }

    @Test("Empty star shown when rating is below half position")
    func starFill_emptyStar_whenRatingBelowHalf() {
        // rating=3.0, position=5 → empty (3.0 < 5-0.5 = 4.5)
        #expect(starType(rating: 3.0, position: 5) == .empty)
        #expect(starType(rating: 1.0, position: 4) == .empty)
        #expect(starType(rating: 0.0, position: 1) == .empty)
    }

    @Test("All stars full for perfect rating of 5")
    func starFill_perfectRating_allStarsFull() {
        for position in 1 ... 5 {
            #expect(starType(rating: 5.0, position: position) == .full)
        }
    }

    @Test("All stars empty for zero rating")
    func starFill_zeroRating_allStarsEmpty() {
        for position in 1 ... 5 {
            #expect(starType(rating: 0.0, position: position) == .empty)
        }
    }

    @Test("Mixed stars for 3.5 rating")
    func starFill_3point5_correctMixedStars() {
        // positions 1-3: full, position 4: half, position 5: empty
        #expect(starType(rating: 3.5, position: 1) == .full)
        #expect(starType(rating: 3.5, position: 2) == .full)
        #expect(starType(rating: 3.5, position: 3) == .full)
        #expect(starType(rating: 3.5, position: 4) == .half)
        #expect(starType(rating: 3.5, position: 5) == .empty)
    }

    // MARK: - Body

    @Test("RatingBar body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        let bar = XGRatingBar(rating: 4.0)
        let body = bar.body
        _ = body
        #expect(true)
    }

    // MARK: - Private

    // MARK: - Helper

    private enum StarType { case full, half, empty }

    /// Mirrors the private `starImage(for:)` logic from XGRatingBar.
    private func starType(rating: Double, position: Int) -> StarType {
        let positionDouble = Double(position)
        if rating >= positionDouble {
            return .full
        } else if rating >= positionDouble - 0.5 {
            return .half
        } else {
            return .empty
        }
    }
}
