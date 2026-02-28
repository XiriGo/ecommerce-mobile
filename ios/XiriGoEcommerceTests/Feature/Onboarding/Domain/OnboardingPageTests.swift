import Testing
@testable import XiriGoEcommerce

// MARK: - OnboardingPageTests

@Suite("OnboardingPage Tests")
struct OnboardingPageTests {
    // MARK: - Static Pages

    @Test("allPages contains exactly four pages")
    func allPages_hasFourEntries() {
        #expect(OnboardingPage.allPages.count == 4)
    }

    @Test("allPages ids are 0, 1, 2, 3")
    func allPages_idsAreSequential() {
        let ids = OnboardingPage.allPages.map(\.id)
        #expect(ids == [0, 1, 2, 3])
    }

    @Test("allPages all have non-empty illustrationName")
    func allPages_illustrationNamesAreNonEmpty() {
        for page in OnboardingPage.allPages {
            #expect(!page.illustrationName.isEmpty)
        }
    }

    @Test("first page has id 0")
    func firstPage_hasIdZero() {
        #expect(OnboardingPage.allPages[0].id == 0)
    }

    @Test("last page has id 3")
    func lastPage_hasIdThree() {
        #expect(OnboardingPage.allPages[3].id == 3)
    }

    @Test("browse page has correct illustrationName")
    func browsePage_hasCorrectIllustrationName() {
        let browsePage = OnboardingPage.allPages[0]
        #expect(browsePage.illustrationName == "onboarding_illustration_browse")
    }

    @Test("compare page has correct illustrationName")
    func comparePage_hasCorrectIllustrationName() {
        let comparePage = OnboardingPage.allPages[1]
        #expect(comparePage.illustrationName == "onboarding_illustration_compare")
    }

    @Test("checkout page has correct illustrationName")
    func checkoutPage_hasCorrectIllustrationName() {
        let checkoutPage = OnboardingPage.allPages[2]
        #expect(checkoutPage.illustrationName == "onboarding_illustration_checkout")
    }

    @Test("track page has correct illustrationName")
    func trackPage_hasCorrectIllustrationName() {
        let trackPage = OnboardingPage.allPages[3]
        #expect(trackPage.illustrationName == "onboarding_illustration_track")
    }

    // MARK: - Equatable

    @Test("two pages with same data are equal")
    func equalityCheck_samePagesAreEqual() {
        let page1 = OnboardingPage.allPages[0]
        let page2 = OnboardingPage.allPages[0]
        #expect(page1 == page2)
    }

    @Test("two pages with different ids are not equal")
    func equalityCheck_differentPagesAreNotEqual() {
        let page1 = OnboardingPage.allPages[0]
        let page2 = OnboardingPage.allPages[1]
        #expect(page1 != page2)
    }

    // MARK: - Identifiable

    @Test("all pages have unique ids")
    func allPages_haveUniqueIds() {
        let ids = OnboardingPage.allPages.map(\.id)
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }
}
