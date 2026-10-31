import SwiftUI
import WidgetKit

struct CounterFace: View {
    let item: CounterItem?
    let date: Date
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }

    var body: some View {
        content.taskFaceFrame(size)
    }

    @ViewBuilder private var content: some View {
        if let item {
            if size == .small {
                CounterSmall(item: item, date: date, palette: palette)
            } else {
                CounterMedium(item: item, date: date, palette: palette)
            }
        } else {
            FaceEmpty(symbol: "plus.circle.fill", title: "یه شمارنده بساز", palette: palette)
        }
    }
}
