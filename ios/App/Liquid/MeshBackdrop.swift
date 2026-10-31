import SwiftUI

struct MeshBackdrop: View {
    private let isLive: Bool

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.animates) private var animates

    init(isLive: Bool = true) {
        self.isLive = isLive
    }

    private var veil: Double {
        colorScheme == .light && contrast == .standard ? 0.2 : 0.55
    }

    private var drifts: Bool {
        !reduceMotion && !PowerState.shared.isLowPower
    }

    var body: some View {
        mesh
            .overlay(Color(.systemBackground).opacity(veil))
            .ignoresSafeArea()
    }

    @ViewBuilder
    private var mesh: some View {
        if drifts {
            TimelineView(.animation(minimumInterval: 1.0 / 15.0, paused: !(isLive && animates))) { context in
                gradient(at: context.date.timeIntervalSinceReferenceDate)
            }
        } else {
            gradient(at: 0)
        }
    }

    private func gradient(at time: Double) -> some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: MeshLayout.points(at: time),
            colors: colorScheme == .dark ? MeshLayout.darkColors : MeshLayout.lightColors
        )
    }
}

private enum MeshLayout {
    static let amplitude: Float = 0.06

    static let anchors: [SIMD2<Float>] = [
        SIMD2(0, 0), SIMD2(0.5, 0), SIMD2(1, 0),
        SIMD2(0, 0.5), SIMD2(0.5, 0.5), SIMD2(1, 0.5),
        SIMD2(0, 1), SIMD2(0.5, 1), SIMD2(1, 1)
    ]

    static let freedom: [SIMD2<Float>] = [
        SIMD2(0, 0), SIMD2(1, 0), SIMD2(0, 0),
        SIMD2(0, 1), SIMD2(1, 1), SIMD2(0, 1),
        SIMD2(0, 0), SIMD2(1, 0), SIMD2(0, 0)
    ]

    static func points(at time: Double) -> [SIMD2<Float>] {
        anchors.indices.map { index in
            anchors[index] + freedom[index] * drift(index: index, time: time)
        }
    }

    private static func drift(index: Int, time: Double) -> SIMD2<Float> {
        let phase = Double(index) * 0.9
        let dx = sin(time * 0.35 + phase)
        let dy = cos(time * 0.28 + phase * 1.3)
        return SIMD2(Float(dx), Float(dy)) * amplitude
    }

    static let lightColors: [Color] = [
        Color(hex: 0xF7F7FA), Color(hex: 0xFFDDC2), Color(hex: 0xD3ECFF),
        Color(hex: 0xD2F4DC), Color(hex: 0xFBF6F2), Color(hex: 0xFFE6D2),
        Color(hex: 0xC9E7FF), Color(hex: 0xCDF3D9), Color(hex: 0xF7F7FA)
    ]

    static let darkColors: [Color] = [
        Color(hex: 0x0B0B0E), Color(hex: 0x5E2A0F), Color(hex: 0x0F3558),
        Color(hex: 0x123F25), Color(hex: 0x0D0D12), Color(hex: 0x5A2B10),
        Color(hex: 0x0E3A63), Color(hex: 0x124528), Color(hex: 0x0B0B0E)
    ]
}
