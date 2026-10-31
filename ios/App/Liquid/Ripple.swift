import SwiftUI

struct RippleEffect: ViewModifier {
    let origin: CGPoint
    let trigger: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let amplitude: Double = 12
    private static let frequency: Double = 15
    private static let decay: Double = 8
    private static let speed: Double = 1200
    private static let duration: Double = 1.2

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.keyframeAnimator(
                initialValue: 0.0,
                trigger: trigger,
                content: { view, elapsed in
                    view.layerEffect(
                        shader(at: elapsed),
                        maxSampleOffset: CGSize(width: CGFloat(Self.amplitude), height: CGFloat(Self.amplitude)),
                        isEnabled: elapsed > 0 && elapsed < Self.duration
                    )
                },
                keyframes: { _ in
                    MoveKeyframe(0.0)
                    LinearKeyframe(Self.duration, duration: Self.duration)
                }
            )
        }
    }

    private func shader(at elapsed: Double) -> Shader {
        ShaderLibrary.Ripple(
            .float2(origin),
            .float(elapsed),
            .float(Self.amplitude),
            .float(Self.frequency),
            .float(Self.decay),
            .float(Self.speed)
        )
    }
}

private struct PingRipple: ViewModifier {
    @State private var origin = CGPoint.zero
    @State private var counter = 0

    func body(content: Content) -> some View {
        content
            .modifier(RippleEffect(origin: origin, trigger: counter))
            .simultaneousGesture(
                SpatialTapGesture()
                    .onEnded { value in
                        origin = value.location
                        counter += 1
                    }
            )
    }
}

extension View {
    func pingRipple() -> some View {
        modifier(PingRipple())
    }
}
