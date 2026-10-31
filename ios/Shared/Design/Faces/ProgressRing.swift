import SwiftUI

struct ProgressRing: View {
    let fraction: Double
    let width: CGFloat
    let color: Color
    let track: Color
    var delay: Double = 0

    @Environment(\.animates) private var animates
    @State private var shown = false

    private var value: Double {
        animates && !shown ? 0 : min(max(fraction, 0.004), 1)
    }

    var body: some View {
        ZStack {
            Circle().inset(by: width / 2).stroke(track, lineWidth: width)
            Circle()
                .inset(by: width / 2)
                .trim(from: 0, to: value)
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .faceAccent()
        }
        .onAppear(perform: appear)
    }

    private func appear() {
        guard animates else { return }
        withAnimation(.spring(duration: 1.3, bounce: 0.2).delay(delay)) { shown = true }
    }
}
