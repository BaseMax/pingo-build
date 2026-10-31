import SwiftUI

struct OnboardingIndicator: View {
    let current: OnboardingPage

    var body: some View {
        GlassGroup(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(OnboardingPage.allCases) { page in
                    dot(isActive: page == current)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .glassCapsule()
            .animation(.liquidStretch, value: current)
        }
        .accessibilityHidden(true)
    }

    private func dot(isActive: Bool) -> some View {
        Capsule()
            .fill(isActive ? Color.signal : Color.secondary.opacity(0.35))
            .frame(width: isActive ? 26 : 8, height: 8)
    }
}
