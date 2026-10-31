import SwiftUI
import WidgetKit

struct CountdownFace: View {
    let item: CountdownItem?
    let date: Date
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
            CountdownLayout(info: CountdownInfo(item: item, date: date), size: size, palette: palette)
        } else {
            FaceEmpty(symbol: "hourglass", title: "یه شمارش معکوس بساز", palette: palette)
        }
    }
}

struct CountdownLayout: View {
    let info: CountdownInfo
    let size: CardSize
    let palette: FacePalette

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            text
            if size != .small {
                CountdownAside(info: info, palette: palette)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            CountdownHeader(info: info, palette: palette)
            Spacer(minLength: 0)
            CountdownHeadline(info: info, palette: palette)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
