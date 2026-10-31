import SwiftUI

struct FalVerseText: View {
    let verse: FalVerse
    let textSize: CGFloat
    let lines: Int
    let spacing: CGFloat
    let palette: FacePalette

    var body: some View {
        VStack(spacing: spacing) {
            hemistich(verse.first)
            hemistich(verse.second)
        }
        .frame(maxWidth: .infinity)
    }

    private func hemistich(_ text: String) -> some View {
        Text(text)
            .dasto(textSize)
            .foregroundStyle(palette.ink)
            .multilineTextAlignment(.center)
            .lineLimit(lines)
            .lineSpacing(4)
            .minimumScaleFactor(0.55)
    }
}
