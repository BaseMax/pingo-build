import SwiftUI

struct OnboardingView: View {
    private let onFinish: () -> Void

    @State private var position: OnboardingPage? = .ping

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    private var current: OnboardingPage { position ?? .ping }

    var body: some View {
        ZStack {
            MeshBackdrop()
            pager
            OnboardingControls(page: current, onAdvance: advance, onSkip: finish)
        }
        .onChange(of: position) { _, _ in
            Haptics.selection()
        }
    }

    private var pager: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(OnboardingPage.allCases) { page in
                    OnboardingPageView(page: page, isCurrent: page == current)
                        .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $position)
        .scrollIndicators(.hidden)
    }

    private func advance() {
        guard let next = current.next else {
            finish()
            return
        }
        Haptics.tap()
        withAnimation(.liquid) { position = next }
    }

    private func finish() {
        Haptics.success()
        onFinish()
    }
}
