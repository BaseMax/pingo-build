import SwiftUI

struct OnboardingControls: View {
    let page: OnboardingPage
    let onAdvance: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            OnboardingIndicator(current: page)
            advanceButton
            skipButton
        }
        .padding(.horizontal, Layout.gutter + 8)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var advanceButton: some View {
        Button(action: onAdvance) {
            ZStack {
                Text(page.buttonTitle)
                    .id(page.buttonTitle)
                    .transition(.blurFade)
            }
            .frame(maxWidth: .infinity)
            .animation(.liquid, value: page.isLast)
        }
        .buttonStyle(.liquidProminent)
    }

    private var skipButton: some View {
        Button(action: onSkip) {
            Text("بعدا")
                .dasto(15)
                .foregroundStyle(Color.secondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
        }
        .buttonStyle(Pressable())
        .modifier(BlurFade(hidden: page.isLast))
        .allowsHitTesting(!page.isLast)
        .animation(.liquid, value: page.isLast)
    }
}
