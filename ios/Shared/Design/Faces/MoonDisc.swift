import SwiftUI

struct MoonColors {
    let lit: Color
    let unlit: Color
    let crater: Color
    let glow: Color?

    init(lit: Color, unlit: Color, crater: Color, glow: Color?) {
        self.lit = lit
        self.unlit = unlit
        self.crater = crater
        self.glow = glow
    }

    init(palette: FacePalette) {
        guard palette.isFullColor else {
            self.init(lit: palette.ink, unlit: palette.track, crater: palette.track, glow: nil)
            return
        }
        let warm = palette.theme.isLight
        let lit = Color(hex: warm ? 0xF4C95D : 0xFFF1CC)
        let crater = Color(hex: warm ? 0xD9A93A : 0xE3D2A0).opacity(0.7)
        self.init(lit: lit, unlit: palette.track, crater: crater, glow: lit)
    }

    static let accessory = MoonColors(lit: Color.primary, unlit: Color.primary.opacity(0.22), crater: Color.clear, glow: nil)
}

struct MoonDisc: View {
    let fraction: Double
    let colors: MoonColors

    var body: some View {
        ZStack {
            if let glow = colors.glow {
                MoonGlow(fraction: fraction, color: glow)
            }
            Circle().fill(colors.unlit)
            Circle()
                .fill(colors.lit)
                .overlay(MoonCraters().fill(colors.crater))
                .mask(MoonLit(fraction: fraction))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct MoonGlow: View {
    let fraction: Double
    let color: Color

    @Environment(\.animates) private var animates
    @State private var breathing = false

    var body: some View {
        MoonLit(fraction: fraction)
            .fill(color)
            .blur(radius: 14)
            .scaleEffect(breathing ? 1.1 : 1)
            .opacity(breathing ? 0.8 : 0.45)
            .onAppear {
                guard animates else { return }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { breathing = true }
            }
    }
}
