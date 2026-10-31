import SwiftUI
import WidgetKit

struct NoteFace: View {
    let item: NoteItem?
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder private var content: some View {
        if let item {
            NoteLayout(text: item.text, size: size, palette: palette)
        } else {
            FaceEmpty(symbol: "pin.fill", title: "یه یادداشت بساز", palette: palette)
        }
    }
}

struct NoteLayout: View {
    let text: String
    let size: CardSize
    let palette: FacePalette

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isEmpty: Bool { trimmed.isEmpty }

    private var fontSize: CGFloat {
        switch size {
        case .small: 16
        case .medium: 18
        case .large: 24
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            pin
            note
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var pin: some View {
        Image(systemName: "pin.fill")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(palette.accent)
            .rotationEffect(.degrees(35))
            .faceAccent()
    }

    private var note: some View {
        Text(isEmpty ? "یه یادداشت بنویس" : trimmed)
            .dasto(fontSize)
            .foregroundStyle(isEmpty ? palette.soft : palette.ink)
            .lineSpacing(fontSize * 0.35)
            .multilineTextAlignment(.leading)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
