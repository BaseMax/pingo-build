import SwiftUI

struct FalMedium: View {
    let verse: FalVerse
    let palette: FacePalette

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            FalVerseText(verse: verse, textSize: 18, lines: 1, spacing: 4, palette: palette)
            Spacer(minLength: 6)
            FalOrnament(palette: palette, length: 110)
            Spacer(minLength: 8)
            HStack {
                Text(verse.poet)
                    .dasto(14)
                    .foregroundStyle(palette.soft)
                Spacer(minLength: 0)
                FalButton(large: false, palette: palette)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FalLarge: View {
    let verse: FalVerse
    let palette: FacePalette

    var body: some View {
        ZStack {
            FalFrame(palette: palette)
            VStack(spacing: 0) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(palette.accent)
                    .faceAccent()
                Spacer(minLength: 8)
                FalVerseText(verse: verse, textSize: 22, lines: 2, spacing: 10, palette: palette)
                Spacer(minLength: 8)
                FalOrnament(palette: palette, length: 140)
                Text(verse.poet)
                    .dasto(16)
                    .foregroundStyle(palette.soft)
                    .padding(.top, 10)
                Spacer(minLength: 8)
                FalButton(large: true, palette: palette)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
