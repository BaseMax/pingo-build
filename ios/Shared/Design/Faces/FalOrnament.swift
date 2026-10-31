import SwiftUI

struct FalOrnament: View {
    let palette: FacePalette
    var length: CGFloat = 120

    var body: some View {
        HStack(spacing: 8) {
            line
            Rectangle()
                .fill(palette.accent)
                .frame(width: 6, height: 6)
                .rotationEffect(.degrees(45))
                .faceAccent()
            line
        }
        .frame(width: length, height: 8)
    }

    private var line: some View {
        Capsule()
            .fill(palette.soft.opacity(0.6))
            .frame(height: 1)
    }
}

struct FalFrame: View {
    let palette: FacePalette

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(palette.soft.opacity(0.6), lineWidth: 1.2)
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(palette.soft.opacity(0.35), lineWidth: 0.8)
                .padding(6)
        }
    }
}
