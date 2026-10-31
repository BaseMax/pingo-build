import SwiftUI

struct OnboardingPingPage: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)
            OnboardingRings()
                .reveal(0.05)
                .pageParallax(1.3)
            VStack(spacing: 12) {
                Text("پینگو")
                    .dasto(52)
                    .reveal(0.2)
                Text("ویجت‌هایی که خودت می‌خوای، فقط برای خودت")
                    .dasto(18)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .reveal(0.32)
            }
            .padding(.horizontal, 24)
            .pageParallax(0.6)
            Spacer(minLength: 0)
        }
    }
}
