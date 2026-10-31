import SwiftUI
import WidgetKit

struct HabitFace: View {
    let item: HabitItem?
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
            HabitLayout(item: item, date: date, showsWeek: size != .small, palette: palette)
        } else {
            FaceEmpty(symbol: "flame.fill", title: "یه عادت بساز", palette: palette)
        }
    }
}

struct HabitLayout: View {
    let item: HabitItem
    let date: Date
    let showsWeek: Bool
    let palette: FacePalette

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            HabitSummary(item: item, date: date, palette: palette)
                .frame(width: showsWeek ? 132 : nil)
            if showsWeek {
                HabitWeek(item: item, date: date, palette: palette)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
