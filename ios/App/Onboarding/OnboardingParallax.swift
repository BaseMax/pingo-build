import SwiftUI

private func distance(_ phase: ScrollTransitionPhase) -> CGFloat {
    CGFloat(Double(phase.value))
}

private func away(_ phase: ScrollTransitionPhase) -> CGFloat {
    min(abs(distance(phase)), 1)
}

private struct PageParallax: ViewModifier {
    let depth: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.scrollTransition(.interactive, axis: .horizontal) { view, phase in
                view
                    .opacity(Double(1 - away(phase) * 0.9))
                    .blur(radius: away(phase) * 14)
                    .scaleEffect(1 - away(phase) * 0.08)
                    .offset(x: distance(phase) * 90 * depth)
            }
        }
    }
}

extension View {
    func pageParallax(_ depth: CGFloat = 1) -> some View {
        modifier(PageParallax(depth: depth))
    }
}

struct OnboardingBob: ViewModifier {
    let period: Double
    let distance: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lifted = false

    func body(content: Content) -> some View {
        content
            .offset(y: lifted ? -distance : distance)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: period).repeatForever(autoreverses: true)) {
                    lifted = true
                }
            }
    }
}
