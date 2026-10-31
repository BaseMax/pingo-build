import SwiftUI

struct ValidityRing: View {
    let status: ExpiryStatus

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drawn = 0.0
    @State private var shownDays = 0
    @State private var breathing = false

    private let lineWidth: CGFloat = 16
    private var color: Color { status.level.color }
    private var pulses: Bool { status.level == .soon && !reduceMotion }
    private var showsDays: Bool { status.level == .healthy || status.level == .soon }

    var body: some View {
        ZStack {
            track
            progress
            center
        }
        .frame(width: 208, height: 208)
        .scaleEffect(pulses && breathing ? 1.03 : 1)
        .onAppear(perform: appear)
        .onChange(of: status) { _, _ in settle() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(status.message)
    }

    private var track: some View {
        Circle().stroke(color.opacity(0.16), lineWidth: lineWidth)
    }

    private var progress: some View {
        Circle()
            .trim(from: 0, to: drawn)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .opacity(drawn > 0.001 ? 1 : 0)
            .shadow(color: color.opacity(pulses && breathing ? 0.5 : 0.18), radius: 14)
    }

    @ViewBuilder
    private var center: some View {
        if showsDays {
            VStack(spacing: 0) {
                Text(Persian.number(shownDays))
                    .dasto(60)
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
                Text("روز مونده")
                    .dasto(14)
                    .foregroundStyle(Color.secondary)
            }
        } else {
            Image(systemName: status.level.symbol)
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(color)
                .symbolEffect(.bounce, value: status.level)
        }
    }

    private func appear() {
        settle()
        guard pulses else { return }
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
            breathing = true
        }
    }

    private func settle() {
        withAnimation(reduceMotion ? Animation.easeOut(duration: 0.2) : Animation.liquidSoft) {
            drawn = status.fractionLeft
            shownDays = status.daysLeft
        }
    }
}
