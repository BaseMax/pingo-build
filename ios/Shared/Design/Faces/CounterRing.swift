import SwiftUI

struct CounterRing<Content: View>: View {
    let fraction: Double
    let width: CGFloat
    let color: Color
    let track: Color
    let content: Content

    @Environment(\.animates) private var animates
    @State private var shown = false

    init(fraction: Double, width: CGFloat, color: Color, track: Color, @ViewBuilder content: () -> Content) {
        self.fraction = fraction
        self.width = width
        self.color = color
        self.track = track
        self.content = content()
    }

    private var value: Double { animates && !shown ? 0 : fraction }

    var body: some View {
        ZStack {
            Circle().inset(by: width / 2).stroke(track, lineWidth: width)
            Circle().inset(by: width / 2)
                .trim(from: 0, to: value)
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .opacity(value > 0 ? 1 : 0)
                .faceAccent()
            content
        }
        .animation(animates ? Animation.spring(duration: 0.6, bounce: 0.2) : nil, value: fraction)
        .onAppear {
            guard animates else { return }
            withAnimation(.spring(duration: 1.2, bounce: 0.2)) { shown = true }
        }
    }
}
