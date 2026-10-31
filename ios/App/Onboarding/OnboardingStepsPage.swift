import SwiftUI

struct OnboardingStepsPage: View {
    let isCurrent: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var active = 0

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 0)
            Text("ویجتت رو این‌طوری اضافه کن")
                .dasto(26)
                .multilineTextAlignment(.center)
                .reveal(0.05)
                .pageParallax(0.6)
            steps
            OnboardingReminderButton()
                .reveal(0.45)
                .pageParallax(0.8)
            Spacer(minLength: 0)
        }
        .task(id: isCurrent) { await cycle() }
    }

    private var steps: some View {
        VStack(spacing: 12) {
            ForEach(Array(OnboardingStep.all.enumerated()), id: \.element.id) { index, step in
                OnboardingStepRow(index: index, step: step, isActive: index == active)
                    .reveal(0.15 + Double(index) * 0.1)
                    .pageParallax(1 + CGFloat(index) * 0.25)
            }
        }
    }

    private func cycle() async {
        guard isCurrent, !reduceMotion else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            withAnimation(.liquid) {
                active = (active + 1) % OnboardingStep.all.count
            }
        }
    }
}
