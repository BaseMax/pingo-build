import SwiftUI

struct MoonLit: Shape {
    let fraction: Double

    private static let steps = 120

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let waxing = fraction < 0.5
        let curve: Double = cos(2 * Double.pi * (waxing ? fraction : 1 - fraction))
        var path = limb(center: center, radius: radius)
        terminator(into: &path, center: center, radius: radius, curve: curve)
        path.closeSubpath()
        guard !waxing else { return path }
        return path.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 2 * center.x, ty: 0))
    }

    private func limb(center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        for step in 0...Self.steps {
            let angle = -Double.pi / 2 + Double.pi * Double(step) / Double(Self.steps)
            let unit = Self.unit(angle)
            let point = CGPoint(x: center.x + radius * unit.x, y: center.y + radius * unit.y)
            if step == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    private func terminator(into path: inout Path, center: CGPoint, radius: CGFloat, curve: Double) {
        for step in 0...Self.steps {
            let angle = Double.pi / 2 - Double.pi * Double(step) / Double(Self.steps)
            let unit = Self.unit(angle)
            path.addLine(to: CGPoint(x: center.x + radius * CGFloat(curve) * unit.x, y: center.y + radius * unit.y))
        }
    }

    private static func unit(_ angle: Double) -> (x: CGFloat, y: CGFloat) {
        let horizontal: Double = cos(angle)
        let vertical: Double = sin(angle)
        return (CGFloat(horizontal), CGFloat(vertical))
    }
}

struct MoonCraters: Shape {
    private static let spots: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.36, 0.3, 0.17), (0.64, 0.5, 0.22), (0.4, 0.7, 0.12), (0.72, 0.24, 0.09), (0.57, 0.8, 0.08), (0.24, 0.5, 0.07)
    ]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for spot in Self.spots {
            let diameter = rect.width * spot.size
            let origin = CGPoint(x: rect.minX + rect.width * spot.x - diameter / 2, y: rect.minY + rect.height * spot.y - diameter / 2)
            path.addEllipse(in: CGRect(origin: origin, size: CGSize(width: diameter, height: diameter)))
        }
        return path
    }
}
