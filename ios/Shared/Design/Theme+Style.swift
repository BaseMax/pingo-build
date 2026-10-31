import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    static let signal = Color(hex: 0xFF5C00)
    static let ocean = Color(hex: 0x1D7FF0)
    static let leaf = Color(hex: 0x34C759)
}

extension Theme {
    var colors: [Color] {
        switch self {
        case .paper: [Color(hex: 0xFFFFFF), Color(hex: 0xF1F1F4)]
        case .haze: [Color(hex: 0xF2F2F7), Color(hex: 0xDADAE2)]
        case .sand: [Color(hex: 0xF6EBD3), Color(hex: 0xEBDBB8)]
        case .signal: [Color(hex: 0xFF8A3D), Color(hex: 0xFF5C00)]
        case .sky: [Color(hex: 0x45B5FF), Color(hex: 0x1D7FF0)]
        case .leaf: [Color(hex: 0x66E38A), Color(hex: 0x2FBF5B)]
        case .ink: [Color(hex: 0x2C2C2E), Color(hex: 0x000000)]
        }
    }

    var ink: Color { isLight ? Color.black : Color.white }
    var soft: Color { ink.opacity(0.55) }
    var track: Color { ink.opacity(isLight ? 0.08 : 0.2) }
    var accent: Color { isLight ? Color.signal : Color.white }
    var onAccent: Color { isLight ? Color.white : colors[1] }

    var rings: [Color] {
        if isLight {
            return [Color.signal, Color.ocean, Color.leaf, Color.black]
        }
        return [1.0, 0.8, 0.6, 0.42].map { Color.white.opacity($0) }
    }

    var background: some View {
        LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}
