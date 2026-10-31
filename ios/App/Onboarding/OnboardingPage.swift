import SwiftUI

enum OnboardingMetrics {
    static let controlsClearance: CGFloat = 200
}

enum OnboardingPage: CaseIterable, Identifiable, Hashable {
    case ping, cluster, steps

    var id: OnboardingPage { self }

    var next: OnboardingPage? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), index + 1 < all.count else { return nil }
        return all[index + 1]
    }

    var isLast: Bool { next == nil }

    var buttonTitle: String { isLast ? "شروع کن" : "ادامه" }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isCurrent: Bool

    var body: some View {
        content
            .padding(.horizontal, Layout.gutter)
            .padding(.bottom, OnboardingMetrics.controlsClearance)
    }

    @ViewBuilder
    private var content: some View {
        switch page {
        case .ping: OnboardingPingPage()
        case .cluster: OnboardingClusterPage()
        case .steps: OnboardingStepsPage(isCurrent: isCurrent)
        }
    }
}
