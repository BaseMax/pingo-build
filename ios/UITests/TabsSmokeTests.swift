import XCTest

final class S02TabsSmokeTests: SmokeCase {
    override func setUp() {
        super.setUp()
        finishOnboardingIfShown()
    }

    func testVisitEveryTab() {
        snap("tab-gallery-top")
        scrollDown(1)
        snap("tab-gallery-scroll-1")
        scrollDown(2)
        snap("tab-gallery-scroll-2")
        scrollDown(3)
        snap("tab-gallery-scroll-3")
        openTab(Labels.library)
        snap("tab-library")
        openTab(Labels.settings)
        snap("tab-settings")
        openTab(Labels.widgets)
        snap("tab-gallery-back")
    }
}
