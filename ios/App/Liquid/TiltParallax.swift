import CoreMotion
import Observation
import SwiftUI

@MainActor
@Observable
final class TiltMotion {
    static let shared = TiltMotion()

    private(set) var x: CGFloat = 0
    private(set) var y: CGFloat = 0
    private(set) var isActive = false

    private let manager = CMMotionManager()
    @ObservationIgnored private var reference: (roll: Double, pitch: Double)?
    @ObservationIgnored private var holders = 0

    private static let range = Double.pi / 6
    private static let smoothing: CGFloat = 0.18

    private init() {}

    func acquire() {
        holders += 1
        if holders == 1 {
            begin()
        }
    }

    func release() {
        holders = max(0, holders - 1)
        if holders == 0 {
            end()
        }
    }

    private func begin() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        isActive = true
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let data else { return }
            let roll = data.attitude.roll
            let pitch = data.attitude.pitch
            MainActor.assumeIsolated {
                if let self {
                    self.consume(roll: roll, pitch: pitch)
                }
            }
        }
    }

    private func end() {
        manager.stopDeviceMotionUpdates()
        reference = nil
        isActive = false
        x = 0
        y = 0
    }

    private func consume(roll: Double, pitch: Double) {
        let base = reference ?? (roll: roll, pitch: pitch)
        reference = base
        let targetX = Self.normalized(roll - base.roll)
        let targetY = Self.normalized(pitch - base.pitch)
        x += (targetX - x) * Self.smoothing
        y += (targetY - y) * Self.smoothing
    }

    private static func normalized(_ angle: Double) -> CGFloat {
        CGFloat(max(-1, min(1, angle / range)))
    }
}

private struct TiltParallax: ViewModifier {
    let strength: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var holding = false

    private static let maxDegrees: CGFloat = 6

    private var motion: TiltMotion { TiltMotion.shared }
    private var degrees: CGFloat { Self.maxDegrees * strength }

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(-motion.y * degrees), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
            .rotation3DEffect(.degrees(motion.x * degrees), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
            .overlay {
                if motion.isActive {
                    highlight
                }
            }
            .onAppear(perform: hold)
            .onDisappear(perform: drop)
            .onChange(of: reduceMotion) { _, reduced in
                if reduced {
                    drop()
                } else {
                    hold()
                }
            }
    }

    private func hold() {
        guard !holding, !reduceMotion else { return }
        holding = true
        motion.acquire()
    }

    private func drop() {
        guard holding else { return }
        holding = false
        motion.release()
    }

    private var highlight: some View {
        RadialGradient(
            colors: [Color.white.opacity(0.9), Color.white.opacity(0)],
            center: UnitPoint(x: 0.5 - motion.x * 0.35, y: 0.5 - motion.y * 0.35),
            startRadius: 0,
            endRadius: 150
        )
        .blendMode(.plusLighter)
        .opacity(0.22 * Double(min(1, strength)))
        .clipShape(RoundedRectangle(cornerRadius: Layout.cardCorner, style: .continuous))
        .allowsHitTesting(false)
    }
}

extension View {
    func tiltParallax(_ strength: CGFloat = 1) -> some View {
        modifier(TiltParallax(strength: strength))
    }
}
