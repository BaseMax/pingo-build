import SwiftUI

extension Animation {
    static var liquid: Animation { .spring(duration: 0.55, bounce: 0.28) }
    static var liquidSoft: Animation { .smooth(duration: 0.8) }
    static var liquidSnap: Animation { .snappy(duration: 0.35) }
    static var liquidStretch: Animation { .spring(duration: 0.7, bounce: 0.5) }
    fileprivate static var reducedFade: Animation { .easeOut(duration: 0.18) }
}

struct BlurFade: ViewModifier {
    let hidden: Bool
    let radius: CGFloat
    let scale: CGFloat

    init(hidden: Bool, radius: CGFloat = 14, scale: CGFloat = 0.97) {
        self.hidden = hidden
        self.radius = radius
        self.scale = scale
    }

    func body(content: Content) -> some View {
        content
            .opacity(hidden ? 0 : 1)
            .blur(radius: hidden ? radius : 0)
            .scaleEffect(hidden ? scale : 1)
    }
}

extension AnyTransition {
    static var blurFade: AnyTransition {
        .modifier(active: BlurFade(hidden: true), identity: BlurFade(hidden: false))
    }
}

private struct Reveal: ViewModifier {
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .modifier(BlurFade(hidden: !shown && !reduceMotion))
            .onAppear {
                guard !reduceMotion else {
                    shown = true
                    return
                }
                withAnimation(Animation.liquidSoft.delay(delay)) { shown = true }
            }
    }
}

private struct ScrollBlur: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.scrollTransition(.animated(.smooth(duration: 0.6))) { view, phase in
                view
                    .opacity(phase.isIdentity ? 1 : 0)
                    .blur(radius: phase.isIdentity ? 0 : 10)
                    .scaleEffect(phase.isIdentity ? 1 : 0.94)
            }
        }
    }
}

private struct RubberBand: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var drag = CGSize.zero

    private static let limit: CGFloat = 64

    private var damped: CGSize {
        guard !reduceMotion else { return .zero }
        return CGSize(width: Self.resist(drag.width), height: Self.resist(drag.height))
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(
                x: 1 + abs(damped.width) / 520 - abs(damped.height) / 900,
                y: 1 + abs(damped.height) / 520 - abs(damped.width) / 900
            )
            .offset(damped)
            .animation(drag == .zero ? Animation.liquidStretch : nil, value: drag)
            .simultaneousGesture(
                DragGesture(minimumDistance: 8)
                    .updating($drag) { value, state, _ in
                        let isHorizontal = abs(value.translation.width) >= abs(value.translation.height)
                        state = isHorizontal ? value.translation : .zero
                    }
            )
    }

    private static func resist(_ value: CGFloat) -> CGFloat {
        let magnitude = limit * (1 - exp(-abs(value) / limit))
        return value < 0 ? -magnitude : magnitude
    }
}

extension View {
    func reveal(_ delay: Double = 0) -> some View {
        modifier(Reveal(delay: delay))
    }

    func scrollBlur() -> some View {
        modifier(ScrollBlur())
    }

    func rubberBand() -> some View {
        modifier(RubberBand())
    }
}

struct Pressable: ButtonStyle {
    init() {}

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        PressableBody(configuration: configuration)
    }
}

private struct PressableBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var pressed: Bool { configuration.isPressed }

    var body: some View {
        if reduceMotion {
            configuration.label
                .opacity(pressed ? 0.6 : 1)
                .animation(Animation.reducedFade, value: pressed)
        } else {
            configuration.label
                .scaleEffect(pressed ? 0.94 : 1)
                .blur(radius: pressed ? 1.2 : 0)
                .animation(Animation.liquidStretch, value: pressed)
        }
    }
}
