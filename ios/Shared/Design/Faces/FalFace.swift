import SwiftUI
import WidgetKit

struct FalFace: View {
    let date: Date
    let seed: Int
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }
    private var verse: FalVerse { Fal.verse(on: date, seed: seed) }

    var body: some View {
        content.taskFaceFrame(size)
    }

    @ViewBuilder private var content: some View {
        if size == .large {
            FalLarge(verse: verse, palette: palette)
        } else {
            FalMedium(verse: verse, palette: palette)
        }
    }
}
