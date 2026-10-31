import SwiftUI

struct ConfettiBurst: View {
    let trigger: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var burst: ConfettiRun?

    init(trigger: Int) {
        self.trigger = trigger
    }

    var body: some View {
        ZStack {
            if let burst {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let elapsed = timeline.date.timeIntervalSince(burst.start)
                        for particle in burst.particles {
                            particle.draw(in: &context, size: size, elapsed: elapsed)
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in
            guard !reduceMotion else { return }
            burst = ConfettiRun()
        }
        .task(id: burst?.id) {
            guard burst != nil else { return }
            do {
                try await Task.sleep(for: .seconds(ConfettiParticle.maxLife))
            } catch {
                return
            }
            burst = nil
        }
    }
}

private struct ConfettiRun: Identifiable {
    let id = UUID()
    let start = Date()
    let particles = (0..<70).map { _ in ConfettiParticle.random() }
}

private struct ConfettiParticle {
    static let maxLife: Double = 1.7

    private static let palette: [Color] = [.signal, .ocean, .leaf, .white, Color(hex: 0xFFB020)]
    private static let drag: Double = 1.8
    private static let gravity: Double = 900

    let angle: Double
    let speed: Double
    let spin: Double
    let flip: Double
    let phase: Double
    let width: CGFloat
    let height: CGFloat
    let isRound: Bool
    let color: Color
    let life: Double
    let jitter: CGFloat

    static func random() -> ConfettiParticle {
        let isRound = Bool.random()
        let side = CGFloat.random(in: 6...11)
        return ConfettiParticle(
            angle: -Double.pi / 2 + Double.random(in: -0.7...0.7),
            speed: Double.random(in: 520...1000),
            spin: Double.random(in: -9...9),
            flip: Double.random(in: 4...10),
            phase: Double.random(in: 0...(2 * Double.pi)),
            width: side,
            height: isRound ? side : side * 1.6,
            isRound: isRound,
            color: palette.randomElement() ?? .signal,
            life: Double.random(in: 1.2...maxLife),
            jitter: CGFloat.random(in: -24...24)
        )
    }

    func draw(in context: inout GraphicsContext, size: CGSize, elapsed: Double) {
        guard elapsed >= 0, elapsed < life else { return }
        var layer = context
        layer.opacity = min(1, (life - elapsed) / 0.4)
        let point = position(elapsed, size)
        layer.translateBy(x: point.x, y: point.y)
        layer.rotate(by: .radians(spin * elapsed + phase))
        layer.scaleBy(x: 1, y: CGFloat(abs(cos(flip * elapsed + phase))) * 0.8 + 0.2)
        layer.fill(shape, with: .color(color))
    }

    private var shape: Path {
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        return isRound ? Path(ellipseIn: rect) : Path(roundedRect: rect, cornerRadius: 2)
    }

    private func position(_ elapsed: Double, _ size: CGSize) -> CGPoint {
        let settle = (1 - exp(-Self.drag * elapsed)) / Self.drag
        let terminal = Self.gravity / Self.drag
        let vx = cos(angle) * speed
        let vy = sin(angle) * speed
        return CGPoint(
            x: size.width / 2 + jitter + CGFloat(vx * settle),
            y: size.height + CGFloat(terminal * elapsed + (vy - terminal) * settle)
        )
    }
}
