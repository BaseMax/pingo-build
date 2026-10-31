import SwiftUI

private struct StretchValues {
    var scaleX = 1.0
    var scaleY = 1.0
}

private struct Stretch<Trigger: Equatable>: ViewModifier {
    let trigger: Trigger

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            stretching(content)
        }
    }

    private func stretching(_ content: Content) -> some View {
        content.keyframeAnimator(initialValue: StretchValues(), trigger: trigger) { view, values in
            view.scaleEffect(x: values.scaleX, y: values.scaleY)
        } keyframes: { _ in
            KeyframeTrack(\.scaleX) {
                CubicKeyframe(1.18, duration: 0.16)
                SpringKeyframe(1.0, duration: 0.55, spring: .bouncy)
            }
            KeyframeTrack(\.scaleY) {
                CubicKeyframe(0.92, duration: 0.16)
                SpringKeyframe(1.0, duration: 0.55, spring: .bouncy)
            }
        }
    }
}

extension View {
    func slideSource<ID: Hashable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        background {
            Color.clear.matchedGeometryEffect(id: id, in: namespace)
        }
    }

    func slidingPill<ID: Hashable>(to id: ID, in namespace: Namespace.ID) -> some View {
        modifier(Stretch(trigger: id))
            .matchedGeometryEffect(id: id, in: namespace, isSource: false)
    }
}
