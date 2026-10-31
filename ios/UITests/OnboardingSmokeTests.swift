import XCTest

final class S01OnboardingSmokeTests: SmokeCase {
    func testOnboardingFlow() {
        snap("onboarding-1", wait: 2)
        tap("ادامه")
        snap("onboarding-2", wait: 1.2)
        tap("ادامه")
        snap("onboarding-3", wait: 2)
        tap("شروع کن")
        snap("after-onboarding", wait: 1.5)
    }
}
