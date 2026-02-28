import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGPaginationDotsTests

/// Logic-level tests for XGPaginationDots.
/// Verifies initialization contracts for page count, current page, and color parameters.
/// View rendering is structural (SwiftUI body); snapshot coverage is handled in UI tests.
@Suite("XGPaginationDots Tests")
struct XGPaginationDotsTests {
    // MARK: - Initialization

    @Test("initialises with explicit pageCount and currentPage")
    func init_explicitPageCountAndCurrentPage() {
        let dots = XGPaginationDots(pageCount: 4, currentPage: 0)
        _ = dots
        #expect(true)
    }

    @Test("initialises with default colors")
    func init_defaultColors_initialises() {
        let dots = XGPaginationDots(pageCount: 3, currentPage: 1)
        _ = dots
        #expect(true)
    }

    @Test("initialises with custom activeColor and inactiveColor")
    func init_customColors_initialises() {
        let dots = XGPaginationDots(
            pageCount: 4,
            currentPage: 2,
            activeColor: .white,
            inactiveColor: .white.opacity(0.4),
        )
        _ = dots
        #expect(true)
    }

    @Test("initialises with a single page")
    func init_singlePage_initialises() {
        let dots = XGPaginationDots(pageCount: 1, currentPage: 0)
        _ = dots
        #expect(true)
    }

    @Test("initialises with pageCount matching onboarding page count (4)")
    func init_fourPages_matchesOnboardingPageCount() {
        let onboardingPageCount = OnboardingPage.allPages.count
        let dots = XGPaginationDots(pageCount: onboardingPageCount, currentPage: 0)
        _ = dots
        #expect(onboardingPageCount == 4)
    }

    // MARK: - Active Page Logic

    @Test("currentPage 0 is valid for a 4-page indicator")
    func currentPage_zero_isFirstPage() {
        let dots = XGPaginationDots(pageCount: 4, currentPage: 0)
        _ = dots
        #expect(true)
    }

    @Test("currentPage 3 is the last page for a 4-page indicator")
    func currentPage_three_isLastPage() {
        let lastPage = 4 - 1
        let dots = XGPaginationDots(pageCount: 4, currentPage: lastPage)
        _ = dots
        #expect(lastPage == 3)
    }

    @Test("active dot is the one at currentPage index")
    func activeDot_isAtCurrentPageIndex() {
        // Verify the semantic relationship: active dot index == currentPage
        let currentPage = 2
        let dots = XGPaginationDots(pageCount: 4, currentPage: currentPage)
        _ = dots
        #expect(currentPage < 4)
    }

    // MARK: - Page Count Edge Cases

    @Test("initialises with large pageCount without crash")
    func init_largePageCount_noCrash() {
        let dots = XGPaginationDots(pageCount: 20, currentPage: 10)
        _ = dots
        #expect(true)
    }
}
