import SwiftUI

struct OnboardingRings: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let ringCount = 4
    private static let period = 4.0
    private static let side: CGFloat = 280

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
            scene(at: reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate)
        }
        .frame(width: Self.side, height: Self.side)
        .accessibilityHidden(true)
    }

    private func scene(at time: Double) -> some View {
        ZStack {
            ForEach(0..<Self.ringCount, id: \.self) { index in
                ring(progress: Self.progress(index: index, time: time))
            }
            center(at: time)
        }
    }

    private func ring(progress: Double) -> some View {
        let eased = 1 - pow(1 - progress, 2)
        return Circle()
            .fill(Color.signal.opacity(0.06))
            .overlay {
                Circle().strokeBorder(Color.signal, lineWidth: 2)
            }
            .scaleEffect(0.1 + eased * 0.9)
            .opacity((1 - progress) * 0.75)
    }

    private func center(at time: Double) -> some View {
        let pulse = 1 + 0.1 * sin(time * 2 * Double.pi / Self.period)
        return Circle()
            .fill(LinearGradient(colors: [Color(hex: 0xFF8A3D), Color.signal], startPoint: .top, endPoint: .bottom))
            .frame(width: 30, height: 30)
            .shadow(color: Color.signal.opacity(0.55), radius: 18, x: 0, y: 4)
            .scaleEffect(pulse)
    }

    private static func progress(index: Int, time: Double) -> Double {
        let offset = Double(index) / Double(ringCount)
        let raw = time / period + offset
        return raw - raw.rounded(.down)
    }
}
